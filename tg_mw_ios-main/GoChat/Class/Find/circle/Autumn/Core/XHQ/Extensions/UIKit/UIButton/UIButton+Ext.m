//
//  UIButton+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/6/19.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UIButton+Ext.h"
#import <objc/runtime.h>

@implementation UIButton (Ext)

+ (instancetype)xhq_buttonFrame:(CGRect)frame
                        bgColor:(UIColor *)bgColor
                     titleColor:(UIColor *)tColor
                    borderWidth:(CGFloat)bWidth
                    borderColor:(CGColorRef)bColor
                   cornerRadius:(CGFloat)cornerRadius
                            tag:(NSInteger)tag
                         target:(id)vc
                         action:(SEL)action
                          title:(NSString *)title {
    return ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame               = frame;
        if (bgColor) {
            button.backgroundColor     = bgColor;
        }
        if (title) {
            [button setTitle:title forState:UIControlStateNormal];
        }
        if (tColor) {
            [button setTitleColor:tColor forState:UIControlStateNormal];
        }
        if (tag >=0) {
            button.tag                 = tag;
        }
        if (action) {
            [button addTarget:vc action:action forControlEvents:UIControlEventTouchUpInside];
        }
        if (bColor) {
            button.layer.masksToBounds = YES;
            button.layer.borderWidth   = bWidth;
            button.layer.borderColor   = bColor;
        }
        if (bWidth) {
            
        }
        if (cornerRadius) {
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius  = cornerRadius;
        }
        button;
    });
}

- (void)xhq_addTarget:(id)target action:(SEL)action {
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end


static const char *xhq_FontKey = "xhq_FontKey";

@implementation UIButton (XHQFont)

- (UIFont *)xhqFont {
    return objc_getAssociatedObject(self, xhq_FontKey);
}

- (void)setXhqFont:(UIFont *)xhqFont {
    objc_setAssociatedObject(self, xhq_FontKey, xhqFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.titleLabel.font = xhqFont;
}

@end
