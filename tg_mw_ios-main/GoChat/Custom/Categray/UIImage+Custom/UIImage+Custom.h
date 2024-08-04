//
//  UIImage+Custom.h
//  SmartClothesHanger
//
//  Created by moorgen on 2017/8/30.
//  Copyright © 2017年 MoorgenSmartHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Custom)
+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize) size;


//渐变
+ (UIImage *)getGradientImageWithSize:(CGSize)size
                               locations:(const CGFloat[])locations
                              components:(const CGFloat[])components
                                count:(NSInteger)count;

- (UIImage *) imageWithTintColorReEnble:(UIColor *)tintColor;
@end
