//
//  CZSaveBtnView.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZSaveBtnView.h"

@interface CZSaveBtnView ()
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (nonatomic,copy)  dispatch_block_t    block;
@end

@implementation CZSaveBtnView

+(CZSaveBtnView *)instanceViewWithClick:(dispatch_block_t)block
{
    CZSaveBtnView* nibView =  [[[NSBundle mainBundle] loadNibNamed:@"CZSaveBtnView" owner:nil options:nil] firstObject];
    nibView.frame = CGRectMake(0, 0,SCREEN_WIDTH, 140);
    [nibView setLoginButtonUI];
    nibView.block = block;
    return nibView;
}

- (void)loginBtnClick:(UIButton *)sender{
    _block();
}

- (void)setLoginButtonUI
{
//    self.loginBtn.backgroundColor = [UIColor colorWithRed:255/255.0 green:30/255.0 blue:0/255.0 alpha:1.0];
   
    [self.registerBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.registerBtn.layer.cornerRadius = 7;
    self.registerBtn.layer.masksToBounds = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
