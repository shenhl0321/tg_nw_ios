//
//  UIImage+Ext.h
//  FirePlatformCompany
//
//  Created by 帝云科技 on 2020/2/27.
//  Copyright © 2020 帝云科技. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Ext)

- (UIImage *)compressToImageWithMaxLength:(NSUInteger)maxLength;

- (NSData *)compressToDataWithMaxLength:(NSUInteger)maxLength;


+ (UIImage *)xhq_imageWithColor:(UIColor *)color;


/// 同步获取视频封面
+ (UIImage *)thumbnailForVideoPath:(NSString *)path;
/// 异步获取视频封面
+ (void)thumbnailForVideoPath:(NSString *)path result:(void(^)(UIImage * _Nullable image))result;

+ (void)thumbnailForAsset:(AVURLAsset *)asset result:(void(^)(UIImage * _Nullable image))result;

@end

NS_ASSUME_NONNULL_END
