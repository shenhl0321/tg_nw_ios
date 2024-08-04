//
//  UIViewController+Ext.h
//  ShangDuHuiProject
//
//  Created by 帝云科技 on 2017/11/7.
//  Copyright © 2017年 APPLE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+XHQ_ActionSheet.h"

@interface UIViewController (Ext)

/**
 pop第几层
 */
- (void)xhq_popToViewControllerWithIndex:(NSInteger)aIndex;

/**
 判断当前控制器是否正在显示
 */
- (BOOL)xhq_isVisible;

/**
 获取屏幕当前显示控制器
 */
+ (UIViewController *)xhq_currentController;

@end
