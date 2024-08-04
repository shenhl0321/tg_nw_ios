//
//  AppConfigInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/6/17.
//

#import <Foundation/Foundation.h>

@interface AppConfigInfo : NSObject
//true 仅好友可以聊天
@property (nonatomic) BOOL onlyFriendChat;
//true 仅能添加白名单里的好友
@property (nonatomic) BOOL onlyWhiteAddFriend;
//是否可以修改用户名
@property (nonatomic,assign) BOOL permitModifyUserName;

//手机验证码登录
@property (nonatomic,assign)    BOOL    phone_code_login;
//注册需要手机验证码
@property (nonatomic,assign)    BOOL    register_need_phone_code;
//注册需要邀请码
@property (nonatomic,assign)    BOOL    register_need_inviter;
/// 重新登录等待时间
@property (nonatomic, assign) NSInteger password_flood_interval;
/// 是否使用oss
@property (nonatomic, assign) BOOL using_oss;
/// 发文件
@property (nonatomic, assign) BOOL can_send_file;
/// 位置
@property (nonatomic, assign) BOOL can_send_location;
/// 红包
@property (nonatomic, assign) BOOL can_send_redpacket;
/// 转账
@property (nonatomic, assign) BOOL can_remit;
/// 联系人页面的通讯录
@property (nonatomic, assign) BOOL can_see_address_book;
/// 发现页面的朋友圈
@property (nonatomic, assign) BOOL can_see_blog;
/// 邀请好友
@property (nonatomic, assign) BOOL can_invite_friend;
/// 是否显示群在线人数
@property (nonatomic, assign) BOOL shown_online_members;
/// 开启截屏通知
@property (nonatomic, assign) BOOL enabled_screenshot_notification;
/// 阅后即焚
@property (nonatomic, assign) BOOL enabled_destroy_after_reading;
/// 退出群聊 是否显示
@property (nonatomic, assign) BOOL shown_everyone_member_changes;
/// 附近的人
@property (nonatomic, assign) BOOL can_see_nearby;
/// 公开的群
@property (nonatomic, assign) BOOL can_see_public_group;
/// 二维码
@property (nonatomic, assign) BOOL can_see_qr_code;
/// 我的钱包
@property (nonatomic, assign) BOOL can_see_wallet;
/// 交易记录
@property (nonatomic, assign) BOOL can_see_wallet_records;
/// 表情商店
@property (nonatomic, assign) BOOL can_see_emoji_shop;

+ (instancetype)sharedInstance;
+ (AppConfigInfo *)getAppConfigInfo;
+ (void)saveAppConfigInfo:(AppConfigInfo *)info;
@end
