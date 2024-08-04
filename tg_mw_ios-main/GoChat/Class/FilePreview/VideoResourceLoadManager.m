#import <Foundation/Foundation.h>
#import "VideoResourceLoadManager.h"
#import "VideoResourceLoader.h"
#import "VideoRequestItem.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoResourceLoadManager()<AVAssetResourceLoaderDelegate,VideoResourceLoadManagerDelegate>
@property (nonatomic, strong) NSMutableDictionary<id<NSCoding>, VideoResourceLoader *> *loaders;
@end

@implementation VideoResourceLoadManager

- (instancetype)init{
    self = [super init];
    if (self) {
        _loaders = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)resourceLoader:(int)fileId didFailWithError:(NSError *)error{
    
}

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSURL *resourceURL = [loadingRequest.request URL];
    NSString *originStr = [resourceURL absoluteString];
    NSArray *array = [originStr componentsSeparatedByString:@"/"];
    if ([array count] >= 5 && [array[0] isEqualToString:@"app:"]) {
        NSString *fileId = array[3];
        NSString *contentLength = array[4];
        NSString *uttype = @"";
        if (@available(iOS 14.0, *)) {
            NSArray *mimeContent = [array subarrayWithRange:NSMakeRange(5, [array count] - 5)];
            NSString *mimeType = [mimeContent componentsJoinedByString:@"/"];
            uttype = [UTType typeWithMIMEType:mimeType].identifier;
        } else {
            uttype = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)(array.lastObject), NULL);
        }
        VideoResourceLoader *loader = self.loaders[fileId];
        if(!loader) {
            loader = [[VideoResourceLoader alloc] initWithFileId:[fileId intValue]];
            self.loaders[fileId] = loader;
            loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
            loadingRequest.contentInformationRequest.contentType = uttype;
            loadingRequest.contentInformationRequest.contentLength = [contentLength longLongValue];
        }
        [loader addRequest:loadingRequest];
        return YES;
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *resourceURL = [loadingRequest.request URL];
    NSString *originStr = [resourceURL absoluteString];
    NSArray *array = [originStr componentsSeparatedByString:@"/"];
    if ([array count] >= 5) {
        NSString *fileId = array[3];
        VideoResourceLoader *loader = self.loaders[fileId];
        if(loader){
            [loader removeRequest:loadingRequest];
        }
    }
}

- (BOOL)onUpdateFile:(int)fileId fileInfo:(FileInfo *)fileInfo{
    NSString *sId = [NSString stringWithFormat:@"%d",fileId];
    VideoResourceLoader *loader = self.loaders[sId];
    if (loader) {
        return [loader onUpdateFile:fileInfo];
    }
    return self.loaders[sId] != NULL;
}

@end
