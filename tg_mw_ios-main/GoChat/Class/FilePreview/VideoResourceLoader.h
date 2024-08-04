
@interface VideoResourceLoader : NSObject

- (VideoResourceLoader*)initWithFileId:(int)fileId;
- (void)addRequest:(AVAssetResourceLoadingRequest *)request;
- (void)removeRequest:(AVAssetResourceLoadingRequest *)request;
- (BOOL)onUpdateFile:(FileInfo *)fileInfo;

@property (nonatomic, strong) AVAssetResourceLoadingRequest *request;
@end

@protocol VideoResourceLoaderDelegate <NSObject>
- (void)resourceLoader:(VideoResourceLoader *)resourceLoader didFailWithError:(NSError *)error;
@end
