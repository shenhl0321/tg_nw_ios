//
//  GC_ChangeAccountInfoVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_ChangeAccountInfoVC.h"

@interface GC_ChangeAccountInfoVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *renameView;
@property (weak, nonatomic) IBOutlet UITextField *renameTF;
@property (weak, nonatomic) IBOutlet UILabel *accountLab;
@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end

@implementation GC_ChangeAccountInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    self.contentView.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}
- (void)initUI{
    [self.customNavBar setTitle:@"提现账户".lv_localized];
    self.renameTF.delegate = self;
    self.accountTF.delegate = self;
    [self.saveBtn setBackgroundColor:[UIColor colorMain]];
    [self.saveBtn setTitle:@"保存".lv_localized forState:UIControlStateNormal];
    self.saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
    
}
- (IBAction)saveAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
