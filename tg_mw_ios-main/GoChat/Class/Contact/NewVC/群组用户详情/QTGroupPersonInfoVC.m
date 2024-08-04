//
//  QTGroupPersonInfoVC.m
//  BaseChat
//
//  Created by 漫漫人生路 on 2023/4/9.
//

#import "QTGroupPersonInfoVC.h"
#import "MNContactDetailEditVC.h"
#import "UserinfoHelper.h"
#import "QTBottomAlertView.h"
#import "QTAddPersonVC.h"
#import "QTGroupPersonEditVC.h"

@interface QTGroupPersonInfoVC ()

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageV;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLab;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageV;
/// 群昵称
@property (weak, nonatomic) IBOutlet UILabel *qunnichengLab;
/// 坤坤TG号
@property (weak, nonatomic) IBOutlet UILabel *mowanghaoLab;

@property (nonatomic, strong) OrgUserInfo *orgUserInfo;
@property (nonatomic, strong) ChatInfo *chat;

@end

@implementation QTGroupPersonInfoVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self getData];
}

#pragma mark - initUI
- (void)initUI{
    self.title = @"";
    self.view.backgroundColor = HEXCOLOR(0xFFFFFF);
    
//    if (self.user.is_contact) {
        self.moreBtn.hidden = NO;
//    }else{
//        self.moreBtn.hidden = YES;
//    }
    
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
    NSString *qunName = [[NSString alloc] init];
    if (orgUserInfo) {
        qunName = [orgUserInfo displayName];
    }else{
        qunName = userInfo.displayName;
    }
//    [self refreshMuteBtn];

    if (userInfo.type.isDeleted) {
        qunName = userInfo.displayName;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:UIButton.class]) {
                view.hidden = YES;
            }
        }
    }
//    self.nickNameLab.text = userInfo.username;
    self.nickNameLab.text = userInfo.first_name;
//    self.qunnichengLab.text = [NSString stringWithFormat:@"群昵称：%@", userInfo.first_name];
//    self.mowanghaoLab.text = [NSString stringWithFormat:@"坤坤TG号：%@", @(userInfo._id)];
    
    self.qunnichengLab.text = [NSString stringWithFormat:@"坤坤TG号：%@", userInfo.username];
    self.mowanghaoLab.text = @"";
    
//    NSString *online = [NSString stringWithFormat:@" %@", userInfo.onlineStatus];
//    [self.onlineButton setTitle:online forState:UIControlStateNormal];
    
    [UserinfoHelper getUserExtInfo:userInfo._id completion:^(UserInfoExt * _Nonnull ext) {
        //
//        NSString *age = [NSString stringWithFormat:@" 年龄%ld岁".lv_localized, ext.age];
//        NSString *country = [NSString stringWithFormat:@" %@", ext.countrys];
//        [self.ageButton setTitle:age forState:UIControlStateNormal];
//        [self.locationButton setTitle:country forState:UIControlStateNormal];
        weakSelf.genderImageV.image = ext.sexIcon_QT;
//        self.locationButton.hidden = self.ageButton.hidden = NO;
    }];
}
- (void)getData{
    
}
#pragma mark - get/set

#pragma mark - click
- (IBAction)buttonClick:(UIButton *)sender {
    MJWeakSelf
    if (sender.tag == 1){ // 返回
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (sender.tag == 2){ // 更多
        if (self.user.is_contact) {//已经是朋友了
            [[QTBottomAlertView sharedInstance] alertViewTitle:@"选项" DataArr:@[self.chat.is_blocked?@"移出黑名单":@"加入黑名单", @"删除好友"] ChooseSuccess:^(NSInteger chooseIndex, NSString * _Nonnull chooseStr) {
                //
                if ([chooseStr containsString:@"黑名单"]){
                    __block NSInteger tag = -1;
                    MMPopupItemHandler block = ^(NSInteger index) {
                        tag = index;
                    };
                    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
                    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:weakSelf.chat.is_blocked?@"确定从黑名单中移除吗？".lv_localized:@"确定加入黑名单吗？".lv_localized items:items];
                    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
                        if(tag == 0){
                            [weakSelf blockUser];
                        }
                    };
                    [MMPopupWindow sharedWindow].touchWildToHide = YES;
                    [sheetView show];
                }else if ([chooseStr isEqualToString:@"删除好友"]){
                    [weakSelf deleteFriendClick];
                }
            }];
        }else{
            QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.user = self.user;
            vc.refreshBlock = ^{
                //
                weakSelf.user.is_contact = YES;
                [weakSelf requestOrgUserInfo];
            };
            [self presentViewController:vc animated:YES completion:nil];
        }
    }else if (sender.tag == 3){ // 音视频通话
        if([CallManager shareInstance].canNewCall && ![CallManager shareInstance].isInCalling){
            //
            [[QTBottomAlertView sharedInstance] alertViewTitle:@"音视频通话" DataArr:@[@"语音通话", @"视频通话"] ChooseSuccess:^(NSInteger chooseIndex, NSString * _Nonnull chooseStr) {
                //
                if ([chooseStr isEqualToString:@"语音通话"]){
                    [weakSelf toOnlineVideoOrVoice:NO];
                }else if ([chooseStr isEqualToString:@"视频通话"]){
                    [weakSelf toOnlineVideoOrVoice:YES];
                }
            }];
        }else{
            [UserInfo showTips:nil des:@"无法发起视频通话".lv_localized];
        }
    }else if (sender.tag == 4){ // 发送消息
        [[TelegramManager shareInstance] createPrivateChat:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:ChatInfo.class])
            {
                [AppDelegate gotoChatView:obj];
            }
        } timeout:^(NSDictionary *request) {
            //
        }];
    }else if (sender.tag == 5){ // 设置备注及分组
        QTGroupPersonEditVC *vc = [[QTGroupPersonEditVC alloc] init];
        vc.toBeModifyUser = self.user;
        vc.successBlock = ^(NSString * _Nonnull nickName) {
            //
            weakSelf.user.first_name = nickName;
            [weakSelf requestOrgUserInfo];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
}
- (void)onlineAv_clickType:(NSInteger)type
{
    
}


//toOnlineVideoOrVoice
- (void)toOnlineVideoOrVoice:(BOOL)isVideo
{
    LocalCallInfo *call = [LocalCallInfo new];
    call.channelName = [Common generateGuid];
    call.from = [UserInfo shareInstance]._id;
    call.to = @[[NSNumber numberWithLong:self.user._id]];
    call.chatId = self.user._id;
    call.isVideo = isVideo;
    call.isMeetingAV = NO;
    call.callState = CallingState_Init;
    call.callTime = [NSDate new].timeIntervalSince1970;
    [[CallManager shareInstance] newCall:call fromView:self];
}

#pragma mark - delegate

#pragma mark - other
//从黑名单移除来
- (void)blockUser
{
    [UserInfo show];
    MJWeakSelf
    BOOL isBlock = !self.chat.is_blocked;
    [[TelegramManager shareInstance] blockUser:self.user._id isBlock:isBlock resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response]){
            [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{
            weakSelf.chat.is_blocked = isBlock;
//            [weakSelf refreshBtn];
            [weakSelf requestOrgUserInfo];
            [UserInfo showTips:nil des:isBlock==YES?@"加入黑名单成功":@"移除黑名单成功"];
        }
    } timeout:^(NSDictionary *request) {
        
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized];
    }];
}

//删除好友
- (void)deleteFriendClick{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 1)
        {
            [self performSelector:@selector(doDeleteContactRequest) withObject:nil afterDelay:0.4];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:[NSString stringWithFormat:@"确定删除好友[%@]吗？".lv_localized, self.user.displayName] items:items];
    [view show];
}

//删除好友的
- (void)doDeleteContactRequest
{
    WS(weakSelf)
    [UserInfo show];
    [[TelegramManager shareInstance] deleteContact:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除好友失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已您的好友列表中删除".lv_localized, weakSelf.user.displayName]];
            weakSelf.user.is_contact = NO;
            [weakSelf toggleChatDelete:self.chat];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除好友失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatDelete:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteChatHistory:chat._id isDeleteChat:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除好友会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除好友会话失败，请稍后重试".lv_localized];
    }];
}


@end
