//
//  UINavigationController+StatusBarStyle.m
//  Aoyo
//
//  Created by 帝云科技 on 2019/3/7.
//  Copyright © 2019 帝云科技. All rights reserved.
//

#import "UINavigationController+StatusBarStyle.h"
#import <objc/runtime.h>

static NSString *const image_bg = @"bg_navtitle";

@implementation UINavigationController (StatusBarStyle)


- (void)dy_setNavigationBarStyle:(DYNavigationBarStyle)style {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    switch (style) {
        case DYNavigationBarStyleDefault:
        {
            attributes[NSForegroundColorAttributeName] = [UIColor xhq_aTitle];
            [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setShadowImage:nil];
            [self.navigationBar setBarTintColor:UIColor.whiteColor];
            [self.navigationBar setTranslucent:NO];
        }
            break;
        case DYNavigationBarStyleClear:
        {
            attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
            [self.navigationBar setBackgroundImage:UIImage.new forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setShadowImage:UIImage.new];
            [self.navigationBar setBarTintColor:UIColor.clearColor];
            [self.navigationBar setTranslucent:YES];
        }
            break;
        case DYNavigationBarStyleImage:
        {
            attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
            [self.navigationBar setBackgroundImage:[UIImage imageNamed:image_bg] forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setShadowImage:UIImage.new];
            [self.navigationBar setBarTintColor:UIColor.clearColor];
            [self.navigationBar setTranslucent:NO];
        }
            break;
    }
    [self.navigationBar setTitleTextAttributes:attributes];
}


- (void)dy_clearNavigationBar {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    [self.navigationBar setTitleTextAttributes:attributes];
    [self.navigationBar setShadowImage:[UIImage new]];
    [self.navigationBar setBackgroundImage:UIImage.new forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBarTintColor:UIColor.clearColor];
    [self.navigationBar setTranslucent:YES];
    /*注意：translucent为YES时 (0,0)位置在起点*/
}

- (void)dy_defaultNavigationBar {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor xhq_aTitle];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    [self.navigationBar setTitleTextAttributes:attributes];
    [self.navigationBar setShadowImage:nil];
    [self.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setBarTintColor:UIColor.whiteColor];
    [self.navigationBar setTranslucent:NO];
    /*注意：translucent为YES时 (0,0)位置在导航栏下*/
}

@end
