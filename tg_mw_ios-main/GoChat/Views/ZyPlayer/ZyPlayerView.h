//
//  ZyPlayerView.h

#import <UIKit/UIKit.h>

@interface ZyPlayerView : UIView
- (id)initWithFrame:(CGRect)frame
           duration:(int)duration
        totalLength:(NSString *)totalLength
     downloadLength:(NSString *)downloadLength
          localPath:(NSString *)localPath
            isSound:(BOOL)isSound
         coverImage:(UIImage *)coverImage
   placeHodlerImage:(NSString *)imagename
          completed:(BOOL)iscompleted;
- (void)stop;

-(void)reloadDownLoadState:(VideoInfo *)videoInfo;
@end
