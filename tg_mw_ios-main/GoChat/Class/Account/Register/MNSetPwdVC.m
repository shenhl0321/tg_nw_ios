//
//  MNSetPwdVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNSetPwdVC.h"
#import "MNRegisterSuccessVC.h"
#import "MNTitleTfRow.h"

@interface MNSetPwdVC ()

@property (nonatomic, strong) UITextField *PwdTf;
@property (nonatomic, strong) UITextField *enSurePwdTf;

@end

@implementation MNSetPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:LocalString(localSetPwd)];
    [self initUI];
}

- (void)initUI{
    MNTitleTfRow *row1 = [[MNTitleTfRow alloc] initWithFrame:CGRectMake(left_margin40(), 35, APP_SCREEN_WIDTH-2*left_margin40(), 81)];
    row1.titleLabel.text = LocalString(localNewPwd);
    self.PwdTf = row1.tf;
    [self.contentView addSubview:row1];
    
    MNTitleTfRow *row2 = [[MNTitleTfRow alloc] initWithFrame:CGRectMake(CGRectGetMinX(row1.frame), 35+CGRectGetMaxY(row1.frame), CGRectGetWidth(row1.frame), 81)];
    row2.titleLabel.text = LocalString(localEnsurePwd);
    self.enSurePwdTf = row2.tf;
    [self.contentView addSubview:row2];
    
    UIButton *btn = [UIButton mn_loginStyleWithTitle:LocalString(localSure)];
    [btn addTarget:self action:@selector(sureAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin30());
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.bottom.mas_equalTo(-100);
    }];
    
    self.PwdTf.placeholder = LocalString(localPlsEnterNewPwd);
    self.enSurePwdTf.placeholder = LocalString(localPlsReEnterNewPwd);
    
}

- (void)sureAction{
    MNRegisterSuccessVC *vc = [[MNRegisterSuccessVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
