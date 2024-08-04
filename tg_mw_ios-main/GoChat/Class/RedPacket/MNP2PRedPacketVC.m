//
//  MNP2PRedPacketVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNP2PRedPacketVC.h"
#import "GotWpPasswordDialog.h"
#import "MNRedTvCell.h"
#import "MNRedTfCell.h"
#import "MNRedBtnCell.h"
#import "MNRedLabCell.h"
#import "MNRedFristTfCell.h"
#import "MNP2PRedPacketVC.h"

@interface MNP2PRedPacketVC ()
<GotWpPasswordDialogDelegate>

@property (nonatomic, strong) UITextField *priceTf;
@property (nonatomic, strong) UITextView *desTv;
@property (nonatomic, strong) UIButton *goBtn;

@property (nonatomic, strong) RedPacketInfo *curCommitRpInfo;

@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic) float tipViewHeight;
@end

@implementation MNP2PRedPacketVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"发红包".lv_localized];
//    self.customNavBar.frame = CGRectMake(0, -APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH, 88);

    //背景
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    //button样式
    [self.goBtn setBackgroundImage:[Common createImageWithColor:HEX_COLOR(@"#D94545") size:self.goBtn.frame.size] forState:UIControlStateNormal];
    [self.goBtn setBackgroundImage:[Common createImageWithColor:UIColor.systemGrayColor size:self.goBtn.frame.size] forState:UIControlStateDisabled];
    self.goBtn.enabled = NO;
    
    //内容变化检测
    [self.priceTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self check];
    
    //错误提示
    self.tipViewHeight = 0;
    self.tipView = [[[UINib nibWithNibName:@"CreateTip" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    self.tipLabel = [self.tipView viewWithTag:1];
}

#pragma mark - 内容变化检测
- (void)textFieldDidChange:(UITextField *)theTextField
{
    [self check];
}

- (void)check
{
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
    double price = [priceStr doubleValue];
    if(price<=0.0f)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包金额".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if(price<0.01f)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"红包金额不能小于0.01元".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if(price>10000.0f)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"红包金额不能大于10000元".lv_localized;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    
    self.tipViewHeight = 0;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    self.goBtn.enabled = YES;
}

#pragma mark - click
- (void)click_go:(id)sender
{
    //金额
    NSString *priceStr = self.priceTf.text;
    priceStr = [priceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(priceStr.length<=0)
    {
        [self check];
        [UserInfo showTips:self.view des:@"请输入红包金额".lv_localized];
        return;
    }
    double price = [priceStr doubleValue];
    if(price<=0.0f)
    {
        [self check];
        [UserInfo showTips:self.view des:@"请输入红包金额".lv_localized];
        return;
    }

    //描述
    NSString *desStr = self.desTv.text;
    desStr = [desStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(desStr.length<=0)
    {
        desStr = @"恭喜发财, 大吉大利".lv_localized;
    }
    
    RedPacketInfo *info = [RedPacketInfo new];
    info.chatId = self.chatId;
    info.title = desStr;
    info.count = 1;
    info.type = 1;
    info.price = price;
    info.total_price = price;
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
                        GotWpPasswordDialog *dialog = [[GotWpPasswordDialog alloc] initDialog:nil payPrice:self.curCommitRpInfo.total_price paymentType:PAYMENT_TYPE_RED_PACKET];
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
    //1对1发红包
    NSArray *items = @[MMItemMake(@"设置".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"尚未设置支付密码，现在去设置？".lv_localized items:items];
    view.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//设置支付密码
            GC_SetPwInputNewPwVC *vc = [[GC_SetPwInputNewPwVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
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
            GotWpPasswordDialog *dialog = [[GotWpPasswordDialog alloc] initDialog:nil payPrice:self.curCommitRpInfo.total_price paymentType:PAYMENT_TYPE_RED_PACKET];
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
                [UserInfo showTips:nil des:@"红包金额不能小于0.01元".lv_localized];
            }
            else if(403 == code)
            {
                [UserInfo showTips:nil des:@"红包金额不能大于10000元".lv_localized];
            }
            else if(404 == code)
            {
                [self tipPaymentInvalidDialog];
            }
            else if(501 == code)
            {
                [UserInfo showTips:nil des:@"对方把你加入了黑名单，不能发红包".lv_localized];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

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
    if (indexPath.row == 0) {
        return 75;
    }else if (indexPath.row == 1){
        return 85;
    }else if(indexPath.row == 2){
        return 125;
    }else if (indexPath.row == 3){
        return APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34()-(75+85+125);
    }
    return 0;
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   if(indexPath.row == 0){
        static NSString *cellId = @"MNRedTfCell";
        MNRedTfCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNRedTfCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            self.priceTf = cell.tf;
        }
      
        return cell;
    }else if (indexPath.row == 1){
        static NSString *cellId = @"MNRedTvCell";
        MNRedTvCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNRedTvCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            self.desTv = cell.tv;
        }
        return cell;
    }else if(indexPath.row == 2){
        static NSString *cellId = @"MNRedBtnCell";
        MNRedBtnCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNRedBtnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            self.goBtn = cell.btn;
            [self.goBtn addTarget:self action:@selector(click_go:) forControlEvents:UIControlEventTouchUpInside];
        }
        return cell;
    }else if (indexPath.row == 3){
        static NSString *cellId = @"MNRedLabCell";
        MNRedLabCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNRedLabCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];;
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
