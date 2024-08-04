//
//  VideoThumbnailDownload.m
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import "VideoThumbnailDownload.h"
#import "FileDownloader.h"

@interface VideoThumbnailDownload ()

@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *downloadQueue;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray *> *downloadResults;

@property (nonatomic, assign) BOOL endDownload;

@end

@implementation VideoThumbnailDownload

+ (VideoThumbnailDownload *)shared {
    static VideoThumbnailDownload *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VideoThumbnailDownload alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if ([super init]) {
        _semaphore = dispatch_semaphore_create(0);
        [self startDownload];
    }
    return self;
}

- (void)startDownload {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (!self.endDownload) {
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            dispatch_block_t block = self.currentQueue;
            !block ? : block();
        }
    });
}

- (void)stopDownload {
    _endDownload = YES;
    dispatch_semaphore_signal(_semaphore);
}

- (void)addDownload:(dispatch_block_t)block {
    [self.downloadQueue addObject:block];
}

- (void)downloadThumbnailWithVideo:(VideoInfo *)video result:(VideoThumbnailResult)result {
    if ([self thumbIsInTheDownload:video withResult:result]) {
        return;
    }
    @weakify(self);
    [self addDownload:^{
        @strongify(self);
        int count = 65536;
        int offset = (int)video.video.expected_size - count;
        int maxCount = count * 3;
//        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        FileDownloader *manager = FileDownloader.instance;
        [manager downloadThumbnail:(int)video.video._id offset:0 limit:count completion:^(FileInfo *file) {
            if (!file) {
                [self resultImage:nil withVideo:video];
//                dispatch_semaphore_signal(sem);
                return;
            }
            [manager downloadThumbnail:(int)video.video._id offset:offset limit:count completion:^(FileInfo *file) {
                if (!file) {
                    [self resultImage:nil withVideo:video];
//                    dispatch_semaphore_signal(sem);
                    return;
                }
                [manager downloadThumbnail:(int)video.video._id offset:0 limit:maxCount completion:^(FileInfo *file) {
                    if (!file) {
                        [self resultImage:nil withVideo:video];
                    } else {
                        [self converToImageWithVideo:video file:file];
                    }
//                    dispatch_semaphore_signal(sem);
                }];
            }];
        }];
//        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)converToImageWithVideo:(VideoInfo *)video file:(FileInfo *)file {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = NSFileManager.defaultManager;
        NSString *temp = NSTemporaryDirectory();
        NSString *path = [temp stringByAppendingPathComponent:video.file_name];
        if ([manager fileExistsAtPath:path]) {
            UIImage *image = [UIImage thumbnailForVideoPath:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resultImage:image withVideo:video];
            });
            return;
        }
        if (![path hasSuffix:@".mp4"]) {
            path = [path stringByAppendingString:@".mp4"];
        }
        NSString *orgPath = file.local.path;
        NSString *tarPath = nil;
        if (![orgPath hasSuffix:@".mp4"]) {
            tarPath = [orgPath stringByAppendingString:@".mp4"];
        }
        NSString *videoPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), video.file_name];
        [manager copyItemAtPath:orgPath toPath:videoPath error:nil];
        
        BOOL res = [manager copyItemAtPath:file.local.path toPath:path error:nil];
        if (tarPath) {
            [manager moveItemAtPath:orgPath toPath:tarPath error:nil];
        }
        
        if (!res) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resultImage:nil withVideo:video];
            });
            return;
        }
        UIImage *image = [UIImage thumbnailForVideoPath:path];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self resultImage:image withVideo:video];
        });
    });
}

- (void)converToImageWithVideo:(VideoInfo *)video file:(FileInfo *)file result:(VideoThumbnailResult)result {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *manager = NSFileManager.defaultManager;
        NSString *temp = NSTemporaryDirectory();
        NSString *path = [temp stringByAppendingPathComponent:video.file_name];
        if ([manager fileExistsAtPath:path]) {
            UIImage *image = [UIImage thumbnailForVideoPath:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                !result ? : result(image);
            });
            return;
        }
        BOOL res = [manager moveItemAtPath:file.local.path toPath:path error:nil];
        if (!res) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !result ? : result(nil);
            });
            return;
        }
        UIImage *image = [UIImage thumbnailForVideoPath:path];
        [NSFileManager.defaultManager removeItemAtPath:path error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            !result ? : result(image);
        });
    });
}

/// 同一个文件存在的回调全部执行
- (void)resultImage:(UIImage *)image withVideo:(VideoInfo *)video {
    NSMutableArray *results = self.downloadResults[video.file_name];
    if (results.count == 0) {
        return;
    }
    for (VideoThumbnailResult result in results) {
        !result ? : result(image);
    }
    [self removeDownloadResultWithVideo:video];
}

/// 已经添加下载了，只保存回调，不重复下载
- (BOOL)thumbIsInTheDownload:(VideoInfo *)video withResult:(VideoThumbnailResult)result {
    NSMutableArray *results = self.downloadResults[video.file_name];
    if (results && results.count > 0) {
        [results addObject:result];
        self.downloadResults[video.file_name] = results;
        return YES;
    }
    results = NSMutableArray.array;
    [results addObject:result];
    self.downloadResults[video.file_name] = results;
    return NO;
}

/// 删除
- (void)removeDownloadResultWithVideo:(VideoInfo *)video {
    [self.downloadResults removeObjectForKey:video.file_name];
}

#pragma mark - getter

- (dispatch_block_t)currentQueue {
    if (self.downloadQueue.count == 0) {
        return nil;
    }
    dispatch_block_t queue = self.downloadQueue.firstObject;
    [self.downloadQueue removeObject:queue];
    return queue;
}

- (NSMutableArray<dispatch_block_t> *)downloadQueue {
    if (!_downloadQueue) {
        _downloadQueue = NSMutableArray.array;
    }
    return _downloadQueue;
}

- (NSMutableDictionary<NSString *, NSMutableArray *> *)downloadResults {
    if (!_downloadResults) {
        _downloadResults = NSMutableDictionary.dictionary;
    }
    return _downloadResults;
}

@end
