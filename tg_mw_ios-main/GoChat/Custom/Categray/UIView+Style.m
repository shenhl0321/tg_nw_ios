//
//  UIView+Style.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/2.
//

#import "UIView+Style.h"

@implementation UIView (Style)

- (void)mn_iconStyle{
//    self.layer.cornerRadius = 26;
//    self.layer.masksToBounds = YES;
//    self.layer.borderColor = [UIColor colorTextForE5EAF0].CGColor;
//    self.layer.borderWidth = 1;
    [self mn_iconStyleWithRadius:26];
}

- (void)mn_iconStyleWithRadius:(CGFloat)radius{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorTextForE5EAF0].CGColor;
    self.layer.borderWidth = 1;
}

@end
