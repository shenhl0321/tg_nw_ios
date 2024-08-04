//
//  UITextField+Ext.h
//  Excellence
//
//  Created by 帝云科技 on 2017/6/22.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Ext)

/**
 输入限制

 @param number 输入字符
 @param limit 限制为
 @return TURE/FALSE
 */
- (BOOL)input:(NSString *)number limit:(NSString *)limit;

/**
 限制位数

 @param index <#index description#>
 */
- (void)substringToIndex:(NSInteger)index;

/**
 设置输入数字
 */
- (void)setNumbersKeyboard;

/**
 设置输入数字和字符
 */
- (void)setNumbersPunctuationKeyBoard;

@end
