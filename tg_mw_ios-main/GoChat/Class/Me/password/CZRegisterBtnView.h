//
//  CZRegisterBtnView.h
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZRegisterBtnView : UIView
+ (CZRegisterBtnView *)instanceViewWithBtnTitle:(NSString *)btnTitle WithClick:(dispatch_block_t)block;
@end

NS_ASSUME_NONNULL_END
