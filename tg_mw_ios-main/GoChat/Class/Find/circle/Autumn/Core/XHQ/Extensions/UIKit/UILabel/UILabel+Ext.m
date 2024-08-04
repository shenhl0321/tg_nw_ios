//
//  UILabel+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/6/19.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UILabel+Ext.h"
#import <objc/runtime.h>

@implementation UILabel (Ext)

+ (instancetype)xhq_layoutColor:(UIColor *)color
                           font:(UIFont *)font
                           text:(NSString *)text {
    return [self xhq_labelFrame:CGRectZero
                        bgColor:[UIColor clearColor]
                      textColor:color
                  textAlignment:0
                           font:font
                           text:text];
}

+ (instancetype)xhq_labelFrame:(CGRect)frame
                       bgColor:(UIColor *)bgColor
                     textColor:(UIColor *)tColor
                 textAlignment:(NSTextAlignment)alignment
                          font:(UIFont *)font
                          text:(NSString *)text {
    return ({
        UILabel *label = [[UILabel alloc]initWithFrame:frame];
        label.textColor = tColor;
        label.backgroundColor = bgColor;
        label.textAlignment = alignment;
        label.font = font;
        label.text = text;
        label;
    });
}



@end
