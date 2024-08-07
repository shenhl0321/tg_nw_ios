//
//  TelegramManager.m
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import "TelegramManager.h"
#import "PathConstant.h"
#import <MJExtension/MJExtension.h>
#import "td_json_client.h"
//#import "td_api.h"
#import "td_log.h"
#import "NSString+PinYin.h"
#import "CheckUserViewController.h"

#import <UserNotifications/UserNotifications.h>
#import "TF_RequestManager.h"
#define RQEUST_TIMEOUT 60

static TelegramManager *g_TelegramManager = nil;

@interface TgTask : SemaphoreTask
@property (nonatomic) int rtId;
@property (nonatomic, copy) NSDictionary *request;
@property (nonatomic, copy) NSDictionary *response;
@property (nonatomic, copy) TgResultBlock resultBlock;
@property (nonatomic, copy) TgTimeoutBlock timeoutBlock;
@end
@implementation TgTask
@end

@interface TelegramManager ()
@property (nonatomic) void *tdClient;

@property (nonatomic) int requestId;
@property (nonatomic) NSMutableDictionary *requestQueue;

//用户状态
@property (nonatomic) GoUserState userState;
@property (nonatomic) GoUserConnectionState userConnectionState;

//最近会话字典
@property (nonatomic, strong) NSMutableDictionary *chat_dic;
//联系人资料
@property (nonatomic, strong) NSMutableDictionary *contacts_dic;
//文件下载队列
@property (nonatomic, strong) NSMutableDictionary *fileTask_dic;
@property (nonatomic, strong) NSMutableDictionary *fileTaskId_dic;

//当前正在聊天的chatid - 0表示没有
@property (nonatomic) long curChatId;
@property (nonatomic,assign) int priority;

/// 首次连接成功
/// 检测连接状态，初始化的时候置为 NO。
/// 为 NO 的时候，如果用户连接状态不为 connectionStateReady，5秒后重新切换域名连接。
/// 状态为 connectionStateReady 后，置为 YES，说明已经连接成功并进入首页。
/// 后续再出现不为 ‘connectionStateReady’ 都不做处理
@property (nonatomic, assign, getter=isFirstConnectionSuccessful) BOOL firstConnectionSuccessful;
/// <#code#>
@property (nonatomic,strong) NSMutableArray *unOwnerSecreatChat;
@end

@implementation TelegramManager
{
    dispatch_queue_t receiveQueue;
    void *receiveQueueTag;
    dispatch_queue_t workQueue;
    void *workQueueTag;
}

+ (TelegramManager *)shareInstance
{
    if(g_TelegramManager == nil)
    {
        g_TelegramManager = [[TelegramManager alloc] init];
    }
    return g_TelegramManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        [self initTdlib];
    }
    return self;
}

- (void)initTdlib
{
    self.firstConnectionSuccessful = NO;
    self.requestId = 1;
    self.priority = 32;
    self.requestQueue = [NSMutableDictionary dictionary];
    //创建线程队列
    const char *receiveQueueName = [[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"receiveQueue"] UTF8String];
    receiveQueue = dispatch_queue_create(receiveQueueName, NULL);
    receiveQueueTag = &receiveQueueTag;
    dispatch_queue_set_specific(receiveQueue, receiveQueueTag, receiveQueueTag, NULL);
    //创建线程队列
    const char *workQueueName = [[NSString stringWithFormat:@"%@%@", NSStringFromClass([self class]), @"WorkQueue"] UTF8String];
    workQueue = dispatch_queue_create(workQueueName, NULL);
    workQueueTag = &workQueueTag;
    dispatch_queue_set_specific(workQueue, workQueueTag, workQueueTag, NULL);
    //
    self.userState = GoUserState_Unkown;
    self.userConnectionState = GoUserConnectionState_Connecting;
    self.chat_dic = [NSMutableDictionary dictionary];
    self.contacts_dic = [NSMutableDictionary dictionary];
    self.fileTask_dic = [NSMutableDictionary dictionary];
    self.fileTaskId_dic = NSMutableDictionary.dictionary;
    self.unOwnerSecreatChat = [NSMutableArray array];
    //log
    td_set_log_verbosity_level(1);
    _tdClient = td_json_client_create();
//#if DEBUG
//    NSString *homePath = NSHomeDirectory();
//    NSString *path = [homePath stringByAppendingString:@"/tmp/log"];
//    td_set_log_verbosity_level(5);
//    td_set_log_file_path([path UTF8String]);
//#else
//    td_set_log_verbosity_level(1);
//#endif
    //receive
    __weak __typeof(self) weakSelf = self;
    dispatch_async(receiveQueue, ^{
        while (true)
        {
            if(weakSelf.tdClient != nil)
            {
                const char *response = td_json_client_receive(weakSelf.tdClient, 10);
                if(response != nil)
                {
                    NSString *res = [NSString stringWithCString:response encoding:NSUTF8StringEncoding];
                    [weakSelf parseResonseImpl:res];
                }
            }
            else
            {
                [NSThread sleepForTimeInterval:0.01];
            }
        }
    });
}

- (void)reInitTdlib
{
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        if(bSelf.tdClient == nil)
        {
            bSelf.userState = GoUserState_Unkown;
            bSelf.userConnectionState = GoUserConnectionState_Connecting;
            //init client
            bSelf.tdClient = td_json_client_create();
        }
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)cleanCurrentData
{
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        bSelf.userState = GoUserState_Unkown;
        bSelf.userConnectionState = GoUserConnectionState_Connecting;
        [bSelf.chat_dic removeAllObjects];
        [bSelf.contacts_dic removeAllObjects];
        [bSelf.fileTask_dic removeAllObjects];
        [bSelf.fileTaskId_dic removeAllObjects];
        [bSelf.unOwnerSecreatChat removeAllObjects];
        bSelf.curChatId = 0;
        bSelf.tdClient = nil;
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//以下方法都在work线程内完成
- (void)parseResonseImpl:(NSString *)response
{
    if ([response length] < 10240){
        ChatLog(@"td_json_client_receive: %@", response);
    }
    dispatch_block_t block = ^{
        [self parseResonse_inline:response];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//内部方法
- (void)parseResonse_inline:(NSString *)response
{
    NSDictionary *dic = [response mj_JSONObject];
    if (![dic isKindOfClass:NSDictionary.class]) {
        ChatLog(@"异常报文: %@", response);
        return;
    }
    NSNumber *rtId = [dic objectForKey:@"@extra"];
    NSString *type = [dic objectForKey:@"@type"];
    if (rtId != nil && [rtId isKindOfClass:[NSNumber class]]) {
        TgTask *task = [self.requestQueue objectForKey:rtId];
        if (task != nil) {
            task.response = dic;
            [task signalSuccess];
            
            if([@"updateAuthorizationState" isEqualToString:type]) {//鉴权状态变更
                [self dealAuthorizationUpdate_inline:[dic objectForKey:@"authorization_state"]];
            }
            return;
        }
    }
    
    if([@"updateAuthorizationState" isEqualToString:type])
    {//鉴权状态变更
        [self dealAuthorizationUpdate_inline:[dic objectForKey:@"authorization_state"]];
    }
    else if([@"updateOption" isEqualToString:type])
    {//当前账号userid
        NSString *type_name = [dic objectForKey:@"name"];
        if([@"my_id" isEqualToString:type_name])
        {
            NSDictionary *valueDic = [dic objectForKey:@"value"];
            if(valueDic != nil && [valueDic isKindOfClass:[NSDictionary class]])
            {
                NSString *valueStr = [valueDic objectForKey:@"value"];
                long _id = [valueStr longLongValue];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UserInfo shareInstance]._id = _id;
                    [[AuthUserManager shareInstance] updateCurrentUserId:_id];
                });
            }
        }
    }
    else if([@"updateUser" isEqualToString:type])
    {//更新当前用户或者联系人资料
        NSDictionary *userDic = [dic objectForKey:@"user"];
        if(userDic != nil && [userDic isKindOfClass:[NSDictionary class]])
        {
            if([@"user" isEqualToString:[userDic objectForKey:@"@type"]])
            {
                [self parseUserInfo_inline:userDic];
            }
        }
    }
    else if([@"updateSecretChat" isEqualToString:type])
    {
        
        SecretChat *secretChat = [SecretChat mj_objectWithKeyValues:dic[@"secret_chat"]];
        
        NSArray<ChatInfo *> *chats = [[TelegramManager shareInstance] getChatList];
        ChatInfo *target = nil;
        for (ChatInfo *chat in chats) {
            if (chat.isSecretChat && chat.secretChatInfo._id == secretChat._id) {
                target = chat;
                break;
            }
        }
        if (target == nil) {
            [self.unOwnerSecreatChat addObject:secretChat];
        } else {
            target.secretChatInfo = secretChat;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateChatUpdateSecretChatStatus) withInParam:secretChat];
        });
    }
    else if([@"updateUserStatus" isEqualToString:type])
    {//更新当前用户或者联系人资料  在线 离线
        NSDictionary *userDic = [dic objectForKey:@"user"];
        if(userDic != nil && [userDic isKindOfClass:[NSDictionary class]])
        {
            if([@"user" isEqualToString:[userDic objectForKey:@"@type"]])
            {
                [self parseUserInfo_inline:userDic];
            }
        }
        //在线状态
        if (dic && [[dic objectForKey:@"@type"] isEqualToString:@"updateUserStatus"]) {
            UserInfo *prev = [self.contacts_dic objectForKey:[NSNumber numberWithLong:[[dic objectForKey:@"user_id"] longValue]]];
            if (prev) {
                prev.status = [dic objectForKey:@"status"];
                [self.contacts_dic setObject:prev forKey:[NSNumber numberWithLong:[[dic objectForKey:@"user_id"] longValue]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateUserUpdateUserStatus) withInParam:nil];
                });
            }
        }
    }
    else if([@"updateUserPrivacySettingRules" isEqualToString:type])
    {//更新个人隐私设置
        NSDictionary *settingDic = [dic objectForKey:@"setting"];
        NSDictionary *rulesDic = [dic objectForKey:@"rules"];
        NSArray *rulesList = [rulesDic objectForKey:@"rules"];
        NSString *psType = [settingDic objectForKey:@"@type"];
//        if(rulesList != nil && rulesList.count>0)
//        {
        NSString *valueType = @"userPrivacySettingRuleRestrictAll";
        if (rulesList != nil && rulesList.count>0) {
            valueType = [[rulesList firstObject] objectForKey:@"@type"];
        }
        
        if([@"userPrivacySettingAllowFindingByPhoneNumber" isEqualToString:psType])
        {//是否可以通过手机号码搜索到当前用户
            
            if([@"userPrivacySettingRuleAllowAll" isEqualToString:valueType])
            {
                [UserInfo shareInstance].isFindByPhoneNumber = YES;
            }
            else
            {
                [UserInfo shareInstance].isFindByPhoneNumber = NO;
            }
            
        }
        else if([@"userPrivacySettingAllowFindingByUsername" isEqualToString:psType])
        {//是否可以通过手机号码搜索到当前用户
            
            if([@"userPrivacySettingRuleAllowAll" isEqualToString:valueType])
            {
                [UserInfo shareInstance].isFindByUserName = YES;
            }
            else
            {
                [UserInfo shareInstance].isFindByUserName = NO;
            }
            
        }
        else if ([@"userPrivacySettingAllowMessages" isEqualToString:psType] ||
                 [@"userPrivacySettingAllowChatInvites" isEqualToString:psType] ||
                 [@"userPrivacySettingShowPhoneNumber" isEqualToString:psType] ||
                 [@"userPrivacySettingAllowCalls" isEqualToString:psType] ||
                 [@"userPrivacySettingShowStatus" isEqualToString:psType]) { // 消息
            [[UserInfo shareInstance].privacyRules setObject:valueType forKey:psType];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateUserPrivacySettings) withInParam:nil];
        });
//        }
    }
    else if([self dealConnectionState_inline:type data:dic])
    {//连接状态处理
    }
    else if([self dealChatList_inline:type data:dic])
    {//最近会话消息处理
    }
    else if([self dealNewMessage_inline:type data:dic])
    {//新消息处理
    }
    else if([self dealGroup_inline:type data:dic])
    {//群组相关
    }
    else if([self dealNewCustomEvent_inline:type data:dic])
    {//自定义消息相关
    }
    else if([self updateUserChatAction:type data:dic])
    {//输入状态
    }
    else if([self updateFile:type data:dic])
    {//文件下载
    }
    else if ([self updateBlog:type data:dic]) {
        
    }
    else
    {
        //ChatLog(@"***: %@", response);
    }
}

- (BOOL)updateUserChatAction:(NSString *)type data:(NSDictionary *)dic{
    if([@"updateUserChatAction" isEqualToString:type]){
        NSString *action = [[dic objectForKey:@"action"] objectForKey:@"@type"];
        if (action && [action isKindOfClass:[NSString class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([action isEqualToString:@"chatActionTyping"]) {
                    //输入
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_User_Inputing) withInParam:dic];
                }else if ([action isEqualToString:@"chatActionCancel"]){
                    //无输入
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_User_Inputing_Canale) withInParam:dic];
                }
            });
        }
    }
    return NO;
}

- (BOOL)updateFile:(NSString *)type data:(NSDictionary *)dic{
    if([@"updateFile" isEqualToString:type]) {
        FileInfo *fileInfo = [FileInfo mj_objectWithKeyValues:[dic objectForKey:@"file"]];
        [self messageVideoDownloadComplete_inlinefile:fileInfo];
        return YES;
    }
    return NO;
}

- (BOOL)updateBlog:(NSString *)type data:(NSDictionary *)dic {
    if ([@"updateBlogSendSucceeded" isEqualToString:type]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Update_Success) withInParam:dic];
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_UnReadMessage) withInParam:nil];
        });
        return YES;
    }
    else if ([@"updateBlogSendFailed" isEqualToString:type]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Update_Fail) withInParam:dic];
        });
        return YES;
    }
    else if ([@"updateBlogLike" isEqualToString:type]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_UnReadMessage) withInParam:nil];
        });
        return YES;
    }
    else if ([@"updateBlogReply" isEqualToString:type]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_UnReadMessage) withInParam:nil];
        });
        /// 朋友圈 有新回复
        /// inputBlogIdReply 是回复评论
        /// inputBlogIdBlog 是评论动态
        NSDictionary *reply = dic[@"new_reply"];
        if (!reply) {
            return YES;
        }
        NSDictionary *blogId = reply[@"blog_id"];
        if (!blogId) {
            return YES;
        }
        NSString *type = blogId[@"@type"];
        int notify;
        NSInteger ids;
        if ([type isEqualToString:@"inputBlogIdReply"]) {
            notify = MakeID(EUserManager, EUser_Timeline_Reply_Comment_Change);
            ids = [blogId[@"reply_id"] integerValue];
        } else if ([type isEqualToString:@"inputBlogIdBlog"]) {
            notify = MakeID(EUserManager, EUser_Timeline_Info_Comment_Change);
            ids = [blogId[@"blog_id"] integerValue];
        } else {
            return YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:notify withInParam:@[@(ids), reply]];
        });
        return YES;
    }
    return NO;
}

- (void)parseUserInfo_inline:(NSDictionary *)userDic
{
    UserInfo *user = [UserInfo mj_objectWithKeyValues:userDic];
    if([UserInfo shareInstance]._id == user._id)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UserInfo shareInstance].first_name = user.first_name;
            [UserInfo shareInstance].last_name = user.last_name;
            [UserInfo shareInstance].phone_number = user.phone_number;
            [UserInfo shareInstance].username = user.username;
            [UserInfo shareInstance].profile_photo = user.profile_photo;
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateUserInfo) withInParam:nil];
            //当前是否用户名密码登录方式，此策略执行后，跟手机号码登录保持一致
            if([UserInfo shareInstance].isPasswordLoginType)
            {
                //更新主键为手机号码
                [[AuthUserManager shareInstance] updateCurrentUserPhone:[UserInfo shareInstance].phone_number];
            }
        });
    }
    else
    {
        BOOL isAdd = NO;
        UserInfo *prev = [self.contacts_dic objectForKey:[NSNumber numberWithLong:user._id]];
        if(prev != nil)
        {//update
            if([prev.displayName isEqualToString:user.displayName])
            {//昵称未改变
                user.displayName_short_py = prev.displayName_short_py;
                user.displayName_full_py = prev.displayName_full_py;
            }
            [self.contacts_dic setObject:user forKey:[NSNumber numberWithLong:user._id]];
        }
        else
        {//新增
            isAdd = YES;
            [self.contacts_dic setObject:user forKey:[NSNumber numberWithLong:user._id]];
        }
        //补充拼音
        if(user.displayName_short_py == nil || user.displayName_short_py.length<=0)
        {
            user.displayName_short_py = [user.displayName shortPY];
        }
        if(user.displayName_full_py == nil || user.displayName_full_py.length<=0)
        {
            user.displayName_full_py = [user.displayName fullPY];
        }
        user.sectionNum = [[UILocalizedIndexedCollation currentCollation] sectionForObject:user collationStringSelector:@selector(displayName_full_py)];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(isAdd)
            {
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_AddNewContactInfo) withInParam:user];
            }
            else
            {
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateContactInfo) withInParam:user];
            }
        });
    }
}

#pragma mark - 鉴权状态相关
- (void)dealAuthorizationUpdate_inline:(NSDictionary *)authorization_state
{
    if(_userState == GoUserState_Ready_Background)
    {//前后端切换
        return;
    }
    
    if([authorization_state isKindOfClass:[NSDictionary class]])
    {
        NSString *type = [authorization_state objectForKey:@"@type"];
        if([@"authorizationStateWaitTdlibParameters" isEqualToString:type]) //授权状态Wait Tdlib参数
        {
            ChatLog(@"开始配置Tdlib参数");
            _userState = GoUserState_TdlibParameters;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_To_TdConfig) withInParam:nil];
            });
        }
        else if([@"authorizationStateWaitEncryptionKey" isEqualToString:type])//授权状态等待加密密钥
        {
            //[self checkDatabaseEncryptionKey];
            _userState = GoUserState_WaitEncryptionKey;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_To_Check_Encryption) withInParam:nil];
            });
        }
        else if([@"authorizationStateWaitPhoneNumber" isEqualToString:type])//授权状态等待电话号码
        {
            //[self setAuthenticationPhoneNumber];
            _userState = GoUserState_WaitPhoneNumber;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Input_Phone) withInParam:nil];
            });
        }
        else if([@"authorizationStateWaitCode" isEqualToString:type])//授权状态等待码
        {
            //[self checkAuthenticationCode];
            _userState = GoUserState_WaitCode;
            dispatch_async(dispatch_get_main_queue(), ^{
                if([UserInfo shareInstance].isPasswordLoginType)
                {//固定验证码
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Input_Code_ByPasswordWay) withInParam:nil];
                }
                else
                {//发送验证码
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Input_Code) withInParam:nil];
                }
            });
        }
        else if([@"authorizationStateWaitRegistration" isEqualToString:type])//授权状态等待注册
        {
            //[self registerUser];
            _userState = GoUserState_WaitRegistration;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Register) withInParam:nil];
            });
        }
        else if([@"authorizationStateWaitPassword" isEqualToString:type])//授权状态等待密码
        {
            //[self checkAuthenticationPassword];
            _userState = GoUserState_WaitPassword;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Input_Password) withInParam:nil];
            });
        }
        else if([@"authorizationStateReady" isEqualToString:type])//授权状态就绪
        {
            /// 此处说明用户已登录，无需在做重连操作
            /// 修改为 连接成功后，再进入首页
//            _firstConnectionSuccessful = YES;
            _userState = GoUserState_Ready;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Ready) withInParam:nil];
            });
        }
        else if([@"authorizationStateClosed" isEqualToString:type])//授权状态已关闭
        {
            _userState = GoUserState_Closed;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Closed) withInParam:nil];
            });
        }
        else if([@"authorizationStateClosing" isEqualToString:type])
        {
            _userState = GoUserState_Closing;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Closing) withInParam:nil];
            });
        }
        else if([@"authorizationStateLoggingOut" isEqualToString:type])//授权状态注销
        {
            _userState = GoUserState_LoggingOut;
            self.firstConnectionSuccessful = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Logout) withInParam:nil];
            });
        }
        else if([@"authorizationStateWaitOtherDeviceConfirmation" isEqualToString:type])//授权状态等待其他设备确认
        {
            _userState = GoUserState_WaitOtherDeviceConfirmation;
        }
        else
        {
            ChatLog(@"未处理状态: %@", authorization_state);
        }
    }
    else
    {
        ChatLog(@"状态异常: %@", authorization_state);
    }
}

#pragma mark - 连接状态处理
- (BOOL)dealConnectionState_inline:(NSString *)type data:(NSDictionary *)dic
{
    if (![@"updateConnectionState" isEqualToString:type]) return NO;
    
    NSDictionary *stateDic = [dic objectForKey:@"state"];
    if (!stateDic || ![stateDic isKindOfClass:NSDictionary.class]) return YES;
    
    NSString *stateStr = [stateDic objectForKey:@"@type"];
    if (!stateStr || ![stateStr isKindOfClass:NSString.class]) return YES;
   
    if ([@"connectionStateReady" isEqualToString:stateStr])
    {
        _userConnectionState = GoUserConnectionState_StateReady;
        self.firstConnectionSuccessful = YES;
        /// 连接成功，取消掉 5 秒重连的延时方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetWork) object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GoLogin" object:nil];
    }
    else if ([@"connectionStateUpdating" isEqualToString:stateStr])
    {
        _userConnectionState = GoUserConnectionState_Updating;
        if (!self.isFirstConnectionSuccessful) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetWork) object:nil];
                [self performSelector:@selector(checkNetWork) withObject:nil afterDelay:5];
            });
        }
    }
    else
    {
        _userConnectionState = GoUserConnectionState_Connecting;
        if (!self.isFirstConnectionSuccessful) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNetWork) object:nil];
                [self performSelector:@selector(checkNetWork) withObject:nil afterDelay:5];
            });
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Connection_State_Changed) withInParam:nil];
    });
    return YES;
}

- (void)checkNetWork {
    if (_userConnectionState == GoUserConnectionState_StateReady) {
        return;
    }
    /// 重新创建
    [NSNotificationCenter.defaultCenter postNotificationName:@"ResetClicent" object:nil];
}

- (void)localAddChat:(ChatInfo *)chat{
    if (chat) {
        [self.chat_dic setObject:chat forKey:[NSNumber numberWithLong:chat._id]];
        dispatch_async(dispatch_get_main_queue(), ^{
            chat.title_full_py = [chat.title fullPY];
            chat.sectionNum = [[UILocalizedIndexedCollation currentCollation] sectionForObject:chat collationStringSelector:@selector(title_full_py)];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_List_Changed) withInParam:chat];
        });
    }
}

#pragma mark - 最近会话处理
- (BOOL)dealChatList_inline:(NSString *)type data:(NSDictionary *)dic
{
    // @自己未读消息数监听
    if ([type isEqualToString:@"updateChatUnreadMentionCount"]) {
        ChatLog(@"%@",dic);
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.unread_mention_count = [[dic objectForKey:@"unread_mention_count"] intValue];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:chat];
            });
        }
        return YES;
    }else if ([type isEqualToString:@"updateMessageMentionRead"]){
        // @自己已读消息数监听
        ChatLog(@"%@",dic);
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.unread_mention_count = [[dic objectForKey:@"unread_mention_count"] intValue];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateNewChat" isEqualToString:type])
    {//新最近会话
        
        if ([UserInfo shareInstance].inOpenGroup) {
            return YES;
        }
        NSDictionary *chatDic = [dic objectForKey:@"chat"];
        if(chatDic != nil && [chatDic isKindOfClass:[NSDictionary class]])
        {
            __block ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:chatDic];
            __block ChatInfo *curChat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chat._id]];
            // 先加入本地缓存
            if(curChat != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [curChat copyChatContent:chat];
                    curChat.title_full_py = [curChat.title fullPY];
                    curChat.sectionNum = [[UILocalizedIndexedCollation currentCollation] sectionForObject:curChat collationStringSelector:@selector(title_full_py)];
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:curChat];
                });
            }
            else
            {
                [self.chat_dic setObject:chat forKey:[NSNumber numberWithLong:chat._id]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    chat.title_full_py = [chat.title fullPY];
                    chat.sectionNum = [[UILocalizedIndexedCollation currentCollation] sectionForObject:chat collationStringSelector:@selector(title_full_py)];
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_List_Changed) withInParam:chat];
                });
            }
            // 请求私密聊天状态
            if (chat.isSecretChat) {
                [TF_RequestManager getSecretChatWithSecretId:chat.type.secret_chat_id resultBlock:^(NSDictionary *request, NSDictionary *response, SecretChat *obj) {
                    ChatInfo *newChat;
                    if(curChat != nil){
                        newChat = [self.chat_dic objectForKey:[NSNumber numberWithLong:curChat._id]];
                    } else {
                        newChat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chat._id]];
                    }
                    newChat.secretChatInfo = obj;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:curChat];
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateChatUpdateSecretChatStatus) withInParam:obj];
                    });


                } timeout:^(NSDictionary *request) {

                }];
            }
            
            if (chat.isSuperGroup) {
                [self getSuperGroupMembers:chat.type.supergroup_id type:@"supergroupMembersFilterRecent" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    if ([obj isKindOfClass:NSArray.class]) {
                        chat.groupMembers = (NSArray *)obj;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:chat];
                        });
                    }
                } timeout:^(NSDictionary *request) {
                    
                }];
            }
        }
        
        return YES;
    }
    else if([@"updateChatLastMessage" isEqualToString:type])
    {//最近会话-更新最后一条消息
        NSDictionary *messageDic = [dic objectForKey:@"last_message"];
        if(messageDic != nil && [messageDic isKindOfClass:[NSDictionary class]])
        {
            MessageInfo *last = [MessageInfo mj_objectWithKeyValues:messageDic];
            ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:last.chat_id]];
            if(chat != nil)
            {
                [self dealMessageType_inline:[[dic objectForKey:@"last_message"] objectForKey:@"content"] message:last];
                dispatch_async(dispatch_get_main_queue(), ^{
                    chat.lastMessage = last;
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Last_Message_Changed) withInParam:chat];
                });
            }
        }
        else
        {
            long chatId = [[dic objectForKey:@"chat_id"] longValue];
            ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
            if(chat != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    chat.lastMessage = nil;
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Last_Message_Changed) withInParam:chat];
                });
            }
        }
        return YES;
    }
    else if([@"updateChatReadInbox" isEqualToString:type])
    {//最近会话-未读角标变化
        //{"@type":"updateChatReadInbox","chat_id":136817704,"last_read_inbox_message_id":357564416,"unread_count":9}
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.unread_count = [[dic objectForKey:@"unread_count"] intValue];
                chat.last_read_inbox_message_id = [[dic objectForKey:@"last_read_inbox_message_id"] longValue];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatReadOutbox" isEqualToString:type])
    {//最近会话-发送消息被读
        //{"@type":"updateChatReadOutbox","chat_id":-1001073741852,"last_read_outbox_message_id":60817408}
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.last_read_outbox_message_id = [[dic objectForKey:@"last_read_outbox_message_id"] longValue];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_OutMessage_Readed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatTitle" isEqualToString:type])
    {//最近会话-标题修改
        //{"@type":"updateChatTitle","chat_id":-32,"title":"Test01"}
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.title = [dic objectForKey:@"title"];
                chat.title_full_py = [chat.title fullPY];
                chat.sectionNum = [[UILocalizedIndexedCollation currentCollation] sectionForObject:chat collationStringSelector:@selector(title_full_py)];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Title_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatPhoto" isEqualToString:type])
    {//最近会话-修改头像
        //{"@type":"updateChatPhoto","chat_id":-36,"photo":{"@type":"chatPhoto",
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            ProfilePhoto *photo = [ProfilePhoto mj_objectWithKeyValues:[dic objectForKey:@"photo"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.photo = photo;
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Photo_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatPermissions" isEqualToString:type])
    {//最近会话-管理员修改了权限
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            ChatPermissions *info = [ChatPermissions mj_objectWithKeyValues:[dic objectForKey:@"permissions"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.permissions = info;
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Permissions_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatPosition" isEqualToString:type])
    {//最近会话-置顶
        //{"@type":"updateChatIsPinned","chat_id":136817691,"is_pinned":true,"order":"9221294784512000001"}
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                ChatPosition *cp = [ChatPosition mj_objectWithKeyValues:[dic objectForKey:@"position"]];
                //chat.is_pinned = [[dic objectForKey:@"is_pinned"] boolValue];
                chat.is_pinned = cp.is_pinned;
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_List_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatDefaultDisableNotification" isEqualToString:type])
    {//最近会话-通知设置
        //{"@type":"updateChatDefaultDisableNotification","chat_id":136817691,"default_disable_notification":false}
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.default_disable_notification = [[dic objectForKey:@"default_disable_notification"] boolValue];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Changed) withInParam:chat];
            });
        }
        return YES;
    }
    else if([@"updateChatIsBlocked" isEqualToString:type])
    {
        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                chat.is_blocked = [[dic objectForKey:@"is_blocked"] boolValue];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Is_Blocked) withInParam:chat];
            });
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 群组相关
- (BOOL)dealGroup_inline:(NSString *)type data:(NSDictionary *)dic
{
    if([@"updateBasicGroup" isEqualToString:type])
    {
        NSDictionary *basicGroupDic = [dic objectForKey:@"basic_group"];
        if(basicGroupDic != nil && [basicGroupDic isKindOfClass:[NSDictionary class]])
        {
            BasicGroupInfo *info = [BasicGroupInfo mj_objectWithKeyValues:basicGroupDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Group_Basic_Info_Changed) withInParam:info];
            });
        }
        return YES;
    }
    else if([@"updateBasicGroupFullInfo" isEqualToString:type])
    {
        NSDictionary *basicFullGroupDic = [dic objectForKey:@"basic_group_full_info"];
        if(basicFullGroupDic != nil && [basicFullGroupDic isKindOfClass:[NSDictionary class]])
        {
            BasicGroupFullInfo *info = [BasicGroupFullInfo mj_objectWithKeyValues:basicFullGroupDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Group_Basic_Full_Info_Changed) withInParam:@{@"info":info, @"basic_group_id":[dic objectForKey:@"basic_group_id"]}];
            });
        }
        return YES;
    }
    else if([@"updateSupergroup" isEqualToString:type])
    {
        NSDictionary *superGroupDic = [dic objectForKey:@"supergroup"];
        if(superGroupDic != nil && [superGroupDic isKindOfClass:[NSDictionary class]])
        {
            SuperGroupInfo *info = [SuperGroupInfo mj_objectWithKeyValues:superGroupDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Group_Super_Info_Changed) withInParam:info];
            });
        }
        return YES;
    }
    else if([@"updateSupergroupFullInfo" isEqualToString:type])
    {
        NSDictionary *superFullGroupDic = [dic objectForKey:@"supergroup_full_info"];
        if(superFullGroupDic != nil && [superFullGroupDic isKindOfClass:[NSDictionary class]])
        {
            SuperGroupFullInfo *info = [SuperGroupFullInfo mj_objectWithKeyValues:superFullGroupDic];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Group_Super_Full_Info_Changed) withInParam:@{@"info":info, @"supergroup_id":[dic objectForKey:@"supergroup_id"]}];
            });
        }
        return YES;
    }else if([@"updateChatOnlineMemberCount" isEqualToString:type])
    {
//        long chatId = [[dic objectForKey:@"chat_id"] longValue];
        NSString *chatId = [NSString stringWithFormat:@"%@", dic[@"chat_id"]];
        NSString *count = [NSString stringWithFormat:@"%@", dic[@"online_member_count"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_UpdateChatOnlineMemberCount) withInParam:@{@"chatId" : chatId, @"count" : count}];
        });
        return YES;
    }
    else
    {
        return NO;
    }
}



- (void)addLocalNotice:(MessageInfo *)msg {
    /// 自己是发送人 不作处理
    if (msg.sender.user_id == UserInfo.shareInstance._id) {
        return;
    }
    MJWeakSelf
    [[TelegramManager shareInstance] getUserSimpleInfo_inline:msg.sender.user_id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        UserInfo *user = [UserInfo mj_objectWithKeyValues:response];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf addLocalNotice:msg user:user];
        });
        
    } timeout:^(NSDictionary *request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf addLocalNotice:msg user:nil];
        });
    }];
    
    
}

- (void)addLocalNotice:(MessageInfo *)msg user:(UserInfo *)user{
    if (@available(iOS 10.0, *)) {
        NSString *name = user.displayName;
        NSString *msgContent = msg.description;
        
        ChatInfo *chat = self.chat_dic[@(msg.chat_id)];
        if (chat && chat.isGroup) {
            name = [chat groupSenderNickname:user._id];
        }
        if (chat && chat.isSecretChat) {
            msgContent = nil;
            name = @"[收到一条新消息]";
        }
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        
        content.title = APP_NAME.lv_localized;
        content.subtitle = name;
        // 内容
        content.body = msgContent;
        // 多少秒后发送,可以将固定的日期转化为时间
        NSTimeInterval time = [[NSDate dateWithTimeIntervalSinceNow:0.1] timeIntervalSinceNow];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:time repeats:NO];
        NSString *identifier = @"noticeId";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            ChatLog(@"成功添加推送");
        }];
    }else {
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
        notif.alertBody = msg.textTypeContent;
        notif.userInfo = @{@"noticeId":@"00001"};
        [[UIApplication sharedApplication] scheduleLocalNotification:notif];
    }
}

#pragma mark - 新消息，包括发送的消息、删除的消息
- (BOOL)dealNewMessage_inline:(NSString *)type data:(NSDictionary *)dic
{
    //       新消息 {"@type":"updateNewMessage","message":{"@type":"message","id":426770432,"sender_user_id":136817704,"chat_id":136817704,"is_outgoing":false,"can_be_edited":false,"can_be_forwarded":true,"can_be_deleted_only_for_self":true,"can_be_deleted_for_all_users":true,"is_channel_post":false,"contains_unread_mention":false,"date":1604831508,"edit_date":0,"reply_to_message_id":0,"ttl":0,"ttl_expires_in":0.000000,"via_bot_user_id":0,"author_signature":"","views":0,"media_album_id":"0","restriction_reason":"","content":{"@type":"messageText","text":{"@type":"formattedText","text":"\u54fc\u54fc\u5527\u5527","entities":[]}}}}
    if([@"updateNewMessage" isEqualToString:type])
    {//新消息，包括发送的消息
        NSDictionary *messageDic = [dic objectForKey:@"message"];
        if(messageDic != nil && [messageDic isKindOfClass:[NSDictionary class]])
        {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:messageDic];
            [TelegramManager parseMessageContent:[messageDic objectForKey:@"content"] message:msg];
//            [self dealMessageType_inline:[[dic objectForKey:@"message"] objectForKey:@"content"] message:msg];
            dispatch_async(dispatch_get_main_queue(), ^{
                // 新增app退到后台的本地推送逻辑
                UIApplicationState state = [UIApplication sharedApplication].applicationState;
                if (state == UIApplicationStateBackground) { // app在后台
                    [self addLocalNotice:msg];
                }
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_New_Message) withInParam:msg];
            });
        }
        return YES;
    }
    else if([@"updateMessageSendSucceeded" isEqualToString:type])
    {//消息发送成功
        //old_message_id
        NSDictionary *messageDic = [dic objectForKey:@"message"];
        if(messageDic != nil && [messageDic isKindOfClass:[NSDictionary class]])
        {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:messageDic];
            [self dealMessageType_inline:[[dic objectForKey:@"message"] objectForKey:@"content"] message:msg];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Send_Message_Success) withInParam:@{@"msg":msg, @"old_message_id":[dic objectForKey:@"old_message_id"]}];
            });
        }
        return YES;
    }
    else if([@"updateMessageSendFailed" isEqualToString:type])
    {//消息发送失败
        NSDictionary *messageDic = [dic objectForKey:@"message"];
        if(messageDic != nil && [messageDic isKindOfClass:[NSDictionary class]])
        {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:messageDic];
            [self dealMessageType_inline:[[dic objectForKey:@"message"] objectForKey:@"content"] message:msg];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Send_Message_Fail) withInParam:@{@"msg":msg, @"old_message_id":[dic objectForKey:@"old_message_id"]}];
            });
        }
        return YES;
    }
    else if([@"updateDeleteMessages" isEqualToString:type])
    {
        //{"@type":"updateDeleteMessages","chat_id":136817700,"message_ids":[177209346],"is_permanent":true,"from_cache":false}
        NSArray *msgIds = [dic objectForKey:@"message_ids"];
        if(msgIds != nil && [msgIds isKindOfClass:[NSArray class]] && msgIds.count>0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Delete_Message) withInParam:@{@"msgIds":msgIds, @"chat_id":[dic objectForKey:@"chat_id"], @"is_permanent":[dic objectForKey:@"is_permanent"], @"from_cache":[dic objectForKey:@"from_cache"]}];
            });
        }
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 消息类型处理
- (void)dealMessageType_inline:(NSDictionary *)contentDic message:(MessageInfo *)msg
{
    [TelegramManager parseMessageContent:contentDic message:msg];
}

+ (void)parseMessageContent:(NSDictionary *)contentDic message:(MessageInfo *)msg
{
    if([contentDic isKindOfClass:[NSDictionary class]])
    {
        NSString *type = [contentDic objectForKey:@"@type"];
        if([@"messageText" isEqualToString:type])
        {
            msg.messageType = MessageType_Text;
            NSDictionary *textDic = [contentDic objectForKey:@"text"];
            if([textDic isKindOfClass:[NSDictionary class]])
            {
                msg.textTypeContent = [textDic objectForKey:@"text"];
            }
            [msg parseTextToExMessage];
        }
        else if([@"messageAnimation" isEqualToString:type])
        {
            msg.messageType = MessageType_Animation;
        }
        else if([@"messageAudio" isEqualToString:type])//音频
        {
            msg.messageType = MessageType_Audio;
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
        }
        else if([@"messageVoiceNote" isEqualToString:type])//语音
        {
            msg.messageType = MessageType_Voice;
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
        }
        else if([@"messageDocument" isEqualToString:type])
        {
            msg.messageType = MessageType_Document;
            //解析标题
            NSDictionary *captionDic = [contentDic objectForKey:@"caption"];
            if([captionDic isKindOfClass:[NSDictionary class]])
            {
                msg.content.title = [captionDic objectForKey:@"text"];
            }
            if(IsStrEmpty(msg.content.title))
            {
                msg.content.title = msg.content.document.file_name;
            }
            if(IsStrEmpty(msg.content.title))
            {
                msg.content.title = @"未知文件名";
            }
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
        }
        else if([@"messagePhoto" isEqualToString:type])
        {
            msg.messageType = MessageType_Photo;
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
            
        }
        else if([@"messagePinMessage" isEqualToString:type])
        {
            msg.messageType = MessageType_Pinned;
        }
        else if([@"messageSticker" isEqualToString:type])
        {
            msg.messageType = MessageType_Sticker;
        }
        else if([@"messageVideo" isEqualToString:type])
        {
            msg.messageType = MessageType_Video;
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
        }
        else if([@"messagePoll" isEqualToString:type])
        {
            msg.messageType = MessageType_Poll;
        }
        else if([@"messageLocation" isEqualToString:type])
        {
            msg.messageType = MessageType_Location;
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
        }
        else if([@"messageCall" isEqualToString:type])
        {
            msg.messageType = MessageType_Call;
        }
        else if([@"messageContactRegistered" isEqualToString:type])
        {
            msg.messageType = MessageType_Contact_Registed;
        }
        else if([@"messageContact" isEqualToString:type]) {
            msg.messageType = MessageType_Card;
            if (msg.ttl_expires_in>0) {
                msg.fireTime = [NSString stringWithFormat:@"%.0f",msg.ttl_expires_in];
            }
        }
        else
        {
            msg.messageType = MessageType_Unkown;
        }
    }
}

#pragma mark - 任务同步
//timeout is 0, DISPATCH_TIME_FOREVER
- (void)addTask:(NSDictionary *)request rtId:(int)rtId result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    [self addTask:request rtId:rtId timeout:RQEUST_TIMEOUT result:resultBlock timeout:timeoutBlock];
}

- (void)addTask:(NSDictionary *)request rtId:(int)rtId timeout:(NSTimeInterval)timeout result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    TgTask *task = [TgTask new];
    task.request = request;
    task.rtId = rtId;
    task.resultBlock = resultBlock;
    task.timeoutBlock = timeoutBlock;
    @synchronized(self) {
        [self.requestQueue setObject:task forKey:[NSNumber numberWithInt:task.rtId]];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL ret = [task wait:timeout];
        dispatch_async(self->workQueue, ^{
            NSNumber *key = [NSNumber numberWithInt:task.rtId];
            if(![self.requestQueue objectForKey:key])
            {
                //request cancel
                return;
            }
            [self.requestQueue removeObjectForKey:key];
            if(ret)
            {//result
                if(task.resultBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        task.resultBlock(task.request, task.response);
                    });
                }
            }
            else
            {//timeout
                if(task.timeoutBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        task.timeoutBlock(task.request);
                    });
                }
            }
        });
    });
}

- (void)cancelTask:(int)taskId
{
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        [bSelf.requestQueue removeObjectForKey:[NSNumber numberWithInt:taskId]];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
}



#pragma mark - 鉴权相关
- (void)setTdlibParameters:(NSString *)data_directory result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    [UserInfo shareInstance].data_directory = data_directory;
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSNumber * useNetIndex = [[NSUserDefaults standardUserDefaults] objectForKey:@"UseNetIndex"];
//        NSNumber * useNetIndex = [NSNumber numberWithInt:0];
        
        NSString *backup_ip =[NetworkManage sharedInstance].backup_ips[[useNetIndex intValue]];
        NSDictionary *paramDic = @{@"database_directory" : data_directory,
                                   //@"files_directory" : @""//不设置，则使用database_directory
                                   @"use_file_database" : [NSNumber numberWithBool:YES],
                                   @"use_chat_info_database" : [NSNumber numberWithBool:YES],
                                   @"use_message_database" : [NSNumber numberWithBool:YES],
                                   @"use_secret_chats" : [NSNumber numberWithBool:YES],
                                   @"api_id" : [NSNumber numberWithInt:8],
                                   @"api_hash" : @"7245de8e747a0d6fbe11f7cc14fcc0bb",
                                   @"system_language_code" : [Common language],
                                   @"device_model" : [Common deviceModel],
                                   @"application_version" : [Common appVersion],
                                   @"system_version" : [Common systemVersion],
                                   @"dc_host_idx" : useNetIndex,//@"dc_host_list" : @[TDLib_Host],
                                   @"dc_host_list" :[NetworkManage sharedInstance].backup_ips,
                                   @"enable_storage_optimizer" : [NSNumber numberWithBool:NO]};//@"dc_host_list" : @[@"a.gochat8.com",@"b.gochat8.com",@"c.gochat8.com"],
        ChatLog(@"配置paramDic : %@",paramDic);
        NSDictionary *funQuery = @{@"@type" : @"setTdlibParameters",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"parameters" : paramDic};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setTdlibParameters %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)checkDatabaseEncryptionKey:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"checkDatabaseEncryptionKey",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"encryption_key" : @""};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke checkDatabaseEncryptionKey %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)setAuthenticationPhoneNumber:(NSString *)phone result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        //@"phone_number" : @"+86 17372202737"
        NSDictionary *funQuery = @{@"@type" : @"setAuthenticationPhoneNumber",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"phone_number" : phone};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setAuthenticationPhoneNumber %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)changeAuthenticationPhoneNumber:(NSString *)phone result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"changePhoneNumber",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"phone_number" : phone,
                                   @"settings" : @{@"allow_flash_call":@NO, @"is_current_phone_number":@YES, @"allow_sms_retriever_api":@YES}};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke changeAuthenticationPhoneNumber %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)checkAuthenticationCode:(NSString *)code result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"checkAuthenticationCode",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"code" : code};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke checkAuthenticationCode %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)registerUser:(NSString *)firstName lastName:(NSString *)lastName result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"registerUser",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"first_name" : firstName,
                                   @"last_name" : lastName};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke registerUser %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)checkAuthenticationPassword:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"checkAuthenticationPassword",
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"password" : @""};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke checkAuthenticationPassword %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)background
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"close"};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke background %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
        self.userState = GoUserState_Ready_Background;
        
        //更新连接状态
        self.userConnectionState = GoUserConnectionState_Connecting;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Connection_State_Changed) withInParam:nil];
        });
        
        //释放client
//        td_json_client_destroy(self.tdClient);
        self.tdClient = nil;
        td_json_client_destroy(self.tdClient);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)logout
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"logOut"};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke logout %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)deleteAccount {
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"deleteAccount"};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke deleteAccount %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)destroy
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"destroy"};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke destroy %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
        //退出登录要调用这个，放在销毁里
//        td_json_client_destroy(self.tdClient);
        self.tdClient = nil;
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 用户状态相关
- (GoUserState)getUserState
{
    __block TelegramManager *bSelf = self;
    __block GoUserState state = GoUserState_Unkown;
    dispatch_block_t block = ^{
        state = bSelf.userState;
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return state;
}

- (GoUserConnectionState)getUserConnectionState
{
    __block TelegramManager *bSelf = self;
    __block GoUserConnectionState state = GoUserConnectionState_Connecting;
    dispatch_block_t block = ^{
        state = bSelf.userConnectionState;
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return state;
}

#pragma mark - 当前会话
- (long)getCurChatId
{
    __block TelegramManager *bSelf = self;
    __block long chatId = 0;
    dispatch_block_t block = ^{
        chatId = bSelf.curChatId;
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return chatId;
}

- (void)updateCurChatId:(long)chatId
{
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        bSelf.curChatId = chatId;
        ChatLog(@"updateCurChatId:%ld", chatId);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


#pragma mark - 开关会话
//开启会话
- (void)openChat:(long)chat_id resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"openChat",
                                                  @"chat_id" : [NSNumber numberWithLong:chat_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
//关闭会话
- (void)closeChat:(long)chat_id resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"openChat",
                                                  @"chat_id" : [NSNumber numberWithLong:chat_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
#pragma mark - 会话相关
- (void)searchPublicChatsList:(NSString *)keyword task:(TgTaskBlock)taskBlock resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//搜索公共会话
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        if(taskBlock != nil)
        {
            taskBlock(rtId);
            /// 此处会导致下面数据回调不执行
//            dispatch_async(dispatch_get_main_queue(), ^{
//                taskBlock(rtId);
//            });
        }
        NSDictionary *funQuery = @{@"@type" : @"searchPublicChats",
                                   @"query" : keyword,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [UserInfo shareInstance].inOpenGroup = YES;
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            [UserInfo shareInstance].inOpenGroup = NO;
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chats"])
                {
                    NSArray *chatIds = [response objectForKey:@"chat_ids"];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, chatIds);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo shareInstance].inOpenGroup = NO;
            if (timeoutBlock) {
                timeoutBlock(request);
            }
        }];
        ChatLog(@"invoke searchPublicChatsList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
// 新增 搜索已是联系人的好友
- (void)searchChatsList:(NSString *)keyword task:(TgTaskBlock)taskBlock resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        if(taskBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                taskBlock(rtId);
            });
        }
        NSDictionary *funQuery = @{@"@type" : @"searchContacts",
                                   @"query" : keyword,
                                   @"limit" : [NSNumber numberWithInt:20],
                                   @"@extra" : [NSNumber numberWithInt:rtId]
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"users"])
                {
                    NSArray *chatIds = [response objectForKey:@"user_ids"];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, chatIds);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke searchPublicChatsList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
//搜索消息 - 返回taskid
- (void)searchMessagesList:(NSString *)keyword task:(TgTaskBlock)taskBlock resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        if(taskBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                taskBlock(rtId);
            });
        }
        NSDictionary *funQuery = @{@"@type" : @"searchMessages",
                                   @"chat_list" : @{@"@type" : @"chatListMain"},
                                   @"query" : keyword,
                                   @"limit" : @20,
                                   //@"filter" : @{@"@type" : @"searchMessagesFilterEmpty"},
                                   //@"min_data" : @0,
                                   //@"max_date" : @0,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"messages"])
                {
                    NSArray *messages = [response objectForKey:@"messages"];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, messages);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke searchMessagesList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//会话是否提醒
- (void)toggleChatDisableNotification:(long)chatId isDisableNotification:(BOOL)isDisableNotification resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"toggleChatDefaultDisableNotification",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"default_disable_notification" : [NSNumber numberWithBool:isDisableNotification],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke toggleChatDisableNotification %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//置顶或者取消置顶
- (void)toggleChatIsPinned:(long)chatId isPinned:(BOOL)isPinned resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"toggleChatIsPinned",
                                   @"chat_list" : @{@"@type" : @"chatListMain"},
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"is_pinned" : [NSNumber numberWithBool:isPinned],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke toggleChatIsPinned %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//加入黑名单
- (void)blockUser:(long)userId isBlock:(BOOL)isBlock resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"toggleMessageSenderIsBlocked",
                                   @"sender" : @{@"@type" : @"messageSenderUser",
                                                  @"user_id" : [NSNumber numberWithLong:userId]},
                                   @"is_blocked" : [NSNumber numberWithBool:isBlock],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke blockUser %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//清空聊天记录-可删除会话
- (void)deleteChatHistory:(long)chatId isDeleteChat:(BOOL)isDeleteChat resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"deleteChatHistory",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"remove_from_chat_list" : [NSNumber numberWithBool:isDeleteChat],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke deleteChatHistory %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)createPrivateChat:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//创建单聊
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"createPrivateChat",
                                   @"user_id" : [NSNumber numberWithLong:userId],
                                   @"force" : [NSNumber numberWithBool:YES],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chat"])
                {
                    ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:response];
                    [self localAddChat:chat];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, chat);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke createPrivateChat %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)createBasicGroupChat:(NSString *)groupName userIds:(NSArray *)userIds resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//创建群组
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"createNewBasicGroupChat",
                                   @"title" : groupName,
                                   @"user_ids" : userIds,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chat"])
                {
                    ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, chat);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke createBasicGroupChat %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)createSuperGroupChat:(NSString *)groupName resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"createNewSupergroupChat",
                                   @"title" : groupName,
                                   @"is_channel" : [NSNumber numberWithBool:NO],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chat"])
                {
                    ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, chat);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke createSuperGroupChat %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getGroupsList:(long)userId offset_chat_id:(long)offset_chat_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//获取讨论组列表
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getGroupsInCommon",
                                   @"user_id" : [NSNumber numberWithLong:userId],
                                   @"offset_chat_id" : [NSNumber numberWithLong:offset_chat_id],
                                   @"limit" : [NSNumber numberWithInt:40],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            //            if(![TelegramManager isResultError:response])
            //            {
            //                NSString *type = [response objectForKey:@"@type"];
            //                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chat"])
            //                {
            //                    ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:response];
            //                    if(resultBlock != nil)
            //                    {
            //                        dispatch_async(dispatch_get_main_queue(), ^{
            //                            resultBlock(request, response, chat);
            //                        });
            //                    }
            //                    return;
            //                }
            //            }
            //            if(resultBlock != nil)
            //            {
            //                dispatch_async(dispatch_get_main_queue(), ^{
            //                    resultBlock(request, response, nil);
            //                });
            //            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getGroupsList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)setGroupName:(long)chatId groupName:(NSString *)groupName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//设置讨论组标题, Supported only for basic groups, supergroups and channels
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatTitle",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"title" : groupName,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setGroupName %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


- (void)setGroupPhoto:(long)chatId localPath:(NSString *)localPath resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//设置讨论组头像
    NSDictionary *photo_Dic = @{
        @"@type" : @"inputChatPhotoStatic",
        @"photo" : @{
                @"@type" : @"inputFileLocal",
                @"path" : localPath
        }
    };
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatPhoto",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"photo" : photo_Dic,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setGroupPhoto %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取群组详情
- (void)getBasicGroupInfo:(long)basic_group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getBasicGroup",
                                   @"basic_group_id" : [NSNumber numberWithLong:basic_group_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"basicGroup"])
                {
                    BasicGroupInfo *info = [BasicGroupInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getBasicGroupInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getBasicGroupFullInfo:(long)basic_group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getBasicGroupFullInfo",
                                   @"basic_group_id" : [NSNumber numberWithLong:basic_group_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"basicGroupFullInfo"])
                {
                    BasicGroupFullInfo *info = [BasicGroupFullInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getBasicGroupFullInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getSuperGroupInfo:(long)group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getSupergroup",
                                   @"supergroup_id" : [NSNumber numberWithLong:group_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"supergroup"])
                {
                    SuperGroupInfo *info = [SuperGroupInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getSuperGroupInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getSuperGroupFullInfo:(long)group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getSupergroupFullInfo",
                                   @"supergroup_id" : [NSNumber numberWithLong:group_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"supergroupFullInfo"])
                {
                    SuperGroupFullInfo *info = [SuperGroupFullInfo mj_objectWithKeyValues:response];
                    if (info.invite_link && [info.invite_link hasPrefix:@"t.me"]) {
                        info.invite_link = [info.invite_link stringByReplacingOccurrencesOfString:@"t.me/joinchat/" withString:KGroupLinkHostAddress];
                    }
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getSuperGroupFullInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取群组成员-仅超级群组
//supergroupMembersFilterAdministrators, supergroupMembersFilterBanned, supergroupMembersFilterBots, supergroupMembersFilterContacts, supergroupMembersFilterMention, supergroupMembersFilterRecent, supergroupMembersFilterRestricted, and supergroupMembersFilterSearch.
//默认-supergroupMembersFilterRecent
- (void)getSuperGroupMembers:(long)group_id type:(NSString *)type keyword:(NSString *)keyword offset:(int)offset limit:(int)limit resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    NSDictionary *filterDic = nil;
    if(IsStrEmpty(keyword))
    {
        filterDic = @{@"@type" : type};
    }
    else
    {
        filterDic = @{@"@type" : type, @"query" : keyword};
    }
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getSupergroupMembers",
                                   @"supergroup_id" : [NSNumber numberWithLong:group_id],
                                   @"filter" : filterDic,
                                   @"offset" : [NSNumber numberWithInt:offset],
                                   @"limit" : [NSNumber numberWithInt:MIN(limit, 200)],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chatMembers"])
                {
                    NSArray *list = [GroupMemberInfo mj_objectArrayWithKeyValuesArray:[response objectForKey:@"members"]];
                    /// 把管理置顶
                    NSMutableArray *admins = NSMutableArray.array;
                    NSMutableArray *members = NSMutableArray.array;
                    [list enumerateObjectsUsingBlock:^(GroupMemberInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isManagerRole) {
                            [admins addObject:obj];
                        } else {
                            [members addObject:obj];
                        }
                    }];
                    NSMutableArray *results = NSMutableArray.array;
                    [results addObjectsFromArray:admins];
                    [results addObjectsFromArray:members];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, results);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getSuperGroupMembers %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getGroupMember:(long)chatId userId:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getChatMember",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:userId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chatMember"])
                {
                    GroupMemberInfo *member = [GroupMemberInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, member);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getGroupMember %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)addMembers2SuperGroup:(long)chatId members:(NSArray *)members resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"addChatMembers",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_ids" : members,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke addMembers2SuperGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)addMember2Group:(long)chatId member:(long)toAddUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"addChatMember",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toAddUserId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke addMember2Group %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)removeMemberFromGroup:(long)chatId member:(long)toDelUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//群组移除成员
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatMemberStatus",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toDelUserId],
                                   @"status" : @{@"@type" : @"chatMemberStatusLeft"},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke removeMemberFromGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)addManager2Group:(long)chatId member:(long)toAddUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//群组添加管理员
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatMemberStatus",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toAddUserId],
                                   @"status" : @{@"@type" : @"chatMemberStatusAdministrator",
                                                 @"can_be_edited" : [NSNumber numberWithBool:YES],
                                                 @"can_change_info" : [NSNumber numberWithBool:YES],
                                                 @"can_post_messages" : [NSNumber numberWithBool:YES],
                                                 @"can_edit_messages" : [NSNumber numberWithBool:YES],
                                                 @"can_delete_messages" : [NSNumber numberWithBool:YES],
                                                 @"can_invite_users" : [NSNumber numberWithBool:YES],
                                                 @"can_restrict_members" : [NSNumber numberWithBool:YES],
                                                 @"can_pin_messages" : [NSNumber numberWithBool:YES],
                                                 @"can_promote_members" : [NSNumber numberWithBool:YES],
                                                 @"is_anonymous" : [NSNumber numberWithBool:YES],
                                   },
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke addManager2Group %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)removeManagerFromGroup:(long)chatId member:(long)toDelUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//先禁言再调用此方法，才会有效-群组移除管理员
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatMemberStatus",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toDelUserId],
                                   @"status" : @{@"@type" : @"chatMemberStatusMember"},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke removeManagerFromGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//退出群组
- (void)leaveGroup:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"leaveChat",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke leaveGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//解散群组
- (void)deleteGroup:(long)group_id resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"deleteSupergroup",
                                   @"supergroup_id" : [NSNumber numberWithLong:group_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke deleteGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//禁言某人
- (void)banMemberFromSuperGroup:(long)chatId member:(long)toBanUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatMemberStatus",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toBanUserId],
                                   @"status" : @{@"@type" : @"chatMemberStatusRestricted",
                                                 @"is_member" : [NSNumber numberWithBool:YES],
                                                 @"restricted_until_date" : [NSNumber numberWithLong:0],
                                                 @"permissions" : @{@"@type" : @"chatPermissions",
                                                                    @"can_send_messages" : [NSNumber numberWithBool:NO],
                                                                    @"can_send_media_messages" : [NSNumber numberWithBool:NO],
                                                                    @"can_send_polls" : [NSNumber numberWithBool:NO],
                                                                    @"can_send_other_messages" : [NSNumber numberWithBool:NO],
                                                                    @"can_add_web_page_previews" : [NSNumber numberWithBool:NO],
                                                                    @"can_change_info" : [NSNumber numberWithBool:NO],
                                                                    @"can_invite_users" : [NSNumber numberWithBool:NO],
                                                                    @"can_pin_messages" : [NSNumber numberWithBool:NO]}},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke banMemberFromSuperGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//取消禁言
- (void)unbanMemberFromSuperGroup:(long)chatId member:(long)toUnbanUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatMemberStatus",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toUnbanUserId],
                                   @"status" : @{@"@type" : @"chatMemberStatusMember"},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke unbanMemberFromSuperGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//设置权限
- (void)setChatPermissions:(long)chatId withPermissions:(NSMutableDictionary *)permissionsDic resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        [permissionsDic setObject:@"chatPermissions" forKey:@"@type"];
        NSDictionary *funQuery = @{@"@type" : @"setChatPermissions",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"permissions" : permissionsDic,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke banAllToGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//全体禁止私聊
//- (void)blockPrivateChatToGroup:(long)chatId isBlock:(BOOL)isBlock resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
//{
//    dispatch_block_t block = ^{
//        if(self.tdClient == nil)
//        {
//            return;
//        }
//
//        ChatPermissions *curPermissions = nil;
//        ChatInfo *curChat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
//        if(curChat != nil)
//        {
//            curPermissions = curChat.permissions;
//        }
//        if(curPermissions == nil)
//        {
//            curPermissions = [ChatPermissions new];
//            curPermissions.can_send_messages = YES;
//            curPermissions.can_send_media_messages = YES;
//            curPermissions.can_send_polls = YES;
//            curPermissions.can_send_other_messages = YES;
//            curPermissions.can_add_web_page_previews = YES;
//            curPermissions.can_change_info = YES;
//            curPermissions.can_invite_users = YES;
//            curPermissions.can_pin_messages = YES;
//        }
//        int rtId = self.requestId++;
//        NSDictionary *funQuery = @{@"@type" : @"setChatPermissions",
//                                   @"chat_id" : [NSNumber numberWithLong:chatId],
//                                   @"permissions" : @{@"@type" : @"chatPermissions",
//                                                 @"can_send_messages" : [NSNumber numberWithBool:curPermissions.can_send_messages],
//                                                 @"can_send_media_messages" : [NSNumber numberWithBool:curPermissions.can_send_media_messages],
//                                                 @"can_send_polls" : [NSNumber numberWithBool:curPermissions.can_send_polls],
//                                                 @"can_send_other_messages" : [NSNumber numberWithBool:curPermissions.can_send_other_messages],
//                                                 @"can_add_web_page_previews" : [NSNumber numberWithBool:!isBlock],
//                                                 @"can_change_info" : [NSNumber numberWithBool:curPermissions.can_change_info],
//                                                 @"can_invite_users" : [NSNumber numberWithBool:curPermissions.can_invite_users],
//                                                 @"can_pin_messages" : [NSNumber numberWithBool:curPermissions.can_pin_messages],
//                                   },
//                                   @"@extra" : [NSNumber numberWithInt:rtId]};
//        NSString *paramStr = [funQuery mj_JSONString];
//        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
//        ChatLog(@"invoke blockPrivateChatToGroup %@", paramStr);
//        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
//    };
//    if (dispatch_get_specific(workQueueTag))
//    {
//        block();
//    }
//    else
//    {
//        dispatch_async(workQueue, block);
//    }
//}

//是否可以加群员
//- (void)canInvideMemberToGroup:(long)chatId isCan:(BOOL)isCan resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
//{
//    dispatch_block_t block = ^{
//        if(self.tdClient == nil)
//        {
//            return;
//        }
//
//        ChatPermissions *curPermissions = nil;
//        ChatInfo *curChat = [self.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
//        if(curChat != nil)
//        {
//            curPermissions = curChat.permissions;
//        }
//        if(curPermissions == nil)
//        {
//            curPermissions = [ChatPermissions new];
//            curPermissions.can_send_messages = YES;
//            curPermissions.can_send_media_messages = YES;
//            curPermissions.can_send_polls = YES;
//            curPermissions.can_send_other_messages = YES;
//            curPermissions.can_add_web_page_previews = YES;
//            curPermissions.can_change_info = YES;
//            curPermissions.can_invite_users = YES;
//            curPermissions.can_pin_messages = YES;
//        }
//        int rtId = self.requestId++;
//        NSDictionary *funQuery = @{@"@type" : @"setChatPermissions",
//                                   @"chat_id" : [NSNumber numberWithLong:chatId],
//                                   @"permissions" : @{@"@type" : @"chatPermissions",
//                                                 @"can_send_messages" : [NSNumber numberWithBool:curPermissions.can_send_messages],
//                                                 @"can_send_media_messages" : [NSNumber numberWithBool:curPermissions.can_send_media_messages],
//                                                 @"can_send_polls" : [NSNumber numberWithBool:curPermissions.can_send_polls],
//                                                 @"can_send_other_messages" : [NSNumber numberWithBool:curPermissions.can_send_other_messages],
//                                                 @"can_add_web_page_previews" : [NSNumber numberWithBool:curPermissions.can_add_web_page_previews],
//                                                 @"can_change_info" : [NSNumber numberWithBool:curPermissions.can_change_info],
//                                                 @"can_invite_users" : [NSNumber numberWithBool:isCan],
//                                                 @"can_pin_messages" : [NSNumber numberWithBool:curPermissions.can_pin_messages],
//                                   },
//                                   @"@extra" : [NSNumber numberWithInt:rtId]};
//        NSString *paramStr = [funQuery mj_JSONString];
//        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
//        ChatLog(@"invoke canInvideMemberToGroup %@", paramStr);
//        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
//    };
//    if (dispatch_get_specific(workQueueTag))
//    {
//        block();
//    }
//    else
//    {
//        dispatch_async(workQueue, block);
//    }
//}

//删除某人全部消息-超级群组
- (void)delAllHisMessagesFromSuperGroup:(long)chatId member:(long)toUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"deleteChatMessagesFromUser",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"user_id" : [NSNumber numberWithLong:toUserId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke delAllHisMessagesFromSuperGroup %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//升级为超级群组
- (void)upgradeBasicGroupChatToSupergroupChat:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"upgradeBasicGroupChatToSupergroupChat",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke upgradeBasicGroupChatToSupergroupChat %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)kickedBySendSensitiveWordsInGroup:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    NSDictionary *parameters = @{
        @"@type" : @"sendCustomRequest",
        @"method": @"chats.kickWhoSendKeyword",
        @"parameters": @{@"chatId": @(chatId)}.mj_JSONString
    };
    [self jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = NO;
        NSString *type = [response objectForKey:@"@type"];
        if ([type isEqualToString:@"customRequestResult"]) {
            NSString *result = [response objectForKey:@"result"];
            if (result != nil && [result isKindOfClass:[NSString class]]) {
                NSDictionary *resp = [result mj_JSONObject];
                if (resp && [resp isKindOfClass:NSDictionary.class]) {
                    NSNumber *code = resp[@"code"];
                    if ([code integerValue] == 200) {
                        isSuccess = YES;
                    }
                }
            }
        }
        if (resultBlock) {
            resultBlock(request, response, @(isSuccess));
        }
        
    } timeout:timeoutBlock];
}

#pragma mark - 消息相关
- (NSArray *)getChatList
{
    __block TelegramManager *bSelf = self;
    __block NSArray *list = nil;
    dispatch_block_t block = ^{
        list = [bSelf.chat_dic allValues];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return list;
}


- (void)deleteChat:(long)chatId
{
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        [bSelf.chat_dic removeObjectForKey:[NSNumber numberWithLong:chatId]];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
}

- (ChatInfo *)getChatInfo:(long)chatId
{//获取某个会话
    __block TelegramManager *bSelf = self;
    __block ChatInfo *chatInfo = nil;
    dispatch_block_t block = ^{
        chatInfo = [bSelf.chat_dic objectForKey:[NSNumber numberWithLong:chatId]];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return chatInfo;
}

- (void)getChatListIds:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getChats",
                                   @"chat_list" : @{@"@type" : @"chatListMain"},
                                   @"offset_order" : [NSNumber numberWithLong:LONG_MAX],
                                   @"offset_chat_id" : [NSNumber numberWithInt:0],
                                   @"limit" : [NSNumber numberWithInt:2000],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getChatHistoryList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getChatLastMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getChatHistory",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"from_message_id" : [NSNumber numberWithInt:0],
                                   @"offset" : [NSNumber numberWithInt:0],
                                   @"limit" : [NSNumber numberWithInt:100],
                                   @"only_local" : [NSNumber numberWithBool:YES],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getChatLastMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getChatMessageList:(long)chatId from_message_id:(long)from_message_id offset:(int)offset limit:(int)limit only_local:(BOOL)only_local resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getChatHistory",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"from_message_id" : [NSNumber numberWithLong:from_message_id],
                                   @"offset" : [NSNumber numberWithInt:offset],
                                   @"limit" : [NSNumber numberWithInt:limit],
//                                   @"only_local" : [NSNumber numberWithBool:only_local],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getChatMessageList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取pin消息
- (void)getChatPinnedMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getChatPinnedMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getChatPinnedMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 设置消息已读
//设置消息已读 - viewMessages
- (void)setMessagesReaded:(long)chatId msgIds:(NSArray *)msgIds
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"viewMessages",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"message_ids" : msgIds,
                                   @"force_read" : [NSNumber numberWithBool:YES]};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke setMessagesReaded %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//设置@消息已读 - readAllChatMentions
- (void)setAtMessagesReaded:(long)chatId
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"readAllChatMentions",
                                   @"chat_id" : [NSNumber numberWithLong:chatId]};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke setAtMessagesReaded %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 发送消息
- (void)reSendMessage:(long)chatId ids:(NSArray *)ids resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//重发消息
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"resendMessages",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"message_ids" : ids,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke reSendMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (NSDictionary *)send_textContent_inline:(NSString *)text withArray:(NSArray *)entityArr
{
    NSMutableArray *entityMutArr = [NSMutableArray array];
    
    if (!entityArr || entityArr.count < 0) {
        //空
    }else{
        for (UserInfo *userinfo in entityArr) {
            NSRange range;
            if(userinfo.realyName){
                range = [CZCommonTool getRangeFromString:text withString:userinfo.realyName];
            }else{
                range = [CZCommonTool getRangeFromString:text withString:userinfo.displayName];
            }
            NSDictionary *entitiesDic = @{
                @"@type" : @"textEntity",
                @"offset" : [NSNumber numberWithLong:range.location],
                @"length" : [NSNumber numberWithLong:range.length],
                @"type" : @{
                        @"@type" : @"textEntityTypeMentionName",
                        @"user_id" : [NSNumber numberWithLong:userinfo._id]
                }
            };
            [entityMutArr addObject:entitiesDic];
        }
    }
    NSDictionary *textDic = @{
        @"@type" : @"formattedText",
        @"text" : text,
        @"entities" : entityMutArr
    };
    return @{@"@type" : @"inputMessageText",
             @"text" : textDic,
             @"disable_web_page_preview" : [NSNumber numberWithBool:NO],
             @"clear_draft" : [NSNumber numberWithBool:NO]};
}

- (void)sendTextMessage:(long)chatId replyid:(long)replyid text:(NSString *)text withUserInfoArr:(NSArray *)remindArr replyMarkup:(NSDictionary *)markup resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {//发送文本消息
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSMutableDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : @(chatId),
                                   @"input_message_content" : [self send_textContent_inline:text withArray:remindArr],
                                   @"reply_to_message_id" : @(replyid),
                                   @"@extra" : @(rtId)}.mutableCopy;
        if (markup) {
            funQuery[@"reply_markup"] = markup;
        }
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendTextMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)sendFireMessage:(long)chatId replyid:(long)replyid text:(NSString *)text withUserInfoArr:(NSArray *)remindArr FireLimit:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{//发送文本消息
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_textContent_inline:text withArray:remindArr],
                                   @"reply_to_message_id" : [NSNumber numberWithLong:replyid],
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendTextMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (void)sendLocalCustomMessage:(long)chatId text:(NSString *)text sender:(long)sender resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"addLocalMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_textContent_inline:text withArray:nil],
                                   @"disable_notification" : @YES,
                                   @"sender" : @{@"@type" : @"messageSenderUser",
                                                 @"user_id" : [NSNumber numberWithLong:sender]},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendTextMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (NSDictionary *)send_photoContent_localPath_inline:(NSString *)localPath photoSize:(CGSize)photoSize
{
    NSDictionary *photoDic = @{
        @"@type" : @"inputFileLocal",
        @"path" : localPath
    };
    NSDictionary *photo_content = @{@"@type" : @"inputMessagePhoto",
             @"width" : [NSNumber numberWithInt:fabs(photoSize.width)],
             @"height" : [NSNumber numberWithInt:fabs(photoSize.height)],
             @"photo" : photoDic};
    
    
//    NSDictionary *photoContent = [self send_photoContent_localPath_inline:localPath photoSize:photoSize];
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (config.using_oss) {
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        content[@"@type"] = @"inputMessageOss";
        content[@"resource"] = photo_content;
        return content;
    } else {
        return photo_content;
    }
    
    
}

- (NSDictionary *)send_GifphotoContent_localPath_inline:(NSString *)localPath photoSize:(CGSize)photoSize
{
    NSDictionary *photoDic = @{
        @"@type" : @"inputFileLocal",
        @"path" : localPath
    };
    NSDictionary *gif_content = @{@"@type" : @"inputMessageAnimation",
             @"width" : [NSNumber numberWithInt:fabs(photoSize.width)],
             @"height" : [NSNumber numberWithInt:fabs(photoSize.height)],
             @"animation" : photoDic};
    
//    NSMutableDictionary *content = [NSMutableDictionary dictionary];
//    content[@"resource"] = gif_content;
//    content[@"@type"] = @"inputMessageOss";
    return gif_content;
    
}

- (void)sendPhotoMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize  replyMarkup:(NSDictionary *)markup resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送图片消息1
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSMutableDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_photoContent_localPath_inline:localPath photoSize:photoSize],
//                                   @"input_message_content" : content,
                                   @"@extra" : [NSNumber numberWithInt:rtId]}.mutableCopy;
        if (markup) {
            funQuery[@"reply_markup"] = markup;
        }
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)sendPhotoTextMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize text:(NSString *)text resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSMutableDictionary *pContent = [self send_photoContent_localPath_inline:localPath photoSize:photoSize].mutableCopy;
        NSDictionary *tContent =  @{
            @"@type" : @"formattedText",
            @"text" : text,
            @"entities" : @[]
        };
        pContent[@"caption"] = tContent ? : @{};
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" :pContent,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)sendFirePhotoMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送图片消息1
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        
//        NSMutableDictionary *photo = [NSMutableDictionary dictionary];
//        photo[@"@type"] = @"inputFileLocal";
//        photo[@"path"] = localPath;
//
//        NSMutableDictionary *resource = [NSMutableDictionary dictionary];
//        resource[@"_comment"] = [NSString stringWithFormat:@"inputMessagePhoto photo:InputFile thumbnail:inputThumbnail added_sticker_file_ids:vector<int32> width:%f height:%f caption:formattedText ttl:int32 = InputMessageContent;", fabs(photoSize.width), fabs(photoSize.height)];
//        resource[@"@type"] = @"inputMessagePhoto";
//        resource[@"width"] = [NSNumber numberWithInt:fabs(photoSize.width)];
//        resource[@"height"] = [NSNumber numberWithInt:fabs(photoSize.height)];
//
//        resource[@"photo"] = photo;
        
        
        
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_photoContent_localPath_inline:localPath photoSize:photoSize],
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
//gif
- (void)sendGifPhotoMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_GifphotoContent_localPath_inline:localPath photoSize:photoSize],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//名片
- (void)sendContentMessage:(long)chatId withRwa:(OrgUserInfo *)obj withChatInfo:(id)chatInfo resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        UserInfo *user = nil;
        if ([chatInfo isKindOfClass:[ChatInfo class]]) {
            ChatInfo *chat = (ChatInfo *)chatInfo;
            user = [[TelegramManager shareInstance] contactInfo:chat.userId];
        } else if ([chatInfo isKindOfClass:[UserInfo class]]) {
            user = chatInfo;
        }
        
        NSDictionary *contact_dic = @{
            @"@type" : @"contact",
            @"last_name" : obj.lastName,
            @"first_name" : obj.firstName,
            @"phone_number" : [@{@"userId": [NSNumber numberWithLong:user._id]} mj_JSONString],
        };
        
        NSDictionary *input_message_content_dic = @{
            @"@type" : @"inputMessageContact",
            @"contact" : contact_dic,
        };
        
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : input_message_content_dic,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//名片
- (void)sendFireContentMessage:(long)chatId withRwa:(OrgUserInfo *)obj withChatInfo:(id)chatInfo fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        UserInfo *user = nil;
        if ([chatInfo isKindOfClass:[ChatInfo class]]) {
            ChatInfo *chat = (ChatInfo *)chatInfo;
            user = [[TelegramManager shareInstance] contactInfo:chat.userId];
        } else if ([chatInfo isKindOfClass:[UserInfo class]]) {
            user = chatInfo;
        }
        
        NSDictionary *contact_dic = @{
            @"@type" : @"contact",
            @"last_name" : obj.lastName,
            @"first_name" : obj.firstName,
            @"phone_number" : [@{@"userId": [NSNumber numberWithLong:user._id]} mj_JSONString],
        };
        
        NSDictionary *input_message_content_dic = @{
            @"@type" : @"inputMessageContact",
            @"contact" : contact_dic,
        };
        
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : input_message_content_dic,
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
//发送收藏的表情
- (void)sendCollectGifPhotoMessage:(long)chatId collectEmoji:(AnimationInfo *)collectModel resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        
        NSDictionary *animation = @{
            @"@type":@"inputFileRemote",
            @"id":collectModel.animation.remote._id,
        };

        NSDictionary *input_message_content_dic = @{
            @"@type" : @"inputMessageAnimation",
            @"width" : @(collectModel.thumbnail.width),
            @"height" : @(collectModel.thumbnail.height),
            @"animation" : animation,
        };
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id": @(chatId),
                                   @"input_message_content" : input_message_content_dic,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendPhotoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
    
}

- (void)sendPhotoMessage:(long)chatId fileId:(NSString *)fileId photoSize:(CGSize)photoSize resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送图片消息2
    
}

- (void)sendPhotoMessage:(long)chatId remotFileId:(NSString *)remotFileId photoSize:(CGSize)photoSize resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送图片消息3
    
}

- (NSDictionary *)send_videoContent_localPath_inline:(NSString *)localCoverPath localVideoPath:(NSString *)localVideoPath videoSize:(CGSize)videoSize duration:(int)duration
{
    //缩略图-不知道为什么，无效
    //    NSDictionary *thumbnail_file_Dic = @{
    //        @"@type" : @"inputFileLocal",
    //        @"path" : localCoverPath
    //    };
    //    NSDictionary *thumbnail_Dic = @{
    //        @"@type" : @"inputThumbnail",
    //        @"thumbnail" : thumbnail_file_Dic
    //    };
    //视频
    NSDictionary *video_Dic = @{
        @"@type" : @"inputFileLocal",
        @"path" : localVideoPath
    };
    NSDictionary *video_content = @{@"@type" : @"inputMessageVideo",
             //@"thumbnail" : thumbnail_Dic,
             @"video" : video_Dic,
             @"width" : [NSNumber numberWithInt:fabs(videoSize.width)],
             @"height" : [NSNumber numberWithInt:fabs(videoSize.height)],
             @"duration" : [NSNumber numberWithInt:duration]
    };
    
//    return video_content;
    
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (config.using_oss) {
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        content[@"resource"] =  video_content;
        content[@"@type"] = @"inputMessageOss";
        return content;
    } else {
        return video_content;
    }
}

- (void)sendVideoMessage:(long)chatId localCoverPath:(NSString *)localCoverPath localVideoPath:(NSString *)localVideoPath  videoSize:(CGSize)videoSize duration:(int)duration resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送视频
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        
        
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_videoContent_localPath_inline:localCoverPath localVideoPath:localVideoPath videoSize:videoSize duration:duration],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendVideoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (void)sendFireVideoMessage:(long)chatId localCoverPath:(NSString *)localCoverPath localVideoPath:(NSString *)localVideoPath videoSize:(CGSize)videoSize duration:(int)duration fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送视频
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_videoContent_localPath_inline:localCoverPath localVideoPath:localVideoPath videoSize:videoSize duration:duration],
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendVideoMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (NSDictionary *)send_audioContent_localPath_inline:(NSString *)localAudioPath duration:(int)duration
{
    //语音
    NSDictionary *audio_Dic = @{
        @"@type" : @"inputFileLocal",
        @"path" : localAudioPath
    };
    return @{@"@type" : @"inputMessageAudio",
             @"audio" : audio_Dic,
             @"duration" : [NSNumber numberWithInt:duration]
    };
}

- (void)sendAudioMessage:(long)chatId localAudioPath:(NSString *)localAudioPath duration:(int)duration resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送音频文件
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_audioContent_localPath_inline:localAudioPath duration:duration],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendVoiceMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (NSDictionary *)send_voiceContent_localPath_inline:(NSString *)localAudioPath duration:(int)duration
{
    //语音
    NSDictionary *audio_Dic = @{
        @"@type" : @"inputFileLocal",
        @"path" : localAudioPath
    };
    return @{@"@type" : @"inputMessageVoiceNote",
             @"voice_note" : audio_Dic,
             @"duration" : [NSNumber numberWithInt:duration]
    };
}

- (void)sendVoiceMessage:(long)chatId localAudioPath:(NSString *)localAudioPath duration:(int)duration resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送语音
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_voiceContent_localPath_inline:localAudioPath duration:duration],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendVoiceMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (void)sendFireAudioMessage:(long)chatId localAudioPath:(NSString *)localAudioPath duration:(int)duration fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送语音
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_audioContent_localPath_inline:localAudioPath duration:duration],
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendVoiceMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (NSDictionary *)send_fileContent_localPath_inline:(NSString *)realFileName localFilePath:(NSString *)localFilePath
{
    //语音
    NSDictionary *file_Dic = @{
        @"@type" : @"inputFileLocal",
        @"path" : localFilePath
    };
    NSDictionary *captionDic = @{
        @"@type" : @"formattedText",
        @"text" : realFileName,
        @"entities" : @[] //忽略格式
    };
    return @{@"@type" : @"inputMessageDocument",
             @"document" : file_Dic,
             @"caption" : captionDic
    };
}

- (void)sendFileMessage:(long)chatId realFileName:(NSString *)realFileName localFilePath:(NSString *)localFilePath resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送文件
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_fileContent_localPath_inline:realFileName localFilePath:localFilePath],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendFileMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (void)sendFireFileMessage:(long)chatId realFileName:(NSString *)realFileName localFilePath:(NSString *)localFilePath fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送文件
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_fileContent_localPath_inline:realFileName localFilePath:localFilePath],
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendFileMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (NSDictionary *)send_locationContent_inline:(double)latitude longitude:(double)longitude
{
    NSDictionary *locationDic = @{
        @"@type" : @"location",
        @"latitude" : [NSNumber numberWithDouble:latitude],
        @"longitude" : [NSNumber numberWithDouble:longitude],
        @"horizontal_accuracy" : [NSNumber numberWithInt:0]
    };
    return @{@"@type" : @"inputMessageLocation",
             @"location" : locationDic,
             @"live_period" : [NSNumber numberWithInt:0],
             @"heading" : [NSNumber numberWithInt:0],
             @"proximity_alert_radius" : [NSNumber numberWithInt:0]
    };
}

- (void)sendLocationMessage:(long)chatId latitude:(double)latitude longitude:(double)longitude resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送位置
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_locationContent_inline:latitude longitude:longitude],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendLocationMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
- (void)sendFireLocationMessage:(long)chatId latitude:(double)latitude longitude:(double)longitude  fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//发送位置
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_locationContent_inline:latitude longitude:longitude],
                                   @"@extra" : [NSNumber numberWithInt:rtId],
                                   @"options":@{
                                           @"ttl_seconds": [NSNumber numberWithInt:fireLimie.intValue]
                                   }
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendLocationMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
//设置pin消息
- (void)setPinMessage:(long)chatId long:(long)msgId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"pinChatMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"message_id" : [NSNumber numberWithLong:msgId],
                                   @"disable_notification" : @NO,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setPinMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


#pragma mark - 收藏表情
- (void)addSavedAnimation:(NSString *)remoteId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        
        NSDictionary *animation = @{
            @"@type" : @"inputFileRemote",
            @"id" : remoteId,
        };
        
        NSDictionary *input_message_content_dict = @{
            @"@type" : @"addSavedAnimation",
            @"animation" : animation,
            @"@extra" : [NSNumber numberWithInt:rtId]
        };
        NSString *paramStr = [input_message_content_dict mj_JSONString];
        [self addTask:input_message_content_dict rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke addSavedAnimation %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//#pragma mark - 获取收藏的表情
//- (void)addSavedAnimation:(NSString *)remoteId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
//
//}


- (void)sendScreenshotMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    [self sendTextMessage:chatId replyid:0 text:[MessageInfo getTextExMessage:@"{}" mainCode:OtherEx_MessageType subCode:OtherEx_MessageType_Screenshot] withUserInfoArr:nil replyMarkup:nil resultBlock:resultBlock timeout:timeoutBlock];
}

- (void)sendBeFriendMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    [self sendTextMessage:chatId replyid:0 text:[MessageInfo getTextExMessage:@"{}" mainCode:OtherEx_MessageType subCode:OtherEx_MessageType_BeFriend] withUserInfoArr:nil replyMarkup:nil resultBlock:resultBlock timeout:timeoutBlock];
}
// 发送阅后即焚
-(void)sendReadFireMessage:(long)chatId Text:(NSString *)text CountDown:(NSString *)countDown resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    //    [self sendTextMessage:chatId replyid:0 text:[MessageInfo getTextExMessage:[NSString stringWithFormat:@"{\"text\":\"%@\",\"countDown\":%@}",text,[NSNumber numberWithInt:countDown.intValue]] mainCode:ReadFire_MessageType subCode:ReadFire_MessageSubType_Text] withUserInfoArr:nil resultBlock:resultBlock timeout:timeoutBlock];
//        NSString * msgText = [NSString stringWithFormat:@"{\"text\":\"%@\"}",text];
        [self sendFireMessage:chatId replyid:0 text:text withUserInfoArr:nil FireLimit:countDown resultBlock:resultBlock timeout:timeoutBlock];
}


- (NSDictionary *)send_forward_inline:(MessageInfo *)forwardMsg
{
    return @{@"@type" : @"inputMessageForwarded",
             @"from_chat_id" : [NSNumber numberWithLong:forwardMsg.chat_id],
             @"message_id" : [NSNumber numberWithLong:forwardMsg._id]
    };
}

- (void)forwardMessage:(long)chatId msg:(MessageInfo *)msg resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"input_message_content" : [self send_forward_inline:msg],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke forwardMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)forwardMessage:(long)chatId msgs:(NSArray *)msgs
{//转发消息
    for(MessageInfo *msg in msgs)
    {
        if(msg.sendState == MessageSendState_Success)
        {
            BOOL isNormalForward = NO;
            if(msg.messageType == MessageType_Photo)
            {
                //图片
                isNormalForward = YES;
            }
            if (msg.messageType == MessageType_Animation) {
                //gif
                isNormalForward = YES;
            }
            if(msg.messageType == MessageType_Video)
            {
                //视频
                isNormalForward = YES;
            }
            if(msg.messageType == MessageType_Audio)
            {
                //音频
                isNormalForward = YES;
            }
            if(msg.messageType == MessageType_Voice)
            {
                //语音
                isNormalForward = YES;
            }
            if(msg.messageType == MessageType_Document)
            {
                //文件
                isNormalForward = YES;
            }
            if(msg.messageType == MessageType_Location)
            {
                //位置
                isNormalForward = YES;
            }
            if(msg.messageType == MessageType_Card)
            {
                //名片
                isNormalForward = YES;
            }
            if(isNormalForward)
            {
                [self forwardMessage:chatId msg:msg resultBlock:^(NSDictionary *request, NSDictionary *response) {
                } timeout:^(NSDictionary *request) {
                }];
                continue;
            }
        }
        /// 文字+按钮 广告
        if (msg.reply_markup && msg.reply_markup.isReplyMarkupInlineKeyboard) {
            [self sendTextMessage:chatId replyid:0 text:msg.description withUserInfoArr:nil replyMarkup:msg.reply_markup.mj_JSONObject resultBlock:^(NSDictionary *request, NSDictionary *response) {
            } timeout:^(NSDictionary *request) {
            }];
            continue;
        }
        //其他消息类型作为文本消息发送
        [self sendTextMessage:chatId replyid:0 text:msg.description withUserInfoArr:nil replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (void)deleteMessage:(long)chatId msgIds:(NSArray *)msgIds revoke:(BOOL)revoke resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//删除单条消息
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"deleteMessages",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"message_ids" : msgIds,
                                   @"revoke" : [NSNumber numberWithBool:revoke],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke deleteMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 联系人
- (UserInfo *)contactInfo:(long)userId
{
    if(userId == [UserInfo shareInstance]._id)
    {//当前登录的用户
        /// 处理群组在线人数
        UserInfo.shareInstance.status = @{@"@type":@"userStatusOnline"};;
        return [UserInfo shareInstance];
    }
    __block UserInfo *user = nil;
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        user = [bSelf.contacts_dic objectForKey:[NSNumber numberWithLong:userId]];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return user;
}

- (NSArray *)getContacts
{
    __block NSMutableArray *list = [NSMutableArray array];
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        NSArray *all = bSelf.contacts_dic.allValues;
        for(UserInfo *user in all)
        {
            if(user.is_contact)
            {
                [list addObject:user];
            }
        }
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return list;
}

- (NSArray *)getContacts:(NSString *)keyword
{
    __block NSMutableArray *list = [NSMutableArray array];
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        NSArray *all = bSelf.contacts_dic.allValues;
        for(UserInfo *user in all)
        {
            if(user.is_contact && [user isMatch:keyword])
            {
                [list addObject:user];
            }
        }
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return list;
}

- (NSArray *)getGroups
{
    __block NSMutableArray *list = [NSMutableArray array];
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        NSArray *all = bSelf.chat_dic.allValues;
        for(ChatInfo *chat in all)
        {
            if(chat.isGroup)
            {
                [list addObject:chat];
            }
        }
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return list;
}

- (NSArray *)getGroups:(NSString *)keyword
{
    __block NSMutableArray *list = [NSMutableArray array];
    __block TelegramManager *bSelf = self;
    dispatch_block_t block = ^{
        NSArray *all = bSelf.chat_dic.allValues;
        for(ChatInfo *chat in all)
        {
            if(chat.isGroup && [chat isMatch:keyword])
            {
                [list addObject:chat];
            }
        }
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return list;
}

- (void)syncMyContacts
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getContacts",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        __block TelegramManager *bSelf = self;
        [self addTask:funQuery
                 rtId:rtId
               result:^(NSDictionary *request, NSDictionary *response) {
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"users"])
                {
                    NSArray *contactIds = [response objectForKey:@"user_ids"];
                    if(contactIds != nil && [contactIds isKindOfClass:[NSArray class]] && contactIds.count>0)
                    {
                        for(NSNumber *userid in contactIds)
                        {
                            [bSelf getUserSimpleInfo_inline:[userid longValue]];
                        }
                    }
                }
            }
        }
              timeout:^(NSDictionary *request) {
            ChatLog(@"syncMyContacts timeout");
        }];
        ChatLog(@"invoke syncMyContacts %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)getUserSimpleInfo_inline:(long)userId
{
    if(self.tdClient == nil)
    {
        return;
    }
    int rtId = self.requestId++;
    NSDictionary *funQuery = @{@"@type" : @"getUser",
                               @"user_id" : [NSNumber numberWithLong:userId],
                               @"@extra" : [NSNumber numberWithInt:rtId]};
    NSString *paramStr = [funQuery mj_JSONString];
    __block TelegramManager *bSelf = self;
    [self addTask:funQuery
             rtId:rtId
           result:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"user"])
            {
                [bSelf parseUserInfo_inline:response];
            }
        }
    }
          timeout:^(NSDictionary *request) {
        ChatLog(@"getUserSimpleInfo_inline timeout");
    }];
    ChatLog(@"invoke getUserSimpleInfo_inline %@", paramStr);
    td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
}
- (void)getUserSimpleInfo_inline:(long)userId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    if(self.tdClient == nil)
    {
        return;
    }
    int rtId = self.requestId++;
    NSDictionary *funQuery = @{@"@type" : @"getUser",
                               @"user_id" : [NSNumber numberWithLong:userId],
                               @"@extra" : [NSNumber numberWithInt:rtId]};
    NSString *paramStr = [funQuery mj_JSONString];
    __block TelegramManager *bSelf = self;
    [self addTask:funQuery
             rtId:rtId
           result:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"user"])
            {
                [bSelf parseUserInfo_inline:response];
            }
        }
        resultBlock(request,response);
    }
          timeout:timeoutBlock];
    ChatLog(@"invoke getUserSimpleInfo_inline %@", paramStr);
    td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
}
- (void)addContact:(UserInfo *)user resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//添加好友
    NSDictionary *contactDic = @{@"@type" : @"contact",
                                 @"first_name" : user.first_name == nil?@"":user.first_name,
                                 @"last_name" : user.last_name == nil?@"":user.last_name,
                                 @"user_id" : [NSNumber numberWithLong:user._id]};
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"addContact",
                                   @"contact" : contactDic,
                                   @"share_phone_number" : [NSNumber numberWithBool:NO],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke addContact %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//设置联系人备注
- (void)setContactNickName:(UserInfo *)user nickName:(NSString *)nickName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    NSDictionary *contactDic = @{@"@type" : @"contact",
                                 @"first_name" : nickName == nil?@"":nickName,
                                 @"last_name" : @"",
                                 @"user_id" : [NSNumber numberWithLong:user._id]};
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"addContact",
                                   @"contact" : contactDic,
                                   @"share_phone_number" : [NSNumber numberWithBool:NO],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setContactNickName %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)deleteContact:(long)userId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//删除好友
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"removeContacts",
                                   @"user_ids" : @[[NSNumber numberWithLong:userId]],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke deleteContact %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)setMyUserName:(NSString *)userName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//设置当前用户username，允许为空，为空表示删除
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setUsername",
                                   @"username" : userName==nil?@"":userName,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setMyUserName %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)setMyNickName:(NSString *)nickName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//设置当前用户昵称
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setName",
                                   @"first_name" : nickName,
                                   @"last_name" : @"",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setMyNickName %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)setMyPhoto:(NSString *)localPath resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{//设置个人头像
    NSDictionary *photo_Dic = @{
        @"@type" : @"inputChatPhotoStatic",
        @"photo" : @{
                @"@type" : @"inputFileLocal",
                @"path" : localPath
        }
    };
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setProfilePhoto",
                                   @"photo" : photo_Dic,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setMyPhoto %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取联系人信息
- (void)requestContactInfo:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getUser",
                                   @"user_id" : [NSNumber numberWithLong:userId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        __block TelegramManager *bSelf = self;
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"user"])
                {
                    //内部逻辑处理，加入缓存
                    [bSelf parseUserInfo_inline:response];
                    //方法正常返回
                    UserInfo *user = [UserInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, user);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke requestContactInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)requestContactFullInfo:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getUserFullInfo",
                                   @"user_id" : [NSNumber numberWithLong:userId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"userFullInfo"])
                {
                    UserFullInfo *full = [UserFullInfo mj_objectWithKeyValues:response];
                    if (userId == UserInfo.shareInstance._id) {
                        UserInfo.shareInstance.bio = full.bio;
                    }
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, full);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke requestContactFullInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取黑名单
- (void)requestblockedUserList:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getBlockedMessageSenders",
                                   @"offset" : @0,
                                   @"limit" : @100,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"messageSenders"])
                {
                    NSArray *senders = [response objectForKey:@"senders"];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, senders);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke requestblockedUserList %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取联系人本身最新的信息，而不是备注 - 自定义api
- (void)requestOrgContactInfo:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"users.info",
                                   @"parameters" : [@{@"uIds":@[[NSNumber numberWithLong:userId]]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *dataList = [resultDic objectForKey:@"data"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                            {
                                NSArray *list = [OrgUserInfo mj_objectArrayWithKeyValuesArray:dataList];
                                if(list != nil && list.count>0)
                                {
                                    if(resultBlock != nil)
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            resultBlock(request, response, [list firstObject]);
                                        });
                                    }
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke requestOrgContactInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//同步当前用户隐私信息
- (void)updateUserPrivacySettingsByAllowFindingByPhoneNumber
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getUserPrivacySettingRules",
                                   @"setting" : @{@"@type":@"userPrivacySettingAllowFindingByPhoneNumber"},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
        } timeout:^(NSDictionary *request) {
        }];
        ChatLog(@"invoke updateUserPrivacySettings %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)setUserPrivacySettingsByAllowFindingByPhoneNumber:(BOOL)allow resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setUserPrivacySettingRules",
                                   @"setting" : @{@"@type":@"userPrivacySettingAllowFindingByPhoneNumber"},
                                   @"rules" : @{@"rules":@[@{@"@type":(allow?@"userPrivacySettingRuleAllowAll":@"userPrivacySettingRuleAllowContacts")}]},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setUserPrivacySettingsByAllowFindingByPhoneNumber %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - file
- (BOOL)isFileDownloading:(long)fileId type:(FileType)type
{
    NSString *keyString = [FileTaskInfo fileTaskKey:type file_id:fileId];
    __block TelegramManager *bSelf = self;
    __block BOOL isDownloading = NO;
    dispatch_block_t block = ^{
        isDownloading = [bSelf.fileTask_dic objectForKey:keyString] != nil;
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_sync(workQueue, block);
    }
    return isDownloading;
}

/// 取消其他正在下载的视频请求
- (void)cancelOtherVideoTasks:(FileType)type {
    if (type != FileType_Message_Video) {
        return;
    }
    for (NSNumber *idx in self.fileTaskId_dic.allValues) {
        [self cancelTask:idx.intValue];
    }
    [self.fileTaskId_dic removeAllObjects];
    NSMutableArray *videoKeys = NSMutableArray.array;
    for (NSString *key in self.fileTask_dic) {
        FileTaskInfo *task = self.fileTask_dic[key];
        if (task.fileType == type) {
            [videoKeys addObject:key];
        }
    }
    for (NSString *key in videoKeys) {
        [self.fileTask_dic removeObjectForKey:key];
    }
}

- (void)DownloadFile:(NSString *)_id fileId:(long)fileId download_offset:(int)download_offset type:(FileType)type
{
    if(IsStrEmpty(_id))
    {
        return;
    }
    dispatch_block_t block = ^{
        NSString *keyString = [FileTaskInfo fileTaskKey:type file_id:fileId];
        BOOL isDownloading = [self.fileTask_dic objectForKey:keyString] != nil;
        if(!isDownloading) {
            [self cancelOtherVideoTasks:type];
            
            FileTaskInfo *task = [FileTaskInfo new];
            task._id = _id;
            task.file_id = fileId;
            task.fileType = type;
            [self.fileTask_dic setObject:task forKey:keyString];
            
            //开始下载
            if(self.tdClient == nil) {
                return;
            }
            int rtId = self.requestId++;
            if (type == FileType_Message_Video) {
                [self.fileTaskId_dic setObject:@(rtId) forKey:keyString];
            }
            if (self.priority > 32) {
                self.priority = 1;
            }
            NSDictionary *funQuery = @{@"@type" : @"downloadFile",
                                       @"file_id" : [NSNumber numberWithLong:fileId],
                                       @"priority" : [NSNumber numberWithInt:self.priority++],
                                       @"offset" : [NSNumber numberWithInt:download_offset],
                                       @"limit" : [NSNumber numberWithInt:0],
                                       @"synchronous" : [NSNumber numberWithBool:YES],
                                       @"@extra" : [NSNumber numberWithInt:rtId]};
            NSString *paramStr = [funQuery mj_JSONString];
            ChatLog(@"111-调用下载文件：fileId - %ld", fileId);
            [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
                ChatLog(@"111-下载文件回调：fileId - %ld", fileId);
                //main thread
                [[TelegramManager shareInstance] downloadFileComplete:task response:response taskId:rtId];
                
//                NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
            } timeout:^(NSDictionary *request) {
                /// 这里是超时返回
                //main thread
                [[TelegramManager shareInstance] downloadFileComplete:task response:nil taskId:rtId];
            }];
            ChatLog(@"invoke DownloadFile %@", paramStr);
            td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

- (void)cancelDownloadFile:(long)fileId
{
    if(self.tdClient == nil) {
        return;
    }
    dispatch_block_t block = ^{
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"cancelDownloadFile",
                                   @"file_id" : [NSNumber numberWithLong:fileId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
            //main threa
            ChatLog(@"invoke cancelDownloadFile %@", response);
        } timeout:^(NSDictionary *request) {
            //main thread
            ChatLog(@"invoke cancelDownloadFile %@", request);
        }];
        ChatLog(@"invoke cancelDownloadFile %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

- (void)downloadImage:(NSString *)_id fileId:(long)fileId type:(FileType)type read_block:(readImageBlock)read_block{
    if (IsStrEmpty(_id)) {
        return;
    }
    dispatch_block_t block = ^{
        NSString *keyString = [FileTaskInfo fileTaskKey:type file_id:fileId];
        BOOL isDownloading = [self.fileTask_dic objectForKey:keyString] != nil;
        if(!isDownloading) {
            [self cancelOtherVideoTasks:type];
            FileTaskInfo *task = [FileTaskInfo new];
            task._id = _id;
            task.file_id = fileId;
            task.fileType = type;
            [self.fileTask_dic setObject:task forKey:keyString];
            
            //开始下载
            if(self.tdClient == nil) {
                return;
            }
            int rtId = self.requestId++;
            if (type == FileType_Message_Video) {
                [self.fileTaskId_dic setObject:@(rtId) forKey:keyString];
            }
            NSDictionary *funQuery = @{@"@type" : @"downloadFile",
                                       @"file_id" : [NSNumber numberWithLong:fileId],
                                       @"priority" : [NSNumber numberWithInt:1],
                                       @"synchronous" : [NSNumber numberWithBool:YES],
                                       @"@extra" : [NSNumber numberWithInt:rtId]};
            NSString *paramStr = [funQuery mj_JSONString];
            ChatLog(@"111-调用下载图片：fileId - %ld", fileId);
            [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
                ChatLog(@"111-下载图片回调：fileId - %ld", fileId);
                //main thread
                [[TelegramManager shareInstance] downloadFileComplete:task response:response taskId:rtId];
                read_block();
            } timeout:^(NSDictionary *request) {
                //main thread
                [[TelegramManager shareInstance] downloadFileComplete:task response:nil taskId:rtId];
                read_block();
            }];
            ChatLog(@"invoke downloadImage %@", paramStr);
            td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
        }
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

- (void)readVideo:(long)fileId read_offset:(int)read_offset read_count:(int)read_count read_block:(readVideoBlock)read_block
{
    if(self.tdClient == nil) {
        return;
    }
    dispatch_block_t block = ^{
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"readFilePart",
                                   @"file_id" : [NSNumber numberWithLong:fileId],
                                   @"offset" : [NSNumber numberWithInt:read_offset],
                                   @"count" : [NSNumber numberWithInt:read_count],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
            //main threa
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:NSString.class] && [type isEqualToString:@"filePart"]) {
                NSString *baseData = [response objectForKey:@"data"];
                NSData* data = [[NSData alloc] initWithBase64EncodedString:baseData options:0];
                read_block(data);
            } else {
                read_block([NSData dataWithBytes:0 length:0]);
            }
        } timeout:^(NSDictionary *request) {
            read_block([NSData dataWithBytes:0 length:0]);
        }];
        ChatLog(@"invoke ReadVideo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

- (void)downloadVideo:(long)fileId download_offset:(int)download_offset download_limit:(int)download_limit read_block:(readVideoBlock)read_block
{
    //开始下载
    if(self.tdClient == nil) {
        return;
    }
    dispatch_block_t block = ^{
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"downloadFile",
                                   @"file_id" : [NSNumber numberWithLong:fileId],
                                   @"priority" : [NSNumber numberWithInt:32],
                                   @"offset" : [NSNumber numberWithInt:download_offset],
                                   @"limit" : [NSNumber numberWithInt:download_limit],
                                   @"synchronous" : [NSNumber numberWithBool:YES],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
            ChatLog(@"invoke DownloadVideo %@", response);
            NSString *type = [response objectForKey:@"@type"];
            if (![type isEqualToString:@"file"]) {
                read_block([NSData dataWithBytes:0 length:0]);
                return;
            }
            [[TelegramManager shareInstance] readVideo:fileId read_offset:download_offset read_count:download_limit read_block:read_block];
            
            FileInfo *fileInfo = [FileInfo mj_objectWithKeyValues:response];
            [TelegramManager.shareInstance messageVideoDownloadComplete_inlinefile:fileInfo];
        } timeout:^(NSDictionary *request) {
            read_block([NSData dataWithBytes:0 length:0]);
        }];
        ChatLog(@"invoke DownloadVideo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

- (void)downloadThumbnailVideo:(long)fileId offset:(int)offset limit:(int)limit completion:(void(^)(FileInfo *file))completion {
    //开始下载
    if(self.tdClient == nil) {
        return;
    }
    dispatch_block_t block = ^{
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{
            @"@type" : @"downloadFile",
            @"file_id" : @(fileId),
            @"priority" : @31,
            @"offset" : @(offset),
            @"limit" : @(limit),
            @"synchronous" : @(YES),
            @"@extra" : @(rtId)
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
            NSString *type = [response objectForKey:@"@type"];
            if (![type isEqualToString:@"file"]) {
                if (completion) completion(nil);
                return;
            }
            FileInfo *fileInfo = [FileInfo mj_objectWithKeyValues:response];
            if (completion) completion(fileInfo);
        } timeout:^(NSDictionary *request) {
            if (completion) completion(nil);
        }];
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)) {
        block();
    } else {
        dispatch_async(workQueue, block);
    }
}


- (void)deleteFilewithFileTaskInfo:(FileTaskInfo *)taskInfo
{
    dispatch_block_t block = ^{
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"deleteFile",
                                   @"file_id" : [NSNumber numberWithLong:taskInfo.file_id],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        __weak __typeof(self) weakSelf = self;
        [self addTask:funQuery rtId:rtId timeout:-1 result:^(NSDictionary *request, NSDictionary *response) {
            //main thread
            if (response && [response isKindOfClass:[NSDictionary class]]) {
                if ([[response objectForKey:@"@type"] isEqualToString:@"ok"]) {
                    [weakSelf DownloadFile:taskInfo._id fileId:taskInfo.file_id download_offset:0 type:taskInfo.fileType];
                }
            }
        } timeout:^(NSDictionary *request) {
            //main thread
            
        }];
        ChatLog(@"invoke DownloadFile %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

- (void)downloadFileComplete:(FileTaskInfo *)task response:(NSDictionary *)response taskId:(int)taskId
{
    dispatch_block_t block = ^{
        if(response != nil && [response isKindOfClass:[NSDictionary class]])
        {
            NSString *type = [response objectForKey:@"@type"];
            
            if([@"file" isEqualToString:type])
            {//下载成功
                FileInfo *fileInfo = [FileInfo mj_objectWithKeyValues:response];
                ChatLog(@"文件id : %ld 大小size : %ld,expected_size : %ld",fileInfo._id,fileInfo.size,fileInfo.expected_size);
                switch (task.fileType) {
                    case FileType_Photo:
                        [self contactPhotoDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Group_Photo:
                        [self groupPhotoDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Message_Photo:
                        [self messagePhotoDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Message_Animation:
                        [self messageGifDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Message_Preview_Photo:
                        [self messagePreviewPhotoDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Message_Video:
                        [self messageVideoDownloadComplete_inline:task file:fileInfo];//不知道为什么注释了  wl 放开了
                        break;
                    case FileType_Message_Audio:
                        [self messageAudioDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Message_Voice:
                        [self messageVoiceDownloadComplete_inline:task file:fileInfo];
                        break;
                    case FileType_Message_Document:
                        [self messageDocumentDownloadComplete_inline:task file:fileInfo];
                        break;
                    default:
                        break;
                }
            }
            else
            {//下载失败
                ChatLog(@"下载失败 : %@",response);
                //删除缓存  重新下载
                //[self deleteFilewithFileTaskInfo:task];
                
                switch (task.fileType) {
                    case FileType_Photo:
                        break;
                    case FileType_Group_Photo:
                        break;
                    case FileType_Message_Photo:
                        break;
                    case FileType_Message_Animation:
                        break;
                    case FileType_Message_Preview_Photo:
                        break;
                    case FileType_Message_Video:
                        break;
                    case FileType_Message_Voice:
                        break;
                    case FileType_Message_Document:
                        break;
                    default:
                        break;
                }
            }
        }
        //从下载队列移除
        [self.fileTask_dic removeObjectForKey:task.fileTaskKey];
        [self.fileTaskId_dic removeObjectForKey:@(taskId)];
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//联系人头像下载完成后的处理
- (void)contactPhotoDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        UserInfo *user = nil;
        if([UserInfo shareInstance]._id == [task._id longLongValue])
        {
            user = [UserInfo shareInstance];
        }
        else
        {
            user = [self.contacts_dic objectForKey:[NSNumber numberWithLong:[task._id longLongValue]]];
        }
        if(user != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(user.profile_photo.big._id == task.file_id)
                {
                    user.profile_photo.big = fileInfo;
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Contact_Photo_Ok) withInParam:user];
                }
                if(user.profile_photo.small._id == task.file_id)
                {
                    user.profile_photo.small = fileInfo;
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Contact_Photo_Ok) withInParam:user];
                }
            });
        }
    }
}

//群组头像下载完成后的处理
- (void)groupPhotoDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        ChatInfo *chat = [self.chat_dic objectForKey:[NSNumber numberWithLong:[task._id longLongValue]]];
        if(chat != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(chat.photo.big._id == task.file_id)
                {
                    chat.photo.big = fileInfo;
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Group_Photo_Ok) withInParam:chat];
                }
                if(chat.photo.small._id == task.file_id)
                {
                    chat.photo.small = fileInfo;
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Group_Photo_Ok) withInParam:chat];
                }
            });
        }
    }
}

//消息图片下载完成后的处理
- (void)messagePhotoDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Photo_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
        });
    }
}

//消息 gif 图片下载完成后的处理
- (void)messageGifDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Animation_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
        });
    }
}

//消息预览图片下载完成后的处理
- (void)messagePreviewPhotoDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Preview_Photo_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
        });
    }
}

//消息视频下载完成后的处理
- (void)messageVideoDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Video_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoDownLoadFinish" object:@{@"task":task, @"file":fileInfo}];
        });
    }
}

//下载中文件的处理
- (void)messageVideoDownloadComplete_inlinefile:(FileInfo *)fileInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Video_Ok) withInParam:fileInfo];
    });
}

//消息语音下载完成后的处理
- (void)messageAudioDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Audio_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
        });
    }
}
//消息语音下载完成后的处理
- (void)messageVoiceDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Voice_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
        });
    }
}

- (void)messageDocumentDownloadComplete_inline:(FileTaskInfo *)task file:(FileInfo *)fileInfo
{
    if(task != nil && fileInfo != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Document_Ok) withInParam:@{@"task":task, @"file":fileInfo}];
        });
    }
}

#pragma mark - 苹果推送
- (void)registerApnsToken:(NSString *)token resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    NSDictionary *device_tokenDic = @{
        @"@type" : @"deviceTokenApplePush",
        @"device_token" : token,
        @"is_app_sandbox" : @(NO)
//#if DEBUG
//        @(YES)
//#else
//        @(NO)
//#endif
    };
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"registerDevice",
                                   @"device_token" : device_tokenDic,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke registerApnsToken %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 文件
//获取文件信息
- (void)getRemoteFile:(NSString *)remoteFileId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{
            @"@type" : @"getRemoteFile",
            @"remote_file_id" : remoteFileId,
            @"file_type" : @{@"@type" : @"fileTypeUnknown"},
            @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getRemoteFile %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - public
+ (BOOL)isResultOk:(NSDictionary *)result
{
    if(result != nil && [result isKindOfClass:[NSDictionary class]])
    {
        NSString *type = [result objectForKey:@"@type"];
        if(type != nil && [type isKindOfClass:[NSString class]])
        {
            return [@"ok" isEqualToString:type];
        }
    }
    return NO;
}

+ (BOOL)isResultError:(NSDictionary *)result
{
    if(result != nil && [result isKindOfClass:[NSDictionary class]])
    {
        NSString *type = [result objectForKey:@"@type"];
        if(type != nil && [type isKindOfClass:[NSString class]])
        {
            return [@"error" isEqualToString:type];
        }
    }
    return NO;
}

+ (NSString *)errorMsg:(NSDictionary *)result
{
    if(result != nil && [result isKindOfClass:[NSDictionary class]])
    {
        NSString *type = [result objectForKey:@"@type"];
        if(type != nil && [type isKindOfClass:[NSString class]])
        {
            if([@"error" isEqualToString:type])
            {
                return [NSString stringWithFormat:@"%@_%@", [result objectForKey:@"code"], [result objectForKey:@"message"]];
            }
        }
    }
    return @"";
}

#pragma mark - 自定义方法
//发送自定义请求
- (void)sendCustomRequest:(NSString *)method parameters:(NSString *)parameters resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : method,
                                   @"parameters" : parameters,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendCustomRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 语音通话相关
//生成声网token
//{"@type":"customRequestResult","result":"{\"code\":200,\"msg\":\"success\",\"data\":{\"token\":\"006161db627fec34f12b6080582682546cbIADvCPLra8m1DoTsrZbZ2vMTZzouSs07X4Ogj+88B4GIyAZMbbTOsPlAIgAKKVoCD0JDYAQAAQCX90FgAgCX90FgAwCX90FgBACX90Fg\"}}","@extra":16}
- (void)createRtcToken:(NSString *)channelName uid:(long)uid resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    NSDictionary *parametersDic = @{
        @"channelName" : channelName,
        @"uid" : [NSNumber numberWithLong:uid]
    };
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.token.create",
                                   @"parameters" : [parametersDic mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSString *tokenStr = [[resultDic objectForKey:@"data"] objectForKey:@"token"];
                            if(tokenStr != nil && [tokenStr isKindOfClass:[NSString class]] && !IsStrEmpty(tokenStr))
                            {
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, tokenStr);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke createRtcToken %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//{"@type":"customRequestResult","result":"{\"code\":200,\"msg\":\"success\",\"data\":{\"callId\":10,\"channelName\":\"5E6996CF683C4E6B8938065028DDE25E\",\"from\":136817707,\"to\":[136817689],\"chatId\":136817689,\"isMeetingAV\":false,\"isVideo\":false,\"createAt\":2288912640}}","@extra":16}
- (void)createCall:(CallBaseInfo *)callInfo resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.create",
                                   @"parameters" : [callInfo mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSNumber *callIdNumber = [[resultDic objectForKey:@"data"] objectForKey:@"callId"];
                            if(callIdNumber != nil && [callIdNumber isKindOfClass:[NSNumber class]])
                            {
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, callIdNumber);
                                    });
                                }
                                return;
                            }
                        }
                        if(code == 501)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, callInfo.isVideo?@"对方把你加入了黑名单，不能进行视频通话":@"对方把你加入了黑名单，不能进行语音通话");
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke createCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//确认收到
- (void)callInviteAsk:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.ack.invite",
                                   @"parameters" : [@{@"callId":[NSNumber numberWithLong:callId]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, [NSNumber numberWithBool:YES]);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithBool:NO]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke callInviteAsk %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//通话取消-仅发起人可以调用
- (void)cancelCall:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.cancel",
                                   @"parameters" : [@{@"callId":[NSNumber numberWithLong:callId]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, [NSNumber numberWithBool:YES]);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithBool:NO]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke cancelCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//加入/开始通话
- (void)startCall:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.start",
                                   @"parameters" : [@{@"callId":[NSNumber numberWithLong:callId]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, [NSNumber numberWithBool:YES]);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithBool:NO]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke startCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//离开/停止通话
- (void)stopCall:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.stop",
                                   @"parameters" : [@{@"callId":[NSNumber numberWithLong:callId]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, [NSNumber numberWithBool:YES]);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithBool:NO]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke stopCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取离线通话记录
- (void)queryOfflineCall:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.queryOffline",
                                   @"parameters" : [@{@"timeOut":[NSNumber numberWithLong:30]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *dataList = [[resultDic objectForKey:@"data"] objectForKey:@"records"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                            {
                                NSArray *list = [RemoteCallInfo mj_objectArrayWithKeyValuesArray:dataList];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, list);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryOfflineCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//分页获取通话记录
/*
 type:0:单聊呼出和接听、1 单聊呼出 、2单聊接听 、3会议
 "count":Number //每页数量
 "page":Number //获取第N页，从1开始
 */
- (void)queryHistoryCall:(int)type count:(int)count page:(int)page resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"call.queryRecord",
                                   @"parameters" : [
                                                    @{
                                                        @"type":[NSNumber numberWithInt:type],
                                                        @"count":[NSNumber numberWithInt:count],
                                                        @"page":[NSNumber numberWithInt:page]
                                                    }
                                                    mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *dataList = [resultDic objectForKey:@"data"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                            {
                                NSArray *list = [RemoteCallInfo mj_objectArrayWithKeyValuesArray:dataList];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, list);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryHistoryCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - RP相关
//创建
- (void)createRp:(RedPacketInfo *)rpInfo resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"redpacket.create",
                                   @"parameters" : [rpInfo mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, [NSNumber numberWithInt:code]);
                            });
                        }
                        return;
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke createRp %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//请求详情
//{"@type":"customRequestResult","result":"{\"code\":200,\"msg\":\"success\",\"data\":{\"from\":136817689,\"createAt\":1617765769,\"chatId\":1073741852,\"type\":2,\"title\":\"\u606d\u559c\u53d1\u8d22, \u5927\u5409\u5927\u5229\",\"price\":0.3,\"total_price\":0.6,\"count\":2,\"isExpire\":true,\"users\":[]}}","@extra":20}
- (void)queryRp:(long)rpId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"redpacket.detail",
                                   @"parameters" : [@{@"redPacketId":[NSNumber numberWithLong:rpId]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                RedPacketInfo *rp = [RedPacketInfo mj_objectWithKeyValues:dataDic];
                                rp.redPacketId = rpId;
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, rp);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryRp %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//领取
//{"@type":"customRequestResult","result":"{\"code\":200,\"msg\":\"success\",\"data\":[{\"userId\":136817707,\"price\":0.1,\"gotAt\":1617952743}]}","@extra":18}
- (void)gotRp:(long)rpId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"redpacket.get",
                                   @"parameters" : [@{@"redPacketId":[NSNumber numberWithLong:rpId]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        NSArray *dataList = [resultDic objectForKey:@"data"];
                        NSArray *userList = nil;
                        if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                        {
                            userList = [RedPacketPickUser mj_objectArrayWithKeyValuesArray:dataList];
                        }
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, userList!=nil?(@{@"code":[NSNumber numberWithInt:code], @"users":userList}):(@{@"code":[NSNumber numberWithInt:code]}));
                            });
                        }
                        return;
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke gotRp %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//查询详情
- (void)queryWalletInfo:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"wallet.info",
                                   @"parameters" : @"",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                WalletInfo *info = [WalletInfo mj_objectWithKeyValues:dataDic];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, info);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithInt:code]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryWalletInfo %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//设置
- (void)setWalletPayPassword:(NSString *)password oldPassword:(NSString *)oldPassword resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        
        NSDictionary *params = @{@"new_password":password} ;
        if (oldPassword != nil) {
            [params setValue:oldPassword forKey:@"old_password"];
            //[@"old_password" : oldPassword]
        }
        
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.account.setWalletPassword",
                                   @"parameters" : [params mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, [NSNumber numberWithInt:code]);
                            });
                        }
                        return;
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke setWalletPayPassword %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


- (void)queryWalletOrderListCall:(int)count page:(int)page resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"wallet.records",
                                   @"parameters" : [@{@"count":[NSNumber numberWithInt:count], @"page":[NSNumber numberWithInt:page]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *list = nil;
                            NSArray *dataList = [resultDic objectForKey:@"data"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                            {
                                list = [WalletOrderInfo mj_objectArrayWithKeyValuesArray:dataList];
                            }
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, list);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryWalletOrderListCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


- (void)queryRedHistoryCall:(int)type count:(int)count page:(int)page resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"redpacket.record",
                                   @"parameters" : [@{@"type":[NSNumber numberWithInt:type], @"count":[NSNumber numberWithInt:count], @"page":[NSNumber numberWithInt:page]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *list = nil;
                            NSArray *dataList = [resultDic objectForKey:@"data"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                            {
                                list = [RedPacketInfo mj_objectArrayWithKeyValuesArray:dataList];
                            }
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, list);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryRedHistoryCall %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


- (void)WalletRechargeRequest:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.recharge",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                WalletRechargeRes *info = [WalletRechargeRes mj_objectWithKeyValues:dataDic];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, info);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithInt:code]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke WalletRechargeRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


- (void)WalletTixianRequest:(float)amount password:(NSString *)password resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.withdraw",
                                   @"parameters" : [@{@"amount":[NSNumber numberWithFloat:amount], @"password":password} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                WalletTixianRes *info = [WalletTixianRes mj_objectWithKeyValues:dataDic];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, info);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithInt:code]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke WalletTixianRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)queryThirdRechargeChannels:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"wallet.getThirdChannels",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                ThirdRechargeChannelInfo *info = [ThirdRechargeChannelInfo mj_objectWithKeyValues:dataDic];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, info);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, [NSNumber numberWithInt:code]);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke WalletTixianRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//删除超级群组某条消息
- (void)deleteSuperGroupMessage:(long)chatId msgIds:(NSArray *)msgIds resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"channel.cleanMessages",
                                   @"parameters" : [@{@"channelId":[NSNumber numberWithLong:chatId], @"messageIds":msgIds} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, @YES);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, @NO);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke deleteSuperGroupMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 发现
//获取发现页菜单列表
- (void)queryDiscoverSections:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.discover",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *dataList = [resultDic objectForKey:@"data"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]])
                            {
                                NSArray *list = [DiscoverMenuSectionInfo mj_objectArrayWithKeyValuesArray:dataList];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, list);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryDiscoverSections %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取tab扩展菜单
- (void)queryTabExMenu:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.system.getCustomMenus",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                TabExMenuInfo *info = [TabExMenuInfo mj_objectWithKeyValues:dataDic];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, info);
                                    });
                                }
                                return;
                            }
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, [TabExMenuInfo new]);
                                });
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryTabExMenu %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取app配置信息
- (void)queryAppConfig:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.system.getAppConfig",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSDictionary *dataDic = [resultDic objectForKey:@"data"];
                            if(dataDic != nil && [dataDic isKindOfClass:[NSDictionary class]])
                            {
                                AppConfigInfo *info = [AppConfigInfo mj_objectWithKeyValues:dataDic];
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, info);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryAppConfig %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 朋友圈 2021-11-01 by JWAutumn

- (void)jw_request:(NSDictionary *)parameters result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    dispatch_block_t block = ^{
        if (!self.tdClient) {
            return;
        }
        int rtId = self.requestId++;
        NSMutableDictionary *params = parameters.mutableCopy;
        params[@"@extra"] = [NSNumber numberWithInt:rtId];
        NSString *paramStr = params.mj_JSONString;
        [self addTask:params rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"jw_request %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)) {
        block();
    } else {
        dispatch_async(workQueue, block);
    }
}

/// 获取朋友圈列表
- (void)queryTimelineWithType:(NSString *)type offset:(int)offset result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    NSDictionary *visible = @{@"@type": type};
    [self queryTimelineWithVisible:visible offset:offset result:resultBlock timeout:timeoutBlock];
}

- (void)queryTimelineWithVisible:(NSDictionary *)visible offset:(int)offset result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    NSDictionary *parameters = @{
        @"@type": @"getHistory",
        @"from_blog_id": @(offset),
        @"visible": visible,
        @"offset": @(0),
        @"limit": @20
    };
    [self jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"blogs"]) {
            if (resultBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
            return;
        }
        NSArray *blogs = response[type];
        if (resultBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, blogs);
            });
        }
    } timeout:timeoutBlock];
}

/// 获取用户标签列表
- (void)blogUserGroupIndex:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    NSDictionary *parameters = @{@"@type": @"getBlogUserGroups"};
    [self jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogUserGroups"]) {
            if (resultBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
            return;
        }
        NSArray *groups = response[@"groups"];
        if (resultBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, groups);
            });
        }
    } timeout:timeoutBlock];
}

/// 创建标签
- (void)BlogUserGroupCreate:(NSString *)title users:(NSArray *)users result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    NSDictionary *parameters = @{
        @"@type": @"createBlogUserGroup",
        @"title": title,
        @"users": users
    };
    [self jw_request:parameters result:resultBlock timeout:timeoutBlock];
}

/// 删除标签
- (void)BlogUserGroupDelete:(int)ids result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    NSDictionary *parameters = @{
        @"@type": @"deleteBlogUserGroup",
        @"groups": @[@(ids)]
    };
    [self jw_request:parameters result:resultBlock timeout:timeoutBlock];
}

/// 标签添加用户
- (void)BlogUserGroupAddUsers:(NSArray *)users groupId:(int)ids result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    
}

- (void)BlogUserGroupModifyName:(NSString *)name groupId:(int)ids result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    
}

/// 标签删除用户
- (void)BlogUserGroupRemoveUsers:(NSArray *)users groupId:(int)ids result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    
}

- (void)publishTimeline:(NSDictionary *)timeline result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    [self jw_request:timeline result:resultBlock timeout:timeoutBlock];
}

- (void)timelineRepay:(NSDictionary *)params result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    [self jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogReplys"]) {
            if (resultBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
            return;
        }
        NSArray *replys = response[@"replys"];
        if (resultBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, replys);
            });
        }
    } timeout:timeoutBlock];
}

#pragma mark - 公共
//发送验证码
- (void)gotSmsCode:(SmsCodeType)type resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"system.sendSmsCode",
                                   @"parameters" : [@{@"type":[NSNumber numberWithInt:type]} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, @YES);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, @NO);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke gotSmsCode %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

- (void)verifySmsCode:(NSString *)code type:(SmsCodeType)type resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock {
    dispatch_block_t block = ^{
        if (self.tdClient == nil) {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"system.verifySmsCode",
                                   @"parameters" : @{
                                       @"type": @(type),
                                       @"code": code
                                   }.mj_JSONString,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            if(resultBlock != nil)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, @YES);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, @NO);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke gotSmsCode %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//请求在线客服
- (void)getOnlineUserService:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.system.getCSNumbers",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        int code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200)
                        {
                            NSArray *dataList = [resultDic objectForKey:@"data"];
                            if(dataList != nil && [dataList isKindOfClass:[NSArray class]] && dataList.count>0)
                            {
                                if(resultBlock != nil)
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        resultBlock(request, response, [dataList firstObject]);
                                    });
                                }
                                return;
                            }
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getOnlineUserService %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

#pragma mark - 自定义事件
/*
 //被邀请
 {"@type":"updateNewCustomEvent","event":"{\"action\":\"call.onInvite\",\"from\":136817689,\"to\":[136817707],\"data\":{\"callId\":70,\"channelName\":\"92934CC965484CB083DF94B1F5EDB796\",\"chatId\":136817707,\"createAt\":2288912640,\"from\":136817689,\"isMeetingAV\":false,\"isVideo\":false,\"to\":[136817707]}}"}
 //通话取消
 {"@type":"updateNewCustomEvent","event":"{\"action\":\"call.onCancel\",\"from\":136817689,\"to\":[136817707],\"data\":{\"callId\":85,\"channelName\":\"30317510CB18463DB416425DC331CF08\",\"chatId\":136817707,\"createAt\":2288912640}}"}
 */
- (BOOL)dealNewCustomEvent_inline:(NSString *)type data:(NSDictionary *)dic
{
    if([@"updateNewCustomEvent" isEqualToString:type])
    {
        NSString *eventJson = [dic objectForKey:@"event"];
        if(eventJson != nil && [eventJson isKindOfClass:[NSString class]])
        {
            NSDictionary *eventDic = [eventJson mj_JSONObject];
            NSString *actionStr = [eventDic objectForKey:@"action"];
            if(actionStr != nil && [actionStr isKindOfClass:[NSString class]])
            {
                if([actionStr isEqualToString:@"call.onInvite"])
                {//被邀请通话
                    NSDictionary *dataDic = [eventDic objectForKey:@"data"];
                    RemoteCallInfo *callInfo = [RemoteCallInfo mj_objectWithKeyValues:dataDic];
                    callInfo.isTimeOut = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[CallManager shareInstance] newIncomingCall:callInfo];
                    });
                }
                if([actionStr isEqualToString:@"call.onCancel"])
                {//通话被取消
                    NSDictionary *dataDic = [eventDic objectForKey:@"data"];
                    RemoteCallInfo *callInfo = [RemoteCallInfo mj_objectWithKeyValues:dataDic];
                    callInfo.isTimeOut = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[CallManager shareInstance] cancelCall:callInfo];
                    });
                }
                if([actionStr isEqualToString:@"call.onLeave"])
                {//某人离开通话
                    NSDictionary *dataDic = [eventDic objectForKey:@"data"];
                    RemoteCallInfo *callInfo = [RemoteCallInfo mj_objectWithKeyValues:dataDic];
                    callInfo.isTimeOut = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[CallManager shareInstance] leaveCall:callInfo];
                    });
                }
                if ([actionStr isEqualToString:@"chats.rights.onUpdate"]) {
                    NSDictionary *dataDic = [eventDic objectForKey:@"data"];
                    CZPermissionsModel *model = [CZPermissionsModel mj_objectWithKeyValues:dataDic];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Chatcustom_Permissions_Change) withInParam:model];
                    });
                }
                if ([actionStr isEqualToString:@"chats.keywords.onUpdate"]) {
                    NSDictionary *dataDic = [eventDic objectForKey:@"data"];
                    NSArray *keys = [dataDic objectForKey:@"keywords"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Keys_Change) withInParam:keys];
                    });
                }
                if ([actionStr isEqualToString:@"chats.nickname,onUpdate"]) {
                    NSDictionary *data = eventDic[@"data"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Group_Member_Nickname_Change) withInParam:data];
                    });
                }
                if ([actionStr isEqualToString:@"messages.reaction.onUpdate"]) {
                    NSDictionary *data = eventDic[@"data"];
                    MessageReaction *reaction = [MessageReaction mj_objectWithKeyValues:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Reaction_Update) withInParam:reaction];
                    });
                }
            }
        }
        return YES;
    }
    return NO;
}



#pragma mark - 获取登录前  通用配置
- (void)getApplicationConfigWithResultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getApplicationConfig",
                                   @"parameters" : @"{}",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"jsonValueObject"])
            {
                NSArray *resultArray = [response objectForKey:@"members"];
                AppConfigInfo *info = [AppConfigInfo sharedInstance];
                for (NSDictionary *itemDic in resultArray) {
                    if ([[itemDic objectForKey:@"key"] isEqualToString:@"phone_code_login"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL    valuebool = [[valueDic objectForKey:@"value"] boolValue];
                        info.phone_code_login = valuebool;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"register_need_phone_code"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL    valuebool = [[valueDic objectForKey:@"value"] boolValue];
                        info.register_need_phone_code = valuebool;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"register_need_inviter"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL    valuebool = [[valueDic objectForKey:@"value"] boolValue];
                        info.register_need_inviter = valuebool;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"password_flood_interval"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        NSInteger password_flood_interval = [NSString stringWithFormat:@"%@", valueDic[@"value"]].integerValue;
                        info.password_flood_interval = password_flood_interval;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"using_oss"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL using_oss = [[valueDic objectForKey:@"value"] boolValue];
                        info.using_oss = using_oss;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_send_file"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_send_file = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_send_file = can_send_file;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_send_location"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_send_location = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_send_location = can_send_location;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"shown_online_members"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL shown_online_members = [[valueDic objectForKey:@"value"] boolValue];
                        info.shown_online_members = shown_online_members;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"enabled_screenshot_notification"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL enabled_screenshot_notification = [[valueDic objectForKey:@"value"] boolValue];
                        info.enabled_screenshot_notification = enabled_screenshot_notification;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"enabled_destroy_after_reading"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL enabled_destroy_after_reading = [[valueDic objectForKey:@"value"] boolValue];
                        info.enabled_destroy_after_reading = enabled_destroy_after_reading;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"shown_everyone_member_changes"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL shown_everyone_member_changes = [[valueDic objectForKey:@"value"] boolValue];
                        info.shown_everyone_member_changes = shown_everyone_member_changes;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_send_redpacket"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_send_redpacket = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_send_redpacket = can_send_redpacket;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_remit"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_remit = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_remit = can_remit;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_address_book"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_address_book = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_address_book = can_see_address_book;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_blog"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_blog = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_blog = can_see_blog;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_invite_friend"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_invite_friend = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_invite_friend = can_invite_friend;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_nearby"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_nearby = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_nearby = can_see_nearby;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_public_group"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_public_group = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_public_group = can_see_public_group;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_qr_code"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_qr_code = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_qr_code = can_see_qr_code;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_wallet"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_wallet = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_wallet = can_see_wallet;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_wallet_records"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_wallet_records = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_wallet_records = can_see_wallet_records;
                    }
                    else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_emoji_shop"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_emoji_shop = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_emoji_shop = can_see_emoji_shop;
                    }else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_private_chat"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_private_chat = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_private_chat = can_see_private_chat;
                    }else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_private_chat"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_private_chat = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_private_chat = can_see_private_chat;
                    }else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_share"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_share = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_share = can_see_share;
                    }else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_complaint"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_complaint = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_complaint = can_see_complaint;
                    }else if ([[itemDic objectForKey:@"key"] isEqualToString:@"can_see_group_setting"]) {
                        NSDictionary *valueDic = [itemDic objectForKey:@"value"];
                        BOOL can_see_group_setting = [[valueDic objectForKey:@"value"] boolValue];
                        info.can_see_group_setting = can_see_group_setting;
                    }
                    
                    
                }
                if(resultBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resultBlock(request, response, info);
                    });
                }
                return;
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke queryAppConfig %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//校验支付密码是否正确
- (void)checkWallerPassword:(NSString *)password resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.account.checkwtPassword",
                                   @"parameters" : [@{@"password":password} mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]]){
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]]){
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200){
                            if(resultBlock != nil){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, resultDic);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke wtTixianRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//是否有登录密码
- (void)checkHasLoginPasswordResultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.account.myInfo",
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]]){
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]]){
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200){
                            if(resultBlock != nil){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, resultDic);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke wtTixianRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//修改登录密码
- (void)changeLoginPaswordWithParams:(NSString *)paramsStr resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"web.account.setPassword",
                                   @"parameters" : paramsStr,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            int code = 0;
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]]){
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]]){
                        code = [[resultDic objectForKey:@"code"] intValue];
                        if(code == 200){
                            if(resultBlock != nil){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, resultDic);
                                });
                            }
                            return;
                        }
                        if(code != 200){
                            if(resultBlock != nil){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, [resultDic objectForKey:@"msg"]);
                                });
                            }
                            return;
                        }
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke wtTixianRequest %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//设置 重置邀请链接
- (void)generateChatInviteLink:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"generateChatInviteLink",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getChatPinnedMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取群邀请的群信息
- (void)checkChatInviteLink:(NSString *)inviteLink resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"checkChatInviteLink",
                                   @"invite_link" : inviteLink,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chatInviteLinkInfo"])
                {
                    ChatInviteLinkInfo *info = [ChatInviteLinkInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getChatPinnedMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//链接入群
- (void)joinChatByInviteLink:(NSString *)inviteLink resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"joinChatByInviteLink",
                                   @"invite_link" : inviteLink,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chat"])
                {
                    ChatInfo *info = [ChatInfo mj_objectWithKeyValues:response];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getChatPinnedMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


//设置群组扩展权限
- (void)settingExtendedPermissions:(NSDictionary *)paramsdic resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"chats.modifyBannedRightex",
                                   @"parameters" : [paramsdic mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, resultDic);
                            });
                        }
                        return;
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//获取群组扩展权限
- (void)gettingExtendedPermissions:(long)chatid resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *paramsdic = @{
            @"chatId" : [NSNumber numberWithLong:chatid]
        };
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"chats.getBannedRightex",
                                   @"parameters" : [paramsdic mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        CZPermissionsModel *model = [CZPermissionsModel mj_objectWithKeyValues:[resultDic objectForKey:@"data"]];
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, model);
                            });
                        }
                        return;
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//停用邀请链接
- (void)stopGroupInviteLink:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *paramsdic = @{
            @"chatId" : [NSNumber numberWithLong:chatId]
        };
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"chats.disableInviteLink",
                                   @"parameters" : [paramsdic mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, resultDic);
                            });
                        }
                        return;
                        
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request,nil);
                });
            }
        } timeout:timeoutBlock];
        
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//查询群屏蔽关键字
- (void)queryGroupShieldWordsWithchtid:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *paramsdic = @{
            @"chatId" : [NSNumber numberWithLong:chatId],
        };
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"chats.getFilterKeywords",
                                   @"parameters" : [paramsdic mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, resultDic);
                            });
                        }
                        return;
                        
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request,nil);
                });
            }
        } timeout:timeoutBlock];
        
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


//设置群屏蔽关键字
- (void)settingGroupShieldWords:(NSArray *)wordsarr withchtid:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *paramsdic = @{
            @"chatId" : [NSNumber numberWithLong:chatId],
            @"keywords" : wordsarr
        };
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendCustomRequest",
                                   @"method" : @"chats.setFilterKeywords",
                                   @"parameters" : [paramsdic mj_JSONString],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            NSString *type = [response objectForKey:@"@type"];
            if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"customRequestResult"])
            {
                NSString *resultString = [response objectForKey:@"result"];
                if(resultString != nil && [resultString isKindOfClass:[NSString class]])
                {
                    NSDictionary *resultDic = [resultString mj_JSONObject];
                    if(resultDic != nil && [resultDic isKindOfClass:[NSDictionary class]])
                    {
                        if(resultBlock != nil)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, resultDic);
                            });
                        }
                        return;
                        
                    }
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request,nil);
                });
            }
        } timeout:timeoutBlock];
        
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
//获取具体哪一条消息
- (void)getMessageWithChatid:(long)chatid withMessageid:(long)messageid result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getMessage",
                                   @"chat_id" : [NSNumber numberWithLong:chatid],
                                   @"message_id" : [NSNumber numberWithLong:messageid],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        __weak __typeof(self) weakSelf = self;
        [self addTask:funQuery rtId:rtId result:^(NSDictionary *request, NSDictionary *response){
            if(![TelegramManager isResultError:response])
            {
                NSString *type = [response objectForKey:@"@type"];
                if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"message"])
                {
                    MessageInfo *info = [MessageInfo mj_objectWithKeyValues:response];
                    [weakSelf dealMessageType_inline:[response objectForKey:@"content"] message:info];
                    if(resultBlock != nil)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, info);
                        });
                    }
                    return;
                }
            }
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        } timeout:timeoutBlock];
        ChatLog(@"invoke getChatPinnedMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


// 正在输入
- (void)sendChatAction:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendChatAction",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"action" : @{@"@type" : @"chatActionTyping"},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke reSendMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

//取消 正在输入
- (void)sendChatActionCancle:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"sendChatAction",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"action" : @{@"@type" : @"chatActionCancel"},
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke reSendMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

//获取预览消息
- (void)getWebPagePreview:(NSString *)text resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getWebPagePreview",
                                   @"text" : @{
                                           @"text" : text,
                                           @"entities" : @[]
                                   },
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke sendTextMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}


//首次通讯录
- (void)importContactsWithArray:(NSArray *)contacts resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"importContacts",
                                   @"contacts" : contacts,
                                   @"@extra" : [NSNumber numberWithInt:rtId]
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke importContacts %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

//第二次通讯录
- (void)changeImportedContactsWithArray:(NSArray *)contacts resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"changeImportedContacts",
                                   @"contacts" : contacts,
                                   @"@extra" : [NSNumber numberWithInt:rtId]
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke importContacts %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

//获取收藏的表情
- (void)getSavedAnimationsWithresultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getSavedAnimations",
                                   @"@extra" : [NSNumber numberWithInt:rtId]
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke getSavedAnimations %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

//移除收藏的某个表情
- (void)removeSavedAnimation:(NSString *)remoteId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"removeSavedAnimation",
                                   @"animation" : @{
                                           @"@type" : @"inputFileRemote",
                                           @"id" : remoteId,
                                       },
                                   @"@extra" : [NSNumber numberWithInt:rtId]
        };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke removeSavedAnimation %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}

//允许PC登录
- (void)authComputerLogin:(NSString *)url resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"confirmQrCodeAuthentication",
                                   @"link" : url,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke confirmQrCodeAuthentication %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag)){
        block();
    }else{
        dispatch_async(workQueue, block);
    }
}
//增加两个api调用 关联在线状态
//app置前台时 setOption("online",true)
//app置后台时 setOption("online",false)
//{
// "@type": "setOption",
// "name": "online",
// "value": {
//  "@type": "optionValueBoolean",
//  "value": true
// }
//}
- (void)setOnlineState:(NSString *)state result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        //@"phone_number" : @"+86 17372202737"
        NSDictionary *funQuery = @{@"@type" : @"setOption",
                                   @"name" : @"online",
                                   @"value" : @{
                                           @"@type": @"optionValueBoolean",
                                         @"value": @(state.boolValue)
                                        }
                                   };
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setOption.online %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
-(void)resetClicent{
//    self.tdClient = nil;
//    td_json_client_destroy(self.tdClient);
//    _tdClient = td_json_client_create();
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        NSDictionary *funQuery = @{@"@type" : @"close"};
        NSString *paramStr = [funQuery mj_JSONString];
        ChatLog(@"invoke resetClicent %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
            
        //释放client
//        td_json_client_destroy(self.tdClient);
        self.tdClient = nil;
        td_json_client_destroy(self.tdClient);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}



- (void)tdRequestWithParams:(NSDictionary *)params task:(TgTaskBlock)taskBlock resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    if (params == nil || params.count < 1) {
        return;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:params];
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        if(taskBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                taskBlock(rtId);
            });
        }
        param[@"@extra"] = [NSNumber numberWithInt:rtId];
        NSString *paramStr = [param mj_JSONString];

        [self addTask:param rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke request %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    
    
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}


//设置群简介的
- (void)setChatDescription:(long)chatId description:(NSString *)description resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"setChatDescription",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"description": description,
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setPinMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}

//设置群简介的
- (void)getChatDescription:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    dispatch_block_t block = ^{
        if(self.tdClient == nil)
        {
            return;
        }
        int rtId = self.requestId++;
        NSDictionary *funQuery = @{@"@type" : @"getChatDescription",
                                   @"chat_id" : [NSNumber numberWithLong:chatId],
                                   @"@extra" : [NSNumber numberWithInt:rtId]};
        NSString *paramStr = [funQuery mj_JSONString];
        [self addTask:funQuery rtId:rtId result:resultBlock timeout:timeoutBlock];
        ChatLog(@"invoke setPinMessage %@", paramStr);
        td_json_client_send(self.tdClient, [paramStr cStringUsingEncoding:NSUTF8StringEncoding]);
    };
    if (dispatch_get_specific(workQueueTag))
    {
        block();
    }
    else
    {
        dispatch_async(workQueue, block);
    }
}
@end
