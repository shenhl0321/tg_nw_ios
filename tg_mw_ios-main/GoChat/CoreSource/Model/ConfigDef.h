//
//  ConfigDef.h
//  
//
//  Created by wang yutao on 15/12/30.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#ifndef GOCHAT_ConfigDef_h
#define GOCHAT_ConfigDef_h

//密钥
#define AES_PASSWORD                            @"GoChat_AES_WZY_2021"

static inline BOOL Battling() {
#if DEBUG
    return NO;
#else
//    return YES;
    NSDate *date = NSDate.date;
    NSString *string = @"2022-07-25 10:00:00", *format = @"yyyy-MM-dd HH:mm:ss";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSDate *takeOffDate = [formatter dateFromString:string];
    return [date compare:takeOffDate] == NSOrderedAscending;
#endif
}


#define ShowLocal_VoiceChat                     YES
#define ShowLocal_VoiceRecord                   YES
//app名称
#define APP_NAME                                @"坤坤TG"
//Go Chat itunes app id
#define APP_ID                                  @""
//接口定义
#define KHostApiAddress                         @"http://tg.uukkim.cc"
//隐私协议
#define KHostPrivacyAddress                     @"http://tg.uukkim.cc/16835.html"
//用户协议
#define KHostUserAgreementAddress               @"http://tg.uukkim.cc/11432.html"
//官网
#define KHostAddress                            @"http://tg.uukkim.cc"
//投诉
#define KHostEReport                            @"http://tg.uukkim.cc/tousu.php"

#define KGroupLinkHostAddress                   @"http://tg.uukkim.cc/joinchat?link="
//分享
#define KShareHostAddress                       @"http://tg.uukkim.cc/user/share"
//注册
#define KRegisterHostAddress                    @"http://tg.uukkim.cc/user/appregister"
//TG请求域名
#define TDLib_Hosts @[@"tg.uukkim.cc"]


//系统公告userid
#define TG_USERID_SYSTEM_NOTICE                 777000
//声网appid
#define AgoraRtc_AppId                          @"3c19f633ad47491b82c3912120cf3e59"
//高德地图appid
#define GaoDeMap_AppId                          @"00000000000000000000"
//高德地图web appid
#define GaoDeMap_Web_AppId                      @"00000000000000000000"
//极光appid-魔链1
#define JM_AppId                                @"00000000000000000000"
//讯飞-appid
#define XF_AppId                                @"00000000000000000000"
//讯飞语言转写-SecretKey
#define XF_SecretKey                            @"00000000000000000000"
//讯飞翻译-APISecret
#define XF_TranslateASK                         @"00000000000000000000"
//讯飞翻译-APIKey
#define XF_TranslateAK                          @"00000000000000000000"

//文件大小限制 - 目前10M
#define MAX_SEND_FILE_SIZE                      1024*1024*10
//主题相关
//是否特别主题
#define Is_Special_Theme                        NO
//导航栏特别背景色
#define COLOR_BG_NAV                            [UIColor whiteColor]
//导航栏文字颜色
#define COLOR_NAV_TINT_COLOR                    HEX_COLOR(@"#28292b")


//目前仅log显示使用
#define DEBUG_MODE 1

//颜色规范定义
#define COLOR_CG1 HEX_COLOR(@"#00c69b")
#define COLOR_CG2 HEX_COLOR(@"#e9230f")
#define COLOR_CG3 HEX_COLOR(@"#f4a63b")

#define COLOR_C1 HEX_COLOR(@"#28292b")
#define COLOR_C2 HEX_COLOR(@"#717682")
#define COLOR_C3 HEX_COLOR(@"#04020C")
#define COLOR_BG HEX_COLOR(@"#eff1f0")
#define COLOR_SP HEX_COLOR(@"#e5e5e5")

//字体规范定义
#define FONT_S1 18
#define FONT_S2 16
#define FONT_S3 14
#define FONT_S4 13
#define FONT_S5 12

//分页数
#define WT_ORDER_PAGE_COUNT           20

//图片显示定义
//图片消息最大宽和高-原则上宽高一致
#define MESSAGE_CELL_PHOTO_MAX_WIDTH        (350)
#define MESSAGE_CELL_PHOTO_MAX_HEIGHT       (350)
//请求的图片消息缩略图实际大小，宽高一致
#define MESSAGE_CELL_PHOTO_THBL_WIDTH       400.0f
//默认大小
#define MESSAGE_CELL_PHOTO_DEFAULT_WIDTH    250.0f
#define MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT   250.0f

//消息正则
#define IM_AT_FORMAT    @"(\\{\\{@([A-Za-z0-9\\-]{6,20})\\|[^}]*\\}\\})|(\\{\\{@all\\|全体成员\\}\\})|(\\{\\{@all\\|全體成員\\}\\})|(\\{\\{@all\\|All members\\}\\})|(\\{\\{@all\\|全体成員\\}\\})".lv_localized
//消息中图片占位符{@img}
#define IM_IMG_FORMAT @"\\{@img\\}"
//动态话题@格式
//{{#123456|张三}}或者管理员{{#55555|管理员}}
#define CLUB_AT_FORMAT  @"\\{\\{#([A-Za-z0-9\\-]{6,20})\\|[^}]*\\}\\}"
//@体系
#define TX_AT_FORMAT    @"\\{\\{@tx([A-Za-z0-9\\-]{6,20})\\|[^}]*\\}\\}"
//#话题#格式
#define TOPIC_FORMAT    @"\\{\\{#[^}]*#\\|[^}]*\\}\\}"
//群公告固定前缀
#define GROUP_NOTICE_PREFIX @"@所有人 ".lv_localized

//业务模块定义类
//用户状态定义
typedef enum {
    GoUserState_Unkown = 1,
    GoUserState_TdlibParameters,
    GoUserState_WaitEncryptionKey,
    GoUserState_WaitPhoneNumber,
    GoUserState_WaitCode,
    GoUserState_WaitRegistration,
    GoUserState_WaitPassword,
    GoUserState_Ready,
    GoUserState_Ready_Background,
    GoUserState_Closed,
    GoUserState_Closing,
    GoUserState_LoggingOut,
    GoUserState_WaitOtherDeviceConfirmation,
} GoUserState;

//用户连接状态
typedef enum {
    GoUserConnectionState_Connecting = 1,
    GoUserConnectionState_Updating,
    GoUserConnectionState_StateReady,
} GoUserConnectionState;

//消息类型定义
typedef enum {
    MessageType_Unkown = 1,
    MessageType_Text,
    MessageType_Text_AudioAVideo_Done,//在线音视频消息
    MessageType_Text_New_Rp,
    MessageType_Text_Got_Rp,
    MessageType_Text_Transfer,
    MessageType_Text_Kicked_SensitiveWords, /// 群组敏感词被踢
    MessageType_Animation, //gif
    MessageType_Audio,
    MessageType_Voice,
    MessageType_Document,
    MessageType_Location,
    MessageType_Photo,
    MessageType_Sticker,
    MessageType_Video,
    MessageType_Poll,
    MessageType_Call,
    MessageType_Pinned,
    MessageType_Card,//名片
    MessageType_Contact_Registed, /// 通讯录注册
    MessageType_Text_Screenshot, //截屏消息
    MessageType_Text_BeFriend, //加好友消息
    MessageType_Text_Blacklist, //被对方加黑名单
    MessageType_Text_Stranger, //对方拒绝接收陌生人消息
    MessageType_Text_InviteLink_ExternGroup,//链接进群
} MessageType;

//扩展消息定义

//在线音视频消息
#define AudioAVideo_MessageType 001
typedef enum {
    AudioAVideo_MessageType_Done = 100, //通话已结束
} AudioAVideo_MessageSubType;

//宝宝消息
#define RP_MessageType 002
typedef enum {
    RP_MessageType_New = 100, //新
    RP_MessageType_Got = 200, //领取
} RP_MessageSubType;

//其它扩展类消息
#define OtherEx_MessageType 003
typedef enum {
    OtherEx_MessageType_Screenshot = 100, //截屏消息
    OtherEx_MessageType_BeFriend = 101, //加好友消息
} OtherEx_MessageSubType;

#define ReadFire_MessageType 4
typedef enum {
    ReadFire_MessageSubType_Text = 100, //截屏消息
} ReadFire_MessageSubType;


#define Transfer_MessageType 5
typedef enum {
    Transfer_MessageSubType_Remit = 100, ///
    Transfer_MessageSubType_Receive = 200, ///
    Transfer_MessageSubType_RefundByUser = 300, ///
    Transfer_MessageSubType_Remind = 400, ///
    Transfer_MessageSubType_RefundBySystem = 500, ///
} Transfer_MessageSubType;

/// 被移出群聊
#define Kicked_MessageType 6
typedef enum {
    Kicked_MessageSubType_SensitiveWords = 100, /// 敏感词
} Kicked_MessageSubType;

//消息发送状态
typedef enum {
    MessageSendState_Success = 1,
    MessageSendState_Pending,
    MessageSendState_Fail,
} MessageSendState;

//文件类型定义
typedef enum {
    //联系人头像
    FileType_Photo = 1,
    //群组头像
    FileType_Group_Photo,
    //消息图片
    FileType_Message_Photo,
    //消息预览图片
    FileType_Message_Preview_Photo,
    //消息视频
    FileType_Message_Video,
    //音频语音
    FileType_Message_Audio,
    //消息语音
    FileType_Message_Voice,
    //消息文件
    FileType_Message_Document,
    //gif
    FileType_Message_Animation,
} FileType;

//群组成员状态
typedef enum {
    GroupMemberState_Administrator = 1,
    GroupMemberState_Creator,
    GroupMemberState_Left,
    GroupMemberState_Member,
    GroupMemberState_Banned,
    GroupMemberState_Restricted,
} GroupMemberState;

//短信验证码类型
typedef enum {
    SmsCodeType_SetWalletPassword = 1, //
    SmsCodeType_Regist = 2, // 注册
    SmsCodeType_CloseAccount = 3, // 注销
} SmsCodeType;

//由业务模块id与相应模块的某个能力id组合成一个唯一的业务调用id
//32位业务调用id = 模块id（高16位）＋ 能力id（低16位）
#define MakeID(x, y) (((x)<<16) + (y))

//从32位业务调用id中分离模块id
#define ModuleID(x) ((x)>>16)

//从32位业务调用id中分离能力id
#define CapabilityID(x) (((x)<<16)>>16)

enum TModuleID {
    EUserManager = 1,
};

enum TEConfigManagerCapability {
    EUser_To_TdConfig = 1,//授权状态Wait Tdlib参数
    EUser_To_Check_Encryption,//授权状态等待加密密钥
    EUser_Td_Input_Phone,//授权状态等待电话号码
    EUser_Td_Input_Code,//授权状态等待码
    EUser_Td_Input_Code_ByPasswordWay,//授权状态等待码
    EUser_Td_Register,//授权状态等待注册
    EUser_Td_Input_Password,//授权状态等待密码
    EUser_Td_Ready,//授权状态就绪
    EUser_Td_Closed,//授权状态已关闭
    EUser_Td_Closing,
    EUser_Td_Logout,//授权状态注销
    
    EUser_Td_Update_Apns_Token,
    
    EUser_Td_Connection_State_Changed,
    EUser_Td_UpdateUserInfo,
    EUser_Td_UpdateContactInfo,
    EUser_Td_UpdateUserPrivacySettings, //个人隐私变化
    EUser_Td_AddNewContactInfo,
    EUser_Td_Message_Total_Unread_Changed, //消息未读总数更新
    EUser_Td_Chat_List_Changed, //最近会话列表个数变化
    EUser_Td_Chat_Changed,//最近会话列表某个会话内容变化
    EUser_Td_Chat_OutMessage_Readed,//发送的消息被读
    EUser_Td_Chat_Last_Message_Changed,//最近会话列表某个会话最后一条消息变化
    EUser_Td_Chat_New_Message,//新消息
    EUser_Td_Chat_Send_Message_Success,//发送成功
    EUser_Td_Chat_Send_Message_Fail,//发送失败
    EUser_Td_Chat_Delete_Message,//删除消息
    EUser_Td_Chat_Title_Changed,//最近会话标题修改
    EUser_Td_Chat_Photo_Changed,//最近会话头像修改
    EUser_Td_Chat_Permissions_Changed,//最近会话权限变更
    EUser_Td_Chat_Bg_Changed,//会话背景图改变
    EUser_Td_Chat_Is_Blocked,//对话更新黑名单状态
    EUser_Td_Contact_Photo_Ok, //联系人头像已准备好
    EUser_Td_Group_Photo_Ok, //讨论组头像已准备好
    EUser_Td_Message_Photo_Ok, //消息图片已准备好
    EUser_Td_Message_Animation_Ok, //gif图片已准备好
    EUser_Td_Message_Preview_Photo_Ok, //消息预览图片已准备好
    EUser_Td_Message_Video_Ok, //消息视频已准备好
    EUser_Td_Message_Audio_Ok, //消息音频已准备好
    EUser_Td_Message_Voice_Ok, //消息语音已准备好
    EUser_Td_Message_Document_Ok, //消息文件已准备好
    EUser_Td_Message_Reaction_Update, //消息表情回复更新
    
    EUser_Td_Group_Basic_Info_Changed,
    EUser_Td_Group_Basic_Full_Info_Changed,
    EUser_Td_Group_Super_Info_Changed,//成员增减
    EUser_Td_Group_Super_Full_Info_Changed,//成员增减
    EUser_Td_UpdateUserUpdateUserStatus, //在线状态变化
    EUser_Td_UpdateChatOnlineMemberCount, //群在线人数发生变化
    EUser_Td_UpdateChatUpdateSecretChatStatus, // 私密聊天状态发生变化
    
    //语音视频通话相关
    EUser_Call_State_Changed,   //通话状态改变
    EUser_Headset_State_Changed,//耳机插拔改变
    EUser_Refresh_Call_Time,    //刷新通话时间
    EUser_Incoming_New_Call,    //来电
    EUser_Call_Local_Voice_Mute_Changed, //语音本地静音改变
    
    // 逆地址转换
    EUser_Td_Location_ReGeocode_Search,
    
    //配置
    EUser_Tab_Ex_Menu_Changed,  //tab扩展菜单变更
    EUser_App_Config_Changed,  //app配置变更
    
    //有联系人需要显示
    EUser_Will_Show_Contact,
    EUser_Invite_Link_Group,//链接进群
    //权限
    EUser_Chatcustom_Permissions_Change,
    //关键字敏感字
    EUser_Keys_Change,
    //正在输入
    EUser_User_Inputing,
    //无输入
    EUser_User_Inputing_Canale,
    /// 群组内用户修改了昵称
    EUser_Group_Member_Nickname_Change,
    
    /// 朋友圈相关
    /// 关注/取关通知
    EUser_Timeline_Follows_Change,
    /// 动态点赞通知
    EUser_Timeline_Info_Liked_Change,
    /// 评论点赞通知
    EUser_Timeline_Reply_Liked_Change,
    /// 动态评论通知
    EUser_Timeline_Info_Comment_Change,
    /// 评论回复通知
    EUser_Timeline_Reply_Comment_Change,
    /// 删除动态通知
    EUser_Timeline_Delete_Change,
    /// 发布成功
    EUser_Timeline_Publish_Success,
    /// 动态更新成功（推送）
    EUser_Timeline_Update_Success,
    /// 动态更新失败（推送）
    EUser_Timeline_Update_Fail,
    /// 屏蔽动态
    EUser_Timeline_Blocked_Change,
    /// 未读消息调用通知
    EUser_Timeline_UnReadMessage,
};

#endif
