//
//  PersonalizedSignatureViewController.m
//  GoChat
//
//  Created by Autumn on 2021/12/18.
//

#import "PersonalizedSignatureViewController.h"

@interface PersonalizedSignatureViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;

@end

static NSInteger const LimitNumber = 70;

@implementation PersonalizedSignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置我的签名".lv_localized;
    self.textView.placeholder = @"请设置个性签名".lv_localized;
    self.textView.text = UserInfo.shareInstance.bio;
    self.textView.mylimitCount = @(70);
    self.textView.delegate = self;
    
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(0, 0, 55, 29);
    [okBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
    [okBtn setBackgroundColor:COLOR_CG1];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    okBtn.layer.masksToBounds = YES;
    okBtn.layer.cornerRadius = 4;
    [okBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:okBtn];
    
    self.numberLabel.text = [NSString stringWithFormat:@"%ld / %ld", LimitNumber - self.textView.text.length, LimitNumber];
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


@end
