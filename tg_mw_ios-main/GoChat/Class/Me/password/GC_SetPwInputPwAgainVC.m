//
//  GC_SetPwInputPwAgainVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "GC_SetPwInputPwAgainVC.h"
#import "GC_SetPwResultVC.h"
#import "TelegramManager.h"
#import "GC_SetPwInputNewPwVC.h"

@interface GC_SetPwInputPwAgainVC ()
@property (weak, nonatomic) IBOutlet CRBoxInputView *pswInputView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation GC_SetPwInputPwAgainVC

-(void)setOldpwdstr:(NSString *)oldpwdstr{
   if (oldpwdstr) {
       _oldpwdstr = oldpwdstr;
   }else{
       _oldpwdstr = @"";
   }
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   self.title = @"";
    
        [self.customNavBar setTitle:@"支付密码".lv_localized];
   //验证码视图样式
   [self setPswInputUI];
    self.contentView.hidden = YES;
    self.nextBtn.clipsToBounds = YES;
    self.nextBtn.layer.cornerRadius = 13;
    self.nextBtn.backgroundColor = [UIColor colorMain];
}

- (void)setPswInputUI
{
   CRBoxInputCellProperty *cellProperty = [CRBoxInputCellProperty new];
   cellProperty.showLine = YES;
   cellProperty.borderWidth = 0;
   cellProperty.cellCursorColor = COLOR_CG1;
   cellProperty.customLineViewBlock = ^CRLineView * _Nonnull{
       CRLineView *lineView = [CRLineView new];
       lineView.underlineColorNormal = HEX_COLOR(@"#717682");
       lineView.underlineColorSelected = HEX_COLOR(@"#04020C");
       lineView.underlineColorFilled = HEX_COLOR(@"#717682");
       [lineView.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
           make.height.mas_equalTo(2);
           make.left.right.bottom.offset(0);
       }];
       lineView.selectChangeBlock = ^(CRLineView * _Nonnull lineView, BOOL selected) {
           if (selected) {
               [lineView.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                   make.height.mas_equalTo(2);
               }];
           } else {
               [lineView.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                   make.height.mas_equalTo(2);
               }];
           }
       };
       return lineView;
   };
   self.pswInputView.inputType = CRInputType_Number;
   self.pswInputView.ifNeedSecurity = YES;
   [self.pswInputView resetCodeLength:6 beginEdit:NO];
   self.pswInputView.customCellProperty = cellProperty;
   [self.pswInputView loadAndPrepareViewWithBeginEdit:YES];
   self.pswInputView.textDidChangeblock = ^(NSString *text, BOOL isFinished) {
       if(isFinished)
       {
           [self checkPsw];
       }
   };
}
- (IBAction)nextAction:(id)sender {
    [self checkPsw];
}

- (void)checkPsw
{
   if(![self.pswInputView.textValue isEqualToString:self.password])
   {
       [UserInfo showTips:nil des:@"密码不一致，请重新输入".lv_localized];
       return;
   }
    
    [[TelegramManager shareInstance] setWalletPayPassword:self.password oldPassword:nil resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [self setDone];
    } timeout:^(NSDictionary *request) {
        
    }];
}


- (void)setDone {
    GC_SetPwResultVC *vc = [[GC_SetPwResultVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:vc animated:YES completion:nil];
    
    for (vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GC_SetPwInputPwAgainVC class]] || [vc isKindOfClass:[GC_SetPwInputNewPwVC class]]) {
            [vc removeFromParentViewController];
        }
    }
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
