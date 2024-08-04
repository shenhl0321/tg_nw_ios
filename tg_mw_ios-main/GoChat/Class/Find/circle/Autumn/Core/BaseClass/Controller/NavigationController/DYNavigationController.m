//
//  DYNavigationController.m
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/10/31.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYNavigationController.h"

@interface DYNavigationController ()<UINavigationControllerDelegate>

@end

@implementation DYNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor xhq_aTitle];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setTitleTextAttributes:attributes];
    [navBar setBarTintColor:[UIColor whiteColor]];
    navBar.translucent = NO;
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor xhq_aTitle]];
}

#pragma mark - 返回按钮
- (UIBarButtonItem *)backButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(back)];
}

- (void)back {
    [self popViewControllerAnimated:YES];
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    if (self.viewControllers.count > 0 && !viewController.navigationItem.leftBarButtonItem) {
        viewController.navigationItem.leftBarButtonItem = [self backButtonItem];
    }
    
    [super pushViewController:viewController animated:animated];
}


@end
