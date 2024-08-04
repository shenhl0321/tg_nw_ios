//
//  MNRegisterSuccessVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNRegisterSuccessVC.h"
#import "TfRow.h"

@interface MNRegisterSuccessVC ()

@end

@implementation MNRegisterSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initUI{
    UIImageView *iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Success"]];
    [self.contentView addSubview:iconImgV];
    UILabel *tipLabel = [[UILabel alloc] init];
    tipLabel.font = fontRegular(22);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor colorTextFor0DBFC0];
    tipLabel.text = LocalString(localSetRestSuccess);
    [self.contentView addSubview:tipLabel];
    
    UILabel *tipLabel2 = [[UILabel alloc] init];
    tipLabel2.font = fontRegular(15);
    tipLabel2.textAlignment = NSTextAlignmentCenter;
    tipLabel2.textColor = [UIColor colorTextFor878D9A];
    tipLabel2.text = LocalString(localYouSetResetSuccess);
    [self.contentView addSubview:tipLabel2];
    
    UIButton *btn = [UIButton mn_loginStyleWithTitle:LocalString(localFinish)];
    [btn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.mas_equalTo(0);
    }];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImgV.mas_bottom).with.offset(15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(31);
    }];
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconImgV.mas_bottom).with.offset(51);
        make.left.mas_equalTo(left_margin40());
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(21);
    }];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin30());
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(-90);
        make.height.mas_equalTo(55);
    }];
}

- (void)finishAction{
    
}

@end
