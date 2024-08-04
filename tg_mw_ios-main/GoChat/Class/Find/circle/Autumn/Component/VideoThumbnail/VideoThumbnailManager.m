//
//  VideoThumbnailManager.m
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import "VideoThumbnailManager.h"
#import "VideoThumbnailStore.h"
#import "VideoThumbnailDownload.h"

@interface VideoThumbnailManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *thumbCache;

@end

@implementation VideoThumbnailManager

+ (VideoThumbnailManager *)manager {
    static VideoThumbnailManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VideoThumbnailManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if ([super init]) {
        _thumbCache = NSMutableDictionary.dictionary;
    }
    return self;
}

- (void)thumbnailForVideo:(VideoInfo *)video result:(VideoThumbnailResult)result {
    /// 内存中存在，直接读取
    UIImage *image = _thumbCache[video.file_name];
    if (image) {
        !result ? : result(image);
        return;
    }
    
    /// 本地磁盘中存在，直接读取，并保存到内存中
    image = [VideoThumbnailStore imageWithVideoName:video.file_name];
    if (image) {
        if (image) {
            !result ? : result(image);
            _thumbCache[video.file_name] = image;
        }
        return;
    }
    /// 后台返回的模糊缩略图，先临时显示
    image = [UIImage imageWithContentsOfFile:video.thumbnail.file.local.path];
    if (image) {
        !result ? : result(image);
    }
    
    /// 视频如果缓存到本地，直接获取视频封面
    if ([self isVideoCached:video]) {
        [self thumbnailForCacheVideo:video result:result];
        return;
    }
    
    /// 视频未缓存，则下载部分，获取封面
    @weakify(self);
    [VideoThumbnailDownload.shared downloadThumbnailWithVideo:video result:^(UIImage * _Nullable image) {
        @strongify(self);
        if (image) {
            !result ? : result(image);
            self.thumbCache[video.file_name] = image;
            [VideoThumbnailStore storeImage:image withVideoName:video.file_name];
        }
    }];
}

/// 根据名称获取本地已经保存的视频封面
/// @param name 视频名称
- (UIImage *)localThumbnailForVideoName:(NSString *)name {
    UIImage *image = _thumbCache[name];
    if (image) {
        return image;
    }
    image = [VideoThumbnailStore imageWithVideoName:name];
    if (image) {
        _thumbCache[name] = image;
        return image;
    }
    return nil;
}

- (void)saveThumbnail:(UIImage *)image forVideoName:(NSString *)name {
    if (!image || !name) {
        return;
    }
    if ([_thumbCache objectForKey:name]) {
        return;
    }
    _thumbCache[name] = image;
    [VideoThumbnailStore storeImage:image withVideoName:name];
}


- (void)saveThumbnailAsset:(AVURLAsset *)asset forVideoName:(NSString *)name completion:(dispatch_block_t)completion {
    UIImage *image = [self localThumbnailForVideoName:name];
    if (image) {
        !completion ? : completion();
        return;
    }
    [UIImage thumbnailForAsset:asset result:^(UIImage * _Nullable image) {
        [self saveThumbnail:image forVideoName:name];
        !completion ? : completion();
    }];
}


#pragma mark - Private

/// 获取本地视频的封面，并保存
- (void)thumbnailForCacheVideo:(VideoInfo *)video result:(VideoThumbnailResult)result {
    @weakify(self);
    [UIImage thumbnailForVideoPath:video.video.local.path result:^(UIImage * _Nullable image) {
        @strongify(self);
        if (image) {
            !result ? : result(image);
            [VideoThumbnailStore storeImage:image withVideoName:video.file_name];
            self.thumbCache[video.file_name] = image;
        }
    }];
}

/// 视频已经缓存到本地
- (BOOL)isVideoCached:(VideoInfo *)video {
    NSString *ext = video.video.local.path.pathExtension;
    return ext.length > 0;
}


@end
