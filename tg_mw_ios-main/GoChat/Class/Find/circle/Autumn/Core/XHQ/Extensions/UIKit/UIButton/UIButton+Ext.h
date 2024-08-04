//
//  UIButton+Ext.h
//  Excellence
//
//  Created by 帝云科技 on 2017/6/19.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+XHQEdgeInsets.h"

@interface UIButton (Ext)

+ (instancetype)xhq_buttonFrame:(CGRect)frame
                      bgColor:(UIColor *)bgColor
                   titleColor:(UIColor *)tColor
                  borderWidth:(CGFloat)bWidth
                  borderColor:(CGColorRef)bColor
                 cornerRadius:(CGFloat)cornerRadius
                          tag:(NSInteger)tag
                       target:(id)vc
                          action:(SEL)action
                        title:(NSString *)title;


/**
 touchUpInside
 */
- (void)xhq_addTarget:(id)target action:(SEL)action;

@end

@interface UIButton (XHQFont)

@property (nonatomic, strong) UIFont *xhqFont;

@end
