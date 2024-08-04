//
//  GC_SayHelloVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/7.
//

#import "GC_SayHelloVC.h"

@interface GC_SayHelloVC ()
@property (weak, nonatomic) IBOutlet UITextField *sayTF;
@property (nonatomic, strong)UIButton *saveBtn;

@end

@implementation GC_SayHelloVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.hidden = YES;
    [self.customNavBar setTitle:self.userInfo.user.username.length > 0 ? self.userInfo.user.username : self.userInfo.user.first_name];
    [self.customNavBar addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(0);
    }];
    // Do any additional setup after loading the view from its nib.
}
- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"发送".lv_localized forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}
- (void)click_ok{
    
    [[TelegramManager shareInstance] sendTextMessage:[self.userInfo.chat_id integerValue]  replyid:0 text:self.sayTF.text withUserInfoArr:nil replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:[self.userInfo.chat_id integerValue]];
        [AppDelegate gotoChatView:chat];
    } timeout:^(NSDictionary *request) {
        
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
