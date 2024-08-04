#import <Foundation/Foundation.h>
#import "FileDownloader.h"

@interface FileDownloader()<NSObject>
@property (nonatomic, strong) dispatch_semaphore_t sem;
@property (nonatomic, strong) NSMutableArray<dispatch_block_t> *downloadQueue;
@property (nonatomic) bool endThread;
@end

@implementation FileDownloader{
    dispatch_queue_t downloadThread;
    void *downloadThreadTag;
}

static FileDownloader *g_VideoDownloader = nil;

+ (FileDownloader *)instance
{
    if(g_VideoDownloader == nil)
    {
        g_VideoDownloader = [[FileDownloader alloc] init];
    }
    return g_VideoDownloader;
}

- (void)stop{
    self.endThread = true;
    dispatch_semaphore_signal(self.sem);
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadQueue = [[NSMutableArray alloc]init];
        if (!downloadThread) {
            _endThread = false;
            _sem = dispatch_semaphore_create(0);
            const char *queueName = [[NSString stringWithFormat:@"%@DownloadQueue", NSStringFromClass([self class])] UTF8String];
            downloadThread = dispatch_queue_create(queueName, NULL);
            downloadThreadTag = &downloadThreadTag;
            dispatch_queue_set_specific(downloadThread, downloadThreadTag, downloadThreadTag, NULL);
            __weak typeof(self) weakSelf = self;
            dispatch_async(downloadThread, ^{
                while (!weakSelf.endThread) {
                    dispatch_semaphore_wait(weakSelf.sem, DISPATCH_TIME_FOREVER);
                    dispatch_block_t block = [weakSelf dequeue];
                    if (block) {
                        block();
                    }
                }
            });
        }
    }
    return self;
}

- (void)enqueue:(dispatch_block_t)anObject {
    [self.downloadQueue addObject:anObject];
}

- (dispatch_block_t)dequeue {
    if ([self.downloadQueue count] == 0) {
        return nil;
    }
    id queueObject = [self.downloadQueue objectAtIndex:0];
    [self.downloadQueue removeObjectAtIndex:0];
    return queueObject;
}

- (void)downloadVideo:(int)fileId offset:(int)offset count:(int)count read_block:(readVideoBlock)read_block {
    NSLog(@"FileDownloader video before queue");
    [self enqueue:^{
        NSLog(@"FileDownloader video after queue");
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [[TelegramManager shareInstance] downloadVideo:fileId download_offset:offset download_limit:count read_block:^(NSData *data){
            read_block(data);
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
    dispatch_semaphore_signal(self.sem);
}

- (void)downloadImage:(NSString *)_id fileId:(long)fileId type:(FileType)type {
    NSLog(@"FileDownloader image before queue");
    [self enqueue:^{
        NSLog(@"FileDownloader image after queue");
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [[TelegramManager shareInstance] downloadImage:_id fileId:fileId type:type read_block:^{
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
    dispatch_semaphore_signal(self.sem);
}

- (void)downloadThumbnail:(int)videoId offset:(int)offset limit:(int)limit completion:(void(^)(FileInfo *file))completion {
    [self enqueue:^{
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        [TelegramManager.shareInstance downloadThumbnailVideo:videoId offset:offset limit:limit completion:^(FileInfo *file) {
            !completion ? : completion(file);
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    }];
    dispatch_semaphore_signal(self.sem);
}

@end
