//
//  CreateGroupRedPacketViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/4/6.
//

#import "CreateGroupRedPacketViewController.h"
#import "GotWpPasswordDialog.h"



@interface CreateGroupRedPacketViewController ()<UITextFieldDelegate, GotWpPasswordDialogDelegate>
//0-拼手气红包 1-普通红包
@property (nonatomic) int curType;
@property (nonatomic, weak) IBOutlet UILabel *binGoTypeLabel;
@property (nonatomic, weak) IBOutlet UILabel *nomalTypeLabel;
//0-拼手气红包为总金额 1-普通红包为单个金额
@property (nonatomic, weak) IBOutlet UILabel *priceTitleLabel;

@property (nonatomic, weak) IBOutlet UITextField *numberTf;
@property (nonatomic, weak) IBOutlet UITextField *priceTf;
@property (nonatomic, weak) IBOutlet UITextView *desTv;
@property (nonatomic, weak) IBOutlet UIButton *goBtn;

@property (nonatomic, strong) RedPacketInfo *curCommitRpInfo;

@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic) float tipViewHeight;
@end

@implementation CreateGroupRedPacketViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"发红包".lv_localized];
    //背景
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self resetTypeUI];
    
    //button样式
    [self.goBtn setBackgroundImage:[Common createImageWithColor:HEX_COLOR(@"#D94545") size:self.goBtn.frame.size] forState:UIControlStateNormal];
    [self.goBtn setBackgroundImage:[Common createImageWithColor:UIColor.systemGrayColor size:self.goBtn.frame.size] forState:UIControlStateDisabled];
    self.goBtn.enabled = NO;
    
    //内容变化检测
    [self.numberTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.priceTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self check];
    
    //价格
    self.priceTf.delegate = self;
    
    //错误提示
    self.tipViewHeight = 0;
    self.tipView = [[[UINib nibWithNibName:@"CreateTip" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    self.tipLabel = [self.tipView viewWithTag:1];
}

- (void)resetTypeUI
{
    //0-拼手气红包为总金额 1-普通红包为单个金额
    if(self.curType == 0)
    {
        self.binGoTypeLabel.textColor = HEX_COLOR(@"#D94545");
        self.nomalTypeLabel.textColor = HEX_COLOR(@"#333333");
        self.binGoTypeLabel.font = [UIFont systemFontOfSize:17];
        self.nomalTypeLabel.font = [UIFont systemFontOfSize:15];
        self.priceTitleLabel.text = @"总金额".lv_localized;
    }
    else
    {
        self.binGoTypeLabel.textColor = HEX_COLOR(@"#333333");
        self.nomalTypeLabel.textColor = HEX_COLOR(@"#D94545");
        self.binGoTypeLabel.font = [UIFont systemFontOfSize:15];
        self.nomalTypeLabel.font = [UIFont systemFontOfSize:17];
        self.priceTitleLabel.text = @"单个金额".lv_localized;
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *toString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (toString.length > 0)
    {
        NSString *stringRegex = @"(\\+|\\-)?(([0]|(0[.]\\d{0,2}))|([1-9]\\d{0,4}(([.]\\d{0,2})?)))?";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
        BOOL flag = [phoneTest evaluateWithObject:toString];
        if (!flag)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 内容变化检测
- (void)textFieldDidChange:(UITextField *)theTextField
{
    [self check];
}

- (void)check
{
    //检测红包个数
    NSString *numberStr = self.numberTf.text;
    if (![CZCommonTool deptNumInputShouldNumber:numberStr]) {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包数量".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    numberStr = [numberStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(numberStr.length<=0)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 0;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    int number = [numberStr intValue];
    if(number<=0)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包数量".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if(number>1000)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"红包个数最多1000个".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    //检测红包金额
    NSString *priceStr = self.priceTf.text;
    priceStr = [priceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(priceStr.length<=0)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 0;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    float price = [priceStr floatValue];
    if(price<=0.0f)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包金额".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if(self.curType == 0)
    {//0-拼手气红包
        if(price/number<0.01f)
        {
            self.goBtn.enabled = NO;
            self.tipViewHeight = 40;
            self.tipLabel.text = @"单个红包金额不能小于0.01元".lv_localized;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        if(price/number>10000.0f)
        {
            self.goBtn.enabled = NO;
            self.tipViewHeight = 40;
            self.tipLabel.text = @"单个红包金额不能大于10000元".lv_localized;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
    else
    {//普通红包
        if(price>10000.0f)
        {
            self.goBtn.enabled = NO;
            self.tipViewHeight = 40;
            self.tipLabel.text = @"单个红包金额不能大于10000元".lv_localized;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
    self.tipViewHeight = 0;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    self.goBtn.enabled = YES;
}

#pragma mark - click
- (IBAction)click_BinGoType:(id)sender
{//0-拼手气红包
    self.curType = 0;
    [self resetTypeUI];
    [self check];
}

- (IBAction)click_NormalType:(id)sender
{//1-普通红包
    self.curType = 1;
    [self resetTypeUI];
    [self check];
}

- (IBAction)click_go:(id)sender
{
    //红包个数
    NSString *numberStr = self.numberTf.text;
    numberStr = [numberStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(numberStr.length<=0)
    {
        [self check];
        [UserInfo showTips:self.view des:@"请输入红包个数".lv_localized];
        return;
    }
    int number = [numberStr intValue];
    if(number<=0)
    {
        [UserInfo showTips:self.view des:@"请输入红包个数".lv_localized];
        return;
    }
    
    //金额
    NSString *priceStr = self.priceTf.text;
    priceStr = [priceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(priceStr.length<=0)
    {
        [self check];
        [UserInfo showTips:self.view des:self.curType==0?@"请输入红包总金额".lv_localized:@"请输入红包单个金额".lv_localized];
        return;
    }
    float price = [priceStr floatValue];
    if(price<=0.0f)
    {
        [self check];
        [UserInfo showTips:self.view des:self.curType==0?@"请输入红包总金额".lv_localized:@"请输入红包单个金额".lv_localized];
        return;
    }
    if(self.curType == 0)
    {//0-拼手气红包
        if(price/number<0.01f)
        {
            [self check];
            [UserInfo showTips:self.view des:@"红包总金额过小，不能发红包".lv_localized];
            return;
        }
    }
    
    //描述
    NSString *desStr = self.desTv.text;
    desStr = [desStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(desStr.length<=0)
    {
        desStr = @"恭喜发财, 大吉大利".lv_localized;
    }
    
    RedPacketInfo *info = [RedPacketInfo new];
    info.chatId = [ChatInfo toServerPeerId:self.chatId];
    info.title = desStr;
    info.count = number;
    //1.单聊红包 2.拼手气红包 3.普通红包
    if(self.curType == 0)
    {//手气红包
        info.type = 2;
        info.price = price/number;
        info.total_price = price;
    }
    else
    {//普通红包
        info.type = 3;
        info.price = price;
        info.total_price = price*info.count;
    }
    self.curCommitRpInfo = info;
    
    //查询余额
    [UserInfo show];
    [[TelegramManager shareInstance] queryWalletInfo:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if(obj != nil)
        {
            if([obj isKindOfClass:[WalletInfo class]])
            {
                WalletInfo *info = obj;
                if(!info.hasPaymentPassword)
                {
                    [self tipSetWalletPaymentPasswordDialog];
                }
                else
                {
                    if(info.balance<self.curCommitRpInfo.total_price)
                    {//余额不足
                        [UserInfo showTips:nil des:@"钱包余额不足，请前往余额中心充值".lv_localized];
                    }
                    else
                    {
                        //输入支付密码
                        GotWpPasswordDialog *dialog = [[GotWpPasswordDialog alloc] initDialog:nil payPrice:self.curCommitRpInfo.total_price paymentType:PAYMENT_TYPE_GROUP_RED_PACKET];
                        dialog.delegate = self;
                        [dialog show];
                    }
                }
            }
            else if([obj isKindOfClass:[NSNumber class]])
            {
                if([obj intValue] == 400)
                {//尚未开户，需要设置支付密码开通
                    [self tipSetWalletPaymentPasswordDialog];
                }
                else
                {
                    [UserInfo showTips:nil des:@"请求失败，请稍后重试".lv_localized];
                }
            }
            else
            {
                [UserInfo showTips:nil des:@"请求失败，请稍后重试".lv_localized];
            }
        }
        else
        {
            [UserInfo showTips:nil des:@"请求失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"请求超时，请稍后重试".lv_localized];
    }];
}

- (void)tipSetWalletPaymentPasswordDialog
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    //发红包
    NSArray *items = @[MMItemMake(@"设置".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"尚未设置支付密码，现在去设置？".lv_localized items:items];
    view.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//设置支付密码
            GC_SetPwInputNewPwVC *v = [[GC_SetPwInputNewPwVC alloc] init];
            [self.navigationController pushViewController:v animated:YES];
            
        }
    };
    [view show];
}

- (void)tipPaymentInvalidDialog
{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 0)
        {
            //输入支付密码
            GotWpPasswordDialog *dialog = [[GotWpPasswordDialog alloc] initDialog:nil payPrice:self.curCommitRpInfo.total_price paymentType:PAYMENT_TYPE_GROUP_RED_PACKET];
            dialog.delegate = self;
            [dialog show];
        }
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"支付密码错误，重新输入？".lv_localized items:items];
    [view show];
}

- (void)GotWpPasswordDialog_withPassword:(NSString *)password
{
    self.curCommitRpInfo.password = [Common md5:password];
    [self createRp];
}

- (void)createRp
{
    [UserInfo show];
    [[TelegramManager shareInstance] createRp:self.curCommitRpInfo resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if(obj != nil)
        {
            int code = [obj intValue];
            if(200 == code)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
//            400:余额少于红包总金额
//            401:红包数量大于1000
//            402:单个红包金额少于0.01
//            403:单个红包金额大于200
            else if(400 == code)
            {
                //todo wangyutao
                [UserInfo showTips:nil des:@"钱包余额不足，请前往余额中心充值".lv_localized];
            }
            else if(401 == code)
            {
                [UserInfo showTips:nil des:@"红包个数最多1000个".lv_localized];
            }
            else if(402 == code)
            {
                [UserInfo showTips:nil des:@"单个红包金额不能小于0.01元".lv_localized];
            }
            else if(403 == code)
            {
                [UserInfo showTips:nil des:@"单个红包金额不能大于10000元".lv_localized];
            }
            else if(404 == code)
            {
                [self tipPaymentInvalidDialog];
            }
            else
            {
                [UserInfo showTips:nil des:@"红包创建失败，请稍后再试".lv_localized];
            }
        }
        else
        {
            [UserInfo showTips:nil des:@"红包创建失败，请稍后再试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"红包创建超时，请稍后再试".lv_localized];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return self.tipViewHeight;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return self.tipView;
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 5)
    {
        CGFloat top = kNavBarAndStatusBarHeight + kBottomSafeHeight;
        return SCREEN_HEIGHT-top-45.0f-75.0f-75.0f-100.0f-100.0f-40.0f;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
