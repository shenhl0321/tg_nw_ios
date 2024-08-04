//
//  QTMineVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "QTMineVC.h"
#import "GC_MineInfoCell.h"
#import "GC_MinePakgeCell.h"
#import "GC_MinePakgeCell02.h"
#import "GC_MineInvateCell.h"
#import "GC_MineMenuCell.h"

#import "GC_MyWalletVC.h"
#import "GC_MySetInfoVC.h"
#import "GC_AboutVC.h"
#import "GC_MyScanVC.h"
#import "GC_NearMainVC.h"
#import "UserTimelineVC.h"
#import "GC_MyInfoVC.h"

#import "RecentCallsViewController.h"
#import "MNScanVC.h"
#import "ComputerLoginViewController.h"
#import "MNContactDetailVC.h"
#import "GC_AccountSafeVC.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"

@interface QTMineVC ()<UITableViewDelegate,UITableViewDataSource, MNScanVCDelegate>

@property (nonatomic, strong)UILabel *wtPriceLabel;

@property (nonatomic, strong)WalletInfo *walletInfo;

@end

#define kGC_MinePakgeCell02 @"GC_MinePakgeCell02"
@implementation QTMineVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    self.customNavBar.hidden = YES;
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    // Do any additional setup after loading the view.
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    
    [self syncWalletInfo];
    [self.tableView reloadData];
}

- (void)initUI{

    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MineInfoCell" bundle:nil] forCellReuseIdentifier:@"GC_MineInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MinePakgeCell" bundle:nil] forCellReuseIdentifier:@"GC_MinePakgeCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MineInvateCell" bundle:nil] forCellReuseIdentifier:@"GC_MineInvateCell"];
    [self.tableView registerClass:[GC_MineMenuCell class] forCellReuseIdentifier:@"GC_MineMenuCell"];
    [self.tableView registerNib:[UINib nibWithNibName:kGC_MinePakgeCell02 bundle:nil] forCellReuseIdentifier:kGC_MinePakgeCell02];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
//        make.top.mas_equalTo(kNavBarHeight);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        GC_MineInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MineInfoCell"];
        [cell.setBtn addTarget:self action:@selector(setAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.scanBtn addTarget:self action:@selector(scanAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.saoyisaoBtn addTarget:self action:@selector(saoyisaoAction) forControlEvents:UIControlEventTouchUpInside];
        [cell resetUI];
        MJWeakSelf
        cell.clickBlock = ^{
            GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        return  cell;
    }
    if (indexPath.section == 1) {
//        GC_MinePakgeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MinePakgeCell"];
//        self.wtPriceLabel = cell.priceLab;
//        return  cell;
        GC_MinePakgeCell02 *cell = [tableView dequeueReusableCellWithIdentifier:kGC_MinePakgeCell02 forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if (indexPath.section == 2) {
        GC_MineInvateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MineInvateCell"];
        cell.menuBlock = ^(NSInteger tag) {
            AppConfigInfo *config = [AppConfigInfo sharedInstance];
            switch (tag) {
                case 0:
                {
                    if ([localAppName.lv_localized isEqualToString:@"涨聊".lv_localized]) {
                        [UserInfo showTips:self.view des:@"邀请好友功能未开放".lv_localized];
                        return;
                    }
                    if (config.can_invite_friend) {
                        [self inviteUrlToShare];
                    } else {
                        [UserInfo showTips:self.view des:@"功能暂未开放".lv_localized];
                    }
                    
                }
                    break;
                case 1:
                {
                    if (config.can_see_nearby) {
                        GC_NearMainVC *vc = [[GC_NearMainVC alloc] init];
                        vc.index = 0;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        [UserInfo showTips:self.view des:@"功能暂未开放".lv_localized];
                    }
                    
                }
                    break;
                case 2:
                {
                    if (config.can_see_public_group) {
                        GC_NearMainVC *vc = [[GC_NearMainVC alloc] init];
                        vc.index = 1;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        [UserInfo showTips:self.view des:@"功能暂未开放".lv_localized];
                    }
                    
                }
                    break;
                default:
                    break;
            }
        };
        return  cell;
    }
    
    if (indexPath.section == 3) {
        GC_MineMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MineMenuCell"];
        MJWeakSelf
        cell.menuBlock = ^(NSInteger tag) {
            switch (tag) {
                case 2:
                {
                    UserTimelineVC *user = [[UserTimelineVC alloc] initWithUserid:UserInfo.shareInstance._id];
                    [weakSelf.navigationController pushViewController:user animated:YES];
                }
                    break;
                case 3:
                {
                    [weakSelf scanAction];
                }
                    break;
                case 4:
                {
                    //我的收藏
                    [[TelegramManager shareInstance] createPrivateChat:[UserInfo shareInstance]._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                        if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                        {
                            [AppDelegate gotoChatView:obj];
                        }
                    } timeout:^(NSDictionary *request) {
                    }];
                }
                    break;
                case 5:
                {
                    RecentCallsViewController *vc = [[RecentCallsViewController alloc] init];
                    [weakSelf.navigationController pushViewController:vc animated:YES];

                }
                    break;
                case 6:
                {
                    [weakSelf toOnlineUserService];
                }
                    break;
                    
                case 7:
                {
                    GC_AboutVC *vc = [[GC_AboutVC alloc] init];
                    [weakSelf.navigationController pushViewController:vc animated:YES];

                }
                    break;
                    
                case 8:
                {
                    GC_AccountSafeVC *vc = [[GC_AccountSafeVC alloc] init];
                    [weakSelf.navigationController pushViewController:vc animated:YES];

                }
                    break;
                    
                case 9:
                {
                    GC_MySetInfoVC *vc = [[GC_MySetInfoVC alloc] init];
                    [weakSelf.navigationController pushViewController:vc animated:YES];

                }
                    break;
                    
                default:
                    break;
            }
        };
        return cell;
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (indexPath.section == 0) {
        return SCREEN_WIDTH*480/1125 + 60 + 70;
    }
    
    if (indexPath.section == 1) {
        
        if (!config.can_see_wallet) {
            return 0;
        }
        return 61;
    }
    
    if (indexPath.section == 2) {
        if (!config.can_invite_friend && !config.can_see_nearby && !config.can_see_public_group) {
            return 0;
        }
        return 183;
    }
    
    if (indexPath.section == 3) {
        int count = 3;
        if (config.can_see_blog) {
            count++;
        }
        if (config.can_see_qr_code) {
            count++;
        }
        if (![localAppName isEqualToString:@"涨聊"]) {
            count++;
        }
        return (count+2) * 61 + 40;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        GC_MyWalletVC *vc = [GC_MyWalletVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)setAction{
    GC_MySetInfoVC *vc = [[GC_MySetInfoVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scanAction{
    GC_MyScanVC *vc = [[GC_MyScanVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)saoyisaoAction{
    [self toScan];
}

- (void)toScan
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        MNScanVC *v = [[MNScanVC alloc] init];
//        v.hidesBottomBarWhenPushed = YES;
        v.delegate = self;
        [self.navigationController pushViewController:v animated:YES];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}

- (void)showNeedCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)scanVC:(MNScanVC *)scanvc scanResult:(NSString *)result{
    [self ChatQrScanViewController_Result:result];
}
- (void)ChatQrScanViewController_Result:(NSString *)result
{
    if(!IsStrEmpty(result))
    {
        
        if ([result containsString:@"login?token"]) {//扫码登录
            ComputerLoginViewController *computerVC = [[ComputerLoginViewController alloc] init];
            computerVC.hidesBottomBarWhenPushed = YES;
            computerVC.link = result;
            [self.navigationController pushViewController:computerVC animated:YES];
            return;
        }
        
        long userId = [[UserInfo shareInstance] userIdFromQrString:result];
        NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:[NSURL URLWithString:result]];
        if(userId <= 0)
        {
            if(invitelink && invitelink.length > 5){
                //链接进群
                [UserInfo shareInstance].inviteLink = invitelink;
                [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
            }else{
                [UserInfo showTips:nil des:@"无效二维码".lv_localized];
            }
        }
        else
        {
            [UserInfo show];
            [[TelegramManager shareInstance] requestContactInfo:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                [UserInfo dismiss];
                if(obj != nil && [obj isKindOfClass:UserInfo.class])
                {
                    UserInfo *user = obj;
                    if(userId == [UserInfo shareInstance]._id)
                    {
                        UIViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
                        v.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:v animated:YES];
                    }
                    else
                    {
//                        MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                        v.user = user;
//                        [self.navigationController pushViewController:v animated:YES];
                        
                        if (user.is_contact){
                            QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
                            vc.user = user;
                            [self presentViewController:vc animated:YES completion:nil];
                        }else{
                            QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
                            vc.user = user;
                            [self presentViewController:vc animated:YES completion:nil];
                        }
                    }
                }
                else
                {
                    [UserInfo showTips:nil des:@"获取联系人失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                }
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"获取联系人失败，请稍后重试".lv_localized];
            }];
        }
    }
    else
    {
        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
    }
}


- (void)inviteUrlToShare
{
    NSString *shareText = @"邀请您进入社交新世界，详情快戳".lv_localized;
    NSURL *shareUrl = [NSURL URLWithString:[UserInfo shareInstance].qrString];
    UIImage *shareImage = [UIImage imageNamed:@"Logo1"];
    NSArray *activityItemsArray = @[shareText, shareImage, shareUrl];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItemsArray applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
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

- (void)syncWalletInfo
{
    //请求钱包信息
    [[TelegramManager shareInstance] queryWalletInfo:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[WalletInfo class]])
        {
            WalletInfo *info = obj;
            self.walletInfo = info;
            self.wtPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",info.balance];
        }
        
    } timeout:^(NSDictionary *request) {
        //超时，不做处理
    }];
}


#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateUserInfo):
        {
            [self.tableView reloadData];
            __block UserInfo *userInfo = [UserInfo shareInstance];
            [[TelegramManager shareInstance] requestOrgContactInfo:userInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
                {
                    userInfo.orgUserInfo = obj;
                }
            } timeout:^(NSDictionary *request) {
            }];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]] && updateUser._id == [UserInfo shareInstance]._id)
            {
                [self.tableView reloadData];
            }
        }
            break;
        default:
            break;
    }
}

@end
