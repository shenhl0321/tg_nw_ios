//
//  GC_PersonalizedSignatureVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/5.
//

#import "GC_PersonalizedSignatureVC.h"

@interface GC_PersonalizedSignatureVC ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong)UIButton *saveBtn;
@end

static NSInteger const LimitNumber = 70;

@implementation GC_PersonalizedSignatureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.hidden = YES;

    [self.customNavBar setTitle:@"设置我的签名".lv_localized];
    self.textView.placeholder = @"请设置个性签名".lv_localized;
    self.textView.text = UserInfo.shareInstance.bio;
    self.textView.mylimitCount = @(70);
    self.textView.delegate = self;
        
    self.numberLabel.text = [NSString stringWithFormat:@"%ld / %ld", LimitNumber - self.textView.text.length, LimitNumber];
    
    [self.customNavBar addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(0);
    }];
    self.view.backgroundColor = [UIColor colorForF5F9FA];
}
- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}


- (void)textViewDidChange:(UITextView *)textView {
    NSInteger number = LimitNumber - textView.text.length;
    number = MAX(number, 0);
    self.numberLabel.text = [NSString stringWithFormat:@"%ld / %ld", number, LimitNumber];
}

- (void)click_ok {
    [self.view endEditing:YES];
    NSString *text = self.textView.text ? : @"";
    NSDictionary *params = @{@"@type": @"setBio", @"bio": text};
    [UserInfo show];
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if ([TelegramManager isResultError:response]) {
            [UserInfo showTips:nil des:@"个性签名设置失败".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        } else {
            [UserInfo showTips:nil des:@"个性签名设置成功".lv_localized];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
