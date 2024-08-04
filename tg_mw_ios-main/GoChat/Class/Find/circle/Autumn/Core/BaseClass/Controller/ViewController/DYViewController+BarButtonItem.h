//
//  DYViewController+BarButtonItem.h
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/7.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DYViewController (BarButtonItem)


/**
 状态栏类型
 */
@property (nonatomic, assign) UIStatusBarStyle dy_barStyle;


/**
 导航栏左侧按钮
 */
- (void)dy_initLeftTitleBarButtonItem:(NSString *)title click:(dispatch_block_t)completion;


/**
 导航栏右侧按钮
 */
- (void)dy_initRightTitleBarButtonItem:(NSString *)title click:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
