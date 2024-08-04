//
//  UIView+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/6/20.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UIView+Ext.h"

@implementation UIView (Ext)

- (CGFloat)xhq_x {
    return self.frame.origin.x;
}

- (CGFloat)xhq_y {
    return self.frame.origin.y;
}

- (void)setXhq_x:(CGFloat)xhq_x {
    CGRect frame = self.frame;
    frame.origin.x = xhq_x;
    self.frame = frame;
}

- (void)setXhq_y:(CGFloat)xhq_y {
    CGRect frame = self.frame;
    frame.origin.y = xhq_y;
    self.frame = frame;
}

- (CGFloat)xhq_width {
    return self.frame.size.width;
}

- (CGFloat)xhq_height {
    return self.frame.size.height;
}

- (void)setXhq_width:(CGFloat)xhq_width {
    CGRect frame = self.frame;
    frame.size.width = xhq_width;
    self.frame = frame;
}

- (void)setXhq_height:(CGFloat)xhq_height {
    CGRect frame = self.frame;
    frame.size.height = xhq_height;
    self.frame = frame;
}

- (CGFloat)xhq_centerX {
    return self.center.x;
}

- (CGFloat)xhq_centerY {
    return self.center.y;
}

- (void)setXhq_centerX:(CGFloat)xhq_centerX {
    CGPoint center = self.center;
    center.x = xhq_centerX;
    self.center = center;
}

- (void)setXhq_centerY:(CGFloat)xhq_centerY {
    CGPoint center = self.center;
    center.y = xhq_centerY;
    self.center = center;
}

- (CGFloat)xhq_bottom {
    return (self.frame.origin.y + self.frame.size.height);
}

- (CGFloat)xhq_right {
    return (self.frame.origin.x + self.frame.size.width);
}

- (void)setXhq_bottom:(CGFloat)xhq_bottom {
    
}

- (void)setXhq_right:(CGFloat)xhq_right {
    
}

- (CGPoint)xhq_origin {
    return self.frame.origin;
}

- (CGSize)xhq_size {
    return self.frame.size;
}

- (void)setXhq_origin:(CGPoint)xhq_origin {
    CGRect frame = self.frame;
    frame.origin = xhq_origin;
    self.frame = frame;
}

- (void)setXhq_size:(CGSize)xhq_size {
    CGRect frame = self.frame;
    frame.size = xhq_size;
    self.frame = frame;
}


- (UIViewController *)xhq_currentController {
    UIResponder *nextResponder =  self;
    do
    {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;

    } while (nextResponder);

    return nil;
}

@end

@implementation UIView (contentMode)

- (void)xhq_setAspectFitContentMode {
    self.contentMode = UIViewContentModeScaleAspectFit;
}

@end




@implementation UIView (layer)

- (void)xhq_borderColor:(UIColor *)bColor borderWidth:(CGFloat)bWidth {
    self.layer.borderColor = bColor.CGColor;
    self.layer.borderWidth = bWidth;
}

- (void)xhq_cornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)xhq_roundCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    [self layoutIfNeeded];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

@end

@implementation UIView (XHQ_CAKeyframeAnimation)

- (void)xhq_errorAnimation
{
    CAKeyframeAnimation *shakeAnim = [CAKeyframeAnimation animation];
    shakeAnim.keyPath = @"transform.translation.x";
    shakeAnim.duration = 0.15;
    CGFloat delta = 10;
    shakeAnim.values = @[@0 , @(-delta), @(delta), @0];
    shakeAnim.repeatCount = 2;
    [self.layer addAnimation:shakeAnim forKey:nil];
    
    if (self.isUserInteractionEnabled) {
        self.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.userInteractionEnabled = YES;
        });
    }
}

@end
