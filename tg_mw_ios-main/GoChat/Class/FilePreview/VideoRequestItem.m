#import <Foundation/Foundation.h>
#import "VideoRequestItem.h"

@interface VideoRequestItem()<NSObject>
@property (nonatomic) int fileId;
@end

@implementation VideoRequestItem

- (VideoRequestItem*)initWithRequest:(int)fileId request:(AVAssetResourceLoadingRequest *)request{
    _fileId = fileId;
    _request = request;
    return self;
}

- (void)start{
    AVAssetResourceLoadingDataRequest *dataRequest = self.request.dataRequest;
    int read_offset = (int)dataRequest.requestedOffset;
    int read_count = (int)dataRequest.requestedLength;
    if (dataRequest.currentOffset != 0) {
        read_offset = (int)dataRequest.currentOffset;
    }
    NSLog(@"FileDownloader addRequest : %p---currentOffset: %lld---requestedOffset: %lld----read_count:%d",self.request,dataRequest.currentOffset,dataRequest.requestedOffset,read_count);
    if (read_count <= 2) {
        [self.request finishLoading];
    } else {
        if (read_count > 65536) {
            read_count = 65536;
        }
        [[FileDownloader instance] downloadVideo:self.fileId offset:read_offset count:read_count read_block:^(NSData *data){
            int dataLen = (int)[data length];
            NSLog(@"read_offset : %d  ----   read_count : %d   -----   dataLen : %d",read_offset,read_count,dataLen);
            [self.request.dataRequest respondWithData:data];
            [self.request finishLoading];
        }];
    }
}

- (void)onLoadFile:(NSData*)data{
    if (self.request) {
        [self.request.dataRequest respondWithData:data];
        [self.request finishLoading];
    }
}

@end
