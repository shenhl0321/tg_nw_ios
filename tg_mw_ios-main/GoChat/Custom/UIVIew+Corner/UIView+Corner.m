//
//  UIView+Corner.m
//  Connect
//
//  Created by moorgen on 2017/12/4.
//  Copyright © 2017年 MoorgenSmartHome. All rights reserved.
//

#import "UIView+Corner.h"

@implementation UIView (Corner)
/**
 *  设置部分圆角
 *
 *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
 *  @param radius   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
 */
- (void)addRoundedCorners:(UIRectCorner)corners
                   radius:(CGFloat)radius {
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    self.layer.mask = shape;
}

/**
 *  设置设置四个圆角圆角
 */
- (void)addRoundedWithRadius:(CGFloat)radius{
    [self addRoundedCorners:UIRectCornerAllCorners
                     radius:radius];
}

@end
