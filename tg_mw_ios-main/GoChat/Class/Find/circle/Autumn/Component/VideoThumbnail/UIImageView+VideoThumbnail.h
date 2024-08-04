//
//  UIImageView+VideoThumbnail.h
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (VideoThumbnail)

/// 获取并显示视频封面
- (void)setThumbnailImage:(VideoInfo *)video;

/// 只显示本地已经获取到的视频封面。
- (void)setLocalThumbnailImage:(VideoInfo *)video;

@end

NS_ASSUME_NONNULL_END
