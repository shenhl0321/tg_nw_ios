//
//  GroupChatManagerViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/10.
//

#import "GroupChatManagerViewController.h"
#import "GroupRestrictedListViewController.h"
#import "ModifyFieldForMultiLineViewController.h"

@interface GroupChatManagerViewController ()<BusinessListenerProtocol>
@property (nonatomic, weak) IBOutlet UISwitch *banAllSwitch;//全体禁言
@property (nonatomic, weak) IBOutlet UISwitch *memberCanInvideSwitch;//群成员可邀请
@property (weak, nonatomic) IBOutlet UISwitch *pictureSwitch;//禁止发图片

@property (nonatomic, weak) IBOutlet UISwitch *blockAllSwitch;//禁止好友私聊
@property (weak, nonatomic) IBOutlet UISwitch *linkSwitch;//禁止发链接
@property (weak, nonatomic) IBOutlet UISwitch *qrcodeSwitch;//禁止发二维码
@property (nonatomic,strong) NSMutableDictionary *permissionsDic;//权限
@property (nonatomic,strong) CZPermissionsModel *cusPermissionsModel;

@end

@implementation GroupChatManagerViewController

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
    return dic;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"群组管理";
    //初始化表格
    self.tableView.sectionIndexColor = COLOR_CG1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = HEX_COLOR(@"#f2f2f2");
    [self.banAllSwitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
    [self.memberCanInvideSwitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
    [self.pictureSwitch addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
    [self.blockAllSwitch addTarget:self action:@selector(switchCustomClick:) forControlEvents:UIControlEventValueChanged];
    [self.linkSwitch addTarget:self action:@selector(switchCustomClick:) forControlEvents:UIControlEventValueChanged];
    [self.qrcodeSwitch addTarget:self action:@selector(switchCustomClick:) forControlEvents:UIControlEventValueChanged];
    [self settingUI];
    [self gettingExtendedPermissions];
}

//开关操作  系统API
- (void)switchClick:(UISwitch *)sender{
    NSMutableDictionary *paramsDic = [self.permissionsDic mutableCopy];
    if (sender == _banAllSwitch) {//全体禁言
        [paramsDic setObject:[NSNumber numberWithBool:!self.banAllSwitch.on] forKey:@"can_send_messages"];
        [paramsDic setObject:[NSNumber numberWithBool:!self.banAllSwitch.on] forKey:@"can_send_media_messages"];
        [paramsDic setObject:[NSNumber numberWithBool:!self.banAllSwitch.on] forKey:@"can_send_polls"];
        [paramsDic setObject:[NSNumber numberWithBool:!self.banAllSwitch.on] forKey:@"can_send_other_messages"];
        [paramsDic setObject:[NSNumber numberWithBool:!self.banAllSwitch.on] forKey:@"can_add_web_page_previews"];
    }else if (sender == _memberCanInvideSwitch){//群成员可邀请
        [paramsDic setObject:[NSNumber numberWithBool:self.memberCanInvideSwitch.on] forKey:@"can_invite_users"];
    }else if (sender == _pictureSwitch){//禁止发图片
        [paramsDic setObject:[NSNumber numberWithBool:!self.pictureSwitch.on] forKey:@"can_send_media_messages"];
    }
    NSLog(@"paramsDic : %@",paramsDic);
    [self setChatPermissions:paramsDic];
}

//开关操作  自定义API
- (void)switchCustomClick:(UISwitch *)sender{
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:[NSNumber numberWithLong:[ChatInfo toServerPeerId:self.chatInfo._id]] forKey:@"chatId"];
    [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banWhisper] forKey:@"banWhisper"];
    [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendKeyword] forKey:@"banSendKeyword"];
    [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendQRcode] forKey:@"banSendQRcode"];
    [paramsDic setObject:[NSNumber numberWithBool:self.cusPermissionsModel.banSendWebLink] forKey:@"banSendWebLink"];
    
    if (sender == _blockAllSwitch) {//禁止好友私聊
        [paramsDic setObject:[NSNumber numberWithBool:self.blockAllSwitch.on] forKey:@"banWhisper"];
    }else if (sender == _linkSwitch){////禁止发链接
        [paramsDic setObject:[NSNumber numberWithBool:self.linkSwitch.on] forKey:@"banSendWebLink"];
    }else if (sender == _qrcodeSwitch){//禁止发二维码
        [paramsDic setObject:[NSNumber numberWithBool:self.qrcodeSwitch.on] forKey:@"banSendQRcode"];
    }
    [self settingExtendedPermissions:paramsDic];
}

- (void)settingUI{
    self.banAllSwitch.on = !self.chatInfo.permissions.can_send_messages;
    self.memberCanInvideSwitch.on = self.chatInfo.permissions.can_invite_users;
    self.pictureSwitch.on = !self.chatInfo.permissions.can_send_media_messages;
    if (self.cusPermissionsModel) {
        self.blockAllSwitch.on = self.cusPermissionsModel.banWhisper;
        self.linkSwitch.on = self.cusPermissionsModel.banSendWebLink;
        self.qrcodeSwitch.on = self.cusPermissionsModel.banSendQRcode;
    }
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 4) {
        //跳转屏蔽词管理页面
        ModifyFieldForMultiLineViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"ModifyFieldForMultiLineViewController"];
        v.hidesBottomBarWhenPushed = YES;
        v.fieldType = Group_ShieldSensitiveWordsManagerStyle;
        v.chatId = self.chatInfo._id;
        [self.navigationController pushViewController:v animated:YES];
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

@end
