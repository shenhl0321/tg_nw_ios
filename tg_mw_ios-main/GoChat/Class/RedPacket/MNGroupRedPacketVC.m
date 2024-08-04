//
//  MNGroupRedPacketVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNGroupRedPacketVC.h"
#import "GotWpPasswordDialog.h"
#import "MNGroupSwitchCell.h"
#import "MNRedTvCell.h"
#import "MNRedTfCell.h"
#import "MNRedBtnCell.h"
#import "MNRedLabCell.h"
#import "MNRedFristTfCell.h"
#import "MNRedTfRow.h"
#import "MNRedTvRow.h"
#import "MNP2PRedPacketVC.h"

@interface MNGroupRedPacketVC ()
<UITextFieldDelegate, GotWpPasswordDialogDelegate>
//0-拼手气红包 1-普通红包
@property (nonatomic) int curType;
@property (nonatomic, strong) UILabel *binGoTypeLabel;
@property (nonatomic, strong) UILabel *nomalTypeLabel;
//0-拼手气红包为总金额 1-普通红包为单个金额
@property (nonatomic, strong) UILabel *priceTitleLabel;

@property (nonatomic, strong) UITextField *numberTf;
@property (nonatomic, strong) UITextField *priceTf;
@property (nonatomic, strong) UITextView *desTv;
@property (nonatomic, strong) UIButton *goBtn;

@property (nonatomic, strong) RedPacketInfo *curCommitRpInfo;

@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic) float tipViewHeight;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *pBtn;
@property (nonatomic, strong) UIButton *nBtn;

@end

@implementation MNGroupRedPacketVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"发红包".lv_localized];
    //背景
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    [self resetTypeUI];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view endEditing:YES];
}
- (void)initUI{
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.pBtn];
    [self.scrollView addSubview:self.nBtn];
    [self.pBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.height.mas_equalTo(47);
        make.width.mas_equalTo(125);
        make.left.mas_equalTo(15);
    }];
    [self.nBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pBtn);
        make.height.equalTo(self.pBtn);
        make.width.equalTo(self.pBtn);
        make.left.equalTo(self.pBtn.mas_right).with.offset(0);
    }];
    
    MNRedTfRow *countRow = [[MNRedTfRow alloc] initWithFrame:CGRectMake(15, 67, APP_SCREEN_WIDTH-15*2, 60)];
    countRow.leftLabel.text = @"红包个数".lv_localized;
    countRow.rightLabel.text = @"个".lv_localized;
    countRow.tf.placeholder = @"填写个数".lv_localized;
    countRow.tf.keyboardType = UIKeyboardTypeNumberPad;
    self.numberTf = countRow.tf;
    [self.scrollView addSubview:countRow];
    
    
    MNRedTfRow *priceRow = [[MNRedTfRow alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(countRow.frame)+15, APP_SCREEN_WIDTH-15*2, 60)];
    priceRow.leftLabel.text = @"金额".lv_localized;
    priceRow.rightLabel.text = @"元".lv_localized;
    priceRow.tf.placeholder = @"0.00".lv_localized;
    priceRow.tf.keyboardType = UIKeyboardTypeDecimalPad;
    self.priceTf = priceRow.tf;
    self.priceTitleLabel = priceRow.leftLabel;
    [self.scrollView addSubview:priceRow];
    
    MNRedTvRow *tvRow = [[MNRedTvRow alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(priceRow.frame)+15, APP_SCREEN_WIDTH-15*2, 70)];
    self.desTv = tvRow.tv;
    [self.scrollView addSubview:tvRow];
    
    UIButton *aBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aBtn.frame = CGRectMake(30, CGRectGetMaxY(tvRow.frame)+15, APP_SCREEN_WIDTH-30*2, 55);
    [aBtn mn_loginStyleWithBgColor:HexRGB(0xD94545)];
    [aBtn setTitle:@"塞钱进红包".lv_localized forState:UIControlStateNormal];
    UIImage *image = [UIImage imageWithColor:UIColor.systemGrayColor size:CGSizeMake(APP_SCREEN_WIDTH-2*30, 55)];
    [aBtn setBackgroundImage:image forState:UIControlStateDisabled];
    [aBtn addTarget:self action:@selector(click_go:) forControlEvents:UIControlEventTouchUpInside];
    self.goBtn = aBtn;
    [self.scrollView addSubview:aBtn];
    
    UILabel *tipLabel = [[UILabel alloc] init];;
    tipLabel.font = fontRegular(15);
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = [UIColor colorFor878D9A];
    tipLabel.text = @"未领取红包, 将于24小时后发起退款".lv_localized;
    [self.contentView addSubview:tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-15);
        make.height.mas_equalTo(21);
        make.centerY.mas_equalTo(0);
    }];

    
    //内容变化检测
    [self.numberTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.priceTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self check];
    
    //价格
    self.priceTf.delegate = self;
    
    //错误提示
    _tipViewHeight = 0;
    self.tipView = [[[UINib nibWithNibName:@"CreateTip" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    self.tipView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, 40);
    self.tipLabel = [self.tipView viewWithTag:1];
    [self.contentView insertSubview:self.tipView belowSubview:self.scrollView];
}

-(void)setTipViewHeight:(float)tipViewHeight{
    _tipViewHeight = tipViewHeight;
    self.scrollView.frame = CGRectMake(0, tipViewHeight, APP_SCREEN_WIDTH, ContentHeight-tipViewHeight);
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, ContentHeight)];
        _scrollView.userInteractionEnabled = YES;
        _scrollView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRec:)];;
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

- (void)tapRec:(UITapGestureRecognizer *)rec{
    [self.view endEditing:YES];
}

-(UIButton *)pBtn{
    if (!_pBtn) {
        _pBtn = [self createBtnWithTitle:@"拼手气红包".lv_localized];
        _pBtn.selected = YES;
        [_pBtn addTarget:self action:@selector(click_BinGoType:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pBtn;
}

-(UIButton *)nBtn{
    if (!_nBtn) {
        _nBtn = [self createBtnWithTitle:@"普通红包".lv_localized];
        [_nBtn addTarget:self action:@selector(click_NormalType:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nBtn;
}


- (UIButton *)createBtnWithTitle:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    NSRange range = NSMakeRange(0, title.length);
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:title];
    [str addAttribute:NSFontAttributeName value:fontSemiBold(19) range:range];
    [str addAttribute:NSForegroundColorAttributeName value:HexRGB(0xD94545) range:range];
    [btn setAttributedTitle:str forState:UIControlStateSelected];
    
    NSMutableAttributedString *strNoraml = [[NSMutableAttributedString alloc] initWithString:title];
    [strNoraml addAttribute:NSFontAttributeName value:fontRegular(16) range:range];
    [strNoraml addAttribute:NSForegroundColorAttributeName value:[UIColor colorTextFor23272A] range:range];
    [btn setAttributedTitle:strNoraml forState:UIControlStateNormal];
   
    return btn;
}

- (void)resetTypeUI
{
    //0-拼手气红包为总金额 1-普通红包为单个金额
    if(self.curType == 0)
    {
//        self.binGoTypeLabel.textColor = HEX_COLOR(@"#D94545");
//        self.nomalTypeLabel.textColor = HEX_COLOR(@"#333333");
//        self.binGoTypeLabel.font = [UIFont systemFontOfSize:17];
//        self.nomalTypeLabel.font = [UIFont systemFontOfSize:15];
        self.priceTitleLabel.text = @"总金额".lv_localized;
        self.pBtn.selected = YES;
        self.nBtn.selected = NO;
    }
    else
    {
//        self.binGoTypeLabel.textColor = HEX_COLOR(@"#333333");
//        self.nomalTypeLabel.textColor = HEX_COLOR(@"#D94545");
//        self.binGoTypeLabel.font = [UIFont systemFontOfSize:15];
//        self.nomalTypeLabel.font = [UIFont systemFontOfSize:17];
        self.priceTitleLabel.text = @"单个金额".lv_localized;
        self.nBtn.selected = YES;
        self.pBtn.selected = NO;
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
    NSLog(@"");
    [self check];
}

- (void)check
{
    //检测红包个数
//    self.goBtn.enabled =  YES;
//    return;;
    NSString *numberStr = self.numberTf.text;
    if (![CZCommonTool deptNumInputShouldNumber:numberStr]) {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包数量".lv_localized;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    numberStr = [numberStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(numberStr.length<=0)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 0;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    int number = [numberStr intValue];
    if(number<=0)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包数量".lv_localized;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if(number>1000)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"红包个数最多1000个".lv_localized;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    //检测红包金额
    NSString *priceStr = self.priceTf.text;
    priceStr = [priceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(priceStr.length<=0)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 0;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    float price = [priceStr floatValue];
    if(price<=0.0f)
    {
        self.goBtn.enabled = NO;
        self.tipViewHeight = 40;
        self.tipLabel.text = @"请输入有效的红包金额".lv_localized;
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        return;
    }
    if(self.curType == 0)
    {//0-拼手气红包
        if(price/number<0.01f)
        {
            self.goBtn.enabled = NO;
            self.tipViewHeight = 40;
            self.tipLabel.text = @"单个红包金额不能小于0.01元".lv_localized;
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        if(price/number>10000.0f)
        {
            self.goBtn.enabled = NO;
            self.tipViewHeight = 40;
            self.tipLabel.text = @"单个红包金额不能大于10000元".lv_localized;
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
    }
    self.tipViewHeight = 0;
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    self.goBtn.enabled = YES;
}

#pragma mark - click
- (void)click_BinGoType:(id)sender
{//0-拼手气红包
    self.curType = 0;
    [self resetTypeUI];
    [self check];
}

- (void)click_NormalType:(id)sender
{//1-普通红包
    self.curType = 1;
    [self resetTypeUI];
    [self check];
}

- (void)click_go:(id)sender
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
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if(section == 0)
//        return self.tipViewHeight;
//    return 0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if(section == 0)
//        return self.tipView;
//    return nil;
//}
//
//
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 6;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 0) {
//        return 60;
//    }else if (indexPath.row == 1){
//        return 75;
//    }else if(indexPath.row == 2){
//        return 75;
//    }else if (indexPath.row == 3){
//        return 85;
//    }else if (indexPath.row == 4){
//        return 125;
//    }else if(indexPath.row == 5){
//        return APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34()- (60+75+75+85+125);
//    }
//
//    return 0;
//
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//   if(indexPath.row == 0){
//       static NSString *cellId = @"MNGroupSwitchCell";
//       MNGroupSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//       if (!cell) {
//           cell = [[MNGroupSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//           self.nomalTypeLabel= cell.rightLabel;
//           self.binGoTypeLabel = cell.leftLabel;
//           [cell.leftBtn addTarget:self action:@selector(click_BinGoType:) forControlEvents:UIControlEventTouchUpInside];
//           [cell.rightBtn addTarget:self action:@selector(click_NormalType:) forControlEvents:UIControlEventTouchUpInside];
//           [self resetTypeUI];
//       }
//
//       return cell;
//    }else if (indexPath.row == 1){
//        static NSString *cellId = @"MNRedFristTfCell";
//        MNRedFristTfCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        if (!cell) {
//            cell = [[MNRedFristTfCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            self.numberTf = cell.tf;
////            self.numberTf.delegate = self;
//            //内容变化检测
//            [self.numberTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//
//            [self check];
//        }
//
//        return cell;
//
//    }else if(indexPath.row == 2){
//        static NSString *cellId = @"MNRedTfCell";
//        MNRedTfCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        if (!cell) {
//            cell = [[MNRedTfCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            self.priceTf = cell.tf;
//            //价格
//            self.priceTf.delegate = self;
//            self.priceTitleLabel = cell.leftLabel;
//            [self.priceTf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
//        }
//
//        return cell;
//
//    }else if (indexPath.row == 3){
//        static NSString *cellId = @"MNRedTvCell";
//        MNRedTvCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        if (!cell) {
//            cell = [[MNRedTvCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            self.desTv = cell.tv;
//        }
//        return cell;
//
//    }else if(indexPath.row == 4){
//        static NSString *cellId = @"MNRedBtnCell";
//        MNRedBtnCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        if (!cell) {
//            cell = [[MNRedBtnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            self.goBtn = cell.btn;
//            [self.goBtn addTarget:self action:@selector(click_go:) forControlEvents:UIControlEventTouchUpInside];
//            //button样式
////#D94545
////            [self.goBtn setBackgroundImage:[Common createImageWithColor:HEX_COLOR(@"#D94545") size:self.goBtn.frame.size] forState:UIControlStateNormal];
////            [self.goBtn setBackgroundImage:[Common createImageWithColor:UIColor.systemGrayColor size:self.goBtn.frame.size] forState:UIControlStateDisabled];
////            self.goBtn.enabled = NO;
//        }
//        return cell;
//    }else if(indexPath.row == 5){
//        static NSString *cellId = @"MNRedLabCell";
//        MNRedLabCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//        if (!cell) {
//            cell = [[MNRedLabCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//        }
//        return cell;
//    }
//
//    return [super tableView:tableView cellForRowAtIndexPath:indexPath];;
//}
//
//-(UITableViewStyle)style{
//    return UITableViewStylePlain;
//}
@end
