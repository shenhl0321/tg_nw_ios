//
//  DYViewController+BarButtonItem.m
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/7.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYViewController+BarButtonItem.h"
#import <objc/runtime.h>

static char DYLeftBlockKey;
static char DYRightBlockKey;

@implementation DYViewController (BarButtonItem)


- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.dy_barStyle;
}

- (UIStatusBarStyle)dy_barStyle {
    return (UIStatusBarStyle)[objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setDy_barStyle:(UIStatusBarStyle)dy_barStyle {
    objc_setAssociatedObject(self, @selector(dy_barStyle), @(dy_barStyle), OBJC_ASSOCIATION_ASSIGN);
    [self setNeedsStatusBarAppearanceUpdate];
}



- (void)dy_initLeftTitleBarButtonItem:(NSString *)title click:(dispatch_block_t)completion {
    if (![NSString xhq_notEmpty:title]) {
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, title.length * 20, kNavigationStatusHeight());
    btn.titleLabel.font = [UIFont xhq_font14];
    [btn setTitleColor:[self textColor] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn xhq_addTarget:self action:@selector(dy_leftBarButtonItemClicked)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    objc_setAssociatedObject(self, &DYLeftBlockKey, completion, OBJC_ASSOCIATION_COPY);
}

- (void)dy_leftBarButtonItemClicked {
    dispatch_block_t block = objc_getAssociatedObject(self, &DYLeftBlockKey);
    !block ? : block();
}


- (void)dy_initRightTitleBarButtonItem:(NSString *)title click:(dispatch_block_t)completion {
    if (![NSString xhq_notEmpty:title]) {
        return;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, title.length * 20, kNavigationStatusHeight());
    btn.titleLabel.font = [UIFont xhq_font14];
    [btn setTitleColor:[self textColor] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [btn xhq_addTarget:self action:@selector(dy_rightBarButtonItemClicked)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    objc_setAssociatedObject(self, &DYRightBlockKey, completion, OBJC_ASSOCIATION_COPY);
}

- (void)dy_rightBarButtonItemClicked {
    dispatch_block_t block = objc_getAssociatedObject(self, &DYRightBlockKey);
    !block ? : block();
}

- (UIColor *)textColor {
    BOOL isWhite = CGColorEqualToColor(self.navigationController.navigationBar.barTintColor.CGColor, UIColor.clearColor.CGColor);
    return isWhite ? UIColor.whiteColor : UIColor.xhq_aTitle;
}

@end
