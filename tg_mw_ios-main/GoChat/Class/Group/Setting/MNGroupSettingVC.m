//
//  MNGroupSettingVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNGroupSettingVC.h"
#import "MNGroupLCLbRCSwitchCell.h"
#import "MNGroupLCLbRArrowCell.h"
#import "GroupRestrictedListViewController.h"
#import "MNSensitiveWordsVC.h"
#import "TF_RequestManager.h"

@interface MNGroupSettingVC ()
<ASwitchDelegate>
@property (nonatomic,strong) NSMutableDictionary *permissionsDic;//权限
@property (nonatomic,strong) CZPermissionsModel *cusPermissionsModel;

@property (nonatomic,strong) SuperGroupInfo *superGroupInfo;//关于公开群的

@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, assign) BOOL isSetOpenGroup;//群成员
@property (nonatomic, assign) BOOL isMute;//禁言
@property (nonatomic, assign) BOOL isNoMedia;
@property (nonatomic, assign) BOOL isNoLink;//禁止发链接
@property (nonatomic, assign) BOOL isNoQRCode;//禁止发二维码
@property (nonatomic, assign) BOOL canInviteFrieend;//群成员可邀请
@property (nonatomic, assign) BOOL isNoAddContactChat;//禁止加好友
/// 禁止发送DM消息
@property (nonatomic,assign) BOOL isNoSendDmMention;
/// 发送敏感词移除群聊
@property (nonatomic,assign) BOOL isSendSensitiveWordsKicked;
/// 敏感词移除群聊提示
@property (nonatomic,assign) BOOL isShowTipWhenKickedBySendSensitiveWords;
@end

@implementation MNGroupSettingVC

- (NSMutableDictionary *)permissionsDic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_send_messages] forKey:@"can_send_messages"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_send_media_messages] forKey:@"can_send_media_messages"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_send_polls] forKey:@"can_send_polls"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_send_other_messages] forKey:@"can_send_other_messages"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_add_web_page_previews] forKey:@"can_add_web_page_previews"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_change_info] forKey:@"can_change_info"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_invite_users] forKey:@"can_invite_users"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_pin_messages] forKey:@"can_pin_messages"];
    [dic setObject:[NSNumber numberWithBool:self.chatInfo.permissions.can_send_dm_messages] forKey:@"can_send_dm_messages"];
    return dic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"群组管理".lv_localized];
    //初始化表格
    [self initTableData];
    [self settingUI];
    [self requestSuperGroupInfo];
    [self gettingExtendedPermissions];
}

- (void)initTableData{
    _rows = [[NSMutableArray alloc] init];
    NSArray *row0;
    NSArray *row1;
    NSArray *row2;
    if([AppConfigInfo sharedInstance].can_see_group_setting){
        row0 = @[@"设置为公开群".lv_localized,@"群成员禁言".lv_localized,@"被禁言成员列表".lv_localized];
        row1 = @[@"禁止发送媒体".lv_localized, @"禁止发送链接".lv_localized, @"禁止发送二维码".lv_localized, @"禁止发送DM消息".lv_localized, @"屏蔽敏感词管理".lv_localized, @"发送敏感词移除群聊".lv_localized, @"敏感词移除群聊提示".lv_localized];
        row2 = @[@"群成员可邀请好友进群".lv_localized,@"禁止加好友、私聊".lv_localized];
        [self.rows addObject:row0];
        [self.rows addObject:row1];
        [self.rows addObject:row2];
    }else{
        row0 = @[@"群成员禁言".lv_localized,@"被禁言成员列表".lv_localized];
        row1 = @[];
        row2 = @[@"群成员可邀请好友进群".lv_localized,@"禁止加好友、私聊".lv_localized];
        [self.rows addObject:row0];
       // [self.rows addObject:row1];
        [self.rows addObject:row2];
    }
   
}

- (void)handleCell:(MNGroupLCLbRCSwitchCell *)cell aSwitch:(ASwitch *)aSwitch rowName:(NSString *)rowName isOn:(BOOL)isOn{
    NSMutableDictionary *paramsDic = [self.permissionsDic mutableCopy];
    if ([rowName isEqualToString:@"群成员禁言".lv_localized]||
        [rowName isEqualToString:@"群成员可邀请好友进群".lv_localized]||
        [rowName isEqualToString:@"禁止发送媒体".lv_localized]) {
        if ([rowName isEqualToString:@"群成员禁言".lv_localized]) {//全体禁言
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_send_messages"];
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_send_media_messages"];
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_send_polls"];
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_send_other_messages"];
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_add_web_page_previews"];
        }else if ([rowName isEqualToString:@"群成员可邀请好友进群".lv_localized]){//群成员可邀请
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"can_invite_users"];
        }else if ([rowName isEqualToString:@"禁止发送媒体".lv_localized]){//禁止发图片
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_send_media_messages"];
        }
        else if ([rowName isEqualToString:@"禁止发送DM消息".lv_localized]){//禁止发图片
            [paramsDic setObject:[NSNumber numberWithBool:!isOn] forKey:@"can_send_dm_messages"];
        }
        NSLog(@"paramsDic : %@",paramsDic);
        [self setChatPermissions:paramsDic];
    }else if ([rowName isEqualToString:@"设置为公开群".lv_localized]){
        [self openGroup:aSwitch];
    }
    else{
        NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
        [paramsDic setObject:[NSNumber numberWithLong:[ChatInfo toServerPeerId:self.chatInfo._id]] forKey:@"chatId"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banWhisper] forKey:@"banWhisper"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendKeyword] forKey:@"banSendKeyword"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendQRcode] forKey:@"banSendQRcode"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendWebLink] forKey:@"banSendWebLink"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendDmMention] forKey:@"banSendDmMention"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.kickWhoSendKeyword] forKey:@"kickWhoSendKeyword"];
        [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.showKickMessage] forKey:@"showKickMessage"];
        
        if ([rowName isEqualToString:@"禁止加好友、私聊".lv_localized]) {//禁止好友私聊
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"banWhisper"];
        }else if ([rowName isEqualToString:@"禁止发送链接".lv_localized]){////禁止发链接
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"banSendWebLink"];
        }else if ([rowName isEqualToString:@"禁止发送二维码".lv_localized]){//禁止发二维码
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"banSendQRcode"];
        }else if ([rowName isEqualToString:@"禁止发送DM消息".lv_localized]){
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"banSendDmMention"];
        }else if ([rowName isEqualToString:@"发送敏感词移除群聊".lv_localized]){
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"kickWhoSendKeyword"];
        }else if ([rowName isEqualToString:@"敏感词移除群聊提示".lv_localized]){
            [paramsDic setObject:[NSNumber numberWithBool:isOn] forKey:@"showKickMessage"];
        }
        [self settingExtendedPermissions:paramsDic];
    }
    
}

- (void)settingUI{
    self.isMute = !self.chatInfo.permissions.can_send_messages;
    self.canInviteFrieend = self.chatInfo.permissions.can_invite_users;
    self.isNoMedia = !self.chatInfo.permissions.can_send_media_messages;
//    self.isSetOpenGroup = self.chatInfo.permissions.can_pin_messages;
    if (self.cusPermissionsModel) {
        self.isNoAddContactChat = self.cusPermissionsModel.banWhisper;
        self.isNoLink = self.cusPermissionsModel.banSendWebLink;
        self.isNoQRCode = self.cusPermissionsModel.banSendQRcode;
        self.isNoSendDmMention = self.cusPermissionsModel.banSendDmMention;
        self.isSendSensitiveWordsKicked = self.cusPermissionsModel.kickWhoSendKeyword;
        self.isShowTipWhenKickedBySendSensitiveWords = self.cusPermissionsModel.showKickMessage;
    }
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)gettingExtendedPermissions{
    [[TelegramManager shareInstance] gettingExtendedPermissions:[ChatInfo toServerPeerId:self.chatInfo._id] resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj){
            self.cusPermissionsModel = (CZPermissionsModel *)obj;
            [self settingUI];
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)setChatPermissions:(NSMutableDictionary *)paramsDic
{
    [UserInfo show];
    [[TelegramManager shareInstance] setChatPermissions:self.chatInfo._id withPermissions:paramsDic resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            [self settingUI];
        }
        else
        {
            //设置成功  更新UI
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
        [self settingUI];
    }];
}

- (void)settingExtendedPermissions:(NSMutableDictionary *)paramsDic
{
    [UserInfo show];
    [[TelegramManager shareInstance] settingExtendedPermissions:paramsDic resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            [self settingUI];
        }
        else
        {
            //设置成功  更新UI
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
        [self settingUI];
    }];
}

//next segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([@"GroupRestrictedListView" isEqualToString:segue.identifier])
    {
        GroupRestrictedListViewController *v = segue.destinationViewController;
        v.hidesBottomBarWhenPushed = YES;
        v.chatInfo = self.chatInfo;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.rows.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *subRows = self.rows[section];
    return subRows.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 17.5;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *aView = [[UIView alloc] init];
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    [aView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    return aView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 17.5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *subRows = self.rows[indexPath.section];
    NSString *rowName = subRows[indexPath.row];
    
    if ([rowName isEqualToString:@"被禁言成员列表".lv_localized]||
        [rowName isEqualToString:@"屏蔽敏感词管理".lv_localized]) {
        static NSString *cellId = @"MNGroupLCLbRArrowCell";
        MNGroupLCLbRArrowCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNGroupLCLbRArrowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.lcLabel.text = rowName;
        return cell;
    }else{
        static NSString *cellId = @"MNGroupLCLbRCSwitchCell";
        MNGroupLCLbRCSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNGroupLCLbRCSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//            cell.rcSwitch.aSwitchDelegate = self;
        }
        cell.lcLabel.text = rowName;
        if ([rowName isEqualToString:@"设置为公开群".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isSetOpenGroup];
        }else if ([rowName isEqualToString:@"群成员禁言".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isMute];
        }else if ([rowName isEqualToString:@"禁止发送媒体".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isNoMedia];
        }else if ([rowName isEqualToString:@"禁止发送链接".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isNoLink];
        }else if ([rowName isEqualToString:@"禁止发送二维码".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isNoQRCode];
        }else if ([rowName isEqualToString:@"禁止发送DM消息".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isNoSendDmMention];
        }else if ([rowName isEqualToString:@"发送敏感词移除群聊".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isSendSensitiveWordsKicked];
        }else if ([rowName isEqualToString:@"敏感词移除群聊提示".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isShowTipWhenKickedBySendSensitiveWords];
        }else if ([rowName isEqualToString:@"群成员可邀请好友进群".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.canInviteFrieend];
        }else if ([rowName isEqualToString:@"禁止加好友、私聊".lv_localized]) {
            [cell.rcSwitch setOnWithOutAnimation:self.isNoAddContactChat];
        }else{
            [cell.rcSwitch setOnWithOutAnimation:NO];
        }
        cell.rowName = rowName;
        WS(weakSelf)
        [cell setGroupSwitchBlock:^(MNGroupLCLbRCSwitchCell *cell, ASwitch *aSwith, BOOL isOn, NSString *rowName) {
            [weakSelf handleCell:cell aSwitch:aSwith rowName:rowName isOn:isOn];
        }];
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 1 && indexPath.row == 4) {
//        //跳转屏蔽词管理页面
//        ModifyFieldForMultiLineViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"ModifyFieldForMultiLineViewController"];
//        v.hidesBottomBarWhenPushed = YES;
//        v.fieldType = Group_ShieldSensitiveWordsManagerStyle;
//        v.chatId = self.chatInfo._id;
//        [self.navigationController pushViewController:v animated:YES];
//    }
    NSArray *subRows = self.rows[indexPath.section];
    NSString *rowName = subRows[indexPath.row];
    

    if ([rowName isEqualToString:@"屏蔽敏感词管理".lv_localized]){
        MNSensitiveWordsVC *v = [[MNSensitiveWordsVC alloc] init];
        v.chat = self.chatInfo;
        [self.navigationController pushViewController:v animated:YES];
    }else if([rowName isEqualToString:@"被禁言成员列表".lv_localized]){
        GroupRestrictedListViewController *vc = [[GroupRestrictedListViewController alloc] init];
        vc.chatInfo = self.chatInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

//屏蔽敏感词管理
- (void)shieldSensitiveWordsManager{
    
}

#pragma mark BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Chat_Permissions_Changed)://权限变更
        {
            if (inParam) {
                ChatInfo *info = inParam;
                self.chatInfo.permissions = info.permissions;
                [self settingUI];
            }
        }
            break;
        case MakeID(EUserManager, EUser_Chatcustom_Permissions_Change)://权限变更
        {
            if (inParam) {
                CZPermissionsModel *info = inParam;
                self.cusPermissionsModel = info;
                [self settingUI];
            }
        }
            break;
        
        default:
            break;
    }
}

#pragma mark - 关于公开群的

- (void)requestSuperGroupInfo{
    MJWeakSelf
    [[TelegramManager shareInstance] getSuperGroupInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, SuperGroupInfo *obj) {
        if(obj != nil && [obj isKindOfClass:[SuperGroupInfo class]])
        {
            weakSelf.superGroupInfo = obj;
            [weakSelf resetGroupOpen];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)resetGroupOpen{
    BOOL isSuper = !IsStrEmpty(self.superGroupInfo.username);
    self.isSetOpenGroup = isSuper;
    [self.tableView reloadData];
}

- (void)openGroup:(ASwitch *)sender {
    
    MJWeakSelf
//    __block BOOL open = !IsStrEmpty(self.superGroupInfo.username);
    BOOL open = sender.isOn;
    [TF_RequestManager toggleChannelPublicWithId:self.chatInfo.type.supergroup_id open:open resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if (open==NO) {
            weakSelf.superGroupInfo.username = @"";
        } else {
            weakSelf.superGroupInfo.username = @"superusername";
        }
        [weakSelf resetGroupOpen];
    } timeout:^(NSDictionary *request) {
        [weakSelf resetGroupOpen];
    }];
    
}
@end
