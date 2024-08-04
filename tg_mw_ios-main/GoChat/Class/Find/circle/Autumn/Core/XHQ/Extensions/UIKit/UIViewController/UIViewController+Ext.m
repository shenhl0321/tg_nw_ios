//
//  UIViewController+Ext.m
//  ShangDuHuiProject
//
//  Created by 帝云科技 on 2017/11/7.
//  Copyright © 2017年 APPLE. All rights reserved.
//

#import "UIViewController+Ext.h"

@implementation UIViewController (Ext)

#pragma mark - 返回控制器
- (void)xhq_popToViewControllerWithIndex:(NSInteger)aIndex {
    NSArray *viewControllers = [self.navigationController viewControllers];
    if (viewControllers.count >= aIndex) {
        [self.navigationController popToViewController:viewControllers[viewControllers.count - aIndex] animated:YES];
    }
}

#pragma mark - 判断当前控制器是否正在显示
- (BOOL)xhq_isVisible
{
    return (self.isViewLoaded && self.view.window);
}


#pragma mark - 获取当前活动控制器
+ (UIViewController *)xhq_currentController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self xhq_currentControllerFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)xhq_currentControllerFrom:(UIViewController *)rootController
{
    UIViewController *currentVC;
    
    if ([rootController presentedViewController])
    {
        rootController = [rootController presentedViewController];
    }
    
    if ([rootController isKindOfClass:[UITabBarController class]])
    {
        currentVC = [self xhq_currentControllerFrom:[(UITabBarController *)rootController selectedViewController]];
    }
    else if ([rootController isKindOfClass:[UINavigationController class]])
    {
        currentVC = [self xhq_currentControllerFrom:[(UINavigationController *)rootController visibleViewController]];
    }
    else
    {
        currentVC = rootController;
    }
    return currentVC;
}

@end
