//
//  GestureNavigationViewController.m
//  
//
//  Created by wang yutao on 2017/7/6.
//  Copyright © 2017 zy technologies inc. All rights reserved.
//

#import "GestureNavigationViewController.h"
#import "C2CCallViewController.h"
#import "ToFullCallTranisition.h"
#import "ToTopCallTranisition.h"

@interface GestureNavigationViewController()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation GestureNavigationViewController

//- (void)showNavigationWithClearBG{
//    self.navigationBar.translucent = YES;
//    // 将状态栏和导航条设置成透明
//    UIImage *image = [UIImage new];
//    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak GestureNavigationViewController *weakSelf = self;
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES)
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES)
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer == self.interactivePopGestureRecognizer)
    {
        if([self.visibleViewController isKindOfClass:[C2CCallViewController class]])
        {
            return NO;
        }
        if(self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0])
        {
            return NO;
        }
    }
    return YES;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if(operation == UINavigationControllerOperationPush)
    {
        if([[CallManager shareInstance] isHaveSmallTopView])
        {
            if([toVC isKindOfClass:[C2CCallViewController class]])
            {
                ToFullCallTranisition *tranisition = [ToFullCallTranisition new];
                CGRect rt = [[CallManager shareInstance] smallTopViewRect];
                tranisition.iconCenter = CGPointMake(rt.origin.x+(rt.size.width/2), rt.origin.y+(rt.size.height/2));
                return tranisition;
            }
        }
    }
    if(operation == UINavigationControllerOperationPop)
    {
        if([CallManager shareInstance].isInCalling)
        {
            if([fromVC isKindOfClass:[C2CCallViewController class]])
            {
                ToTopCallTranisition *tranisition = [ToTopCallTranisition new];
                CGRect rt = [[CallManager shareInstance] smallTopViewRect];
                tranisition.iconCenter = CGPointMake(rt.origin.x+(rt.size.width/2), rt.origin.y+(rt.size.height/2));
                return tranisition;
            }
        }
    }
    return nil;
}

#pragma mark - 控制屏幕旋转方法
- (BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
