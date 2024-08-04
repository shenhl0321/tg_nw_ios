//
//  UIImage+dy_generateAnImage.h

#import <UIKit/UIKit.h>

@interface UIImage (dy_generateAnImage)

/**
 *  获取指定位置的视频的截屏
 *  @param videoURL 视频NSURL
 *  @param time     要截屏的时间点,如果大于视频时长则截取视频时长三分之一处
 *  @return 截取的视频截屏图片
 */
//FIXME:这里只能获取第一帧视频截屏
+ (UIImage *)dy_generateVideoThumbnailImage:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end
