//
//  GC_MyWalletVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/5.
//

#import "GC_MyWalletVC.h"
#import "GC_MyWalletCell.h"
#import "GC_MyWalletTopCell.h"

#import "GC_CollectionCode.h"
#import "GC_TransactionRecordVC.h"
#import "GC_RedRecordVC.h"
#import "GC_CashAccountVC.h"
//#import "GC_CashOutVC.h"
//#import "GC_RechargeVC.h"
#import "GotWpPasswordDialog.h"
#import "GC_SetPswCodeVC.h"

@interface GC_MyWalletVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UILabel *walletPriceLabel;
@property (nonatomic, strong)NSArray *dataArr;
@property (nonatomic, strong)WalletInfo *walletInfo;
@property (nonatomic) BOOL isTipSetPassword;

@end


@implementation GC_MyWalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"钱包".lv_localized];
    [self initUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self syncWalletInfo];
}
- (NSArray *)dataArr{
    if (!_dataArr) {
        AppConfigInfo *config = [AppConfigInfo sharedInstance];
        NSMutableArray *arr = [NSMutableArray array];
        if (config.can_see_wallet_records) {
            [arr addObject:@{@"title": @"交易记录".lv_localized, @"image": @"icon_wallet_record"}];
        }
        [arr addObject:@{@"title": @"红包记录".lv_localized, @"image": @"icon_wallet_red"}];
        [arr addObject:@{@"title": @"支付密码".lv_localized, @"image": @"icon_wallet_pay"}];
        _dataArr = arr;
    }
    return _dataArr;
}

- (void)initUI{
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MyWalletCell" bundle:nil] forCellReuseIdentifier:@"GC_MyWalletCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MyWalletTopCell" bundle:nil] forCellReuseIdentifier:@"GC_MyWalletTopCell"];
    self.tableView.rowHeight = 44;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count + 1;
}
- (void)toOnlineUserService
{
    [UserInfo show];
    [[TelegramManager shareInstance] getOnlineUserService:^(NSDictionary *request, NSDictionary *response, id obj) {
        if([obj isKindOfClass:[NSNumber class]])
        {
            [UserInfo dismiss];
            [self toChatView:[obj longValue]];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取客服信息失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"获取客服信息失败，请稍后重试".lv_localized];
    }];
}
- (void)toChatView:(long)userId
{
    if([[TelegramManager shareInstance] contactInfo:userId] != nil)
    {
        [[TelegramManager shareInstance] createPrivateChat:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:ChatInfo.class])
            {
                [AppDelegate gotoChatView:obj];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    else
    {
        [UserInfo show];
        [[TelegramManager shareInstance] requestContactInfo:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            [UserInfo dismiss];
            [[TelegramManager shareInstance] createPrivateChat:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                {
                    [AppDelegate gotoChatView:obj];
                }
            } timeout:^(NSDictionary *request) {
            }];
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"请求超时，请稍后重试".lv_localized];
        }];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        GC_MyWalletTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MyWalletTopCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *rechargeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rechargeAction)];
        [cell.rechargeView addGestureRecognizer:rechargeTap];
//        cell.rechargeView.hidden = YES;
//        cell.cashOutView.hidden = YES;
        UITapGestureRecognizer *cashTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cashAction)];
        [cell.cashOutView addGestureRecognizer:cashTap];
        self.walletPriceLabel = cell.priceLab;
        [self priceAttributedUnit:@"￥" price:[Common priceFormat:self.walletInfo.balance] priceLabel:self.walletPriceLabel];
        return cell;
    }
    GC_MyWalletCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MyWalletCell"];
    cell.dataDic = self.dataArr[indexPath.row - 1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 190;
    }
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *list = self.dataArr[indexPath.row - 1];
    NSString *title = list[@"title"];
    if ([title isEqualToString:@"二维码收款".lv_localized]) {
        GC_CollectionCode *vc = [[GC_CollectionCode alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"交易记录".lv_localized]) {
        GC_TransactionRecordVC *vc = [[GC_TransactionRecordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"红包记录".lv_localized]) {
        GC_RedRecordVC *vc = [[GC_RedRecordVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"支付密码".lv_localized]) {
        GC_SetPswCodeVC *vc = [[GC_SetPswCodeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"提现账户".lv_localized]) {
        GC_CashAccountVC *vc = [[GC_CashAccountVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)rechargeAction{
    
    [self toOnlineUserService];
    [UserInfo show];
//    [[TelegramManager shareInstance] WalletRechargeRequest:^(NSDictionary *request, NSDictionary *response, id obj) {
//        [UserInfo dismiss];
//        if(obj != nil && [obj isKindOfClass:[WalletRechargeRes class]])
//        {
//            WalletRechargeRes *info = obj;
//            if(!IsStrEmpty(info.payUrl))
//            {
////                GC_RechargeVC *vc = [[GC_RechargeVC alloc] init];
////                [self.navigationController pushViewController:vc animated:YES];
//            }
//            else
//            {
//                [self tipRechargeToKefuDialog:info.csUserId];
//            }
//        }
//    } timeout:^(NSDictionary *request) {
//        [UserInfo dismiss];
//        [UserInfo showTips:nil des:@"请求超时，请稍后重试".lv_localized];
//    }];
    
}
- (void)cashAction{
//    GC_CashOutVC *vc = [[GC_CashOutVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)syncWalletInfo
{
    //请求钱包信息
    [[TelegramManager shareInstance] queryWalletInfo:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[WalletInfo class]])
        {
            WalletInfo *info = obj;
            [self priceAttributedUnit:@"￥" price:[Common priceFormat:info.balance] priceLabel:self.walletPriceLabel];
            if(!info.hasPaymentPassword)
            {
                if(!self.isTipSetPassword)
                {
                    self.isTipSetPassword = YES;
                    [self tipSetWalletPaymentPasswordDialog];
                }
            }
        }
        if(obj != nil && [obj isKindOfClass:[NSNumber class]])
        {
            if([obj intValue] == 400)
            {//尚未开户，需要设置支付密码开通
                if(!self.isTipSetPassword)
                {
                    self.isTipSetPassword = YES;
                    [self tipSetWalletPaymentPasswordDialog];
                }
            }
        }
    } timeout:^(NSDictionary *request) {
        //超时，不做处理
    }];
}

- (void)tipSetWalletPaymentPasswordDialog
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    
    //进入 我的钱包
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

- (void)priceAttributedUnit:(NSString *)unitStr price:(NSString *)priceStr priceLabel:(UILabel *)priceLabel
{
    NSString *str = [NSString stringWithFormat:@"%@%@", unitStr, priceStr];
    NSMutableAttributedString *strAttr=[[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range_s = [str rangeOfString:priceStr];
    [strAttr addAttributes:@{NSFontAttributeName:[UIFont semiBoldCustomFontOfSize:40], NSForegroundColorAttributeName:[UIColor colorTextForFFFFFF]} range:range_s];
    
    NSRange range_u = [str rangeOfString:unitStr];
    [strAttr addAttributes:@{NSFontAttributeName:[UIFont semiBoldCustomFontOfSize:24], NSForegroundColorAttributeName:[UIColor colorTextForFFFFFF]} range:range_u];
    
    [priceLabel setAttributedText:strAttr];
}

- (IBAction)click_recharge:(id)sender
{
    
}

- (void)tipRechargeToKefuDialog:(long)kefuId
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示" detail:@"目前不存在充值平台，请联系客服进行充值".lv_localized items:items];
    view.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//跳转客服
            if([[TelegramManager shareInstance] contactInfo:kefuId] != nil)
            {
                [[TelegramManager shareInstance] createPrivateChat:kefuId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                    {
                        [AppDelegate gotoChatView:obj];
                    }
                } timeout:^(NSDictionary *request) {
                }];
            }
            else
            {
                [UserInfo show];
                [[TelegramManager shareInstance] requestContactInfo:kefuId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    [UserInfo dismiss];
                    [[TelegramManager shareInstance] createPrivateChat:kefuId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                        if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                        {
                            [AppDelegate gotoChatView:obj];
                        }
                    } timeout:^(NSDictionary *request) {
                    }];
                } timeout:^(NSDictionary *request) {
                    [UserInfo dismiss];
                    [UserInfo showTips:nil des:@"请求超时，请稍后重试".lv_localized];
                }];
            }
        }
    };
    [view show];
}


- (IBAction)payBtnClick:(UIButton *)sender {
    
    [[TelegramManager shareInstance] queryWalletInfo:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[WalletInfo class]])
        {
            WalletInfo *info = obj;
            if(info.hasPaymentPassword)
            {
                //输入支付密码
                GotWpPasswordDialog *dialog = [[GotWpPasswordDialog alloc] initDialog:nil payPrice:0.00 paymentType:PAYMENT_TYPE_GROUP_RED_PACKET];
                dialog.delegate = self;
                [dialog show];
                
            }else{
                GC_SetPwInputNewPwVC *vc = [[GC_SetPwInputNewPwVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        if(obj != nil && [obj isKindOfClass:[NSNumber class]])
        {
            if([obj intValue] == 400)
            {//尚未开户，需要设置支付密码开通
                GC_SetPwInputNewPwVC *vc = [[GC_SetPwInputNewPwVC alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    } timeout:^(NSDictionary *request) {
        //超时，不做处理
    }];
}

- (void)GotWpPasswordDialog_withPassword:(NSString *)password
{
    [self createRp:[Common md5:password]];
}

- (void)createRp:(NSString *)password
{
    [UserInfo show];
    [[TelegramManager shareInstance] checkWallerPassword:password resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if(obj){
            
            GC_SetPwInputNewPwVC *vc = [[GC_SetPwInputNewPwVC alloc] init];
            vc.isChange = YES;
            vc.oldpwdstr = password;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            [UserInfo showTips:nil des:@"支付密码错误，请重新输入".lv_localized];
            return;
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:self.view des:@"请求超时，请稍后重试".lv_localized];
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
