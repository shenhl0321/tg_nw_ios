
#import "VideoResourceLoadManager.h"

@interface VideoRequestItem : NSObject

- (VideoRequestItem*)initWithRequest:(int)fileId request:(AVAssetResourceLoadingRequest *)request;
- (void)start;

@property (nonatomic, strong) AVAssetResourceLoadingRequest *request;
@end


