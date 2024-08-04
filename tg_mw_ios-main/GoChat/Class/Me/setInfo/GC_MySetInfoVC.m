//
//  GC_MySetInfoVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_MySetInfoVC.h"
#import "GC_MySetCell.h"
#import "GC_MySetLogoutCell.h"
#import "GC_MyHeaderCell.h"

#import "GC_MyInfoVC.h"
#import "GC_AccountSafeVC.h"
#import "GC_DataStorgeVC.h"
#import "GC_PrivacyVC.h"
#import "GC_NotifcationSetVC.h"
#import "GC_CommonSetVC.h"
#import "GC_AboutVC.h"
#import "CZReSetPwdViewController.h"

#import "TF_DiskCache.h"
#import "MainVC.h"
#import "ChangeLanguageTipVC.h"
#import "NSBundle+Language.h"
#import "MNNickNameVC.h"
#import "QTChangeLoginPasswordVC.h"

@interface GC_MySetInfoVC ()

@property (nonatomic, strong)NSArray *dataArr;

@property (nonatomic, copy) NSString *cache;

@end

@implementation GC_MySetInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  initUI];
    [self calculateCahce];
}

- (NSArray *)dataArr{
    if (!_dataArr) {
        NSArray *array01 = @[@"个人资料".lv_localized];
//        NSArray *array02 = @[@"修改密码".lv_localized, @"账号与安全".lv_localized, @"数据与储存".lv_localized, @"隐私与权限".lv_localized, @"通用".lv_localized, @"清空缓存".lv_localized];
        NSArray *array02 = @[@"数据与储存".lv_localized, @"隐私与权限".lv_localized, @"通用".lv_localized, @"清空缓存".lv_localized];
        NSArray *array03 = @[@"切换语言".lv_localized];
        NSArray *array04 = @[@"关于我们".lv_localized];
        NSArray *array05 = @[@"退出账号".lv_localized];
        _dataArr = @[array01, array02, array03, array04, array05];
//        _dataArr = @[@"个人资料".lv_localized, @"修改密码".lv_localized, @"账号与安全".lv_localized, @"数据与储存".lv_localized, @"隐私与权限".lv_localized, @"通用".lv_localized, @"清空缓存".lv_localized,@"切换语言".lv_localized];
    }
    return _dataArr;
}
- (void)initUI{
    [self.customNavBar setTitle:@"设置".lv_localized];
    self.customNavBar.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetLogoutCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetLogoutCell"];
    
    
//    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    self.tableView.backgroundColor = HEXCOLOR(0xF6F6F6);
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
        make.bottom.mas_equalTo(0);
    }];
    self.view.backgroundColor = self.tableView.backgroundColor;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = self.dataArr[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = self.dataArr[indexPath.section];
    NSString *text = array[indexPath.row];
    if ([text isEqualToString:@"退出账号".lv_localized]){
        GC_MySetLogoutCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetLogoutCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLab.text = text;
        return cell;
    }else{
        GC_MySetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLab.text = text;
        cell.lineView.hidden = array.count-1==indexPath.row;
        if ([text isEqualToString:@"清空缓存".lv_localized]) {
            cell.contentLab.text = self.cache;
        } else {
            cell.contentLab.text = @"";
        }
        
        return cell;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    backView.backgroundColor = HEXCOLOR(0xF6F6F6);
    return backView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = self.dataArr[indexPath.section];
    NSString *title = array[indexPath.row];
    if ([title isEqualToString:@"个人资料".lv_localized]) {
        GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"修改密码".lv_localized]) {
        [self judgeHasPassWord];
//        MNNickNameVC *vc = [[MNNickNameVC alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
        
    } else if ([title isEqualToString:@"隐私与权限".lv_localized]) {
        GC_PrivacyVC *vc = [[GC_PrivacyVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"数据与储存".lv_localized]) {
        GC_DataStorgeVC *vc = [[GC_DataStorgeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"账号与安全".lv_localized]) {
        GC_AccountSafeVC *vc = [[GC_AccountSafeVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"通知与声音".lv_localized]) {
        GC_NotifcationSetVC *vc = [[GC_NotifcationSetVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"通用".lv_localized]) {
        GC_CommonSetVC *vc = [[GC_CommonSetVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"清空缓存".lv_localized]) {
        [self clearCache];
    } else if ([title isEqualToString:@"切换语言".lv_localized]){
        [self changeLanguage];
    }else if ([title isEqualToString:@"关于我们".lv_localized]){
        GC_AboutVC *vc = [[GC_AboutVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([title isEqualToString:@"退出账号".lv_localized]){
        [self exitAction];
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
//        [self.navigationController pushViewController:vc animated:YES];
        [self presentViewController:vc animated:YES completion:nil];
    }];
}


- (void)exitAction{
    //提示用户
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 0)
        {
            [UserInfo show];
            [[TelegramManager shareInstance] registerApnsToken:@"" resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                [[TelegramManager shareInstance] logout];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"退出失败，请检查网络".lv_localized];
            }];
        }
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"账号退出登录后，本地数据将被清空，确定退出当前账号？".lv_localized items:items];
    [view show];
}

- (void)changeLanguage{
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index == 0) {
            [self changeLanguageTo:@"en"];
        } else if (index == 1) {
            [self changeLanguageTo:@"zh-Hans"];
        }
    };
    NSMutableArray *items = @[MMItemMake(@"英文".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"中文".lv_localized, MMItemTypeNormal, block)].mutableCopy;

    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)changeLanguageTo:(NSString *)language{
    NSArray *langArr1 = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *currentLanguage = langArr1.firstObject;
    if ([currentLanguage isEqualToString:language]) {
        return;
    }
    
    
    [[NSUserDefaults standardUserDefaults] setObject:@[language] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
//    MMPopupItemHandler block = ^(NSInteger index) {
//        if(index == 1)
//        {
////            [self performSelector:@selector(loginout)];
//            AppDelegate  *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            UIWindow *window = app.window;
//            //动画
//            [UIView animateWithDuration:1.0f animations:^{
//                window.alpha = 0;
//                window.frame = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 0, 0);
//            }completion:^(BOOL finished) {
//                exit(0);
//            }];
//
//        }
//    };
//    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeHighlight, block),
//                       MMItemMake(@"确定".lv_localized, MMItemTypeNormal, block)];
//    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"语言切换成功，请重新启动app以生效".lv_localized items:items];
//    [view show];
//
    // 设置语言
    [NSBundle setLanguage:language];

    ChangeLanguageTipVC *vc = [[ChangeLanguageTipVC alloc] init];
    ((AppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController = vc;
//    [self resetClicent];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangedLanguage" object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        MainVC *mainVc = [[MainVC alloc] init];
//        [[TelegramManager shareInstance] logout];
        
        [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
    });
    
}

- (void)configTd {
    NSString *data_directory = nil;
    AuthUserInfo *curUser = [[AuthUserManager shareInstance] currentAuthUser];
    if (curUser) {
        data_directory = curUser.data_directoryPath;
    } else {
        data_directory = [[AuthUserManager shareInstance] create_data_directory];
    }
    [[TelegramManager shareInstance] setTdlibParameters:data_directory result:^(NSDictionary *request, NSDictionary *response) {
        if (![TelegramManager isResultOk:response]) {
            //配置失败，系统级错误
            NSLog(@"Config td lib fail......");
            [self resetClicent];
        } else {
            [[TelegramManager shareInstance] setOnlineState:@"true" result:^(NSDictionary *request, NSDictionary *response) {
            } timeout:^(NSDictionary *request) {
            }];
        }
    } timeout:^(NSDictionary *request) {
        //超时，系统级错误
        NSLog(@"Config td lib timeout......");
        [self resetClicent];
    }];
}

- (void)resetClicent {
    /// 连接中状态五秒后，切换下一个域名，重连
    /// 只有启动 App 的时候才会执行，只要连接成功一次，就不会再执行此处了。
    
    [TelegramManager.shareInstance resetClicent];
    [TelegramManager.shareInstance reInitTdlib];
    [self configTd];
}

- (void)calculateCahce {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CGFloat total = [TF_DiskCache goChatCacheSize];
        self.cache = [NSString stringWithFormat:@"%.2f M", total];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)clearCache {
    if ([self.cache isEqualToString:@"0.00 M"]) {
        [UserInfo showTips:nil des:@"没有可清理的缓存".lv_localized];
        return;
    }
    MMPopupItemHandler block = ^(NSInteger index) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [TF_DiskCache goChatCacheClear];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self calculateCahce];
                [UserInfo showTips:nil des:@"清空缓存成功".lv_localized];
            });
        });
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, nil)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"清空缓存会使本地的图片视频等媒体文件不可逆转的删除，是否确定清空缓存".lv_localized items:items];
    [view show];
}

@end
