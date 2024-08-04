//
//  UITextView+ZWPlaceHolder.h
//  FinancialUnion
//
//  Created by 帝云科技 on 2019/1/3.
//  Copyright © 2019年 帝云科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (ZWPlaceHolder)
/**
 *  UITextView+placeholder
 */
@property (nonatomic, copy) NSString *zw_placeHolder;
/**
 *  IQKeyboardManager等第三方框架会读取placeholder属性并创建UIToolbar展示
 */
@property (nonatomic, copy) NSString *placeholder;
/**
 *  placeHolder颜色
 */
@property (nonatomic, strong) UIColor *zw_placeHolderColor;

@end

NS_ASSUME_NONNULL_END
