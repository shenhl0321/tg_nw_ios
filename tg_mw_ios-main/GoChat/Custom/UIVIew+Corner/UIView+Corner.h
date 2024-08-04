//
//  UIView+Corner.h
//  Connect
//
//  Created by moorgen on 2017/12/4.
//  Copyright © 2017年 MoorgenSmartHome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Corner)
/**
 *  设置部分圆角
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radius   需要设置的圆角大小
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                   radius:(CGFloat)radius;

/**
 *  设置设置四个圆角圆角
 */
- (void)addRoundedWithRadius:(CGFloat)radius;
@end
