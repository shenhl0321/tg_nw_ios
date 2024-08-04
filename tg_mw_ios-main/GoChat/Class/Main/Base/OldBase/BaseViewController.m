//
//  BaseViewController.m
//
//  Created by wang yutao on 15/3/5.
//  Copyright (c) 2015年 wangyutao. All rights reserved.
//

#import "BaseViewController.h"
#define NAVBAR_TINT_COLOR

@interface BaseViewController ()
@end

@implementation BaseViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(Is_Special_Theme)
//    {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        [self setWhiteStyle];
//    }
//    else
//    {
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }//UIStatusBarStyleDarkContent  UIStatusBarStyleDefault
        [self setDefaultStyle];
//    }
    //去除导航栏分割线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (IBAction)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setWhiteStyle
{
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:fontSemiBold(19)}];
    self.navigationController.navigationBar.tintColor = [UIColor colorTextFor23272A];
    self.navigationController.navigationBar.barTintColor = COLOR_BG_NAV;
    if(self.navigationController.viewControllers.count>0 && self.navigationController.viewControllers[0] != self)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateNormal];
//        [backBtn setImage:[UIImage imageNamed:@"com_nav_ic_back_white"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

- (void)setDefaultStyle
{
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorTextFor23272A],NSFontAttributeName:fontSemiBold(19)}];
    self.navigationController.navigationBar.tintColor = [UIColor colorTextFor23272A];
    self.navigationController.navigationBar.barTintColor = COLOR_BG_NAV;
    if(self.navigationController.viewControllers.count>0 && self.navigationController.viewControllers[0] != self)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y >= scrollView.contentSize.height-self.view.frame.size.height)
    {
        if(_needLoadMore && !_isLoadMore)
        {
            self.isLoadMore = YES;
            [self startLoadingMore];
        }
    }
}

- (void)startLoadingMore
{
}

- (void)stopLoadMore
{
    if (self.isLoadMore)
    {
        self.isLoadMore = NO;
    }
}

- (EmptyView *)emptyView
{
    if(_emptyView == nil)
    {
        _emptyView = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    return _emptyView;
}

#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end

@implementation BaseTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if(Is_Special_Theme)
//    {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        [self setWhiteStyle];
//    }
//    else
//    {
        if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
        [self setDefaultStyle];
//    }
    //去除导航栏分割线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setWhiteStyle
{
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:fontSemiBold(19)}];
    self.navigationController.navigationBar.tintColor = [UIColor colorTextFor23272A];
    self.navigationController.navigationBar.barTintColor = COLOR_BG_NAV;
    if(self.navigationController.viewControllers.count>0 && self.navigationController.viewControllers[0] != self)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

- (void)setDefaultStyle
{
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorTextFor23272A],NSFontAttributeName:fontSemiBold(19)}];
    self.navigationController.navigationBar.tintColor = [UIColor colorTextFor23272A];
    self.navigationController.navigationBar.barTintColor = COLOR_BG_NAV;
    if(self.navigationController.viewControllers.count>0 && self.navigationController.viewControllers[0] != self)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y >= scrollView.contentSize.height-self.tableView.frame.size.height)
    {
        if(_needLoadMore && !_isLoadMore)
        {
            self.isLoadMore = YES;
            [self startLoadingMore];
        }
    }
}

- (void)startLoadingMore
{
}

- (void)stopLoadMore
{
    if (self.isLoadMore)
    {
        self.isLoadMore = NO;
    }
}

- (EmptyView *)emptyView
{
    if(_emptyView == nil)
    {
        _emptyView = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    return _emptyView;
}

- (EmptyView *)emptyViewForShare
{
    if(_emptyView == nil)
    {
        _emptyView = [[[UINib nibWithNibName:@"EmptyViewForShare" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    return _emptyView;
}

#pragma mark - 控制屏幕旋转方法
//是否自动旋转,返回YES可以自动旋转,返回NO禁止旋转
- (BOOL)shouldAutorotate
{
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
