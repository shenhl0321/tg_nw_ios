//
//  UIFont+Ext.h
//  Excellence
//
//  Created by 帝云科技 on 2017/6/19.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>


static inline UIFont *XHQFont(CGFloat size) {
    return [UIFont systemFontOfSize:size];
}

static inline UIFont *XHQBoldFont(CGFloat size) {
    return [UIFont boldSystemFontOfSize:size];
}


/**
 iPhone5 iiPhoneSE字体 比正常小2
 */
static inline UIFont *XHQ5SEFont(CGFloat size) {
    if (kIsIPhone5SE()) {
        return [UIFont systemFontOfSize:size - 2];
    }else {
        return XHQFont(size);
    }
}


@interface UIFont (Ext)

+ (instancetype)xhq_font18;
+ (instancetype)xhq_font17;
+ (instancetype)xhq_font16;
+ (instancetype)xhq_font15;
+ (instancetype)xhq_font14;
+ (instancetype)xhq_font13;
+ (instancetype)xhq_font12;
+ (instancetype)xhq_font10;
+ (instancetype)xhq_font8;

@end
