//
//  GC_AccountSafeVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_AccountSafeVC.h"
#import "DeviceListVC.h"
#import "CloseAccountVC.h"

#import "GC_MySetCell.h"
#import "GC_MySetSwitchCell.h"
#import "GC_MySetDesCell.h"
#import "SettingHelper.h"
#import "CZReSetPwdViewController.h"
#import "QTChangeLoginPasswordVC.h"
#import "GC_AccountSafeHeadView.h"


@interface GC_AccountSafeVC ()

@property (nonatomic, strong)NSArray *dataArr;

/// 账号离线清除数据天数
@property (nonatomic, copy) NSNumber *accountTtlDay;
/// 允许多端登录
@property (nonatomic, assign, getter=isAllowedMultipleOnline) BOOL allowedMultipleOnline;

@property (strong, nonatomic) GC_AccountSafeHeadView *headView;

@end


@implementation GC_AccountSafeVC

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self getAccountTtl];
    [self getAccountMultiOnline];
}

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@"修改密码".lv_localized, @"登录的设备".lv_localized, @"允许多端登录".lv_localized, @"账号离线".lv_localized];
    }
    return _dataArr;
}

- (void)initUI{
    [self.customNavBar setTitle:@"安全".lv_localized];
    self.customNavBar.backgroundColor = [UIColor blackColor];
    self.customNavBar.titleLabel.textColor = [UIColor whiteColor];
    [self.customNavBar setLeftBtnWithImageName:@"NavBackWhite" title:@"" highlightedImageName:@"NavBackWhite"];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.bounces = NO;
    self.tableView.tableHeaderView = self.headView;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetSwitchCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetSwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetDesCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetDesCell"];
    
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(0);
    }];
//    self.view.backgroundColor = self.tableView.backgroundColor;
}

- (void)getAccountTtl {
    [SettingHelper getAccountTtl:^(NSNumber * _Nonnull days) {
        self.accountTtlDay = days;
        [self.tableView reloadData];
    }];
}

- (void)getAccountMultiOnline {
    [SettingHelper getAccountMultiOnline:^(BOOL success) {
        self.allowedMultipleOnline = success;
        [self.tableView reloadData];
    }];
}

- (void)setAccountTtl:(NSNumber *)day {
    [SettingHelper setAccountTtl:day completion:^(BOOL success) {
        if (success) {
            self.accountTtlDay = day;
            [self.tableView reloadData];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *text = self.dataArr[indexPath.section];
    if ([text isEqualToString:@"允许多端登录".lv_localized]) {
        GC_MySetSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetSwitchCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLab.text = text;
        cell.openSwitch.onTintColor = HEXCOLOR(0x08CF98);
        cell.openSwitch.on = self.isAllowedMultipleOnline;
        [cell.openSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    if ([text isEqualToString:@"账号离线".lv_localized]) {
        GC_MySetDesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetDesCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLab.text = text;
        cell.contentLab.text = [self dayTextWithDays:self.accountTtlDay];
        cell.desLab.text = @"如果在此期间您的账号未曾上线，您账户的所有资料--包括消息记录、联系人都会被删除".lv_localized;
        return cell;
    }
    
    GC_MySetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLab.text = text;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == self.dataArr.count - 1) {
        return 90;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    view.backgroundColor = self.tableView.backgroundColor;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = self.dataArr[indexPath.section];
    if ([text isEqualToString:@"账号离线".lv_localized]) {
        [self accountOffline];
        return;
    } else if ([text isEqualToString:@"登录的设备".lv_localized]) {
        DeviceListVC *device = [[DeviceListVC alloc] init];
        [self.navigationController pushViewController:device animated:YES];
    } else if ([text isEqualToString:@"注销账号".lv_localized]) {
        CloseAccountVC *close = [[CloseAccountVC alloc] init];
        [self.navigationController pushViewController:close animated:YES];
    } else if ([text isEqualToString:@"修改密码".lv_localized]) {
        [self judgeHasPassWord];
    }
}

- (void)switchValueChanged:(UISwitch *)sender {
    [SettingHelper setAccountMultiOnline:sender.isOn completion:^(BOOL success) {
        if (!success) {
            return;
        }
        self.allowedMultipleOnline = sender.isOn;
        [self.tableView reloadData];
    }];
}

- (void)accountOffline {
    NSArray *titles = @[@"一个月".lv_localized, @"三个月".lv_localized, @"半年".lv_localized, @"一年".lv_localized];
    NSArray *days = @[@30, @90, @180, @365];
    NSMutableArray *items = NSMutableArray.array;
    for (NSString *title in titles) {
        MMItemType type = [title isEqualToString:[self dayTextWithDays:self.accountTtlDay]] ? MMItemTypeHighlight : MMItemTypeNormal;
        MMPopupItem *item = MMItemMake(title, type, ^(NSInteger index) {
            [self setAccountTtl:days[index]];
        });
        item.color = UIColor.colorMain;
        [items addObject:item];
    }
    MMSheetView *sheet = [[MMSheetView alloc] initWithTitle:nil items:items];
    [sheet show];
}

- (NSString *)dayTextWithDays:(NSNumber *)days {
    switch (days.intValue) {
        case 30:
            return @"一个月".lv_localized;
        case 90:
            return @"三个月".lv_localized;
        case 180:
            return @"半年".lv_localized;
        case 365:
            return @"一年".lv_localized;
        default:
            return @"";
    }
}
//是否有密码
- (void)judgeHasPassWord{
    [UserInfo show];
    [[TelegramManager shareInstance] checkHasLoginPasswordResultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if (obj) {
            NSDictionary *dic = (NSDictionary *)obj;
            BOOL    hasPwd = [[[dic objectForKey:@"data"] objectForKey:@"hasPassword"] boolValue];
//            CZReSetPwdViewController *vc = [CZReSetPwdViewController new];
//            vc.hasPwd = hasPwd;
//            [self.navigationController pushViewController:vc animated:YES];
            
            QTChangeLoginPasswordVC *vc = [[QTChangeLoginPasswordVC alloc] init];
            vc.hasPwd = hasPwd;
            vc.successBlock = ^{
                //
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            };
//            [self.navigationController pushViewController:vc animated:YES];
            [self presentViewController:vc animated:YES completion:nil];
        }
        
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
//        CZReSetPwdViewController *vc = [CZReSetPwdViewController new];
//        vc.hasPwd = YES;
//        [self.navigationController pushViewController:vc animated:YES];
        
        QTChangeLoginPasswordVC *vc = [[QTChangeLoginPasswordVC alloc] init];
        vc.hasPwd = YES;
        vc.successBlock = ^{
            //
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        };
//        [self.navigationController pushViewController:vc animated:YES];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}
- (GC_AccountSafeHeadView *)headView{
    if (!_headView){
        _headView = [[NSBundle mainBundle] loadNibNamed:@"GC_AccountSafeHeadView" owner:nil options:nil].firstObject;
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.6 * SCREEN_WIDTH);
    }
    return _headView;
}

@end


