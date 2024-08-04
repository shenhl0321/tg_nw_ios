//
//  MainVC.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/4.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "MainVC.h"
#import "MNTabMeVC.h"
#import "MNTabExploreVC.h"
#import "BaseNavController.h"
#import "MNTabFindVC.h"
#import "MNTabAddressBookVC.h"
#import "MNTabMessageVC.h"
#import "MSTabbarItem.h"
#import "HSUpdateApp.h"
#import "TimelineHelper.h"
#import "Lottie.h"
#import "QTMineVC.h"
#import "QTTongXunLuVC.h"

#define ItemTagOffset 100001
#define isShowGif YES
#define gitTop 7
#define gitWH 36

@interface MainVC ()
<BusinessListenerProtocol>

@property (nonatomic, strong) UIView *msTabbar;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) NSMutableArray *itemsArr;
@property (strong, nonatomic) UIView *lineView;

@property (strong, nonatomic) LOTAnimationView *homeAnimationView;
@property (strong, nonatomic) LOTAnimationView *txlAnimationView;
@property (strong, nonatomic) LOTAnimationView *findAnimationView;
@property (strong, nonatomic) LOTAnimationView *mineAnimationView;

@property (strong, nonatomic) UIImageView *findImageV;
@property (strong, nonatomic) UIImageView *centerImageV;

@end

@implementation MainVC
-(CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.strokeColor = [UIColor colorTextForE5EAF0].CGColor;
        _shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        _shapeLayer.lineWidth = 0.5;
        UIBezierPath *path = [[UIBezierPath alloc] init];
        CGFloat width = APP_SCREEN_WIDTH/5.0;
        
        CGPoint point1 = CGPointMake(0, 0);
        CGPoint point2 = CGPointMake(width*2, 0);
        CGPoint point3 = CGPointMake(width*3, 0);
        CGPoint point4 = CGPointMake(width*5, 0);
        [path moveToPoint:point1];
        [path addLineToPoint:point2];
        [path addQuadCurveToPoint:point3 controlPoint:CGPointMake(width*2.5, -30)];
//        [path addCurveToPoint:<#(CGPoint)#> controlPoint1:<#(CGPoint)#> controlPoint2:<#(CGPoint)#>];
//        [path addArcWithCenter:CGPointMake(width*2.5, 17) radius:32 startAngle:0 endAngle:2*M_PI clockwise:YES];
        [path addLineToPoint:point4];
        _shapeLayer.path = path.CGPath;
    }
    return _shapeLayer;
}

- (void)dealloc
{
    ChatLog(@"==============");
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
//    [self reloadTabContentViews];
    
    //同步联系人
    [[TelegramManager shareInstance] syncMyContacts];
    //上传苹果推送token
    [self syncApnsToken];
    // 检测是否版本更新
    [self appVersionCheck];
    
    _itemsArr = [[NSMutableArray alloc] init];
    [self setupVC];
    
    if (isShowGif == YES){
        [self initTabbarGifView];
    }
}
- (void)initTabbarGifView{
//    [self.homeAnimationView setAnimationNamed:@"home_s"];
//    [self.txlAnimationView setAnimationNamed:@"conta"];
//    [self.findAnimationView setAnimationNamed:@"explore"];
//    [self.mineAnimationView setAnimationNamed:@"mine"];
    
    [self.homeAnimationView playWithCompletion:^(BOOL animationFinished) {
        //
        NSLog(@"");
    }];
    [self.txlAnimationView playWithCompletion:^(BOOL animationFinished) {
        //
        NSLog(@"");
    }];
    [self.findAnimationView playWithCompletion:^(BOOL animationFinished) {
        //
        NSLog(@"");
    }];
    [self.mineAnimationView playWithCompletion:^(BOOL animationFinished) {
        //
        NSLog(@"");
    }];
}

- (LOTAnimationView *)homeAnimationView{
    if (!_homeAnimationView){
        _homeAnimationView = [LOTAnimationView animationNamed:@"home_s"];
        // 循环播放动画
        _homeAnimationView.loopAnimation = NO;
//        _homeAnimationView.hidden = YES;
        _homeAnimationView.userInteractionEnabled = NO;
    }
    return _homeAnimationView;
}
- (LOTAnimationView *)txlAnimationView{
    if (!_txlAnimationView){
        _txlAnimationView = [LOTAnimationView animationNamed:@"conta"];
        // 循环播放动画
        _txlAnimationView.loopAnimation = NO;
        _txlAnimationView.hidden = YES;
        _txlAnimationView.userInteractionEnabled = NO;
    }
    return _txlAnimationView;
}
- (LOTAnimationView *)findAnimationView{
    if (!_findAnimationView){
        _findAnimationView = [LOTAnimationView animationNamed:@"explore"];
        // 循环播放动画
        _findAnimationView.loopAnimation = NO;
        _findAnimationView.hidden = YES;
        _findAnimationView.userInteractionEnabled = NO;
    }
    return _findAnimationView;
}
- (LOTAnimationView *)mineAnimationView{
    if (!_mineAnimationView){
        _mineAnimationView = [LOTAnimationView animationNamed:@"mine"];
        // 循环播放动画
        _mineAnimationView.loopAnimation = NO;
        _mineAnimationView.hidden = YES;
        _mineAnimationView.userInteractionEnabled = NO;
    }
    return _mineAnimationView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshView];
    [self reloadMessage];
}

-(void)setupVC{
    MNTabMessageVC *vc1 = [[MNTabMessageVC alloc] init];
    BaseNavController* nav1 = [[BaseNavController alloc] initWithRootViewController:vc1];
//    MNTabAddressBookVC *vc2 = [[MNTabAddressBookVC alloc] init];
    QTTongXunLuVC *vc2 = [[QTTongXunLuVC alloc] init];
    BaseNavController* nav2 = [[BaseNavController alloc] initWithRootViewController:vc2];
    MNTabFindVC *vc3 = [[MNTabFindVC alloc] init];
    BaseNavController* nav4 = [[BaseNavController alloc] initWithRootViewController:vc3];
    MNTabExploreVC *vc4 = [[MNTabExploreVC alloc] init];
    vc4.contentView.frame = CGRectMake(0, APP_TOP_BAR_HEIGHT, kScreenWidth(), APP_SCREEN_HEIGHT-kTabBarHeights()-APP_TOP_BAR_HEIGHT);
//    vc4.type = WEB_LOAD_TYPE_TAB_EX_URL;
    BaseNavController* nav3 = [[BaseNavController alloc] initWithRootViewController:vc4];
    QTMineVC *vc5 = [[QTMineVC alloc] init];
    BaseNavController* nav5 = [[BaseNavController alloc] initWithRootViewController:vc5];
    
    if (isShowGif == YES){
        self.viewControllers = @[nav1,nav2,nav3,nav4,nav5];
//        self.viewControllers = @[nav1,nav2,nav4,nav5];
    }else{
        self.viewControllers = @[nav1,nav2,nav3,nav4,nav5];
    }
    
    [self createTabbar];
    self.selectedIndex = 0;
    
    vc1.appearBlock = ^{
        [self reloadMessage];
    };
    vc2.appearBlock = ^{
        [self reloadMessage];
    };
    vc3.appearBlock = ^{
        [self reloadMessage];
    };
    vc4.appearBlock = ^{
        [self reloadMessage];
    };
    vc5.appearBlock = ^{
        [self reloadMessage];
    };
}


- (void)reloadMessage {
    [TimelineHelper queryUnreadCountCompletion:^(NSInteger count) {
        for (MSTabbarItem *item in self.itemsArr) {
            if ([item.titleLabel.text isEqualToString:LocalString(localFind)]) {
                if (count == 0) {
                    item.badgeValue = nil;
                } else {
                    item.badgeValue = [NSString stringWithFormat:@"%ld", count];
                }
                return;
            }
        }
    }];
}
- (void)createTabbar {
    [self.tabBar addSubview:self.msTabbar];
    [self.tabBar setShadowImage:[UIImage new]];
    [self.tabBar setBackgroundImage:[UIImage new]];
    self.tabBar.backgroundColor = HEXCOLOR(0xFAFAFA);
    
    
    NSArray *normalImgs = @[];
    NSArray *selectImgs = @[];
    NSArray *titles = @[];
    if (isShowGif == YES){
        normalImgs = @[@"tab_icon_message_default", @"tab_icon_txl_default", @"icon_tabbar_selected", @"tab_icon_home_default", @"tab_icon_my_default"];
        
        selectImgs = @[@"icon_tabbar_selected", @"icon_tabbar_selected",@"icon_tabbar_selected", @"icon_tabbar_selected", @"icon_tabbar_selected"];
        titles = @[LocalString(localMessage), LocalString(@"通讯录"), LocalString(localExplore), LocalString(localFind), LocalString(localMe)];
    }else{
        normalImgs = @[@"TabItemMsg", @"TabItemContact", @"TabItemExplore", @"TabItemFind", @"TabItemMe"];
        selectImgs = @[@"TabItemMsgSel", @"TabItemContactSel", @"TabItemExploreSel", @"TabItemFindSel", @"TabItemMeSel"];
        titles = @[LocalString(localMessage), LocalString(localContactPerson), LocalString(localExplore), LocalString(localFind), LocalString(localMe)];
    }
    
    CGFloat itemWidth = APP_SCREEN_WIDTH/titles.count;
    CGFloat itemHeight = APP_TAB_BAR_HEIGHT2();
    CGFloat count = titles.count;
    
    for (int i = 0; i < count; i++) {
        MSTabbarItem *item = [[MSTabbarItem alloc] initWithFrame:CGRectMake(itemWidth*i, 0, itemWidth, itemHeight)];
        item.tag = ItemTagOffset + i;
        [item setTitle:titles[i] forState:UIControlStateNormal];
        [item setImage:[UIImage imageNamed:normalImgs[i]] forState:UIControlStateNormal];
        [item setImage:[UIImage imageNamed:selectImgs[i]] forState:UIControlStateSelected];
        [self.msTabbar addSubview:item];
        [item addTarget:self action:@selector(selectItem:) forControlEvents:UIControlEventTouchUpInside];
        [item setImagePosition:LXMImagePositionTop spacing:1];
        
        if (i == 0) {
            if (isShowGif == YES){
                [item addSubview:self.homeAnimationView];
                
                [self.homeAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
                    //
                    make.centerX.equalTo(item);
                    make.centerY.equalTo(item).offset(-gitTop);
                    make.width.height.mas_offset(gitWH);
                }];
            }
            
            item.selected = YES;
            self.selectedIndex = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
            tap.numberOfTapsRequired = 2;
            tap.delaysTouchesEnded=NO;
            [item addGestureRecognizer:tap];
        }else if (i == 1){
            if (isShowGif == YES){
                [item addSubview:self.txlAnimationView];
                
                [self.txlAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
                    //
                    make.centerX.equalTo(item);
                    make.centerY.equalTo(item).offset(-gitTop);
                    make.width.height.mas_offset(gitWH);
                }];
            }
        }else if (i == 2){
            [item addSubview:self.centerImageV];
            
            [self.centerImageV mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.centerX.equalTo(item);
                make.centerY.equalTo(item).offset(-gitTop);
                make.width.height.mas_offset(gitWH-5);
            }];
        }else if (i == 3) {
            if (isShowGif == YES){
//                [item addSubview:self.findAnimationView];
//
//                [self.findAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    //
//                    make.centerX.equalTo(item);
//                    make.centerY.equalTo(item).offset(-gitTop);
//                    make.width.height.mas_offset(gitWH);
//                }];
                
                [item addSubview:self.findImageV];

                [self.findImageV mas_makeConstraints:^(MASConstraintMaker *make) {
                    //
                    make.centerX.equalTo(item);
                    make.centerY.equalTo(item).offset(-gitTop);
                    make.width.height.mas_offset(gitWH);
                }];
            }
            [self refreshView];
        }else if (i == 4){
            if (isShowGif == YES){
                [item addSubview:self.mineAnimationView];
                
                [self.mineAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
                    //
                    make.centerX.equalTo(item);
                    make.centerY.equalTo(item).offset(-gitTop);
                    make.width.height.mas_offset(gitWH);
                }];
            }
        }
        [self.itemsArr addObject:item];
    }
    
    if (isShowGif == YES){
        [self.msTabbar addSubview:self.lineView];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.left.top.right.equalTo(self.msTabbar);
            make.height.mas_offset(1);
        }];
    }
}
- (UIView *)lineView{
    if (!_lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = HEXCOLOR(0xF0F0F0);
    }
    return _lineView;
}

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"双击~~~~");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kDoubleClickTabItemNotification" object:nil];
}
- (void)selectItem:(MSTabbarItem *)item{
    if (isShowGif == YES){
        NSInteger index = item.tag-ItemTagOffset;
        if (index == 0){
            self.homeAnimationView.hidden = NO;
            self.txlAnimationView.hidden = YES;
            self.findAnimationView.hidden = YES;
            self.mineAnimationView.hidden = YES;
            
            [self.homeAnimationView stop];
            [self.txlAnimationView stop];
            [self.findAnimationView stop];
            [self.mineAnimationView stop];
            
            [self.homeAnimationView play];
            
            [self.findImageV stopAnimating];
            self.findImageV.hidden = YES;
            self.findImageV.image = [UIImage imageNamed:@""];
        }else if (index == 1){
            self.homeAnimationView.hidden = YES;
            self.txlAnimationView.hidden = NO;
            self.findAnimationView.hidden = YES;
            self.mineAnimationView.hidden = YES;
            
            [self.homeAnimationView stop];
            [self.txlAnimationView stop];
            [self.findAnimationView stop];
            [self.mineAnimationView stop];
            
            [self.txlAnimationView play];
            
            [self.findImageV stopAnimating];
            self.findImageV.hidden = YES;
            self.findImageV.image = [UIImage imageNamed:@""];
        }else if (index == 2){
            self.homeAnimationView.hidden = YES;
            self.txlAnimationView.hidden = YES;
            self.findAnimationView.hidden = YES;
            self.mineAnimationView.hidden = YES;
            
            [self.homeAnimationView stop];
            [self.txlAnimationView stop];
            [self.findAnimationView stop];
            [self.mineAnimationView stop];
            
            [self.findImageV stopAnimating];
            self.findImageV.hidden = YES;
            self.findImageV.image = [UIImage imageNamed:@""];
        }else if (index == 3){
            self.homeAnimationView.hidden = YES;
            self.txlAnimationView.hidden = YES;
//            self.findAnimationView.hidden = NO;
            self.findAnimationView.hidden = YES;
            self.mineAnimationView.hidden = YES;
            
            [self.homeAnimationView stop];
            [self.txlAnimationView stop];
//            [self.findAnimationView play];
            [self.findAnimationView stop];
            [self.mineAnimationView stop];
            
            [self.findImageV startAnimating];
            self.findImageV.hidden = NO;
            self.findImageV.image = [UIImage imageNamed:@"icon_find21"];
        }else if (index == 4){
            self.homeAnimationView.hidden = YES;
            self.txlAnimationView.hidden = YES;
            self.findAnimationView.hidden = YES;
            self.mineAnimationView.hidden = NO;
            
            [self.homeAnimationView stop];
            [self.txlAnimationView stop];
            [self.findAnimationView stop];
            [self.mineAnimationView stop];
            
            [self.mineAnimationView play];
            
            [self.findImageV stopAnimating];
            self.findImageV.hidden = YES;
            self.findImageV.image = [UIImage imageNamed:@""];
        }
    }
    
    for (UIView *item in self.msTabbar.subviews) {
        if ([item isKindOfClass:[MSTabbarItem class]]) {
            ((MSTabbarItem *)item).selected = NO;
        }
    }
    item.selected = YES;
    self.selectedIndex = item.tag-ItemTagOffset;
}

- (void)refreshSelctedFromSelectedIndex{
    for (MSTabbarItem *item in self.itemsArr) {
        item.selected = NO;
    }
    NSInteger selctedIndex = 0;
    if (self.selectedIndex < self.itemsArr.count) {
        selctedIndex = self.selectedIndex;
    }
    MSTabbarItem *item = self.itemsArr[selctedIndex];
    item.selected = YES;
    [self selectItem:item];
}

-(UIView *)msTabbar{
    if (!_msTabbar) {
        _msTabbar = [[UIView alloc] initWithFrame:CGRectMake(0, 49-APP_TAB_BAR_HEIGHT2(), APP_SCREEN_WIDTH, APP_TAB_BAR_HEIGHT2())];
        _msTabbar.backgroundColor = self.tabBar.backgroundColor;
    }
    return _msTabbar;
}

- (void)refreshView{
//    return;
    TabExMenuInfo *curTabExMenuInfo = [TabExMenuInfo getTabExMenuInfo];
    if (curTabExMenuInfo.status == YES){
        NSInteger index = 0;
        CGFloat itemWidth = APP_SCREEN_WIDTH/5.0;
        CGFloat itemHeight = APP_TAB_BAR_HEIGHT2();
        for (MSTabbarItem *item in self.itemsArr) {
            item.hidden = NO;
            item.frame = CGRectMake(itemWidth*index, 0, itemWidth, itemHeight);
            index++;
        }
        
        if (self.itemsArr.count>=2) {
            MSTabbarItem *item = self.itemsArr[2];
            item.hidden = NO;
            if(curTabExMenuInfo != nil && [curTabExMenuInfo isValid])
            {
                [item setTitle:curTabExMenuInfo.site_name forState:UIControlStateNormal];
                [self.centerImageV sd_setImageWithURL:[NSURL URLWithString:curTabExMenuInfo.site_logo] placeholderImage:[UIImage imageNamed:@""]];
            }else{
                [item setTitle:@"探索".lv_localized forState:UIControlStateNormal];
                [item setImage:[UIImage imageNamed:@"TabItemExplore"] forState:UIControlStateNormal];
                [item setImage:[UIImage imageNamed:@"TabItemExploreSel"] forState:UIControlStateSelected];
            }
        }
        
    }else{
        NSInteger index = 0;
        CGFloat itemWidth = APP_SCREEN_WIDTH/4.0;
        CGFloat itemHeight = APP_TAB_BAR_HEIGHT2();
        for (MSTabbarItem *item in self.itemsArr) {
            NSInteger i = index;
            if (i >= 2){
                i = index-1;
            }
             item.frame = CGRectMake(itemWidth*i, 0, itemWidth, itemHeight);
            if (index == 2){
                item.hidden = YES;
            }else{
                item.hidden = NO;
            }
            index++;
        }
    }
    [self.tabBar bringSubviewToFront:self.msTabbar];
}

- (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize {
    
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}
//
//- (void)loadNotification {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInvalid) name:TuyaSmartUserNotificationUserSessionInvalid object:nil];
//}
//
//- (void)sessionInvalid {
//        NSLog(@"sessionInvalid");
//        //跳转至登录页面
////        MyLoginViewController *vc = [[MyLoginViewController alloc] init];
////        self.window.rootViewController = vc;
////      [self.window makeKeyAndVisible];
//    [HolfMannAPPDelegate pushToSignInVC:NO];
//}


#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Message_Total_Unread_Changed):
        {
            NSNumber *number = inParam;
            if([number isKindOfClass:[NSNumber class]])
            {
                int unreadCount = [number intValue];
                MSTabbarItem *homeTb;
                if (self.itemsArr.count) {
                    homeTb = [self.itemsArr objectAtIndex:0];
                    if(unreadCount<=0)
                    {
                        homeTb.badgeValue = nil;
                    }
                    else if(unreadCount<=99)
                    {
                        homeTb.badgeValue = [NSString stringWithFormat:@"%d", unreadCount];
                    }
                    else
                    {
                        homeTb.badgeValue = @"99+";
                    }
                }
                
                
            }
        }
            break;
        case MakeID(EUserManager, EUser_To_TdConfig):
        {
            [self configTd];
        }
            break;
        case MakeID(EUserManager, EUser_To_Check_Encryption):
        {
            [self check];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Update_Apns_Token):
        {
            [self syncApnsToken];
        }
            break;
        case MakeID(EUserManager, EUser_Tab_Ex_Menu_Changed):
        {
//            [self reloadTabContentViews];
            [self refreshView];
           
        }
            break;
        default:
            break;
    }
}

- (void)configTd
{
    AuthUserInfo *curUser = [[AuthUserManager shareInstance] currentAuthUser];
    if(curUser != nil)
    {
        [[TelegramManager shareInstance] setTdlibParameters:curUser.data_directoryPath result:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (void)check
{
    [[TelegramManager shareInstance] checkDatabaseEncryptionKey:^(NSDictionary *request, NSDictionary *response) {
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)syncApnsToken
{
    if(!IsStrEmpty([UserInfo shareInstance].pushToken))
    {
        [[TelegramManager shareInstance] registerApnsToken:[UserInfo shareInstance].pushToken resultBlock:^(NSDictionary *request, NSDictionary *response) {
            //[UserInfo showTips:nil des:[NSString stringWithFormat:@"%@", response]];
        } timeout:^(NSDictionary *request) {
        }];
    }
    
}


// 版本检测
- (void)appVersionCheck
{
    [HSUpdateApp hs_updateWithAPPID:APP_ID withBundleId:nil block:^(NSString *currentVersion, NSString *storeVersion, NSString *openUrl, BOOL isUpdate) {
        if(isUpdate)
        {
            NSString *localVersion = [self getIgStoreVersion];
            if(IsStrEmpty(localVersion) || ![localVersion isEqualToString:storeVersion])
            {
                [self goUpdateApp:openUrl storeVersion:storeVersion];
            }
        }
    }];
}

- (NSString *)getIgStoreVersion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"ig_storeVersion"];
}

- (void)saveIgStoreVersion:(NSString *)storeVersion
{
    [[NSUserDefaults standardUserDefaults] setObject:storeVersion forKey:@"ig_storeVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)goUpdateApp:(NSString *)openUrl storeVersion:(NSString *)storeVersion
{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 0)
        {
            NSLog(@"更新");
            if (@available(iOS 10.0, *))
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl] options:@{} completionHandler:nil];
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl] options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
        }
        else if (index == 1)
        {
            NSLog(@"不再提醒");
            [self saveIgStoreVersion:storeVersion];
        }
        else if (index == 2)
        {
            NSLog(@"取消");
        }
    };
    NSArray *items = @[MMItemMake(@"现在更新".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"不再提醒".lv_localized, MMItemTypeHighlight, block),
                       MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block)];
    
    NSString *info = [NSString stringWithFormat:@"%@有新版本，是否更新？".lv_localized,localAppName.lv_localized];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:info items:items];
    [view show];
}
- (UIImageView *)centerImageV{
    if (!_centerImageV){
        _centerImageV = [[UIImageView alloc] init];
        _centerImageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _centerImageV;
}
- (UIImageView *)findImageV{
    if (!_findImageV){
        _findImageV = [[UIImageView alloc] init];
        NSMutableArray *imagesArr = [[NSMutableArray alloc] init];
        for (int i=0; i<21; i++) {
            NSString *numStr = @"";
            if (i<=10){
                numStr = [NSString stringWithFormat:@"0%d", i-1];
            }else{
                numStr = [NSString stringWithFormat:@"%d", i-1];
            }
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_find%@", numStr]];
            [imagesArr addObject:image];
        }
        
        CGFloat time = 0.3;
        _findImageV.animationImages = imagesArr;
        _findImageV.animationDuration = time;
        _findImageV.animationRepeatCount = 1;
        _findImageV.hidden = YES;
        
        MJWeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //
            weakSelf.findImageV.image = imagesArr.lastObject;
        });
    }
    return _findImageV;
}


@end
