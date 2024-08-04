//
//  GC_SetPwInputNewPwVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "GC_SetPwInputNewPwVC.h"
#import "GC_SetPwInputPwAgainVC.h"

@interface GC_SetPwInputNewPwVC ()
@property (weak, nonatomic) IBOutlet CRBoxInputView *pswInputView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation GC_SetPwInputNewPwVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isChange) {
      
        [self.customNavBar setTitle:@"重置支付密码".lv_localized];
    }else{
    
        [self.customNavBar setTitle:@"支付密码".lv_localized];
    }
    self.contentView.hidden = YES;
    self.nextBtn.clipsToBounds = YES;
    self.nextBtn.layer.cornerRadius = 13;
    self.nextBtn.backgroundColor = [UIColor colorMain];
    //验证码视图样式
    [self setPswInputUI];
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
            [self checkPsw:text];
        }
    };
}

- (void)checkPsw:(NSString *)psw
{
    [self nextAction:nil];
}

- (IBAction)nextAction:(id)sender {
    
    GC_SetPwInputPwAgainVC *v = [[GC_SetPwInputPwAgainVC alloc] init];
    v.smsCode = self.smsCode;
    v.oldpwdstr = self.oldpwdstr;
    v.password = self.pswInputView.textValue;
    [self.navigationController pushViewController:v animated:YES];
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
