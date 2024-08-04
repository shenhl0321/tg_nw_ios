//
//  AppDelegate.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/19.
//

#import "AppDelegate.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
//#import <JMLink/JMLinkService.h>
#import "CZRegisterViewController.h"
#import "JoinChatInviteLinkViewController.h"
#import "MNLoginVC.h"
#import "MainVC.h"
#import "BaseNavController.h"
#import "CheckUserViewController.h"
#import "BaseNavController.h"
#import "MNChatViewController.h"
#import "MNThemeManager.h"
#import "PublishTimelinesVC.h"
#import "AppBackgroundTaskManager.h"
#import "NSString+SFLocalizedString.h"
#import "NSBundle+Language.h"
#import "XinstallSDK.h"


#import "QTLoginVC.h"
#import "QTLoginBottomView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <Bugly/Bugly.h>

//设置边框颜色
@interface CALayer (ZZYXibBorderColor)
@end
@implementation CALayer (ZZYXibBorderColor)
- (void)setBorderColorWithUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}
@end

@implementation NSObject (CategoryWithProperty)
- (NSNumber *)mylimitCount
{
    return objc_getAssociatedObject(self, @selector(mylimitCount));
}

- (void)setMylimitCount:(NSNumber *)value
{
    objc_setAssociatedObject(self, @selector(mylimitCount), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@implementation LimitInput
+ (void)load
{
    [super load];
    [LimitInput sharedInstance];
}

+ (LimitInput *)sharedInstance
{
    static LimitInput *g_limitInput;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_limitInput = [[LimitInput alloc] init];
    });
    return g_limitInput;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidChange:) name:UITextFieldTextDidChangeNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object: nil];
    }
    return self;
}

- (void)textFieldViewDidChange:(NSNotification*)notification
{
    UITextField *textField = (UITextField *)notification.object;
    NSNumber *number = textField.mylimitCount;
    if (number && textField.text.length > [number integerValue] && textField.markedTextRange == nil)
    {
        textField.text = [textField.text substringWithRange: NSMakeRange(0, [number integerValue])];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptLimitLength" object: textField];
    }
}

- (void)textViewDidChange: (NSNotification *) notificaiton
{
    UITextView *textView = (UITextView *)notificaiton.object;
    NSNumber *number = textView.mylimitCount;
    if (number && textView.text.length > [number integerValue] && textView.markedTextRange == nil)
    {
        textView.text = [textView.text substringWithRange: NSMakeRange(0, [number integerValue])];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptLimitLength" object: textView];
    }
}
@end

@implementation RightAlignedNoSpaceFixTextField
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self addSpaceFixActions];
    }
    return self;
}

- (void)addSpaceFixActions
{
    [self addTarget:self action:@selector(replaceNormalSpaces) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(replaceBlankSpaces) forControlEvents:UIControlEventEditingDidEnd];
}

- (void)replaceNormalSpaces
{
    if (self.textAlignment == NSTextAlignmentRight)
    {
        NSRange range = [self.text rangeOfString:@" "];
        if(range.location != NSNotFound)
        {
            UITextRange *textRange = self.selectedTextRange;
            self.text = [self.text stringByReplacingOccurrencesOfString:@" " withString:@"\u00a0"];
            [self setSelectedTextRange:textRange];
        }
    }
}

- (void)replaceBlankSpaces
{
    self.text = [self.text stringByReplacingOccurrencesOfString:@"\u00a0" withString:@" "];
}
@end

@interface AppDelegate ()<UNUserNotificationCenterDelegate,BusinessListenerProtocol,XinstallDelegate>
//2021-7-10
@property (nonatomic,strong) ChatInviteLinkInfo *inviteInfo;

@end

@implementation AppDelegate

#pragma mark - 关于apns
- (void)setNotificationTokenSettings:(UIApplication *)application
{
    if (@available(iOS 10.0, *))
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                }];
            }
        }];
    }
    else
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if ([[UIDevice currentDevice].systemVersion floatValue] < 10.0)
    {
        NSString *token = [[[[deviceToken description]
                             stringByReplacingOccurrencesOfString:@"<"withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString: @" " withString: @""];
        ChatLog(@"DeviceToken++++++++++++{%@}", token);
        [UserInfo shareInstance].pushToken = token;
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 13.0)
    {
        ChatLog(@"DeviceToken++++++++++++{%@}", [self stringFromDeviceToken:deviceToken]);
        [UserInfo shareInstance].pushToken = [self stringFromDeviceToken:deviceToken];
    }
    else
    {
        NSString *deviceString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        deviceString = [deviceString stringByReplacingOccurrencesOfString:@" " withString:@""];
        ChatLog(@"deviceToken++++++++++++%@",deviceString);
        [UserInfo shareInstance].pushToken = deviceString;
    }
    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Update_Apns_Token) withInParam:nil];
}

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken
{
    NSUInteger length = deviceToken.length;
    if (length == 0)
    {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i)
    {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)doNotification:(int)type detail:(NSDictionary *)detail isForground:(BOOL)isForground
{
    if(detail != nil && [detail isKindOfClass:[NSDictionary class]])
    {
    }
}

//前端使用中接收到消息
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler API_AVAILABLE(ios(10.0))
{
}

//click action
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler API_AVAILABLE(ios(10.0))
{
}

//iOS7及以上系统
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}

//scheme
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if([AuthUserManager shareInstance].currentAuthUser != nil)
    {
        long userId = [[UserInfo shareInstance] userIdFromUrl:url];
        if(userId > 0)
        {
            [UserInfo shareInstance].willShowContactId = userId;
            //发送通知
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Will_Show_Contact) withInParam:nil];
        }
        
        NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:url];
        if(invitelink && invitelink.length > 5)
        {
            [UserInfo shareInstance].inviteLink = invitelink;
            
            [self addGroupWithInviteLink];
        }
    }
    [XinstallSDK handleSchemeURL:url];
    //uid=nFe9dJ+/m9QwCtJirisOSA==
    NSLog(@"openURL:%@,%@,%@", url.scheme, url.query, url.resourceSpecifier);
//    [JMLinkService routeMLink:url];
    return YES;
}

//通过universal link来唤起app
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    //判断是否通过ShareInstall Universal Links 唤起App
    if ([XinstallSDK continueUserActivity:userActivity]) {
       return YES ;
    }
//    [JMLinkService continueUserActivity:userActivity];
    return YES;
}

#pragma mark - main path
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSArray *langArr1 = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *currentLanguage = langArr1.firstObject;
    // 不是中文的话，都设置成英文
    if (![currentLanguage hasPrefix:@"zh-"] ) {
        [[NSUserDefaults standardUserDefaults] setObject:@[@"en"] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [NSBundle setLanguage:@"en"];
    }
    
    [XinstallSDK initWithDelegate:self];

    
//    // 强制关闭暗黑模式
//    if(@available(iOS 13.0,*)){
//    self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
//    }
//    [self test];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];//常驻
    if (YELLOW) {
        MNThemeMgr().themeStyle = MNThemeStyleYellow;
    }else if (BLUE){
        MNThemeMgr().themeStyle = MNThemeStyleBlue;
    }else if (GREEN){
        MNThemeMgr().themeStyle = MNThemeStyleGreen;
    }
//
    //注册配置推送APNS
    [self setNotificationTokenSettings:application];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self gotoCheckUserView];
    [self.window makeKeyAndVisible];
    
    // 初始化高德地图
    [self initGaoDeMap];
    //初始化表情
    [EmojiManager shareInstance];
    
    //初始化语音视频模块
    [CallManager shareInstance];
//    application.applicationIconBadgeNumber = 0;
    [MMSheetViewConfig globalConfig].itemHighlightColor = UIColor.colorMain;
    
    [IQKeyboardManager sharedManager].toolbarTintColor = HEXCOLOR(0x08CF98);

    
    // Bugly
    [Bugly startWithAppId:@"811483e5d4"];
    
    return YES;
}

#pragma mark ShareInstallDelegate
//通过ShareInstall获取自定义参数，数据为空时也会调用此方法
- (void)getInstallParamsFromSmartInstall:(id) params withError: (NSError *) error{
    ChatLog(@"安装参数params=%@",params);
}
- (void)getWakeUpParamsFromSmartInstall: (id) params withError: (NSError *) error{
    ChatLog(@"唤醒参数params=%@",params);
   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL shceme 进来的" message: params delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //弹出提示框（便于调试，调试完成后删除此代码）
   [alert show];
}
- (void)initGaoDeMap {
    [AMapServices sharedServices].apiKey = GaoDeMap_AppId;
}

- (void)gotoHomeView {
//    PublishTimelinesVC *vc = [[PublishTimelinesVC alloc] init];
//    BaseNavController *nav = [[BaseNavController alloc] initWithRootViewController:vc];
//    self.window.rootViewController = nav;
    MainVC *vc = [[MainVC alloc] init];
    self.window.rootViewController = vc;
}

- (void)gotoCheckUserView {
    
    CheckUserViewController *vc = [[CheckUserViewController alloc] init];
    BaseNavController *nav = [[BaseNavController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

- (void)gotoLoginView {
#if 0
    GestureNavigationViewController *nav = [[GestureNavigationViewController alloc] initWithRootViewController:[CZRegisterViewController new]];
    self.window.rootViewController = nav;
#endif
//    MNLoginVC *vc = [[MNLoginVC alloc] init];
    QTLoginVC *vc = [[QTLoginVC alloc] init];
    BaseNavController *nav = [[BaseNavController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
}

- (void)getApplicationConfigSettingLoginStyle {
    [[TelegramManager shareInstance] getApplicationConfigWithResultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj && [obj isKindOfClass:[AppConfigInfo class]]) {
            [self gotoLoginView];
        } else {
            [self getApplicationConfigSettingLoginStyle];
        }
    } timeout:^(NSDictionary *request) {
        //超时，系统级错误
        //todo wangyutao
        NSLog(@"check DatabaseEncryption timeout......");
        [self gotoLoginView];
    }];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.isAllowOrentitaionRotation) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self setOnline:@"false"];
//    [self applyTimeForBackgroundTaskTime];
//
//    [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"======");
//    }];
    
    [[AppBackgroundTaskManager shareInstance] startBackgroundTaskWithApp:application];
}

- (void)applyTimeForBackgroundTaskTime {
    __block UIBackgroundTaskIdentifier backgroundTaskId;
//    backgroundTaskId = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
//        [UIApplication.sharedApplication endBackgroundTask:backgroundTaskId];
//        [self applyTimeForBackgroundTaskTime];
//    }];
    
    backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backtask" expirationHandler:^{
        [UIApplication.sharedApplication endBackgroundTask:backgroundTaskId];
        [self applyTimeForBackgroundTaskTime];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self setOnline:@"true"];
//    application.applicationIconBadgeNumber = 0;
    [[AppBackgroundTaskManager shareInstance] stopBackgroundTask];
}

- (void)setOnline:(NSString *)state {
    [[TelegramManager shareInstance] setOnlineState:state result:^(NSDictionary *request, NSDictionary *response) {
    } timeout:^(NSDictionary *request) {
    }];
}

//跳转聊天页面
+ (void)gotoChatView:(NSObject *)chat {
    [AppDelegate gotoChatView:chat destMsgId:0];
}

+ (void)gotoChatView:(NSObject *)chat destMsgId:(long)destMsgId {
    UIViewController *rootView = ((AppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
    BaseNavController *navVC = [[BaseNavController alloc] init];
   
    if ([rootView isKindOfClass:[MainVC class]]) {
        UINavigationController *nav = [self gotoChatListView:rootView animation:NO];
        MNChatViewController *chatView = [[MNChatViewController alloc] initWithNibName:@"MNChatViewController" bundle:nil];
        chatView.chatInfo = (ChatInfo *)chat;
        chatView.destMsgId = destMsgId;
//        chatView.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:chatView animated:YES];
    }
}

+ (void)gotoChatListView {
    UIViewController *rootView = ((AppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
    if ([rootView isKindOfClass:[MainVC class]]) {
        [self gotoChatListView:rootView animation:YES];
    }
    
}

+ (UINavigationController *)gotoChatListView:(UIViewController *)controller animation:(BOOL)animation {
    MainVC *v = (MainVC *)controller;
    [self dismissAllViewController:v animation:animation];
    if(v.selectedIndex != 0){
        [v setSelectedIndex:0];
    }else{
        [tp_topMostViewController().navigationController popToRootViewControllerAnimated:YES];
        [v setSelectedIndex:0];
    }
    [v refreshSelctedFromSelectedIndex];
    return (UINavigationController *)v.selectedViewController;
}

+ (void)dismissAllViewController:(UIViewController *)controller animation:(BOOL)animation
{
    if([controller isKindOfClass:[UITabBarController class]])
    {
        UITabBarController *tab = (UITabBarController *)controller;
        if([tab selectedViewController])
        {
            if([[tab selectedViewController] isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *nav = (UINavigationController *)[tab selectedViewController];
                [self dismissAllPresentVC:[nav topViewController]];
                [nav popToRootViewControllerAnimated:animation];
            }
            else
            {
                [self dismissAllPresentVC:[tab selectedViewController]];
            }
        }
    }
    else
    {
        [self dismissAllPresentVC:controller];
    }
}

+ (void)dismissAllPresentVC:(UIViewController *)controller
{
    NSMutableArray* presentVCAry = [NSMutableArray array];
    UIViewController* presentVC = controller.presentedViewController;
    while(presentVC)
    {
        [presentVCAry insertObject:presentVC atIndex:0];
        presentVC = presentVC.presentedViewController;
    }
    
    // 逐层dismiss
    for(presentVC in presentVCAry)
    {
        [presentVC dismissViewControllerAnimated:NO completion:nil];
    }
}


#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Logout):
        {
            NSLog(@"开始退出登录_delegate");
            [[TelegramManager shareInstance] destroy];
            //清理数据
            [[TelegramManager shareInstance] cleanCurrentData];
            [[UserInfo shareInstance] reset];
            [[CallManager shareInstance] reset];
            [ChatExCacheManager reset];
            [[AuthUserManager shareInstance] logout];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            [self gotoCheckUserView];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Closed):
        {
            if([TelegramManager shareInstance].getUserState != GoUserState_Ready_Background)
            {
            }
        }
            break;
        default:
            break;
    }
}



//邀请进群
- (void)addGroupWithInviteLink
{
    NSString *inviteLink = [UserInfo shareInstance].inviteLink;
    if(inviteLink && inviteLink.length>5)
    {
        [UserInfo show];
        [[TelegramManager shareInstance] checkChatInviteLink:inviteLink resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            [UserInfo dismiss];
            if(obj != nil && [obj isKindOfClass:ChatInviteLinkInfo.class]){
                self.inviteInfo = obj;
                [self hasExternGroup:[request objectForKey:@"invite_link"]];
            }
            else
            {
                if([[response objectForKey:@"message"] isEqualToString:@"INVITE_HASH_INVALID"]){
                    [UserInfo showTips:nil des:@"进群链接已过期!".lv_localized];
                }else{
                    [UserInfo showTips:nil des:@"获取群信息失败，请稍后重试".lv_localized];
                }
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群信息失败，请稍后重试".lv_localized];
        }];
    }
    [UserInfo shareInstance].inviteLink = nil;
}

//弹出进群弹框
- (void)showExtenGroupViewwith:(NSString *)link{
    
    UIViewController *curVC = [CZCommonTool getCurrentVC];
    
    //自定义动画
    CATransition *animation = [CATransition animation];
    animation.duration = 0.3;
    animation.type = kCATransitionMoveIn;
    animation.subtype = kCATransitionFromBottom;
    [curVC.view.window.layer addAnimation:animation forKey:nil];
    
    JoinChatInviteLinkViewController *v = [JoinChatInviteLinkViewController new];
    v.inviteInfo = self.inviteInfo;
    v.inviteLink = link;
    v.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    curVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    //加载模态视图
    [curVC presentViewController:v animated:YES completion:^{
        }];
}

//当群数据异常的时候  判断是否已经存在于群中
- (void)hasExternGroup:(NSString *)link{
    if (self.inviteInfo.member_count < 1  || self.inviteInfo.member_user_ids.count < 1) {
        //在群中
        [[TelegramManager shareInstance] getGroupMember:self.inviteInfo.chat_id userId:[[AuthUserManager shareInstance] currentAuthUser].userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[GroupMemberInfo class]])
            {
                GroupMemberInfo *info = (GroupMemberInfo *)obj;
                if(info){
                    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.inviteInfo.chat_id];
                    [AppDelegate gotoChatView:chat];
                }
            }else{
                //不在群中  群可能已经解散但是数据扔在
                [UserInfo showTips:nil des:@"此群已被解散!".lv_localized];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }else{
        //不在群中
        [self showExtenGroupViewwith:link];
    }
}


@end
