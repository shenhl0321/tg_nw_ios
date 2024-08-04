//
//  UIButton+Style.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Style)
//注册按钮的那个样式的
- (void)mn_registerStyle;

//登录按钮那个样式
- (void)mn_loginStyle;

//登录按钮那个样式,还有宝宝按钮
- (void)mn_loginStyleWithBgColor:(UIColor *)color;

//注册按钮的那个样式的
+ (UIButton *)mn_registerStyleText:(NSString *)text;

//登录按钮那个样式
+ (UIButton *)mn_loginStyleWithTitle:(NSString *)title;

//登录按钮那个样式,还有宝宝按钮
+ (UIButton *)mn_loginStyleWithBgColor:(UIColor *)color title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
