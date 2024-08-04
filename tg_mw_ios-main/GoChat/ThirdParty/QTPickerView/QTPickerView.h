//
//  QTPickerView.h
//  QTPickerView
//
//  Created by ijointoo on 2017/10/19.
//  Copyright © 2017年 demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QTPickerView : UIView

/** pickerView
 *  title 标题
 */
- (instancetype)initWithFrame:(CGRect)frame;

/*
 * - Parameters:
 *   - title: 标题
 *   - selectedStr: 选中日期
 *   - confirmBlock: 确定回调
 *   - cancle: 取消回调
 */
- (void)appearWithTitle:(NSString *)title selectedStr:(NSString *)selectedStr sureAction:(void(^)(NSInteger path,NSString *pathStr))confirmBlock cancleAction:(void(^)(void))cancelBlock;

- (void)disAppear;
@end
