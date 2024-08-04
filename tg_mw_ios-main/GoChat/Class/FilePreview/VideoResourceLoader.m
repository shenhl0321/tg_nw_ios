#import <Foundation/Foundation.h>
#import "VideoResourceLoadManager.h"
#import "VideoResourceLoader.h"
#import "VideoRequestItem.h"

@interface VideoResourceLoader()<NSObject>
@property (nonatomic) int fileId;
@property (nonatomic, strong) NSMutableArray<VideoRequestItem*> *pendingRequests;
@end

@implementation VideoResourceLoader

- (VideoResourceLoader*)initWithFileId:(int)fileId {
    _fileId = fileId;
    _pendingRequests = [NSMutableArray array];
    return self;
}

- (void)addRequest:(AVAssetResourceLoadingRequest *)request {
    VideoRequestItem *item = [[VideoRequestItem alloc] initWithRequest:self.fileId request:request];
    [self.pendingRequests addObject: item];
    [item start];
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)request{
    __block VideoRequestItem *deleteRequest = nil;
    [self.pendingRequests enumerateObjectsUsingBlock:^(VideoRequestItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.request == request) {
            deleteRequest = obj;
            *stop = YES;
        }
    }];
    if (deleteRequest) {
        [self.pendingRequests removeObject:deleteRequest];
    }
}

- (BOOL)onUpdateFile:(FileInfo *)fileInfo{
    return YES;
}

@end
