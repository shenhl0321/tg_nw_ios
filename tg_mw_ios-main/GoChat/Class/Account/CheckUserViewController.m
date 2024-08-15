//
//  CheckUserViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import "CheckUserViewController.h"
#import "WHPingTester.h"
#import "TF_Timer.h"
@interface CheckUserViewController ()<BusinessListenerProtocol, WHPingDelegate>
//ping 测试
@property (nonatomic, strong) WHPingTester *pingTester;
@property (nonatomic, assign) int pingIndex;
@property (nonatomic, assign) int pingCount;

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
/// 计时
@property (nonatomic, assign) NSInteger timer;
/// <#code#>
@property (nonatomic, assign) BOOL tdSuccess;
/// <#code#>
@property (nonatomic, copy) NSString *taskName;
@end

@implementation CheckUserViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timer = 4;
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goLogin) name:@"GoLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetClicent) name:@"ResetClicent" object:nil];
    
    [self.customNavBar removeFromSuperview];

    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.iconImageView];
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-40);
    }];
    
    if([NetworkManage sharedInstance].main_ip != nil){
        self.timer = 0;
        [TelegramManager.shareInstance reInitTdlib];
        [self configTd];
        return;
    }
    
    [self configNetwork];
    
    self.taskName = [TF_Timer execTask:^{
        self.timer--;
        ChatLog(@"====%ld", self.timer);
        if (self.timer == 0) {
            [TF_Timer cancelTask:self.taskName];
            if (self.tdSuccess) {
                [self goLogin];
            }
        }
    } start:0 interval:1 repeats:YES async:YES];
}

- (void)configNetwork {
    self.pingCount = 0;
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"UseNetIndex"];
    self.pingIndex = num.intValue;
    AppDelegate *appDelegate = (AppDelegate*)UIApplication.sharedApplication.delegate;
    [NSUserDefaults.standardUserDefaults setObject:@(8) forKey:@"UseNetIndex"];
    appDelegate.pingHost = YES;
    MJWeakSelf;
    [[NetworkManage sharedInstance] syncTabExMenuComplete:^{
        appDelegate.pingHost = YES;
        [weakSelf pingHost];
        //    if (appDelegate.isPingHost) {
        //        
        //        
        //        [TelegramManager.shareInstance reInitTdlib];
        //        [self configTd];
        //    } else {
        //        appDelegate.pingHost = YES;
        //        [self pingHost];
        //    }
    }];
}

#pragma mark - ping
- (void)pingHost {
    if (self.pingTester) {
        [self.pingTester stopPing];
        self.pingTester = nil;
        self.pingTester.delegate = nil;
    }
    /// 循环了一圈都ping不同，弹窗提示
    if (self.pingCount == [NetworkManage sharedInstance].backup_ips.count) {
        NSString *message = @"暂时无法连接到服务器，请稍后重试".lv_localized;
        self.pingCount = 0;
        [self pingHost];
        return;
    }
    self.pingCount ++;
    
    if (self.pingIndex >= [NetworkManage sharedInstance].backup_ips.count) {
        self.pingIndex = 0;
    }
    NSLog(@"ping - 当前索引：%d，次数：%d，总数：%ld", self.pingIndex, self.pingCount, [NetworkManage sharedInstance].backup_ips.count);
    self.pingTester = [[WHPingTester alloc] initWithHostName:[NetworkManage sharedInstance].backup_ips[self.pingIndex]];
    self.pingTester.delegate = self;
    [self.pingTester startPing];
}

#pragma mark - Notification
#pragma mark 连接成功，进入主页
- (void)goLogin {
    self.tdSuccess = YES;
    if (self.timer > 0) {
        return;
    }
    
    if ([UserInfo shareInstance]._id==0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            [((AppDelegate*)([UIApplication sharedApplication].delegate)) getApplicationConfigSettingLoginStyle];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [[TelegramManager shareInstance] getApplicationConfigWithResultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
            } timeout:^(NSDictionary *request) {
                
            }];
        });
    }
}

#pragma mark 重新连接，针对超时、失败的处理
- (void)resetClicent {
    /// 连接中状态五秒后，切换下一个域名，重连
    /// 只有启动 App 的时候才会执行，只要连接成功一次，就不会再执行此处了。
    self.pingIndex ++;
    if (self.pingIndex >= [NetworkManage sharedInstance].backup_ips.count) {
        self.pingIndex = 0;
    }
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    [ud setObject:@(self.pingIndex) forKey:@"UseNetIndex"];
    [ud synchronize];
    [TelegramManager.shareInstance resetClicent];
    [TelegramManager.shareInstance reInitTdlib];
    [self configTd];
}
#pragma mark -

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

- (void)check {
    [[TelegramManager shareInstance] checkDatabaseEncryptionKey:^(NSDictionary *request, NSDictionary *response) {
        if (![TelegramManager isResultOk:response]) {
            //配置失败，系统级错误
            NSLog(@"check DatabaseEncryption fail......");
//            [self resetClicent];
        }
    } timeout:^(NSDictionary *request) {
        //超时，系统级错误
        NSLog(@"check DatabaseEncryption timeout......");
//        [self resetClicent];
    }];
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch(notifcationId) {
        case MakeID(EUserManager, EUser_To_TdConfig):
        {
            
        }
            break;
        case MakeID(EUserManager, EUser_To_Check_Encryption):
        {
            [self check];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Ready):
        {
            //goto home view
            /// 参照安卓，连接成功后在进入首页
//            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoHomeView];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Input_Phone):
        case MakeID(EUserManager, EUser_Td_Input_Code):
        case MakeID(EUserManager, EUser_Td_Input_Password):
        case MakeID(EUserManager, EUser_Td_Register):
        {
            //goto login view
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//            [((AppDelegate*)([UIApplication sharedApplication].delegate)) getApplicationConfigSettingLoginStyle];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Logout):
        {
            //goto login view
            NSLog(@"开始退出登录_Check");
//            [[TelegramManager shareInstance] destroy];
            //清理数据
//            [[TelegramManager shareInstance] cleanCurrentData];
//            [[UserInfo shareInstance] reset];
//            [[CallManager shareInstance] reset];
//            [ChatExCacheManager reset];
//            [[AuthUserManager shareInstance] logout];
//
//            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//            [((AppDelegate*)([UIApplication sharedApplication].delegate)) gotoCheckUserView];
            
            //进入鉴权页面
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//            CheckUserViewController *checkView = [sb instantiateViewControllerWithIdentifier:@"CheckUserView"];
//            ((AppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController = checkView;
        }
            break;
        case MakeID(EUserManager, EUser_Td_Closed):
        {
            [[TelegramManager shareInstance] cleanCurrentData];
            [[TelegramManager shareInstance] reInitTdlib];
        }
            break;
        default:
            break;
    }
}


#pragma mark ping的回调
- (void)didPingSucccessWithTime:(float)time withError:(NSError *)error {
    if (error) {
        NSLog(@"网络有问题");
        self.pingIndex ++;
        [self pingHost];
    } else {
        if (self.pingTester) {
            [self.pingTester stopPing];
            self.pingTester = nil;
            self.pingTester.delegate = nil;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(self.pingIndex) forKey:@"UseNetIndex"];
        [self configTd];
    }
}

#pragma mark - getter
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
#if YELLOW
        NSString *name = @"LaunchBg2";
#elif GREEN
        NSString *name = @"LaunchBg3";
#elif BLUE
        NSString *name = @"LaunchBg";
#else
        NSString *name = @"LaunchBg";
#endif
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        
//        NSInteger index = arc4random_uniform(2);
//        _bgImageView = [[UIImageView alloc] init];
//        [_bgImageView sd_setImageWithURL:[NSURL URLWithString:@"https://jk.douliaoapp.com/get_img?name=app_start_img"]];
//        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        
    }
    return _bgImageView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
//        [_iconImageView sd_setImageWithURL:[NSURL URLWithString:@"https://jk.douliaoapp.com/get_img?name=app_start_img2"]];
    }
    return _iconImageView;
}

@end
