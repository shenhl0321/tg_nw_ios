//
//  BaseNavController.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "BaseNavController.h"
#import "BaseVC.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
@interface BaseNavController ()
<UIAdaptivePresentationControllerDelegate>
@end

@implementation BaseNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;//隐藏导航栏
    if (@available(iOS 11.0, *)) {
        self.navigationBar.prefersLargeTitles = NO;
    } else {
        // Fallback on earlier versions
    }
//    [self createBackButton];
//    self.navigationItem.leftBarButtonItem = [self createBackButton];
//    self.navigationBarHidden = NO;// 使右滑返回手势可用
    // Do any additional setup after loading the view.
    self.fd_fullscreenPopGestureRecognizer.enabled = YES;
//    [self preferredStatusBarStyle];
   
}

//-(UIBarButtonItem *)createBackButton {
//    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBack"] style:UIBarButtonItemStylePlain target:self action:@selector(popself)];
//}
////- (UIStatusBarStyle)preferredStatusBarStyle{
////    return UIStatusBarStyleLightContent;
////}
//- (void)popself{
//    [self.navigationController popViewControllerAnimated:YES];
//}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count ==1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }else{
        viewController.hidesBottomBarWhenPushed = NO;
    }

//    NSArray *viewControllers = self.viewControllers;
//    if (viewControllers.count > 0) {
//        UIViewController *lastVC = viewControllers[viewControllers.count - 1];
//        if ([viewController isKindOfClass:NSClassFromString(@"HubDeviceListVC")]) {
//            [super pushViewController:viewController animated:animated];
//        }else{
//            if ([lastVC class] != [viewController class]) {
//                [super pushViewController:viewController animated:animated];
//            }
//        }
//    }else{
//        [super pushViewController:viewController animated:animated];
//    }
    [super pushViewController:viewController animated:animated];
}

@end
