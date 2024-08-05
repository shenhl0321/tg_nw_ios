//
//  MNGroupInfoVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNGroupInfoVC.h"
#import "CZGroupFirTableViewCell.h"
#import "CZGroupShareLinkTableViewCell.h"
#import "CZGroupNoticeTableViewCell.h"
#import "GC_MySetCell.h"
#import "CZShowAllMemberViewController.h"
#import "CZGroupQRCodeViewController.h"
#import "CZShareLinkMenuModel.h"
#import "CZGroupMediaHeaderView.h"
#import "CZGroupMemberFirTableViewCell.h"
#import "CZMediaTableViewCell.h"
#import "MNGroupSettingVC.h"
#import "PhotoAVideoPreviewPagesViewController.h"
#import "FilePreviewViewController.h"
#import "PlayAudioManager.h"
#import "CZLinkMsgTableViewCell.h"
#import "CZNOPreviewTableViewCell.h"
#import "MNEditGroupViewController.h"
#import "MNContactDetailVC.h"
#import "MNAddGroupVC.h"
#import "GC_MyInfoVC.h"
#import "MNGroupIntroVC.h"
#import "MNGroupAnnounceVC.h"
#import "MNContactDetailSearchVC.h"
#import "TF_RequestManager.h"
#import "WebHtmlInfoRequest.h"
#import "GC_ModifyFieldVC.h"
#import "QTGroupFirTableViewCell.h"
#import "QTGroupWenJianVC.h"
#import "QTGroupHeadView01.h"
#import "QTGroupHeadView02.h"
#import "QTGroupHeadView03.h"
#import "QTGroupPersonInfoVC.h"
#import "QTSetInfoBottomView.h"
#import "MNChatViewController.h"
#import "TZImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+Height.h"

@interface MNGroupInfoVC ()
<BusinessListenerProtocol, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TimerCounterDelegate,CZGroupFirTableViewCellDelegate,YBPopupMenuDelegate,CZGroupShareLinkTableViewCellDelegate,CZGroupMediaHeaderViewDelegate,CZMediaTableViewCellDelegate, QTGroupFirTableViewCellDelegate>


@property (nonatomic, strong) BasicGroupInfo *groupInfo;
@property (nonatomic, strong) BasicGroupFullInfo *groupFullInfo;
@property (nonatomic, strong) SuperGroupInfo *super_groupInfo;
@property (nonatomic, strong) SuperGroupFullInfo *super_groupFullInfo;
//群成员字典表
@property (nonatomic, strong) NSMutableDictionary *membersDic;
//群成员列表
@property (nonatomic, strong) NSMutableArray *membersList;
//群管理员列表
@property (nonatomic, strong) NSArray *memberIsManagersList;
//公告
@property (nonatomic, strong) MessageInfo *lastPinnedMsg;
@property (nonatomic, strong) TimerCounter *reloadMembersTimer;
@property (nonatomic,assign) BOOL isShowAll;//公告
@property (nonatomic,assign) NSInteger currentSel;
@property (nonatomic,strong) CZGroupMediaHeaderView *headerView;
@property (nonatomic,strong) NSMutableArray *secondArray;//媒体
@property (nonatomic,strong) NSMutableArray *thridArray;//文件
@property (nonatomic,strong) NSMutableArray *fourArray;//语音
@property (nonatomic,strong) NSMutableArray *fiveArray;//链接
@property (nonatomic,strong) NSMutableArray *sixArray;//GIF

/// 媒体高度
@property (nonatomic,assign) CGFloat mediaHeight;
/// gif高度
@property (nonatomic,assign) CGFloat gifHeight;

/// 媒体是否还有更多数据 1~5 媒体、文件、语言、链接、GIF  1没有任何数据，2加载完成，3还有数据
@property (nonatomic,strong) NSMutableDictionary *dataStatus;
@property (nonatomic,assign) int offset;

@end

@implementation MNGroupInfoVC

- (NSMutableDictionary *)dataStatus{
    if (!_dataStatus) {
        _dataStatus = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    return _dataStatus;
}

- (NSMutableArray *)secondArray{
    if (!_secondArray) {
        _secondArray = [NSMutableArray array];
    }
    return _secondArray;
}

- (NSMutableArray *)thridArray{
    if (!_thridArray) {
        _thridArray = [NSMutableArray array];
    }
    return _thridArray;
}

- (NSMutableArray *)fourArray{
    if (!_fourArray) {
        _fourArray = [NSMutableArray array];
    }
    return _fourArray;
}

- (NSMutableArray *)fiveArray{
    if (!_fiveArray) {
        _fiveArray = [NSMutableArray array];
    }
    return _fiveArray;
}

- (NSMutableArray *)sixArray{
    if (!_sixArray) {
        _sixArray = [NSMutableArray array];
    }
    return _sixArray;
}

- (CZGroupMediaHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[CZGroupMediaHeaderView alloc]init];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (NSMutableArray *)messageList
{
    if(_messageList == nil)
    {
        _messageList = [NSMutableArray array];
    }
    return _messageList;
}

- (NSMutableArray *)membersList{
    if (!_membersList) {
        _membersList = [NSMutableArray array];
    }
    return _membersList;
}

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
    
    [self.reloadMembersTimer stopCountProcess];
    self.reloadMembersTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self syncGroupNotice];
    [self getChatMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.offset = 0;
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    //
    self.reloadMembersTimer = [TimerCounter new];
    self.reloadMembersTimer.delegate = self;
    self.currentSel = 100;
    
    //先同步会话信息
    [self syncChatInfo];
    [self.customNavBar setTitle:@"群组信息".lv_localized];
    [self resetBaseInfo];
    [self getAllQuoteMessage];
    
    [self setRefresh];
    [self loadDataWithIndex:1 loadMoar:NO];
    [self loadDataWithIndex:2 loadMoar:NO];
    [self loadDataWithIndex:3 loadMoar:NO];
    [self loadDataWithIndex:4 loadMoar:NO];
    [self loadDataWithIndex:5 loadMoar:NO];
    
    self.view.backgroundColor = HEXCOLOR(0xF5F9FA);
    self.contentView.backgroundColor = HEXCOLOR(0xF5F9FA);
    self.tableView.backgroundColor = HEXCOLOR(0xF5F9FA);
}

- (void)setRefresh{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [footer setTitle:@"上拉加载更多".lv_localized forState:MJRefreshStateIdle];
    [footer setTitle:@"正在刷新...".lv_localized forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据".lv_localized forState:MJRefreshStateNoMoreData];

    footer.triggerAutomaticallyRefreshPercent = 0.5;
    self.tableView.mj_footer = footer;
}

- (void)loadMoreData{
    [self loadDataWithIndex:self.currentSel - 100 loadMoar:YES];
}

- (void)endLoadMore:(BOOL)noData hiddenFooter:(BOOL)hidden{

    [self.tableView.mj_footer endRefreshing];
    if (hidden) {
        [self.tableView.mj_footer setHidden:YES];
    } else if (noData) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.tableView reloadData];
}


- (void)loadDataWithIndex:(NSInteger)index loadMoar:(BOOL)loadMore{
    __block NSInteger type = index;
    __block BOOL load = loadMore;
    int startId = 0;
    if(loadMore){
        MessageInfo *firstInfo;
        switch (index) {
            case 3:
                firstInfo = self.secondArray.lastObject;
                break;
            case 2:
                firstInfo = self.thridArray.lastObject;
                break;
            case 1:
                firstInfo = self.fourArray.lastObject;
                break;
            case 4:
                firstInfo = self.fiveArray.lastObject;
                break;
            case 5:
                firstInfo = self.sixArray.lastObject;
                break;
                
            default:
                break;
        }
        startId = (int)firstInfo._id;
    }
        
    
    
    MJWeakSelf
    [TF_RequestManager searchChatMessagesWithType:type userId:nil startId:startId chatId:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, NSMutableArray *obj) {
        switch (type) {
            case 3:
            {
                CGFloat itemW = (SCREEN_WIDTH - 40)/3;
                if (!load) {
                    [weakSelf.secondArray removeAllObjects];
                }
                [weakSelf.secondArray addObjectsFromArray:obj];
                weakSelf.mediaHeight = (itemW + 10) * (weakSelf.secondArray.count + 2) / 3;
            }
                break;
            case 2:
                if (!load) {
                    [weakSelf.thridArray removeAllObjects];
                }
                
                [weakSelf.thridArray addObjectsFromArray:obj];
                break;
            case 1:
                if (!load) {
                    [weakSelf.fourArray removeAllObjects];
                }
               
                [weakSelf.fourArray addObjectsFromArray:obj];
                break;
            case 4:
                if (!load) {
                    [weakSelf.fiveArray removeAllObjects];
                }
                [weakSelf requestHeaderInfo:obj];
                break;
            case 5:{
                if (!load) {
                    [weakSelf.sixArray removeAllObjects];
                }
                [weakSelf.sixArray addObjectsFromArray:obj];
                
                CGFloat itemW = (SCREEN_WIDTH - 40)/3;
                weakSelf.gifHeight = (itemW + 10) * (weakSelf.sixArray.count + 2) / 3 +  40;
                break;
            }
                
            default:
                break;
        }
        NSInteger status = 0;
        if (obj.count < 1) {
            NSInteger lastStatus = [weakSelf.dataStatus[@(type)] integerValue];
            if (lastStatus < 2) { // 之前没有设置过或者设置成了没有数据
                [weakSelf endLoadMore:YES hiddenFooter:YES];
                status = 1;
            } else {
                [weakSelf endLoadMore:YES hiddenFooter:NO];
                status = 2;
            }
        }
        else {
            [weakSelf endLoadMore:NO hiddenFooter:NO];
            status = 3;
        }
        weakSelf.dataStatus[@(type)] = @(status);
//        weak
        [weakSelf.tableView reloadData];
        
    } timeout:^(NSDictionary *request) {
        [weakSelf.tableView reloadData];
        [weakSelf endLoadMore:NO hiddenFooter:NO];
    }];
}

- (void)requestHeaderInfo:(NSArray<MessageInfo *> *)arr{
    
    for (MessageInfo *msg in arr) {
        WebpageModel *webmodel = msg.content.web_page;
        if (webmodel) {
            [self.fiveArray addObject:msg];
        } else {
            __block MessageInfo *info = msg;
            
//            NSArray *arr = [CZCommonTool getURLFromStr:info.textTypeContent];
//            NSString *url = @"";
//            if (arr && arr.count > 0) {
//                url = [arr firstObject];
//            }else{
//                NSArray *sep = [info.textTypeContent componentsSeparatedByString:@" "];
//                if (sep.count > 0) {
//                    url = sep.firstObject;
//                } else {
//                    url = info.textTypeContent;
//                }
//            }
            
            NSArray<TextUnit *> *urls = [CZCommonTool parseURLWithContent:info.textTypeContent];
            if (urls.count < 1) {
                continue;
            }
            TextUnit *textUnit = urls.firstObject;
            NSString *url = textUnit.transferredContent;
            info.linkUrls = urls;
            [[WebHtmlInfoRequest shareInstance] getWebHtmlHeaderInfo:url success:^(id  _Nonnull response, NSDictionary * _Nonnull data) {
                info.headerInfo = data;
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                
            }];
            [self.fiveArray addObject:info];
        }
        
    }
}

- (void)settingRightNavBar{
    if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
//        [self.customNavBar setRightBtnWithImageName:nil title:@"编辑".lv_localized highlightedImageName:nil];
    }
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self click_edit];
}
- (void)click_edit{
    if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
        
        MNEditGroupViewController *vc = [[MNEditGroupViewController alloc] init];
        vc.chatInfo = self.chatInfo;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)getChatMessage{
    if(self.super_groupFullInfo){//已经获取过 二次进去此页面
        [[TelegramManager shareInstance] getChatPinnedMessage:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            //成功
            //检查状态
            [self checkUserChatState];
            [self syncFullGroupInfo];
        } timeout:^(NSDictionary *request) {
        }];
    }else{//首次进去此页面
        //检查状态
        [self checkUserChatState];
        [self syncFullGroupInfo];
    }
}

- (void)syncChatInfo
{
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.chatInfo._id];
    if(chat != nil)
    {
        self.chatInfo = chat;
    }
}

- (void)resetSwitchInfo{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)notificationSwitchClick
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatDisableNotification:self.chatInfo._id isDisableNotification:!self.chatInfo.default_disable_notification  resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
//            [self resetSwitchInfo];
            [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [self syncChatInfo];
            [self resetSwitchInfo];
            
//            self.headview01.tongzhiBtn.selected = !self.chatInfo.default_disable_notification;
            
            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
//        [self resetSwitchInfo];
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized];
    }];
}

- (void)pinSwitchClick
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatIsPinned:self.chatInfo._id isPinned:!self.chatInfo.is_pinned resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [self resetSwitchInfo];
            [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [self syncChatInfo];
            [self resetSwitchInfo];
        }
    } timeout:^(NSDictionary *request) {
        [self resetSwitchInfo];
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatDeleteConfirm
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定清空聊天记录吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//删除
            [self toggleChatDelete];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)toggleChatDelete
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteChatHistory:self.chatInfo._id isDeleteChat:NO resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"清空聊天记录失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:@"聊天记录已清空".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"清空聊天记录失败，请稍后重试".lv_localized];
    }];
}

- (void)resetBaseInfo
{
//    [self.headerImageView setClipsToBounds:YES];
//    [self.headerImageView setContentMode:UIViewContentModeScaleAspectFill];
//    if(self.chatInfo.photo != nil)
//    {
//        if(!self.chatInfo.photo.isSmallPhotoDownloaded)
//        {
//            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
//            //本地头像
//            self.headerImageView.image = nil;
//            self.headerImageView1.image = nil;
//            unichar text = [@" " characterAtIndex:0];
//            if(self.chatInfo.title.length>0)
//            {
//                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
//            }
//            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(42, 42) withChar:text];
//            [UserInfo setColorBackgroundWithView:self.headerImageView1 withSize:CGSizeMake(42, 42) withChar:text];
//        }
//        else
//        {
//            [UserInfo cleanColorBackgroundWithView:self.headerImageView];
//            [UserInfo cleanColorBackgroundWithView:self.headerImageView1];
//            self.headerImageView.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
//            self.headerImageView1.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
//        }
//    }
//    else
//    {
//        //本地头像
//        self.headerImageView.image = nil;
//        self.headerImageView1.image = nil;
//        unichar text = [@" " characterAtIndex:0];
//        if(self.chatInfo.title.length>0)
//        {
//            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
//        }
//        [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(42, 42) withChar:text];
//        [UserInfo setColorBackgroundWithView:self.headerImageView1 withSize:CGSizeMake(42, 42) withChar:text];
//    }
//    self.groupNameLabel.text = self.chatInfo.title;
//    self.groupNameLabel1.text = self.chatInfo.title;
}

- (void)checkUserChatState
{
    if(self.chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupInfo class]])
            {
                self.super_groupInfo = obj;
                [self settingRightNavBar];
//                [self.membersListCell resetTitle:[NSString stringWithFormat:@"群成员(%d人)", self.super_groupInfo.member_count]];
//                [self.membersListCell resetMembersList:self.membersList canAdd:[self canInvideMember] canDelete:[self canEditGroupSetting]];
//                [self.memberIsManagersListCell resetMembersList:self.memberIsManagersList canAdd:[self canEditGroupManagerSetting] canDelete:[self canEditGroupManagerSetting]];
//                [self.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    else
    {//普通群组
        //获得群组基本资料
        [[TelegramManager shareInstance] getBasicGroupInfo:self.chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[BasicGroupInfo class]])
            {
                self.groupInfo = obj;
//                [self.membersListCell resetTitle:[NSString stringWithFormat:@"群成员(%d人)", self.groupInfo.member_count]];
//                [self.membersListCell resetMembersList:self.membersList canAdd:[self canInvideMember] canDelete:[self canEditGroupSetting]];
//                [self.memberIsManagersListCell resetMembersList:self.memberIsManagersList canAdd:[self canEditGroupManagerSetting] canDelete:[self canEditGroupManagerSetting]];
//                [self.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (BOOL)canInvideMember
{
    BOOL canInvide = [self canEditGroupSetting];
    if(canInvide)
    {
        return canInvide;
    }
    return self.chatInfo.permissions.can_invite_users;
}

- (BOOL)canEditGroupSetting
{
    if(self.chatInfo.isSuperGroup)
    {
        switch ([self.super_groupInfo.status getMemberState])
        {
            case GroupMemberState_Administrator:
                //管理员
                return YES;
            case GroupMemberState_Creator:
                //创建者
                if(self.super_groupInfo.status.is_member)
                {//创建者已不在群组
                    return YES;
                }
                break;
            case GroupMemberState_Left:
                //不在群组
                break;
            case GroupMemberState_Member:
                //普通成员
                break;
            case GroupMemberState_Banned:
                //被禁用
                break;
            case GroupMemberState_Restricted:
                //被禁言
                break;
            default:
                break;
        }
    }
    else
    {
        if(self.groupInfo.is_active)
        {//是否激活
            switch ([self.groupInfo.status getMemberState])
            {
                case GroupMemberState_Administrator:
                    //管理员
                    return YES;
                case GroupMemberState_Creator:
                    //创建者
                    if(self.groupInfo.status.is_member)
                    {//创建者已不在群组
                        return YES;
                    }
                    break;
                case GroupMemberState_Left:
                    //不在群组
                    break;
                case GroupMemberState_Member:
                    //普通成员
                    break;
                case GroupMemberState_Banned:
                    //被禁用
                    break;
                case GroupMemberState_Restricted:
                    //被禁言
                    break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (BOOL)canEditGroupManagerSetting
{
    if(self.chatInfo.isSuperGroup)
    {
        switch ([self.super_groupInfo.status getMemberState])
        {
            case GroupMemberState_Creator:
                //创建者
                if(self.super_groupInfo.status.is_member)
                {//创建者还在群组
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    else
    {
        if(self.groupInfo.is_active)
        {//是否激活
            switch ([self.groupInfo.status getMemberState])
            {
                case GroupMemberState_Creator:
                    //创建者
                    if(self.groupInfo.status.is_member)
                    {//创建者还在群组
                        return YES;
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (BOOL)isOwnerGroup
{
    if(self.chatInfo.isSuperGroup)
    {
        switch ([self.super_groupInfo.status getMemberState])
        {
            case GroupMemberState_Creator:
                //创建者
                if(self.super_groupInfo.status.is_member)
                {
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    else
    {
        if(self.groupInfo.is_active)
        {//是否激活
            switch ([self.groupInfo.status getMemberState])
            {
                case GroupMemberState_Creator:
                    //创建者
                    if(self.groupInfo.status.is_member)
                    {
                        return YES;
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (void)syncFullGroupInfo
{
    if(self.chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupFullInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupFullInfo class]])
            {
                self.super_groupFullInfo = obj;
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//                [self.memberIsManagersListCell resetTitle:[NSString stringWithFormat:@"群管理员(%d人)", self.super_groupFullInfo.administrator_count]];
                //获取超级群组成员列表
                [self getSuperMembers];
                //获取超级群组管理员列表
                [self getSuperAdminMembers];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    else
    {//普通群组
        [[TelegramManager shareInstance] getBasicGroupFullInfo:self.chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[BasicGroupFullInfo class]])
            {
                self.groupFullInfo = obj;
                [self resetMembers:self.groupFullInfo.members];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (void)resetMembers:(NSArray *)list
{
    [self.membersList removeAllObjects];
    [self.membersList addObjectsFromArray:self.groupFullInfo.members];
    NSMutableArray *managersList = [NSMutableArray array];
    [self.membersDic removeAllObjects];
    for(GroupMemberInfo *member in self.membersList)
    {
        if([member isManagerRole])
        {
            [managersList addObject:member];
        }
        [self.membersDic setObject:member forKey:[NSNumber numberWithLong:member.user_id]];
    }
    self.memberIsManagersList = managersList;
    [self.tableView reloadData];
}

- (void)getSuperMembers {
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterRecent" keyword:nil offset:self.offset limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:[NSArray class]]) {
            NSArray *list = (NSArray *)obj;
            if(self.offset + list.count < [response[@"total_count"] intValue]){
                [self.membersList removeAllObjects];
                [self.membersList addObjectsFromArray:list];
                self.offset = (int)list.count;
                [self getSuperMembers];
            }else{
                [self.membersList removeAllObjects];
                [self.membersList addObjectsFromArray:list];
                [self.tableView reloadData];
            }
            NSLog(@"");
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)getSuperAdminMembers {
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterAdministrators" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]]) {
            NSArray *list = (NSArray *)obj;
            self.memberIsManagersList = list;
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)reloadBasicGroupFullInfo:(BasicGroupFullInfo *)info
{
    self.groupFullInfo = info;
    [self resetMembers:self.groupFullInfo.members];
}

- (void)reloadSuperGroupFullInfo:(SuperGroupFullInfo *)info
{
    self.super_groupFullInfo = info;
//    [self.memberIsManagersListCell resetTitle:[NSString stringWithFormat:@"群管理员(%d人)", self.super_groupFullInfo.administrator_count]];
    //性能考虑
    [self.reloadMembersTimer stopCountProcess];
    [self.reloadMembersTimer startCountProcess:1 repeat:NO];
    NSLog(@"添加好友 - gggggggggg");
}

- (NSString *)myNickname {
    NSString *nickname = UserInfo.shareInstance.displayName;
    if (self.membersList.count == 0) {
        return nickname;
    }
    for (GroupMemberInfo *m in self.membersList) {
        if (m.user_id == UserInfo.shareInstance._id &&
            [NSString xhq_notEmpty:m.nickname]) {
            nickname = m.nickname;
            break;
        }
    }
    return nickname;
}

#pragma mark - 群通知
- (NSString *)resetNoticeInfoWithDefault:(BOOL)defaultValue{
    if(self.lastPinnedMsg != nil)
    {
        NSString *text = self.lastPinnedMsg.description;
        if([text hasPrefix:GROUP_NOTICE_PREFIX])
        {
            text = [text substringFromIndex:GROUP_NOTICE_PREFIX.length];
        }
        return text;
    }
    else
    {
        if (defaultValue) {
            return @"未设置".lv_localized;
        }else{
            return @"";
        }
        
    }
}
- (NSString *)resetNoticeInfo
{
    return [self resetNoticeInfoWithDefault:YES];
}

- (void)syncGroupNotice
{
    [[TelegramManager shareInstance] getChatPinnedMessage:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
            [TelegramManager parseMessageContent:[response objectForKey:@"content"] message:msg];
            self.lastPinnedMsg = msg;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

#pragma mark - 群简介

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 5) {
//        return self.headerView;
        QTGroupHeadView02 *headview;
        if([AppConfigInfo sharedInstance].can_see_complaint){
            headview = [[NSBundle mainBundle] loadNibNamed:@"QTGroupHeadView02" owner:nil options:nil].firstObject;
        }else{
            headview = [[NSBundle mainBundle] loadNibNamed:@"QTGroupHeadView02" owner:nil options:nil][1];
        }
        headview.frame = CGRectMake(0, 0, SCREEN_WIDTH, 192);
        [headview.tousuBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [headview.jsqzBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [headview.ltjlBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        if ([self isOwnerGroup]) {
            //解散
            headview.titleLab.text = @"删除并退出";
        }else{
            //退出
            headview.titleLab.text = @"退出群组";
        }
        return headview;
    }else if (section == 1) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
//        view.backgroundColor = HEXCOLOR(0xF5F9FA);
//        return view;
        QTGroupHeadView01 *headview = [[NSBundle mainBundle] loadNibNamed:@"QTGroupHeadView01" owner:nil options:nil].firstObject;
        headview.frame = CGRectMake(0, 0, SCREEN_WIDTH, 70 + [self getGroupListViewHei]);
        [headview.qcyBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
//        NSMutableArray *dataArr = [[NSMutableArray alloc] initWithArray:self.membersList];
        
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        for (int i=0; i<self.membersList.count; i++) {
            if (i<7*2){
                [dataArr addObject:self.membersList[i]];
            }
        }
        
//        [dataArr addObject:@"add"];
//        if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
//            [dataArr addObject:@"delete"];
//        }
        headview.personNum = self.membersList.count;
        headview.dataArr = [dataArr copy];
        MJWeakSelf
        headview.chooseBlock = ^(NSInteger index) {
            //
            NSObject *detailModel = dataArr[index];
            if([detailModel isKindOfClass:[GroupMemberInfo class]]){
                GroupMemberInfo *info = (GroupMemberInfo *)detailModel;
                [weakSelf MemberListCell_Click_Membermember:info];
            }else if([detailModel isKindOfClass:[MessageInfo class]]){
                NSLog(@"头像类型 - 2");
            }else if([detailModel isKindOfClass:[NSString class]]){
                NSLog(@"头像类型 - 3");
                if([@"add" isEqualToString:(NSString *)detailModel]) // 添加
                {
                    //添加成员
                    BOOL canaddMember = [weakSelf canInvideMember];
                    if (canaddMember) {//增加成员
                        MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
                        chooseView.chooseType = MNContactChooseType_Group_Add_Member;
                        chooseView.group_membersList = weakSelf.membersList;
                        chooseView.chatId = weakSelf.chatInfo._id;
                        chooseView.isSuperGroup = weakSelf.chatInfo.isSuperGroup;
                        [weakSelf.navigationController pushViewController:chooseView animated:YES];
                    }else{
                        [UserInfo showTips:weakSelf.view des:@"无邀请新成员权限!".lv_localized];
                    }
                }
                if([@"delete" isEqualToString:(NSString *)detailModel]) // 删除
                {
                    //删除成员
                    BOOL canaddMember = [weakSelf canInvideMember];
                    if (canaddMember) {//增加成员
                        MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
                        chooseView.chooseType = MNContactChooseType_Group_Add_Member;
                        chooseView.group_membersList = weakSelf.membersList;
                        chooseView.chatId = weakSelf.chatInfo._id;
                        chooseView.isSuperGroup = weakSelf.chatInfo.isSuperGroup;
                        [weakSelf.navigationController pushViewController:chooseView animated:YES];
                    }else{
                        [UserInfo showTips:weakSelf.view des:@"无邀请新成员权限!".lv_localized];
                    }
                }
            }
        };
        return headview;
    }else if (section == 2) {
        QTGroupHeadView03 *headview = [[NSBundle mainBundle] loadNibNamed:@"QTGroupHeadView03" owner:nil options:nil].firstObject;
        headview.frame = CGRectMake(0, 0, SCREEN_WIDTH, 142);
        headview.nickNameLab.text = [self myNickname];
        headview.tongzhiBtn.selected = !self.chatInfo.default_disable_notification;
        [headview.nickNameBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [headview.tongzhiBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        return headview;
    }else{
        return [UIView new];
    }
}


/// 跳转
/// - Parameter sender.tag: 1、群成员 2、查找聊天记录
- (void)clickButton:(UIButton *)sender{
    MJWeakSelf
    if (sender.tag == 1){ // 添加成员
        //添加成员
        BOOL canaddMember = [self canInvideMember];
        if (canaddMember) {//增加成员
//                ContactChooseViewController *chooseView = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactChooseViewController"];
//                chooseView.hidesBottomBarWhenPushed = YES;
//            MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
//            chooseView.chooseType = MNContactChooseType_Group_Add_Member;
//            chooseView.group_membersList = self.membersList;
//            chooseView.chatId = self.chatInfo._id;
//            chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
//            [self.navigationController pushViewController:chooseView animated:YES];
            
            CZShowAllMemberViewController *allMemberVC = [CZShowAllMemberViewController new];
            allMemberVC.chatInfo = self.chatInfo;
            allMemberVC.cusPermissionsModel = self.cusPermissionsModel;
            [self.navigationController pushViewController:allMemberVC animated:YES];
        }else{
            [UserInfo showTips:self.view des:@"无邀请新成员权限!".lv_localized];
        }
    }else if (sender.tag == 2){ // 查找聊天记录
        MNContactDetailSearchVC *vc = [[MNContactDetailSearchVC alloc] init];
        vc.chatId = self.chatInfo._id;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 3){ // 投诉
        NSString *url = [NSString stringWithFormat:@"%@?uid=%ld&chatid=%ld", KHostEReport, [UserInfo shareInstance]._id, self.chatInfo._id];
        BaseWebViewController *v = [BaseWebViewController new];
        v.hidesBottomBarWhenPushed = YES;
        v.titleString = @"投诉".lv_localized;
        v.urlStr = url;
        v.type = WEB_LOAD_TYPE_URL;
        [self.navigationController pushViewController:v animated:YES];
    }else if (sender.tag == 4){ // 解散群组
        if ([self isOwnerGroup]) {
            //解散
            [self deleteGroupConfirm];
        }else{
            //退出
            [self delAndLeftConfirm];
        }
    }else if (sender.tag == 6){ // 修改本群昵称
        [[QTSetInfoBottomView sharedInstance] alertViewType:QT_Set_My_Group_Nickname ChatId:[NSString stringWithFormat:@"%ld", [ChatInfo toServerPeerId:self.chatInfo._id]] TitleStr:@"我在本群的昵称" ContentStr:[self myNickname] PlaceStr:@"请输入我在本群的昵称"];
        [[QTSetInfoBottomView sharedInstance] setSuccessBlock:^(NSString * _Nonnull contentStr) {
            //
            [weakSelf syncGroupNotice];
            [weakSelf getChatMessage];
            [weakSelf.tableView reloadData];
        }];
    }else if (sender.tag == 7){ // 通知
        //关闭开启通知
        [self notificationSwitchClick];
    }
}

- (CGFloat)getGroupListViewHei{
    
    NSInteger count = 7;
    CGFloat space = 10;
    CGFloat left_W = 20;
    CGFloat right_W = left_W;
    CGFloat view_W = (SCREEN_WIDTH-left_W-right_W-(count-1)*space)/count;
    CGFloat view_H = view_W;
    
//    NSMutableArray *dataArr = [[NSMutableArray alloc] initWithArray:self.membersList];
    NSMutableArray *dataArr = [[NSMutableArray alloc] init];
    for (int i=0; i<self.membersList.count; i++) {
        if (i<count*2){
            [dataArr addObject:self.membersList[i]];
        }
    }
    
//    [dataArr addObject:@"add"];
//    if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
//        [dataArr addObject:@"delete"];
//    }
    
    if (dataArr.count == 0){
        return 0;
    }
    return ((dataArr.count + 6) / 7) * (view_H+space) + 20 - space;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 5) {
        return 192;
    }else if (section == 1) {
        return 70 + [self getGroupListViewHei];
    }else if (section == 2) {
        return 142;
    }else{
        return 0.01;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
//设置UITabView每组显示几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 5) {
        return 0;
    }else if (section == 3){
        return 0;
    }else if (section == 1){
        return [AppConfigInfo sharedInstance].can_see_share ? 1 : 0;
    }else{
        return 1;
    }
}
//设置每一行的每一组显示单元格的什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
//            CZGroupFirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupFirTableViewCell"];
            QTGroupFirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QTGroupFirTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"QTGroupFirTableViewCell" owner:nil options:nil] firstObject];
            }
            if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
                cell.guanliView.hidden = NO;
            }else{
                cell.guanliView.hidden = YES;
            }
            cell.delegate = self;
            cell.chatInfo = self.chatInfo;
            cell.membersList = self.membersList;
            return cell;
        }
            break;
        case 3: {
            GC_MySetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"GC_MySetCell" owner:nil options:nil] firstObject];
            }
            cell.titleLab.text = @"我在本群的昵称".lv_localized;
            cell.contentLab.text = [self myNickname];
            cell.lineView.hidden = YES;
            cell.leftWidCon.constant = 20;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case 2:
        {
            CZGroupNoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupNoticeTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupNoticeTableViewCell" owner:nil options:nil] firstObject];
                cell.mainLabel.numberOfLines = 1;
            }
            if (indexPath.section == 2) {
                [cell refreshMainLabelWithText:@"群简介".lv_localized];
                if ([Util objToStr:self.super_groupFullInfo.group_description].length) {
                    cell.gonggaoStr = [Util objToStr:self.super_groupFullInfo.group_description];
                }else{
                    cell.gonggaoStr = @"未设置".lv_localized;
                }
                cell.hiddeLine = YES;
            }else{
                [cell refreshMainLabelWithText:@"群公告".lv_localized];
                cell.isShowAll = self.isShowAll;
                cell.groupNoticeStr = [self resetNoticeInfo];
                cell.hiddeLine = NO;
            }
            
            return cell;
        }
            break;
        case 1:
        {
            CZGroupShareLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupShareLinkTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupShareLinkTableViewCell" owner:nil options:nil] firstObject];
            }
            cell.delegate = self;
            cell.super_groupFullInfo = self.super_groupFullInfo;
            return cell;
        }
            break;
        case 4:
        {
            return [UITableViewCell new];
        }
            break;
        case 5:
        {
            switch (self.currentSel) {
                case 100:
                {
                    CZGroupMemberFirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupMemberFirTableViewCell"];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupMemberFirTableViewCell" owner:nil options:nil] firstObject];
                    }
                    NSObject *obj = [self.membersList objectAtIndex:indexPath.row];
                    cell.cellModel = obj;
                    return cell;
                }
                    break;
                case 101:
                {
                    CZMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZMediaTableViewCell"];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZMediaTableViewCell" owner:nil options:nil] firstObject];
                    }
                    cell.delegate = self;
                    cell.chatInfo = self.chatInfo;
                    cell.soureArray = self.secondArray;
                    MJWeakSelf
                    cell.startLoadCall = ^{
                        [weakSelf.tableView reloadData];
                        
                    };
                    return cell;
                }
                    break;
                case 102:
                {
                    CZGroupMemberFirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupMemberFirTableViewCell"];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupMemberFirTableViewCell" owner:nil options:nil] firstObject];
                    }
                    NSObject *obj = [self.thridArray objectAtIndex:indexPath.row];
                    cell.cellModel = obj;
                    return cell;
                }
                    break;
                case 103:
                {
                    CZGroupMemberFirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupMemberFirTableViewCell"];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupMemberFirTableViewCell" owner:nil options:nil] firstObject];
                    }
                    NSObject *obj = [self.fourArray objectAtIndex:indexPath.row];
                    cell.cellModel = obj;
                    return cell;
                }
                    break;
                case 104:
                {
                    MessageInfo *obj = [self.fiveArray objectAtIndex:indexPath.row];
                    WebpageModel *webmodel = obj.content.web_page;
                    if (webmodel) {
                        CZLinkMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZLinkMsgTableViewCell"];
                        if (cell == nil) {
                            cell = [[[NSBundle mainBundle] loadNibNamed:@"CZLinkMsgTableViewCell" owner:nil options:nil] firstObject];
                        }
                        cell.cellInfo = obj;
                        return cell;
                    }else{
                        CZNOPreviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZNOPreviewTableViewCell"];
                        if (cell == nil) {
                            cell = [[[NSBundle mainBundle] loadNibNamed:@"CZNOPreviewTableViewCell" owner:nil options:nil] firstObject];
                        }
                        cell.cellInfo = obj;
                        return cell;
                    }
                }
                    break;
                case 105:
                {
                    CZMediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZMediaTableViewCell"];
                    if (cell == nil) {
                        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZMediaTableViewCell" owner:nil options:nil] firstObject];
                    }
                    cell.delegate = self;
                    cell.chatInfo = self.chatInfo;
                    cell.soureArray = self.sixArray;
                    return cell;
                }
                    break;
                    
                default:
                    return [UITableViewCell new];
                    break;
            }
        }
            break;
            
            
        default:
        {
            return [UITableViewCell new];
        }
            break;
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            return 230;
        }
            break;
        case 3:
            return 60;
        case 2:
        {
            return 74.5 + 10 + 10;
        }
            break;
        case 1:
        {
            return 74.5 + 10;
        }
            break;
        case 4:{
            return 0;
        }
            break;
        case 5:
        {
            switch (self.currentSel) {
                case 100:
                {
                    return 62;
                }
                    break;
                case 101:
                {
//                    CGFloat height = self.tableView.frame.size.height - 50;
//                    return height;
                    long row = (self.secondArray.count + 2) / 3;
                    
                    return self.mediaHeight;
                }
                    break;
                case 102:
                {
                    return 62;
                }
                    break;
                case 103:
                {
                    return 62;
                }
                    break;
                case 104:
                {
                    MessageInfo *obj = [self.fiveArray objectAtIndex:indexPath.row];
//                    WebpageModel *webmodel = obj.content.web_page;
//                    if (webmodel) {
//                        return 104;
//                    }else{
//                        return 82;
//                    }
                    return obj.linkRowHeight;
                }
                    break;
                case 105:
                {
                    return self.gifHeight;
//                    CGFloat height = self.tableView.frame.size.height - 50;
//                    return height;
                }
                    break;
                    
                default:
                    return 0.01;
                    break;
            }

        }
            break;
            
        default:
            return 0.01;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 3: {
            MJWeakSelf
            [[QTSetInfoBottomView sharedInstance] alertViewType:QT_Set_My_Group_Nickname ChatId:[NSString stringWithFormat:@"%ld", [ChatInfo toServerPeerId:self.chatInfo._id]] TitleStr:@"我在本群的昵称" ContentStr:[self myNickname] PlaceStr:@"请输入我在本群的昵称"];
            [[QTSetInfoBottomView sharedInstance] setSuccessBlock:^(NSString * _Nonnull contentStr) {
                //
                [weakSelf.tableView reloadData];
            }];
//            GC_ModifyFieldVC *vc = [[GC_ModifyFieldVC alloc] init];
//            vc.fieldType = ModifyFieldType_Set_Group_Nickname;
//            vc.chatId = [ChatInfo toServerPeerId:self.chatInfo._id];
//            vc.prevValueString = [self myNickname];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            if (indexPath.section == 2) {
                MNGroupIntroVC *vc = [[MNGroupIntroVC alloc] init];
                vc.chat = self.chatInfo;
                vc.canEdit = [CZCommonTool isGroupManager:self.super_groupInfo];
                vc.originValue = self.super_groupFullInfo.group_description;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                
                MNGroupAnnounceVC *vc = [[MNGroupAnnounceVC alloc] init];
                vc.chat = self.chatInfo;
                vc.originName = [self resetNoticeInfo];
                vc.canEdit = [CZCommonTool isGroupManager:self.super_groupInfo];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case 1:
        {
            [self shareLinkClickWithTag:100];
        }
            break;
        case 4:
        {
            break;
        }
        case 5:
        {
            switch (self.currentSel) {
                case 100:
                {
                    NSObject *obj = [self.membersList objectAtIndex:indexPath.row];
                    [self MemberListCell_Click_Membermember:(GroupMemberInfo *)obj];
                }
                    break;
                case 101:
                {
                    //媒体
                }
                    break;
                case 102:
                {
                    // 文件
                    MessageInfo *info = [self.thridArray objectAtIndex:indexPath.row];
                    {
                        NSString *fileName = info.content.document.file_name;
                        if([DocumentInfo isImageFile:fileName])
                        {//图片文件
                            PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
                            v.previewList = @[info];
                            v.curIndex = 0;
                            v.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:v animated:YES];
                        }
                        else if([DocumentInfo isVideoFile:fileName])
                        {//视频文件
                            PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
                            v.previewList = @[info];
                            v.curIndex = 0;
                            v.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:v animated:YES];
                        }
                        else
                        {//文件浏览器
                            FilePreviewViewController *vc = [[FilePreviewViewController alloc] initWithNibName:@"FilePreviewViewController" bundle:nil];
                            vc.previewMessage = info;
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                    }
                }
                    break;
                case 103:
                {
                    //
                    MessageInfo *msg = [self.fourArray objectAtIndex:indexPath.row];
                    if(msg.messageType == MessageType_Voice)
                    {//语音消息
                        VoiceInfo *audioInfo = msg.content.voice_note;
                        if(audioInfo != nil)
                        {
                            if(!audioInfo.isAudioDownloaded)
                            {//未下载，启动下载
                                [UserInfo showTips:nil des:@"语音下载中...".lv_localized];
                                if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.voice._id type:FileType_Message_Voice]
                                   && audioInfo.voice.remote.unique_id.length > 1)
                                {
                                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.voice._id download_offset:0 type:FileType_Message_Voice];
                                }
                            }
                            else
                            {//播放
                                [[PlayAudioManager sharedPlayAudioManager] playAudio:msg.content.audio.localAudioPath chatId:self.chatInfo._id msgId:msg._id];
//                                [self.tableView reloadData];
                            }
                        }
                    }
                }
                    break;
                case 104:
                {
                    //链接
                    MessageInfo *obj = [self.fiveArray objectAtIndex:indexPath.row];
                    WebpageModel *webmodel = obj.content.web_page;
                    if (webmodel && webmodel.url && webmodel.url.length > 0) {
                        BaseWebViewController *v = [BaseWebViewController new];
                        v.hidesBottomBarWhenPushed = YES;
                        v.titleString = @"";
                        v.urlStr = webmodel.url;
                        v.type = WEB_LOAD_TYPE_URL;
                        [self.navigationController pushViewController:v animated:YES];
                    }else{
                        if ([CZCommonTool checkUrlWithString:obj.textTypeContent]) {
                            NSString *urlstr = obj.textTypeContent;
                            if(![urlstr hasPrefix:@"https://"] && ![urlstr hasPrefix:@"http://"])
                            {
                                urlstr = [NSString stringWithFormat:@"http://%@", urlstr];
                            }
                            BaseWebViewController *v = [BaseWebViewController new];
                            v.hidesBottomBarWhenPushed = YES;
                            v.titleString = @"";
                            v.urlStr = urlstr;
                            v.type = WEB_LOAD_TYPE_URL;
                            [self.navigationController pushViewController:v animated:YES];
                        }else{
                            NSArray *arr = [CZCommonTool getURLFromStr:obj.textTypeContent];
                            if (arr && arr.count > 0) {
                                NSString *urlstr = [arr firstObject];
                                if(![urlstr hasPrefix:@"https://"] && ![urlstr hasPrefix:@"http://"])
                                {
                                    urlstr = [NSString stringWithFormat:@"http://%@", urlstr];
                                }
                                BaseWebViewController *v = [BaseWebViewController new];
                                v.hidesBottomBarWhenPushed = YES;
                                v.titleString = @"";
                                v.urlStr = urlstr;
                                v.type = WEB_LOAD_TYPE_URL;
                                [self.navigationController pushViewController:v animated:YES];
                            }else{
                                [UserInfo showTips:self.view des:@"数据异常".lv_localized];
                            }
                        }
                    }
                }
                    break;
                case 105:
                {
                    //GIF
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - TimerCounterDelegate
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    //获取超级群组成员列表
    [self getSuperMembers];
    //获取超级群组管理员列表
    [self getSuperAdminMembers];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Chat_Title_Changed):
        {//会话标题修改通知
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo.title = chat.title;
                    [self resetBaseInfo];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Permissions_Changed):
        {//会话权限变更通知
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo.permissions = chat.permissions;
//                    [self.membersListCell resetMembersList:self.membersList canAdd:[self canInvideMember] canDelete:[self canEditGroupSetting]];
                    //todo ......
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Photo_Changed):
        {//会话头像修改通知
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo.photo = chat.photo;
                    [self resetBaseInfo];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Photo_Ok):
        {
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo = chat;
                    [self resetBaseInfo];
//                    [self.tableView reloadData];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
//            [self.tableView reloadData];
            break;
        case MakeID(EUserManager, EUser_Td_Group_Basic_Info_Changed):
        {
            if(self.chatInfo.isGroup && !self.chatInfo.isSuperGroup)
            {
                BasicGroupInfo *info = inParam;
                if(info != nil && [info isKindOfClass:[BasicGroupInfo class]])
                {
                    if(self.chatInfo.type.basic_group_id == info._id)
                    {
                        self.groupInfo = info;
                        //同步详情
                        [self syncFullGroupInfo];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Basic_Full_Info_Changed):
        {//@{@"info":info, @"basic_group_id":[dic objectForKey:@"basic_group_id"]}
            if(self.chatInfo.isGroup && !self.chatInfo.isSuperGroup)
            {
                NSDictionary *obj = inParam;
                if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
                {
                    BasicGroupFullInfo *info = [obj objectForKey:@"info"];
                    NSNumber *basic_group_id = [obj objectForKey:@"basic_group_id"];
                    if(info != nil && basic_group_id != nil)
                    {
                        if([info isKindOfClass:[BasicGroupFullInfo class]] && [basic_group_id isKindOfClass:[NSNumber class]])
                        {
                            if(self.chatInfo.type.basic_group_id == basic_group_id.longValue)
                            {
                                //延时加载
                                [self performSelector:@selector(reloadBasicGroupFullInfo:) withObject:info afterDelay:0.1];
                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Super_Info_Changed):
        {
            if(self.chatInfo.isGroup && self.chatInfo.isSuperGroup)
            {
                SuperGroupInfo *info = inParam;
                if(info != nil && [info isKindOfClass:[SuperGroupInfo class]])
                {
                    if(self.chatInfo.type.supergroup_id == info._id)
                    {
                        self.super_groupInfo = info;
                        [self settingRightNavBar];
//                        [self.membersListCell resetTitle:[NSString stringWithFormat:@"群成员(%d人)", self.super_groupInfo.member_count]];
//                        [self.membersListCell resetMembersList:self.membersList canAdd:[self canInvideMember] canDelete:[self canEditGroupSetting]];
//                        [self.memberIsManagersListCell resetMembersList:self.memberIsManagersList canAdd:[self canEditGroupManagerSetting] canDelete:[self canEditGroupManagerSetting]];
//                        [self.tableView reloadData];
                        
                        //同步详情
                        //[self syncFullGroupInfo];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Super_Full_Info_Changed):
        {//@{@"info":info, @"supergroup_id":[dic objectForKey:@"supergroup_id"]}
            if(self.chatInfo.isGroup && self.chatInfo.isSuperGroup)
            {
                NSDictionary *obj = inParam;
                if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
                {
                    SuperGroupFullInfo *info = [obj objectForKey:@"info"];
                    NSNumber *super_group_id = [obj objectForKey:@"supergroup_id"];
                    if(info != nil && super_group_id != nil)
                    {
                        if([info isKindOfClass:[SuperGroupFullInfo class]] && [super_group_id isKindOfClass:[NSNumber class]])
                        {
                            if(self.chatInfo.type.supergroup_id == super_group_id.longValue)
                            {
                                //延时加载
                                [self performSelector:@selector(reloadSuperGroupFullInfo:) withObject:info afterDelay:0.1];
                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Chatcustom_Permissions_Change)://权限变更
        {
            if (inParam) {
                CZPermissionsModel *info = inParam;
                self.cusPermissionsModel = info;
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Photo_Ok)://消息图片已准备好
        case MakeID(EUserManager, EUser_Td_Message_Audio_Ok)://消息语音已准备好
        case MakeID(EUserManager, EUser_Td_Message_Voice_Ok)://消息语音已准备好
        case MakeID(EUserManager, EUser_Td_Message_Animation_Ok)://gif已准备好
        {//@{@"task":task, @"file":fileInfo}
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long chatId = [list.firstObject longLongValue];
                        if(self.chatInfo._id == chatId)
                        {//是当前会话的
                            long msgId = [list.lastObject longLongValue];
                            if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Photo_Ok))
                            {//图片
                                [self updatePhotoMsg:msgId file:fileInfo];
                            }
                            else if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Audio_Ok))
                            {//语音
                                [self updateAudioMsg:msgId file:fileInfo];
                            }
                            else if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Voice_Ok))
                            {//语音
                                [self updateVoiceMsg:msgId file:fileInfo];
                            }
                            else if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Animation_Ok))
                            {//gif
                                [self updateGifMsg:msgId file:fileInfo];
                            }
//                            else
//                            {//视频
//                                [self updateVideoMsg:msgId file:fileInfo];
//                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Video_Ok)://消息视频已准备好
        {
//            FileInfo *fileInfo = inParam;
//            [self updatePhotoMsg:0 file:fileInfo];
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long chatId = [list.firstObject longLongValue];
                        if(self.chatInfo._id == chatId)
                        {//是当前会话的
                            long msgId = [list.lastObject longLongValue];
                            [self updateVideoMsg:msgId file:fileInfo];
                        }
                    }

                }
            }else{
                FileInfo *fileInfo = inParam;
                [self updateVideoMsg:0 file:fileInfo];
            }
        }
            break;
       
        default:
            break;
    }
}


#pragma mark -- CZGroupFirTableViewCellDelegate
- (void)cellFunctionBtnClickWithTag:(NSInteger)tag withSender:(nonnull UIButton *)sender{
    MJWeakSelf
    switch (tag) {
        case 100:
        {
            //添加成员
            BOOL canaddMember = [self canInvideMember];
            if (canaddMember) {//增加成员
//                ContactChooseViewController *chooseView = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactChooseViewController"];
//                chooseView.hidesBottomBarWhenPushed = YES;
                MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
                chooseView.chooseType = MNContactChooseType_Group_Add_Member;
                chooseView.group_membersList = self.membersList;
                chooseView.chatId = self.chatInfo._id;
                chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
                [self.navigationController pushViewController:chooseView animated:YES];
            }else{
                [UserInfo showTips:self.view des:@"无邀请新成员权限!".lv_localized];
            }
        }
            break;
        case 101:
        {
            //关闭开启通知
            [self notificationSwitchClick];
        }
            break;
        case 102:
        {
            CZShowAllMemberViewController *allMemberVC = [CZShowAllMemberViewController new];
            allMemberVC.chatInfo = self.chatInfo;
            allMemberVC.cusPermissionsModel = self.cusPermissionsModel;
            [self.navigationController pushViewController:allMemberVC animated:YES];
        }
            break;
        case 103:
        {
            [self showPopView:sender];
        }
            break;
            
        case 1000: // 群公告
        {
            MNGroupAnnounceVC *vc = [[MNGroupAnnounceVC alloc] init];
            vc.chat = self.chatInfo;
            vc.originName = [self resetNoticeInfo];
            vc.canEdit = [CZCommonTool isGroupManager:self.super_groupInfo];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1001: // 图片
        {
            QTGroupWenJianVC *vc = [[QTGroupWenJianVC alloc] init];
            vc.chatInfo = self.chatInfo;
            vc.cusPermissionsModel = self.cusPermissionsModel;
            vc.messageList = self.messageList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1002: // 搜索
        {
            MNContactDetailSearchVC *vc = [[MNContactDetailSearchVC alloc] init];
            vc.chatId = self.chatInfo._id;
            [self.navigationController pushViewController:vc animated:YES];
//            CZShowAllMemberViewController *allMemberVC = [CZShowAllMemberViewController new];
//            allMemberVC.chatInfo = self.chatInfo;
//            allMemberVC.cusPermissionsModel = self.cusPermissionsModel;
//            [self.navigationController pushViewController:allMemberVC animated:YES];
        }
            break;
        case 1003: // 管理
        {
            [self click_edit];
        }
            break;
        case 1004: // 修改头像
        {
            // 群主
            if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
                [self click_setGroupPhoto];
            }
        }
            break;
        case 1005: // 修改群昵称
        {
            // 群主
            if ([CZCommonTool isGroupManager:self.super_groupInfo]) {
                [[QTSetInfoBottomView sharedInstance] alertViewType:QT_Set_Group_Nickname ChatId:[NSString stringWithFormat:@"%ld", self.chatInfo._id] TitleStr:@"群昵称" ContentStr:self.chatInfo.title PlaceStr:@"请输入我在本群昵称"];
                [[QTSetInfoBottomView sharedInstance] setSuccessBlock:^(NSString * _Nonnull contentStr) {
                    //
                    weakSelf.chatInfo.title = contentStr;
                    [weakSelf.tableView reloadData];
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- CZGroupShareLinkTableViewCellDelegate //100  链接点击   101  二维码点击
- (void)shareLinkClickWithTag:(NSInteger)tag{
    switch (tag) {
        case 100:
        {
            //有链接  复制  分享
            //管理    重置   关闭
            NSMutableArray *arr = [NSMutableArray array];
            NSString *invitationStr = self.super_groupFullInfo.invite_link;
            if (invitationStr && invitationStr.length > 5) {
                if ([CZCommonTool isGroupManager:self.super_groupInfo]) {//管理
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"复制链接".lv_localized withTag:100]];
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"分享链接".lv_localized withTag:101]];
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"重置链接".lv_localized withTag:102]];
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"关闭链接".lv_localized withTag:103]];
                }else{
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"复制链接".lv_localized withTag:100]];
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"分享链接".lv_localized withTag:101]];
                }
            }else{
                if ([CZCommonTool isGroupManager:self.super_groupInfo]) {//管理
                    [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"重置链接".lv_localized withTag:102]];
                }else{
                    [UserInfo showTips:nil des:@"暂无群邀请链接".lv_localized];
                    return;
                }
            }
            [arr addObject:[CZShareLinkMenuModel initModleWithTilele:@"取消".lv_localized withTag:104]];
            [self shareGroupLinkClick:arr];
        }
            break;
        case 101:
        {//群二维码
            NSString *invitationStr = self.super_groupFullInfo.invite_link;
            if (invitationStr && invitationStr.length > 5) {
                CZGroupQRCodeViewController *vc = [CZGroupQRCodeViewController new];
                vc.chatInfo = self.chatInfo;
                vc.super_groupFullInfo = self.super_groupFullInfo;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                [UserInfo showTips:nil des:@"暂无群邀请链接".lv_localized];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)shareGroupLinkClick:(NSArray *)menuArr{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < menuArr.count; i++) {
        CZShareLinkMenuModel *itemmodel = [menuArr objectAtIndex:i];
        if (i != menuArr.count - 1) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:itemmodel.title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self shareLinkClickHandler:itemmodel];
            }];
            [alert addAction:action];
        }else{
            UIAlertAction *action = [UIAlertAction actionWithTitle:itemmodel.title style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                [self shareLinkClickHandler:itemmodel];
            }];
            [alert addAction:action];
        }
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)shareLinkClickHandler:(CZShareLinkMenuModel *)model{
    NSLog(@"tag : %ld",model.tag);
    switch (model.tag) {
        case 100:
        {
            //复制
            NSString *invitationStr = self.super_groupFullInfo.invite_link;
            if (invitationStr && invitationStr.length > 5) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = invitationStr;
                [UserInfo showTips:self.view des:@"复制链接成功".lv_localized];
            }else{
                [UserInfo showTips:self.view des:@"本群暂未设置邀请链接,请先设置链接".lv_localized];
            }
        }
            break;
        case 101:
        {
            NSString *invitationStr = self.super_groupFullInfo.invite_link;
            if (invitationStr && invitationStr.length > 5) {
                NSString *shareText = [NSString stringWithFormat:@"点击加入群聊【%@】".lv_localized,self.chatInfo.title];
                NSURL *shareUrl = [NSURL URLWithString:invitationStr];
                UIImage *shareImage = [UIImage imageNamed:@"Logo1"];
                NSArray *activityItemsArray = @[shareText, shareImage, shareUrl];
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItemsArray applicationActivities:nil];
                [self presentViewController:activityViewController animated:YES completion:nil];
            }else{
                [UserInfo showTips:self.view des:@"本群暂未设置邀请链接,请先设置链接".lv_localized];
            }
        }
            break;
        case 102:
        {
            [UserInfo show];
            [[TelegramManager shareInstance] generateChatInviteLink:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if([TelegramManager isResultError:response])
                {
                    [UserInfo showTips:nil des:@"重置链接失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                }else{//重置成功
                    [UserInfo showTips:self.view des:@"重置链接成功".lv_localized];
                    self.super_groupFullInfo.invite_link = [response objectForKey:@"invite_link"];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                }
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"重置链接失败，请稍后重试".lv_localized];
            }];
        }
            break;
        case 103:
        {
            [UserInfo show];
            [[TelegramManager shareInstance] stopGroupInviteLink:[ChatInfo toServerPeerId:self.chatInfo._id] resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if([TelegramManager isResultError:response])
                {
                    [UserInfo showTips:nil des:@"停用链接失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                }else{//重置成功
                    [UserInfo showTips:self.view des:@"停用链接成功".lv_localized];
                    self.super_groupFullInfo.invite_link = @"";
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
                }
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"停用链接失败，请稍后重试".lv_localized];
            }];
        }
            break;
            
        default:
            break;
    }
}


- (void)showPopView:(UIButton *)sender{
    NSArray *titleArr = @[@"投诉".lv_localized,@"查找聊天记录".lv_localized,[self isOwnerGroup] ? @"解散群组".lv_localized : @"退出群聊".lv_localized];
    [YBPopupMenu showRelyOnView:sender titles:titleArr icons:nil menuWidth:140 otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.dismissOnSelected = YES;
        popupMenu.isShowShadow = NO;
        popupMenu.delegate = self;
        popupMenu.offset = 2;
        popupMenu.type = YBPopupMenuTypeDefault;
        popupMenu.maxVisibleCount = 8;
        popupMenu.rectCorner = UIRectCornerAllCorners;
        popupMenu.tableView.separatorColor = [UIColor clearColor];
        popupMenu.arrowHeight = 0;
        popupMenu.font = fontRegular(15);
        popupMenu.textColor = [UIColor colorTextFor23272A];
//          popupMenu.rectCorner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
      }];
}

- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index{
    NSLog(@"index : %ld",(long)index);
    switch (index) {
        case 0:
        {
            NSString *url = [NSString stringWithFormat:@"%@?uid=%ld&chatid=%ld", KHostEReport, [UserInfo shareInstance]._id, self.chatInfo._id];
            BaseWebViewController *v = [BaseWebViewController new];
            v.hidesBottomBarWhenPushed = YES;
            v.titleString = @"投诉".lv_localized;
            v.urlStr = url;
            v.type = WEB_LOAD_TYPE_URL;
            [self.navigationController pushViewController:v animated:YES];
        }
            break;
        case 1:
        {
            MNContactDetailSearchVC *vc = [[MNContactDetailSearchVC alloc] init];
            vc.chatId = self.chatInfo._id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            if ([self isOwnerGroup]) {
                //解散
                [self deleteGroupConfirm];
            }else{
                //退出
                [self delAndLeftConfirm];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)delAndLeftConfirm
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定退出群组吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//删除
            [self delAndLeft];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)delAndLeft
{
    [UserInfo show];
    [[TelegramManager shareInstance] leaveGroup:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"退出群组失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [TelegramManager.shareInstance deleteChat:self.chatInfo._id];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"退出群组失败，请稍后重试".lv_localized];
    }];
}

- (void)deleteGroupConfirm
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定解散群组吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//解散
            [self deleteGroup];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)deleteGroup
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteGroup:self.chatInfo.superGroupId resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"解散群组失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [TelegramManager.shareInstance deleteChat:self.chatInfo._id];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"解散群组失败，请稍后重试".lv_localized];
    }];
}

#pragma mark -- CZGroupMediaHeaderViewDelegate
- (void)sectionHeaderViewClickWithTag:(NSInteger)tag{
    NSLog(@"tag : %ld",(long)tag);
    self.currentSel = tag;
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    NSInteger count;
    switch (self.currentSel - 100) {
        case 3:
            count = self.secondArray.count;
            break;
        case 2:
            count = self.thridArray.count;
            break;
        case 1:
            count = self.fourArray.count;
            break;
        case 4:
            count = self.fiveArray.count;
            break;
        case 5:
            count = self.sixArray.count;
            break;
            
        default:
            count = 0;
            break;
    }
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
    }
    if (count == 0) {
        [self.tableView.mj_footer setHidden:YES];
        return;
    }
    NSInteger status = [self.dataStatus[@(count)] integerValue];
    if (status == 1) {
        [self.tableView.mj_footer setHidden:YES];
    } else if (status == 2) {
        [self.tableView.mj_footer setHidden:NO];
//        [self.mainTableview.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer setHidden:NO];
        [self.tableView.mj_footer resetNoMoreData];
    }
    
    
}



- (void)MemberListCell_Click_Membermember:(GroupMemberInfo *)member
{//点击了成员，进入联系人详情
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
    if (!user) {
        return;
    }
    if(user._id == [UserInfo shareInstance]._id){
        GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    /// 群组禁止单聊时，普通成员无法点击用户头像 22-01-07
    BOOL isGroupChat = (self.chatInfo.isSuperGroup && self.super_groupInfo);
    BOOL isGroupAdmin = [@[@(GroupMemberState_Administrator), @(GroupMemberState_Creator)] containsObject:@(self.super_groupInfo.status.getMemberState)];
    /// 是群组 不是管理员 群组禁止私聊 。。
    if (self.cusPermissionsModel.banWhisper) {
        if (isGroupChat && !isGroupAdmin) {
            return;
        }
    }
    
//    MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
    QTGroupPersonInfoVC *v = [[QTGroupPersonInfoVC alloc] init];
    v.hidesBottomBarWhenPushed = YES;
    v.user = user;
//    [self.navigationController pushViewController:v animated:YES];
    [self presentViewController:v animated:YES completion:nil];
}

//获取全部聊天记录  暂时限制两万条
- (void)getAllQuoteMessage{
    int startid = 0;
    if (self.messageList.count == 0) {
        startid = 0;
    }else{
        MessageInfo *firstInfo = [self.messageList firstObject];
        startid = (int)firstInfo._id;
    }
    
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:startid offset:0 limit:100 only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]])
            {
                int count = 0;
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    if(msg._id != startid){
                        [self.messageList insertObject:msg atIndex:0];
                        count++;
                    }
                }
                //判断是否还有
                if (self.messageList.count < 20000 && list.count == 100) {//小于100说明已经拉完
                    [self getAllQuoteMessage];
                }else{
                    //消息已经全部拉完
                    [self handlerMessage];
                }
            }
        }else{
            [self handlerMessage];
        }
       
    } timeout:^(NSDictionary *request) {
        [self handlerMessage];
    }];
}

- (void)handlerMessage{
    NSArray *arrLin01 = [[self.messageList reverseObjectEnumerator] allObjects];
    for (int i = 0; i < arrLin01.count; i++) {
        MessageInfo *msg = [arrLin01 objectAtIndex:i];
        switch (msg.messageType) {
            case MessageType_Video://视频
            case MessageType_Photo://图片
            {
                //媒体
                [self.secondArray addObject:msg];
            }
                break;
            case MessageType_Document://文件
            {
                [self.thridArray addObject:msg];
            }
                break;
            case MessageType_Audio://语音
            {
                [self.fourArray addObject:msg];
            }
                break;
            case MessageType_Text://文本 -> 链接
            {
                NSString *contentStr = msg.textTypeContent;//文本内容
                NSArray *urlarr = [CZCommonTool getURLFromStr:contentStr];
                if ([CZCommonTool checkUrlWithString:contentStr] || (urlarr && urlarr.count > 0)) {
                    [self.fiveArray addObject:msg];
                }
            }
                break;
            case MessageType_Animation://gif
            {
                [self.sixArray addObject:msg];
            }
                break;
                
            default:
                break;
        }
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
}

- (int)isMsgLoadedVideo:(FileInfo *)info
{
    for(int i=0; i<self.secondArray.count; i++)
    {
        MessageInfo *msg = [self.secondArray objectAtIndex:i];
        if (msg.messageType == MessageType_Video) {
            if (msg.content.video.video._id == info._id) {
                return i;
            }
        }
    }
    return -1;
}

- (int)isMsgLoaded:(long)msgId
{
    for(int i=0; i<self.messageList.count; i++)
    {
        MessageInfo *msg = [self.messageList objectAtIndex:i];
        if(msg._id == msgId)
            return i;
    }
    return -1;
}

//photo
- (void)updatePhotoMsg:(long)msgId file:(FileInfo *)file
{
//    int index = [self isMsgLoaded:msgId];
//    if(index != -1)
//    {
//        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
//        msgInfo.content.photo.messagePhoto.photo = file;
//        if (self.currentSel == 101) {
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
//        }
//    }
    
    int index = [self isMsgLoadedVideo:file];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.secondArray objectAtIndex:index];
        if (msgInfo.messageType == MessageType_Photo) {
            msgInfo.content.photo.messagePhoto.photo = file;
        }else if(msgInfo.messageType == MessageType_Video){
            msgInfo.content.video.video = file;
        }
       
        if (self.currentSel == 101) {
            NSDictionary *dicLim = @{
                @"targetNum" : [NSNumber numberWithInt:index],
                @"msgInfo" : msgInfo
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EUser_Td_Message_Source_Ok" object:dicLim];
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

//audio
- (void)updateAudioMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.audio.audio = file;
        if (self.currentSel == 103) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

//audio
- (void)updateVoiceMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.voice_note.voice = file;
        if (self.currentSel == 103) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

//video
- (void)updateVideoMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoadedVideo:file];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.secondArray objectAtIndex:index];
        msgInfo.content.video.video = file;
        if (self.currentSel == 101) {
            NSDictionary *dicLim = @{
                @"targetNum" : [NSNumber numberWithInt:index],
                @"msgInfo" : msgInfo
            };
            [[NSNotificationCenter defaultCenter] postNotificationName:@"EUser_Td_Message_Source_Ok" object:dicLim];
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}


//gif
- (void)updateGifMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.animation.animation = file;
        if (self.currentSel == 105) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark -- CZMediaTableViewCellDelegate
- (void)collectioncellClickWtihArray:(NSArray *)arr withIndex:(int)cursel{
    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
    v.previewList = arr;
    v.curIndex = cursel;
    v.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:v animated:YES];
    
//    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
//    v.previewList = @[cell.chatRecordDTO];
//    v.curIndex = 0;
//    v.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:v animated:YES];
}
-(UITableViewStyle)style{
    return UITableViewStyleGrouped;
}


- (void)click_setGroupPhoto{//设置群组头像
    MMPopupItemHandler block = ^(NSInteger index){
        if(index == 0)
        {//拍照
            [self click_camera];
        }
        if(index == 1)
        {//从手机相册选择
            [self click_photo];
        }
    };
    NSArray *items =
    @[MMItemMake(@"拍照".lv_localized, MMItemTypeNormal, block),
      MMItemMake(@"从手机相册选择".lv_localized, MMItemTypeNormal, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                          items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)click_camera
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
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:nil];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *toSendImage = [Common fixOrientation:image];
        NSString *path = [MNChatViewController localPhotoPath:toSendImage];
        if(path != nil)
        {
            [self setPhoto:path];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)click_photo
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowCrop = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if(photos.count>0)
        {
            UIImage *toSendImage = [Common fixOrientation:[photos firstObject]];
            NSString *path = [MNChatViewController localPhotoPath:toSendImage];
            if(path != nil)
            {
                [self setPhoto:path];
            }
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)setPhoto:(NSString *)localPath
{
    [UserInfo show];
    [[TelegramManager shareInstance] setGroupPhoto:self.chatInfo._id localPath:localPath resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"群组头像设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组头像设置失败，请稍后重试".lv_localized];
    }];
}

@end
