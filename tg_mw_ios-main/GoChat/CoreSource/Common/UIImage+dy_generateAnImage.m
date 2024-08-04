//
//  UIImage+dy_generateAnImage.m

#import "UIImage+dy_generateAnImage.h"
@import AVFoundation;

@implementation UIImage (dy_generateAnImage)

+ (UIImage *)dy_generateVideoThumbnailImage:(NSURL *)videoURL atTime:(NSTimeInterval)time;
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    //获取视频时长
    CMTime duration = asset.duration;
    float durationSeconds =CMTimeGetSeconds(duration);
    
    CFTimeInterval thumbnailImageTime = time > durationSeconds ?  durationSeconds / 3 : time;
    //想要截屏参数(截取的秒数,视频每秒多少帧)
    CMTime thumbnailTime = CMTimeMake(thumbnailImageTime, 600);
    CMTime actualTime;//实际截屏时间
    
    NSError *error = nil;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    imageGenerator.maximumSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    //获取截屏精确时间,不从缓存中取
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:&actualTime error:&error];
    
    CMTimeShow(thumbnailTime);
    CMTimeShow(actualTime);
    
    if (!imageRef){
        NSLog(@"thumbnailImageGenerationError %@", error);
    }
    
    UIImage *thumbnailImage = imageRef ? [[UIImage alloc] initWithCGImage:imageRef]: nil;
    CGImageRelease(imageRef);
    
    return thumbnailImage;
}

@end
