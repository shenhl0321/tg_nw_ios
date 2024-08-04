//
//  TF_RequestManager.h
//  GoChat
//
//  Created by apple on 2021/12/20.
//

#import <Foundation/Foundation.h>
@class BlogLocationList;

@interface TF_RequestManager : NSObject
/// 更新自己的定位
+ (void)setLocation:(BlogLocationList *)location result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 搜索附近的人
+ (void)searchChatsNearby:(BlogLocationList *)location result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 加入群聊
+ (void)joinChatWithId:(long )chatId result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 搜索附近的群
+ (void)searchPublicChatsWithQuery:(NSDictionary *)param resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 切换群是否公开的属性
+ (void)toggleChannelPublicWithId:(long )supergroupId open:(BOOL)open resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 获取群/个人资料
/// @param type 类型
/// @param userId 用户id，用于区分查询群媒体还是个人媒体
/// @param startId 起始id
/// @param chatId 回话id
+ (void)searchChatMessagesWithType:(NSInteger)type userId:(NSString *)userId startId:(NSInteger)startId chatId:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 获取相同的小组
/// @param userId 需要查询的用户id
/// @param offsetChatId 回话id
+ (void)getGroupsInCommonWithId:(long)userId offsetChatId:(long)offsetChatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 创建私密聊天
/// @param userId 对方用户id
+ (void)createNewSecretChatWithUserId:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 关闭私密聊天
/// @param secretChatId 聊天id
+ (void)closeSecretChatWithId:(long)secretChatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 获取群信息
/// /// @param chatId 群id
+ (void)getChatWithId:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 获取私密聊天信息
/// @param chatId 私密聊天id
+ (void)getSecretChatWithSecretId:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 获取群在线人数
/// @param channelID 服务器id
+ (void)requestOnlieNumberWithChannelID:(long)channelID resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 搜索群
/// @param query 关键字
+ (void)searchChatsWithQuery:(NSString *)query resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 获取聊天的最后一条消息
/// @param chatId 回话id
+ (void)getLastChatMsg:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 修改用户隐私设置
/// 
/// @param ruleType 设置大类
/// userPrivacySettingShowStatus  - 最后上线时间
/// userPrivacySettingAllowCalls  - 语音通话
/// userPrivacySettingShowPhoneNumber   - 电话号码
/// userPrivacySettingAllowChatInvites  - 群组
/// userPrivacySettingAllowMessages  - 消息
///
/// @param settingRule 具体的规则
/// userPrivacySettingRuleAllowAll         // 所有人
/// userPrivacySettingRuleAllowContacts // 联系人
/// userPrivacySettingRuleRestrictAll   // 没有人
+ (void)changeUserPrivacySettingsRule:(NSString *)ruleType settingRule:(NSString *)settingRule resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 获取用户隐私设置
///
/// @param ruleType 设置大类
/// userPrivacySettingShowStatus  - 最后上线时间
/// userPrivacySettingAllowCalls  - 语音通话
/// userPrivacySettingShowPhoneNumber   - 电话号码
/// userPrivacySettingAllowChatInvites  - 群组
/// userPrivacySettingAllowMessages  - 消息
///
///
+ (void)getUserPrivacySettingWithRuleType:(NSString *)ruleType resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 查询自定义隐私权限
+ (void)getAllCustomPrivacySettingResultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 朋友查看范围
/// @param days 最近3天/最近一个月/最近半年/最近一年
+ (void)setCustomPrivacyOfTimeRange:(NSInteger)days resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 陌生人查看范围
/// @param number （3条/10条/所有）
+ (void)setCustomPrivacyOfNumberRange:(NSInteger)number resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


/// 添加删除用户-不让谁看/不看谁
/// @param userIds 添加或删除的uids
/// @param isAdding true:添加 false：删除
/// @param type 1 不让谁看;2 不看谁
+ (void)setCustomPrivacyChangeUserAuthority:(NSArray *)userIds isAdding:(BOOL)isAdding type:(NSInteger)type resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;


+ (void)uploadTestLocalPath:(NSString *)localPath resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

+ (void)downloadTestWithPath:(NSString *)path fileName:(NSString *)fileName resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
@end

