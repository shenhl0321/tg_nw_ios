//
//  NavBaseVC.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "NavBaseVC.h"

@interface NavBaseVC ()

@end

@implementation NavBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.customNavBar];
    [self.view bringSubviewToFront:self.customNavBar];
    [self.view addSubview:self.contentView];
    [self.customNavBar style_title_LeftBtn_RightBtn];
    self.customNavBar.delegate = self;
   
//    self.customNavBar.backgroundColor = [UIColor whiteColor];
    if (self.navigationController.viewControllers.count > 1) {
       self.backBtn = [self.customNavBar setLeftBtnWithImageName:@"NavBack" title:nil highlightedImageName:nil];
    }else{
        if ([self isKindOfClass:NSClassFromString(@"CameraViewController")]) {
            self.backBtn = [self.customNavBar setLeftBtnWithImageName:@"NavBack" title:nil highlightedImageName:nil];
        }
    }
    [self dy_initData];
    [self dy_initUI];
    [self dy_request];
//    self.navigationController.navigationBar.hidden = YES;
//    self.navigationController.navigationBar.hidden = YES;
}

- (void)setNavBarHidden:(BOOL)navBarHidden{
    _navBarHidden = navBarHidden;
    if (navBarHidden) {
        self.fd_prefersNavigationBarHidden = YES;
        self.customNavBar.hidden = YES;
        _customNavBar = [[MNNavigationBar alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 0)];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(MNNavigationBar *)customNavBar{
    if (!_customNavBar) {
        _customNavBar = [[MNNavigationBar alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_TOP_BAR_HEIGHT)];
        
       
    }
    return _customNavBar;
}

- (void)refreshCustonNavBarFrame:(CGRect)frame{
    self.customNavBar.frame = frame;
    self.contentView.frame = CGRectMake(0, CGRectGetMaxY(self.customNavBar.frame), APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-CGRectGetMaxY(self.customNavBar.frame)-kBottom34());
//    [self.customNavBar addRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight radius:36];
    
    [self.view bringSubviewToFront:self.customNavBar];
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickLeftBtn:(UIButton *)btn{
    [self back];
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34())];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}
#pragma mark - getter

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self dy_reloadData];
    !self.appearBlock ? : self.appearBlock();
}

- (void)dy_initData {
    self.firstLoadHUD = YES;
}

- (void)dy_initUI {
    
}

- (void)dy_request {
    
}

- (void)dy_reloadData {
    
}

@end
