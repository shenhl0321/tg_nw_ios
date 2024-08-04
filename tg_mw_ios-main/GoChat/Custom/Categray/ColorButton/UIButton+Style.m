//
//  UIButton+Style.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "UIButton+Style.h"

@implementation UIButton (Style)

//注册按钮的那个样式的
- (void)mn_registerStyle{
    self.titleLabel.font = fontRegular(17);
    self.layer.cornerRadius = 13;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorTextForA9B0BF].CGColor;
    [self setTitleColor:[UIColor colorTextFor878D9A] forState:UIControlStateNormal];
}

//登录按钮那个样式
- (void)mn_loginStyle{
    [self mn_loginStyleWithBgColor:HEXCOLOR(0x34CDAC)];
}

//登录按钮那个样式,还有宝宝按钮
- (void)mn_loginStyleWithBgColor:(UIColor *)color{
    self.layer.cornerRadius = 27.5;
    self.layer.masksToBounds = YES;
    self.titleLabel.font = fontRegular(17);
    [self setTitleColor:[UIColor colorTextForFFFFFF] forState:UIControlStateNormal];
    UIImage *image = [UIImage imageWithColor:color size:CGSizeMake(APP_SCREEN_WIDTH-2*30, 55)];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

//注册按钮的那个样式的
+ (UIButton *)mn_registerStyleText:(NSString *)text{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn mn_registerStyle];
    return btn;
}

//登录按钮那个样式
+ (UIButton *)mn_loginStyleWithTitle:(NSString *)title{
    return [UIButton mn_loginStyleWithBgColor:HEXCOLOR(0x34CDAC) title:title];
}

//登录按钮那个样式,还有宝宝按钮
+ (UIButton *)mn_loginStyleWithBgColor:(UIColor *)color title:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn mn_loginStyleWithBgColor:color];
    return btn;
}
@end
