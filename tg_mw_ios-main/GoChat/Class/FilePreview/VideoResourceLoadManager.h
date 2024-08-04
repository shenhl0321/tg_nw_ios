
@protocol VideoResourceLoadManagerDelegate;

@interface VideoResourceLoadManager : NSObject<AVAssetResourceLoaderDelegate>

- (BOOL)onUpdateFile:(int)fileId fileInfo:(FileInfo *)fileInfo;

@property (nonatomic, weak) id<VideoResourceLoadManagerDelegate> delegate;
@end

@protocol VideoResourceLoadManagerDelegate <NSObject>
- (void)resourceLoader:(int)fileId didFailWithError:(NSError *)error;
@end
