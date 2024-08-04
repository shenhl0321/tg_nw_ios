//
//  UIView+XHQGestureRecognizer.m
//  Cafu
//
//  Created by 帝云科技 on 2018/4/25.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import "UIView+XHQGestureRecognizer.h"
#import <objc/runtime.h>

static char xhq_kTapActionBlockKey;
static char xhq_kTapActionGestureKey;

@implementation UIView (XHQGestureRecognizer)

- (void)xhq_addTapActionWithBlock:(XHQGestureActionBlock)block
{
    UITapGestureRecognizer *gesture = objc_getAssociatedObject(self, &xhq_kTapActionGestureKey);
    if (!gesture) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xhq_tapAction:)]];
        objc_setAssociatedObject(self, &xhq_kTapActionGestureKey, gesture, OBJC_ASSOCIATION_RETAIN);
    }
    objc_setAssociatedObject(self, &xhq_kTapActionBlockKey, block, OBJC_ASSOCIATION_COPY);
}

- (void)xhq_tapAction:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        
        XHQGestureActionBlock block = objc_getAssociatedObject(self, &xhq_kTapActionBlockKey);
        !block ? : block(tap);
    }
}

@end
