//
//  UIImage+Custom.m
//  SmartClothesHanger
//
//  Created by moorgen on 2017/8/30.
//  Copyright © 2017年 MoorgenSmartHome. All rights reserved.
//

#import "UIImage+Custom.h"

@implementation UIImage (Custom)
+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize) size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  @brief  获取采集图像
 *
 *  @para   image   原始图像
 *          percent  裁剪百分比
 *          isVertical 是否是垂直方向裁剪:YES垂直方向 NO水平方向
 */
+(UIImage*)clipImage:(UIImage*)image percent:(CGFloat)percent isVertical:(BOOL)isVertical {
    if (image == nil) {
        return nil;
    }
    if (percent == 0) {
        return image;
    }else {
        
        if (percent > 1.0){
            percent = 1.0;
        }

        CGSize subImageSize;
        CGRect subImageRect;
        
        if (isVertical) {
            subImageSize = CGSizeMake(image.size.width*2,image.size.height*percent*2);
            subImageRect = CGRectMake(0, 0,image.size.width*2,image.size.height*percent*2);
        }else{
            subImageSize = CGSizeMake(image.size.width*percent*2,image.size.height*2);
            subImageRect = CGRectMake(0, 0,image.size.width*percent*2,image.size.height*2);
        }
        subImageSize = CGSizeMake((int)subImageSize.width, (int)subImageSize.height);
        subImageRect = CGRectMake((int)subImageRect.origin.x, (int)subImageRect.origin.y, (int)subImageRect.size.width, (int)subImageRect.size.height);
        if (subImageSize.height <= 0.0 ||subImageSize.width<=0) {
            return nil;
        }
        
        CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, subImageRect);
        UIGraphicsBeginImageContext(subImageSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, subImageRect, subImageRef);
        UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(subImageRef);
        return subImage;
    }
}

/**
 *  @brief  获取反向采集图像
 *
 *  @para   image   原始图像
 *          percent  裁剪百分比
 *          isVertical 是否是垂直方向裁剪:YES垂直方向 NO水平方向
 */
+(UIImage*)clipFlipImage:(UIImage*)image percent:(CGFloat)percent isVertical:(BOOL)isVertical {
    
    if (percent == 0) {
        return image;
    }else {
        CGSize subImageSize;
        CGRect subImageRect;
        
        if (percent > 1.0){
            percent = 1.0;
        }
        
        if (isVertical) {
            subImageSize = CGSizeMake(image.size.width*2,image.size.height*percent*2);
            subImageRect = CGRectMake(0, image.size.height*(1-percent)*2,image.size.width*2,image.size.height*percent*2);
        }else{
            subImageSize = CGSizeMake(image.size.width*percent*2,image.size.height*2);
            subImageRect = CGRectMake(image.size.width*(1-percent)*2, 0,image.size.width*percent*2,image.size.height*2);
        }
        
        subImageSize = CGSizeMake((int)subImageSize.width, (int)subImageSize.height);
        subImageRect = CGRectMake((int)subImageRect.origin.x, (int)subImageRect.origin.y, (int)subImageRect.size.width, (int)subImageRect.size.height);
        
        if (subImageSize.height <= 0||subImageSize.width<=0) {
            return nil;
        }
        CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, subImageRect);
        UIGraphicsBeginImageContext(subImageSize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, subImageRect, subImageRef);
        UIImage* subImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(subImageRef);
    
        return subImage;
    }
}






//渐变
+ (UIImage *)getGradientImageWithSize:(CGSize)size
                               locations:(const CGFloat[])locations
                              components:(const CGFloat[])components
                                   count:(NSInteger)count
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建色彩空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    /*指定渐变色
     space:颜色空间
     components:颜色数组,注意由于指定了RGB颜色空间，那么四个数组元素表示一个颜色（red、green、blue、alpha），
     如果有三个颜色则这个数组有4*3个元素
     locations:颜色所在位置（范围0~1），这个数组的个数不小于components中存放颜色的个数
     count:渐变个数，等于locations的个数
     */
    CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    //释放颜色空间
    CGColorSpaceRelease(colorSpace);
    
//这里调节渐变方向，此时的渐变是上到下
    CGPoint startPoint = (CGPoint){size.width,0};
    CGPoint endPoint = (CGPoint){size.width,size.height};
    /*绘制线性渐变
     context:图形上下文
     gradient:渐变色
     startPoint:起始位置
     endPoint:终止位置
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，到结束点之后继续填充
     */
    CGContextDrawLinearGradient(context, colorGradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);

    CGGradientRelease(colorGradient);
  
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//+ (UIImage *) imageWithTintColorReEnble:(UIColor *)tintColor{
//    return [[UIImage alloc] imageWithTintColorReEnble:tintColor];;
//}

- (UIImage *) imageWithTintColorReEnble:(UIColor *)tintColor{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [self drawInRect:bounds blendMode:kCGBlendModeDestinationAtop alpha:1.f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end
