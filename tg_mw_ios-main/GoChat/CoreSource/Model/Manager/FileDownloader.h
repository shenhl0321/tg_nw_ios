
@interface FileDownloader : NSObject
+ (FileDownloader *)instance;
- (void)downloadVideo:(int)fileId offset:(int)offset count:(int)count read_block:(readVideoBlock)read_block;
- (void)downloadImage:(NSString *)_id fileId:(long)fileId type:(FileType)type;

- (void)downloadThumbnail:(int)videoId offset:(int)offset limit:(int)limit completion:(void(^)(FileInfo *file))completion;

@end
