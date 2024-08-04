//
//  MNEditGroupViewController.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/14.
//

#import "MNEditGroupViewController.h"
#import "CZEditFirTableViewCell.h"
#import "CZEditSedTableViewCell.h"
#import "CZEditThridTableViewCell.h"
#import "CZEditFourTableViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MNChatViewController.h"
#import "TZImagePickerController.h"
#import "CZSaveBtnView.h"
#import "GroupChatManagerViewController.h"
#import "MNGroupSettingVC.h"
#import "MNContactDetailVC.h"
#import "MNAddGroupVC.h"
#import "GC_MyInfoVC.h"
#import "MNGroupNameVC.h"
#import "CZGroupNoticeTableViewCell.h"
#import "NSString+Height.h"
#import "MNGroupIntroVC.h"
#import "MNGroupAnnounceVC.h"
#import "QTGroupPersonInfoVC.h"

@interface MNEditGroupViewController ()
<CZEditFirTableViewCellDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,BusinessListenerProtocol,TimerCounterDelegate,CZEditFourTableViewCellDelegate,MNChooseUserDelegate>

@property (nonatomic, strong) SuperGroupInfo *super_groupInfo;
@property (nonatomic, strong) SuperGroupFullInfo *super_groupFullInfo;
@property (nonatomic, strong) TimerCounter *reloadMembersTimer;
@property (nonatomic, strong) MessageInfo *lastPinnedMsg;
@property (nonatomic, strong) MessageInfo *sendingMsg;
@property (nonatomic,strong) NSMutableArray *cells;//防止cell销毁
@property (nonatomic,strong) NSString *groupTitleStr;
@property (nonatomic,strong) NSString *groupIntroStr;
//群成员列表
@property (nonatomic, strong) NSArray *membersList;
//群管理员列表
@property (nonatomic, strong) NSArray *memberIsManagersList;
@end

@implementation MNEditGroupViewController

- (NSMutableArray *)cells{
    if (!_cells) {
        _cells = [NSMutableArray array];
    }
    return _cells;
}

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
//    [self.reloadMembersTimer stopCountProcess];
//    self.reloadMembersTimer = nil;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.reloadMembersTimer stopCountProcess];
    self.reloadMembersTimer = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getChatMessage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reloadMembersTimer = [TimerCounter new];
    self.reloadMembersTimer.delegate = self;
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self.customNavBar setTitle:@"编辑群组".lv_localized];
    [self.customNavBar setRightBtnWithImageName:nil title:@"完成".lv_localized highlightedImageName:nil];
//    __weak __typeof(self) weakSelf = self;
//    self.tableView.tableFooterView = [CZSaveBtnView instanceViewWithClick:^{
//        [weakSelf getFieldStrWithTag];
//        if (weakSelf.groupTitleStr) {
//            [weakSelf saveGroupName:self.groupTitleStr];
//        }
//        if (weakSelf.groupIntroStr) {
//            [self setGroupPinnedMessage_step1:weakSelf.groupIntroStr];
//        }
//    }];
    //公告
    [self syncGroupNotice];
    // Do any additional setup after loading the view from its nib.
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
//    [self getFieldStrWithTag];
//    if (self.groupTitleStr) {
//        [self saveGroupName:self.groupTitleStr];
//    }
//    if (self.groupIntroStr) {
//        [self setGroupPinnedMessage_step1:self.groupIntroStr];
//    }
    [self.navigationController popViewControllerAnimated:YES];
}

//设置UITabView每组显示几行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section>=3?1:0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

//设置每一行的每一组显示单元格的什么内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if ([self getCellFromCellsWithTag:100]) {
                return [self getCellFromCellsWithTag:100];
            }
            CZEditFirTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZEditFirTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZEditFirTableViewCell" owner:nil options:nil] firstObject];
            }
            cell.delegate = self;
            cell.chatInfo = self.chatInfo;
            [self.cells addObject:cell];
            return cell;
        }
            break;
        case 1:
        case 2:
        {
            
//            if ([self getCellFromCellsWithTag:101]) {
//                return [self getCellFromCellsWithTag:101];
//            }
//            CZEditSedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZEditSedTableViewCell"];
//            if (cell == nil) {
//                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZEditSedTableViewCell" owner:nil options:nil] firstObject];
//            }
//            cell.cellModel = self.lastPinnedMsg;
//            [self.cells addObject:cell];
//            return cell;
           
            CZGroupNoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZGroupNoticeTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZGroupNoticeTableViewCell" owner:nil options:nil] firstObject];
                cell.hiddeLine = YES;
            
            }
            if (indexPath.section == 1) {//群简介
                [cell refreshMainLabelWithText:@"群简介".lv_localized];
//                cell.
                if ([Util objToStr:self.super_groupFullInfo.group_description].length) {
                    cell.gonggaoStr = [Util objToStr:self.super_groupFullInfo.group_description];
                }else{
                    cell.gonggaoStr = @"未设置".lv_localized;
                }
            }else{
                [cell refreshMainLabelWithText:@"群公告".lv_localized];
                cell.groupNoticeStr = [self resetNoticeInfo:YES];
            }
            return cell;
        }
            break;
        case 3:
        {
            CZEditThridTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZEditThridTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZEditThridTableViewCell" owner:nil options:nil] firstObject];
            }
            return cell;
        }
            break;
        case 4:
        {
            CZEditFourTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZEditFourTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"CZEditFourTableViewCell" owner:nil options:nil] firstObject];
            }
            cell.delegate = self;
            cell.memberIsManagersList = [self getManagerArray];//GroupMemberInfo
            return cell;
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
            return 207;
        }
            break;
        case 1:
        {
//            [CZCommonTool getCellHeightWithStr:[self resetNoticeInfo] withbool:self.isShowAll] + 10;
            return 84.5;
        }
            break;
        case 2:
        {
            NSString *str = [self resetNoticeInfo:YES];
            CGFloat height = [str heightWithFont:fontRegular(15) width:APP_SCREEN_WIDTH-30];
            return MAX(84.5, 73.5 + height);
        }
            break;
        case 3:
        {
            return 70;
        }
            break;
        case 4:
        {
            return [self managerCellHeight];
        }
            break;
            
        default:
            return 0.01;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 3) {//权限管理
        //群管
        MNGroupSettingVC *VC = [[MNGroupSettingVC alloc] init];
//        VC.hidesBottomBarWhenPushed = YES;
        VC.chatInfo = self.chatInfo;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.section == 1){
        MNGroupIntroVC *vc = [[MNGroupIntroVC alloc] init];
        vc.chat = self.chatInfo;
        vc.canEdit = YES;
        vc.originValue = self.super_groupFullInfo.group_description;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 2){
        MNGroupAnnounceVC *vc = [[MNGroupAnnounceVC alloc] init];
        vc.chat = self.chatInfo;
        vc.canEdit = YES;
        vc.originName = [self resetNoticeInfo:NO];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
    if (cell.tag == 100) {
        if ([cell isMemberOfClass:[CZEditFirTableViewCell class]]) {
            CZEditFirTableViewCell *cellLim = (CZEditFirTableViewCell *)cell;
            self.groupTitleStr = cellLim.groupTitleStr;
        }
    }
    if (cell.tag == 101) {
        if ([cell isMemberOfClass:[CZEditSedTableViewCell class]]) {
            CZEditSedTableViewCell *cellLim = (CZEditSedTableViewCell *)cell;
            self.groupIntroStr = cellLim.groupIntroStr;
        }
    }
}

#pragma mark -- CZEditFourTableViewCellDelegate
- (void)groupMemberClickwithobject:(NSObject *)cellmodel{
    if([cellmodel isKindOfClass:[GroupMemberInfo class]])
    {
        [self MemberListCell_Click_Membermember:(GroupMemberInfo *)cellmodel];
    }
    if([cellmodel isKindOfClass:[NSString class]])
    {
        if([@"add" isEqualToString:(NSString *)cellmodel])
        {
            [self MemberListCell_AddMember];
        }
        if([@"delete" isEqualToString:(NSString *)cellmodel])
        {
            [self MemberListCell_DeleteMember];
        }
    }
}

#pragma mark -- CZEditFirTableViewCellDelegate
- (void)uploadGroupImageViewClick{
    [self click_setGroupPhoto];
}

//进入到群组名称编辑页
- (void)editGrouNameClick{
    MNGroupNameVC *vc = [[MNGroupNameVC alloc] init];
    vc.chat = self.chatInfo;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
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
                    //群标题修改成功
                    CZEditFirTableViewCell *cell = (CZEditFirTableViewCell *)[self getCellFromCellsWithTag:100];
                    cell.chatInfo = self.chatInfo;
                    [cell resetBaseInfo];
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
                    CZEditFirTableViewCell *cell = (CZEditFirTableViewCell *)[self getCellFromCellsWithTag:100];
                    cell.chatInfo = self.chatInfo;
                    [cell resetBaseInfo];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Photo_Ok)://群组图片下载完成
        {
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo = chat;
                    CZEditFirTableViewCell *cell = (CZEditFirTableViewCell *)[self getCellFromCellsWithTag:100];
                    cell.chatInfo = self.chatInfo;
                    [cell resetBaseInfo];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
//            [self.tableView reloadData];
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
                        //同步详情
                        [self syncFullGroupInfo];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Photo_Ok)://消息图片已准备好
        {
            
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Success):
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Fail):
        {
            //@{@"msg":msg, @"old_message_id":[dic objectForKey:@"old_message_id"]}
            NSDictionary *params = inParam;
            if(params != nil && [params isKindOfClass:[NSDictionary class]])
            {
                MessageInfo *msg = [params objectForKey:@"msg"];
                if(msg != nil && [msg isKindOfClass:[MessageInfo class]])
                {
                    if(msg.chat_id == self.chatInfo._id)
                    {//当前会话
                        long oldMsgId = -1;
                        NSNumber *old_message_id = [params objectForKey:@"old_message_id"];
                        if(old_message_id != nil && [old_message_id isKindOfClass:[NSNumber class]])
                        {
                            oldMsgId = [old_message_id longValue];
                        }
                        if(self.sendingMsg._id == oldMsgId)
                        {
                            if(msg.sendState == MessageSendState_Success)
                            {//发送成功
                                [UserInfo show];
                                [self setGroupPinnedMessage_step2:msg._id];
                            }
                            else
                            {
                                [UserInfo showTips:nil des:@"群介绍设置失败，请稍后重试".lv_localized];
                            }
                        }
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

/*功能代码区*/

- (void)MemberListCell_Click_Membermember:(GroupMemberInfo *)member
{//点击了成员，进入联系人详情
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
    if(user != nil)
    {
        if(user._id == [UserInfo shareInstance]._id)
        {
            GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
//            UIViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
//            v.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:v animated:YES];
        }
        else
        {
            MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//            QTGroupPersonInfoVC *v = [[QTGroupPersonInfoVC alloc] init];
//            v.hidesBottomBarWhenPushed = YES;
            v.user = user;
            if(self.chatInfo.isSuperGroup && self.super_groupInfo != nil)
            {
                GroupMemberState state = self.super_groupInfo.status.getMemberState;
                if(state == GroupMemberState_Administrator || state == GroupMemberState_Creator)
                {//可以查看进群方式
                    v.toShowInvidePath = YES;
                    v.chatId = self.chatInfo._id;
                }
                else
                {//普通成员，是否禁止单聊、互发消息
                    v.blockContact = self.cusPermissionsModel.banWhisper;
                }
            }
            
            [self presentViewController:v animated:YES completion:nil];
//            [self.navigationController pushViewController:v animated:YES];
        }
    }
}

- (void)MemberListCell_AddMember
{//增加管理员
//    ContactChooseViewController *chooseView = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactChooseViewController"];
//    chooseView.hidesBottomBarWhenPushed = YES;
    MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
    chooseView.chooseType = MNContactChooseType_Group_Add_Manager;
    chooseView.group_membersList = self.membersList;
    chooseView.group_managersList = self.memberIsManagersList;
    chooseView.chatId = self.chatInfo._id;
    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
    [self.navigationController pushViewController:chooseView animated:YES];
}

- (void)MemberListCell_DeleteMember
{//删除管理员
//    ContactChooseViewController *chooseView = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactChooseViewController"];
//    chooseView.hidesBottomBarWhenPushed = YES;
    MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
    chooseView.chooseType = MNContactChooseType_Group_Delete_Manager;
    chooseView.group_managersList = self.memberIsManagersList;
    chooseView.chatId = self.chatInfo._id;
    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
    [self.navigationController pushViewController:chooseView animated:YES];
}

- (void)getSuperMembers
{
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterRecent" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = (NSArray *)obj;
            self.membersList = list;
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)setGroupPinnedMessage_step1:(NSString *)content
{
    //第一步，发送文本消息
    //第二步，设置为pinned消息
    if(!IsStrEmpty(content))
    {
        content = [NSString stringWithFormat:@"%@%@", GROUP_NOTICE_PREFIX, content];
        [UserInfo show];
        [[TelegramManager shareInstance] sendTextMessage:self.chatInfo._id replyid:0 text:content withUserInfoArr:nil replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"群介绍设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
                if(msg.sendState == MessageSendState_Success)
                {//发送成功
                    [self setGroupPinnedMessage_step2:msg._id];
                }
                else if(msg.sendState == MessageSendState_Pending)
                {//等待回调结果
                    self.sendingMsg = msg;
                }
                else
                {
                    [UserInfo showTips:nil des:@"群介绍设置失败，请稍后重试".lv_localized];
                }
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群介绍设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写群介绍".lv_localized];
    }
}

- (void)setGroupPinnedMessage_step2:(long)msgId
{
    [UserInfo show];
    [[TelegramManager shareInstance] setPinMessage:self.chatInfo._id long:msgId resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultOk:response])
        {
            [UserInfo showTips:nil des:@"群介绍设置成功".lv_localized];
            [self syncGroupNotice];
//            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [UserInfo showTips:nil des:@"群介绍设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];

        [UserInfo showTips:nil des:@"群介绍设置失败，请稍后重试".lv_localized];
    }];
}

- (void)saveGroupName:(NSString *)name
{
    if(!IsStrEmpty(name))
    {
        [UserInfo show];
        [[TelegramManager shareInstance] setGroupName:self.chatInfo._id groupName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                [UserInfo showTips:nil des:@"群组名称设置成功".lv_localized];
//                [self.navigationController popViewControllerAnimated:YES];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组名称设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写群组名称".lv_localized];
    }
}

- (UITableViewCell *)getCellFromCellsWithTag:(NSInteger)tag{
    for (UITableViewCell *cellItem in self.cells) {
        if (cellItem.tag == tag) {
            return cellItem;
        }
    }
    return nil;
}

- (void)getFieldStrWithTag{ //无效  取不到不在显示的cell
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell.tag == 100) {
            if ([cell isMemberOfClass:[CZEditFirTableViewCell class]]) {
                CZEditFirTableViewCell *cellLim = (CZEditFirTableViewCell *)cell;
                self.groupTitleStr = cellLim.groupTitleStr;
            }
        }
        if (cell.tag == 101) {
            if ([cell isMemberOfClass:[CZEditSedTableViewCell class]]) {
                CZEditSedTableViewCell *cellLim = (CZEditSedTableViewCell *)cell;
                self.groupIntroStr = cellLim.groupIntroStr;
            }
        }
    }
}

- (CGFloat)managerCellHeight{
    NSArray *arrlin = [self getManagerArray];
    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
    float cellrows = ceilf(arrlin.count/5.0);
    CGFloat heightLim = 20 + 58 + cellrows * (cellWidth + 20) + (cellrows - 1)*15 + 30;
    return heightLim;
}

- (NSArray *)getManagerArray{
    NSMutableArray *arr = [NSMutableArray array];
    if (self.memberIsManagersList) {
        arr = [self.memberIsManagersList mutableCopy];
    }
    if ([self canEditGroupManagerSetting]) {
        [arr addObject:@"add"];
        [arr addObject:@"delete"];
    }
    return arr;
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
    return NO;
}

- (void)checkUserChatState
{
    if(self.chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupInfo class]])
            {
                self.super_groupInfo = obj;
            }
        } timeout:^(NSDictionary *request) {
        }];
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

- (void)syncFullGroupInfo
{
    MJWeakSelf
    if(self.chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupFullInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupFullInfo class]])
            {
                weakSelf.super_groupFullInfo = obj;
//                [self.memberIsManagersListCell resetTitle:[NSString stringWithFormat:@"群管理员(%d人)", self.super_groupFullInfo.administrator_count]];
                //获取超级群组成员列表
                [weakSelf getSuperMembers];
                //获取超级群组管理员列表
                [weakSelf getSuperAdminMembers];
                [weakSelf.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

#pragma mark - 群通知
- (NSString *)resetNoticeInfo:(BOOL)needDefault
{
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
        if (needDefault) {
            return @"未设置";
        }
        return @"";
    }
    
}
//
//- (void)resetNoticeInfo
//{
//    if(self.lastPinnedMsg != nil)
//    {
//        if ([self getCellFromCellsWithTag:101]) {
//            CZEditSedTableViewCell *cell = (CZEditSedTableViewCell *)[self getCellFromCellsWithTag:101];
//            cell.cellModel = self.lastPinnedMsg;
//        }
//    }
//}

- (void)syncGroupNotice
{
    [[TelegramManager shareInstance] getChatPinnedMessage:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
            [TelegramManager parseMessageContent:[response objectForKey:@"content"] message:msg];
            self.lastPinnedMsg = msg;
            [self resetNoticeInfo:YES];
            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)getSuperAdminMembers
{
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterAdministrators" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = (NSArray *)obj;
            self.memberIsManagersList = list;
            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
    }];
}


- (void)reloadSuperGroupFullInfo:(SuperGroupFullInfo *)info
{
    self.super_groupFullInfo = info;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //性能考虑
    [self.reloadMembersTimer stopCountProcess];
    [self.reloadMembersTimer startCountProcess:1 repeat:NO];
    NSLog(@"添加好友 - 9999999999");
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


//群权限变更   需要监听   管理员临时被干掉无法继续操作
//设置标题  群公告  无需监听
//管理员的加减  需要监听


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
