//
//  NavBaseVC.h
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNNavigationBar.h"


@interface NavBaseVC : UIViewController
<MNNavigationBarDelegate>
@property (nonatomic, strong) MNNavigationBar *customNavBar;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, assign) BOOL navBarHidden;



/**
 HUD显示判断
 不同的页面要根据情况加载HUD 根据修改次状态来判断
 eg: 第一次进入要显示 之后刷新都不显示
 */
@property (nonatomic, assign, getter=isFirstLoadHUD) BOOL firstLoadHUD;

/** 初始化数据 */
- (void)dy_initData;

/** 初始化控件 */
- (void)dy_initUI;

/** 数据请求 */
- (void)dy_request;

/** viewwillappear调用 */
- (void)dy_reloadData;

- (void)refreshCustonNavBarFrame:(CGRect)frame;

-(void)back;

@property (nonatomic, copy) dispatch_block_t appearBlock;

@end

