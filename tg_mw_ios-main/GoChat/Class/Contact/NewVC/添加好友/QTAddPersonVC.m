//
//  QTAddPersonVC.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import "QTAddPersonVC.h"
#import "MNContactDetailEditVC.h"
#import "UserinfoHelper.h"
#import "QTBottomAlertView.h"

@interface QTAddPersonVC () <BusinessListenerProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLab;
@property (weak, nonatomic) IBOutlet UILabel *accountLab;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageV;
@property (nonatomic, strong) OrgUserInfo *orgUserInfo;
@property (nonatomic, strong) ChatInfo *chat;
@property (nonatomic, strong) ChatInfo *send_chatInfo;

@end

@implementation QTAddPersonVC

- (void)dealloc{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}
#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateContactInfo):
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]])
            {
                if(self.user._id == updateUser._id)
                {
                    self.user = updateUser;
                    [self requestOrgUserInfo];
//                    [self resetBaseInfo];
//                    [self.tableView reloadData];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self getData];
}

#pragma mark - initUI
- (void)initUI{
    self.title = @"";
    self.view.backgroundColor = HEXCOLOR(0xFFFFFF);
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    [self requestOrgUserInfo];
}
#pragma mark - getData
- (void)requestOrgUserInfo{
    MJWeakSelf
    [[TelegramManager shareInstance] requestOrgContactInfo:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
        {
            weakSelf.orgUserInfo = obj;
            [weakSelf refreshUIWithUserInfo:weakSelf.user orgUserInfo:weakSelf.orgUserInfo];
//            [self resetBaseInfo];
//            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
        //
    }];
}
- (void)refreshUIWithUserInfo:(UserInfo *)userInfo orgUserInfo:(OrgUserInfo *)orgUserInfo{
    self.user = userInfo;
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:userInfo._id];
   
    MJWeakSelf
    self.chat = chat;
    
    if(self.user.profile_photo != nil)
    {
        if(!self.user.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", self.user._id] fileId:self.user.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.avatarImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.user.displayName.length>0)
            {
                text = [[self.user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.avatarImageV withSize:self.avatarImageV.frame.size withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.avatarImageV];
            self.avatarImageV.image = [UIImage imageWithContentsOfFile:self.user.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.avatarImageV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.user.displayName.length>0)
        {
            text = [[self.user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.avatarImageV withSize:self.avatarImageV.frame.size withChar:text];
    }
    
    self.nickNameLab.text = userInfo.displayName;
    self.accountLab.text = [NSString stringWithFormat:@"坤坤TG号：%@", userInfo.username];
    
    [UserinfoHelper getUserExtInfo:userInfo._id completion:^(UserInfoExt * _Nonnull ext) {
        //
        weakSelf.genderImageV.image = ext.sexIcon_QT;
    }];
}
- (void)getData{
    self.send_chatInfo = [[TelegramManager shareInstance] getChatInfo:self.user._id];
    if (!self.send_chatInfo) {
        [[TelegramManager shareInstance] createPrivateChat:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
                self.send_chatInfo = (ChatInfo *)obj;
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}
#pragma mark - get/set

#pragma mark - click
- (IBAction)buttonClick:(UIButton *)sender {
    if (sender.tag == 1){ // 返回
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (sender.tag == 2){ // 添加好友
        [self addContact_click:sender];
    }
}

- (BOOL)canAddFriend
{
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        if(info.onlyWhiteAddFriend)
        {
            UserInfo *userInfo = [UserInfo shareInstance];
            return self.orgUserInfo.isInternal || userInfo.orgUserInfo.isInternal;
        }
    }
    return YES;
}
- (void)doAddContactRequest
{
    MJWeakSelf
    if (![self canAddFriend]) {
        [UserInfo showTips:nil des:@"当前设置不允许添加好友".lv_localized];
        return;
    }
    [UserInfo show];
    [[TelegramManager shareInstance] addContact:self.user resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"添加好友失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已被添加到您的好友列表中".lv_localized, weakSelf.user.displayName]];
            [[TelegramManager shareInstance] sendBeFriendMessage:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
                //
                if (weakSelf.refreshBlock){
                    weakSelf.refreshBlock();
                }
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            } timeout:^(NSDictionary *request) {
                //
            }];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"添加好友失败，请稍后重试".lv_localized];
    }];
}
//添加好友的
- (void)addContact_click:(id)sender
{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 1)
        {
            [self performSelector:@selector(doAddContactRequest) withObject:nil afterDelay:0.4];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:[NSString stringWithFormat:@"确定添加[%@]为好友吗？".lv_localized, self.user.displayName] items:items];
    [view show];
}

#pragma mark - delegate

#pragma mark - other


@end
