//
//  TelegramManager.h
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import <Foundation/Foundation.h>

typedef void (^TgTaskBlock)(int taskId);
typedef void (^TgResultBlock)(NSDictionary *request, NSDictionary *response);
typedef void (^TgObjectResultBlock)(NSDictionary *request, NSDictionary *response, id obj);
typedef void (^TgTimeoutBlock)(NSDictionary *request);
typedef void (^readImageBlock)(void);
typedef void (^readVideoBlock)(NSData *data);

@interface TelegramManager : NSObject
+ (TelegramManager *)shareInstance;

//鉴权相关
- (void)setTdlibParameters:(NSString *)data_directory result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)checkDatabaseEncryptionKey:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)setAuthenticationPhoneNumber:(NSString *)phone result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)changeAuthenticationPhoneNumber:(NSString *)phone result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)checkAuthenticationCode:(NSString *)code result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)registerUser:(NSString *)firstName lastName:(NSString *)lastName result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)checkAuthenticationPassword:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)background;
- (void)logout;
- (void)deleteAccount;
- (void)destroy;
- (void)reInitTdlib;
- (void)cleanCurrentData;

//状态相关
- (GoUserState)getUserState;
- (GoUserConnectionState)getUserConnectionState;

- (void)localAddChat:(ChatInfo *)chat;

//当前会话
- (long)getCurChatId;
- (void)updateCurChatId:(long)chatId;

//会话相关
//搜索公共会话 - 返回taskid
- (void)searchPublicChatsList:(NSString *)keyword task:(TgTaskBlock)taskBlock resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
// 新增 搜索已是联系人的好友
- (void)searchChatsList:(NSString *)keyword task:(TgTaskBlock)taskBlock resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//搜索消息 - 返回taskid
- (void)searchMessagesList:(NSString *)keyword task:(TgTaskBlock)taskBlock resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//会话是否提醒
- (void)toggleChatDisableNotification:(long)chatId isDisableNotification:(BOOL)isDisableNotification resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//置顶或者取消置顶
- (void)toggleChatIsPinned:(long)chatId isPinned:(BOOL)isPinned resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//清空聊天记录-可删除会话
- (void)deleteChatHistory:(long)chatId isDeleteChat:(BOOL)isDeleteChat resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//加入黑名单
- (void)blockUser:(long)userId isBlock:(BOOL)isBlock resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//创建单聊
- (void)createPrivateChat:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//创建群组
- (void)createBasicGroupChat:(NSString *)groupName userIds:(NSArray *)userIds resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)createSuperGroupChat:(NSString *)groupName resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取讨论组列表 - 无效，可能不存在当前用户讨论组列表的api
//- (void)getGroupsList:(long)userId offset_chat_id:(long)offset_chat_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置讨论组标题
//Supported only for basic groups, supergroups and channels
- (void)setGroupName:(long)chatId groupName:(NSString *)groupName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置讨论组头像
- (void)setGroupPhoto:(long)chatId localPath:(NSString *)localPath resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取群组详情
- (void)getBasicGroupInfo:(long)basic_group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)getBasicGroupFullInfo:(long)basic_group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)getSuperGroupInfo:(long)group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)getSuperGroupFullInfo:(long)group_id resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取群组成员-仅超级群组
//supergroupMembersFilterAdministrators, supergroupMembersFilterBanned, supergroupMembersFilterBots, supergroupMembersFilterContacts, supergroupMembersFilterMention, supergroupMembersFilterRecent, supergroupMembersFilterRestricted, and supergroupMembersFilterSearch.
//默认-supergroupMembersFilterRecent
- (void)getSuperGroupMembers:(long)group_id type:(NSString *)type keyword:(NSString *)keyword offset:(int)offset limit:(int)limit resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)getGroupMember:(long)chatId userId:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//群组增加成员
- (void)addMembers2SuperGroup:(long)chatId members:(NSArray *)members resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)addMember2Group:(long)chatId member:(long)toAddUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//群组移除成员
- (void)removeMemberFromGroup:(long)chatId member:(long)toDelUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//群组添加管理员
- (void)addManager2Group:(long)chatId member:(long)toAddUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//群组移除管理员
- (void)removeManagerFromGroup:(long)chatId member:(long)toDelUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//退出群组
- (void)leaveGroup:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//解散群组
- (void)deleteGroup:(long)group_id resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//禁言某人
- (void)banMemberFromSuperGroup:(long)chatId member:(long)toBanUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//取消禁言
- (void)unbanMemberFromSuperGroup:(long)chatId member:(long)toUnbanUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//全体禁言或者取消全体禁言
//- (void)banAllToGroup:(long)chatId isBanAll:(BOOL)isBanAll resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//全体禁止私聊
//- (void)blockPrivateChatToGroup:(long)chatId isBlock:(BOOL)isBlock resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置权限
- (void)setChatPermissions:(long)chatId withPermissions:(NSMutableDictionary *)permissionsDic resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//是否可以加群员
//- (void)canInvideMemberToGroup:(long)chatId isCan:(BOOL)isCan resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//删除某人全部消息-超级群组
- (void)delAllHisMessagesFromSuperGroup:(long)chatId member:(long)toUserId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//升级为超级群组
- (void)upgradeBasicGroupChatToSupergroupChat:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 发送敏感词被踢
- (void)kickedBySendSensitiveWordsInGroup:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//消息相关
//获取最近会话列表-未排序
- (NSArray *)getChatList;
//- (NSArray *)getContactsList;//获取联系人列表
- (void)deleteChat:(long)chatId;
//获取某个会话
- (ChatInfo *)getChatInfo:(long)chatId;
//最近会话列表-通过获取会话ids,触发一系列update动作,可以分页，也可以不分页，为逻辑简单，设置阀值2000条
- (void)getChatListIds:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//解析消息具体内容
+ (void)parseMessageContent:(NSDictionary *)contentDic message:(MessageInfo *)msg;

//获取会话最后一条消息
//- (void)getChatLastMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)getChatMessageList:(long)chatId from_message_id:(long)from_message_id offset:(int)offset limit:(int)limit only_local:(BOOL)only_local resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取pin消息
- (void)getChatPinnedMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//设置消息已读 - viewMessages
- (void)setMessagesReaded:(long)chatId msgIds:(NSArray *)msgIds;
//设置@消息已读 - readAllChatMentions
//- (void)setAtMessagesReaded:(long)chatId;

//发送消息相关
//重发消息 - 经测试文本消息有效，图片、视频消息重发失败
- (void)reSendMessage:(long)chatId ids:(NSArray *)ids resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送文本消息
- (void)sendTextMessage:(long)chatId replyid:(long)replyid text:(NSString *)text withUserInfoArr:(NSArray *)remindArr replyMarkup:(NSDictionary *)markup resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)sendLocalCustomMessage:(long)chatId text:(NSString *)text sender:(long)sender resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送图片
- (void)sendPhotoMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize replyMarkup:(NSDictionary *)markup resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 发送图文
- (void)sendPhotoTextMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize text:(NSString *)text resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)sendFirePhotoMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//- (void)sendPhotoMessage:(long)chatId fileId:(NSString *)fileId photoSize:(CGSize)photoSize resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//- (void)sendPhotoMessage:(long)chatId remotFileId:(NSString *)remotFileId photoSize:(CGSize)photoSize resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送视频
- (void)sendVideoMessage:(long)chatId localCoverPath:(NSString *)localCoverPath localVideoPath:(NSString *)localVideoPath  videoSize:(CGSize)videoSize duration:(int)duration resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送阅后即焚视频消息
- (void)sendFireVideoMessage:(long)chatId localCoverPath:(NSString *)localCoverPath localVideoPath:(NSString *)localVideoPath videoSize:(CGSize)videoSize duration:(int)duration fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送语音
- (void)sendVoiceMessage:(long)chatId localAudioPath:(NSString *)localAudioPath duration:(int)duration resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送音频
- (void)sendAudioMessage:(long)chatId localAudioPath:(NSString *)localAudioPath duration:(int)duration resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送阅后即焚语音消息
- (void)sendFireAudioMessage:(long)chatId localAudioPath:(NSString *)localAudioPath duration:(int)duration fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送文件
- (void)sendFileMessage:(long)chatId realFileName:(NSString *)realFileName localFilePath:(NSString *)localFilePath resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送阅后即焚文件
- (void)sendFireFileMessage:(long)chatId realFileName:(NSString *)realFileName localFilePath:(NSString *)localFilePath fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送位置
- (void)sendLocationMessage:(long)chatId latitude:(double)latitude longitude:(double)longitude resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送阅后即焚位置消息
- (void)sendFireLocationMessage:(long)chatId latitude:(double)latitude longitude:(double)longitude  fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置pin消息
- (void)setPinMessage:(long)chatId long:(long)msgId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//发送截屏消息
- (void)sendScreenshotMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送加好友消息
- (void)sendBeFriendMessage:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送阅后即焚消息
-(void)sendReadFireMessage:(long)chatId Text:(NSString *)text CountDown:(NSString *)countDown resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//收藏表情
- (void)addSavedAnimation:(NSString *)remoteId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//转发消息
- (void)forwardMessage:(long)chatId msgs:(NSArray *)msgs;

- (void)forwardMessage:(long)chatId msg:(MessageInfo *)msg resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//消息操作
//删除单条消息
- (void)deleteMessage:(long)chatId msgIds:(NSArray *)msgIds revoke:(BOOL)revoke resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//联系人相关
- (UserInfo *)contactInfo:(long)userId;
- (NSArray *)getContacts;
- (NSArray *)getContacts:(NSString *)keyword;
- (NSArray *)getGroups;
- (NSArray *)getGroups:(NSString *)keyword;
- (void)syncMyContacts;
//添加好友
- (void)addContact:(UserInfo *)user resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置联系人备注
- (void)setContactNickName:(UserInfo *)user nickName:(NSString *)nickName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//删除好友
- (void)deleteContact:(long)userId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置当前用户username，允许为空，为空表示删除
- (void)setMyUserName:(NSString *)userName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置当前用户昵称
- (void)setMyNickName:(NSString *)nickName resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置个人头像
- (void)setMyPhoto:(NSString *)localPath resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取联系人信息
- (void)requestContactInfo:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取联系人详细信息
- (void)requestContactFullInfo:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取黑名单
- (void)requestblockedUserList:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取联系人本身最新的信息，而不是备注 - 自定义api
- (void)requestOrgContactInfo:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//同步当前用户隐私信息
- (void)updateUserPrivacySettingsByAllowFindingByPhoneNumber;
- (void)setUserPrivacySettingsByAllowFindingByPhoneNumber:(BOOL)allow resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//文件相关
- (BOOL)isFileDownloading:(long)fileId type:(FileType)type;
- (void)DownloadFile:(NSString *)_id fileId:(long)fileId download_offset:(int)download_offset type:(FileType)type;
- (void)cancelDownloadFile:(long)fileId;
- (void)downloadImage:(NSString *)_id fileId:(long)fileId type:(FileType)type read_block:(readImageBlock)read_block;
- (void)readVideo:(long)fileId read_offset:(int)read_offset read_count:(int)read_count read_block:(readVideoBlock)read_block;
- (void)downloadVideo:(long)fileId download_offset:(int)download_offset download_limit:(int)download_limit read_block:(readVideoBlock)read_block;
/// 下载视频缩略图
- (void)downloadThumbnailVideo:(long)fileId offset:(int)offset limit:(int)limit completion:(void(^)(FileInfo *file))completion;

//结束请求任务
- (void)cancelTask:(int)taskId;

//苹果推送相关
- (void)registerApnsToken:(NSString *)token resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取文件信息
- (void)getRemoteFile:(NSString *)remoteFileId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//通用解析
+ (BOOL)isResultOk:(NSDictionary *)result;
+ (BOOL)isResultError:(NSDictionary *)result;
+ (NSString *)errorMsg:(NSDictionary *)result;

//自定义方法
//发送自定义请求
- (void)sendCustomRequest:(NSString *)method parameters:(NSString *)parameters resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//语音通话相关
//生成声网token
- (void)createRtcToken:(NSString *)channelName uid:(long)uid resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//创建新通话
- (void)createCall:(CallBaseInfo *)callInfo resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//确认收到
- (void)callInviteAsk:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//通话取消-仅发起人可以调用
- (void)cancelCall:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//加入/开始通话
- (void)startCall:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//离开/停止通话
- (void)stopCall:(long)callId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取离线通话记录
- (void)queryOfflineCall:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//分页获取通话记录
- (void)queryHistoryCall:(int)type count:(int)count page:(int)page resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//RP相关
//创建
- (void)createRp:(RedPacketInfo *)rpInfo resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//请求RP详情
- (void)queryRp:(long)rpId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//领取RP
- (void)gotRp:(long)rpId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//查询RP详情
- (void)queryWalletInfo:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//设置包支密码
- (void)setWalletPayPassword:(NSString *)password oldPassword:(NSString *)smsCode resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//分页获取钱包交易记录
- (void)queryWalletOrderListCall:(int)count page:(int)page resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//分页获取红包记录-type 1创建红包 2领取红包
- (void)queryRedHistoryCall:(int)type count:(int)count page:(int)page resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//充值信息获取
- (void)WalletRechargeRequest:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//提现信息获取
- (void)WalletTixianRequest:(float)amount password:(NSString *)password resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//查询第三方充值通道
- (void)queryThirdRechargeChannels:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//删除超级群组某条消息
- (void)deleteSuperGroupMessage:(long)chatId msgIds:(NSArray *)msgIds resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//发现
//获取发现页菜单列表
- (void)queryDiscoverSections:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取tab扩展菜单
- (void)queryTabExMenu:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取app配置信息
- (void)queryAppConfig:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// jw
- (void)jw_request:(NSDictionary *)parameters result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 朋友圈
- (void)queryTimelineWithType:(NSString *)type offset:(int)offset result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)queryTimelineWithVisible:(NSDictionary *)visible offset:(int)offset result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 发布相关
/// 获取用户标签列表
- (void)blogUserGroupIndex:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 创建标签
- (void)BlogUserGroupCreate:(NSString *)title users:(NSArray *)users result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 删除标签
- (void)BlogUserGroupDelete:(int)ids result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 标签添加用户
- (void)BlogUserGroupAddUsers:(NSArray *)users groupId:(int)ids result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 标签修改名称
- (void)BlogUserGroupModifyName:(NSString *)name groupId:(int)ids result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 标签删除用户
- (void)BlogUserGroupRemoveUsers:(NSArray *)users groupId:(int)ids result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 发布朋友圈
- (void)publishTimeline:(NSDictionary *)timeline result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

/// 获取评论
- (void)timelineRepay:(NSDictionary *)params result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//公共
//发送验证码
- (void)gotSmsCode:(SmsCodeType)type resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
/// 验证验证码
- (void)verifySmsCode:(NSString *)code type:(SmsCodeType)type resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//请求在线客服
- (void)getOnlineUserService:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

//全体禁言
//userPrivacySettingRuleRestrictChatMembers - 优先
//setUserPrivacySettingRules
//updateUserPrivacySettingRules
//getUserPrivacySettingRules

//setChatPermissions
//禁言某个群组某个成员
//setChatMemberStatus
//删除历史消息
//deleteChatMessagesFromUser
//升级为超级群组

//置顶
//toggleChatIsPinned

//群组禁止私加好友，用以下字段代替
//chatPermissions - can_add_web_page_previews true为不限制私聊

//获取登录前  通用配置
- (void)getApplicationConfigWithResultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//校验支付密码是否正确
- (void)checkWallerPassword:(NSString *)password resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//是否有登录密码
- (void)checkHasLoginPasswordResultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//修改登录密码
- (void)changeLoginPaswordWithParams:(NSString *)paramsStr resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置 重置邀请链接
- (void)generateChatInviteLink:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取群邀请的群信息
- (void)checkChatInviteLink:(NSString *)inviteLink resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//链接入群
- (void)joinChatByInviteLink:(NSString *)inviteLink resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//gif
- (void)sendGifPhotoMessage:(long)chatId localPath:(NSString *)localPath photoSize:(CGSize)photoSize resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取群组扩展权限
- (void)gettingExtendedPermissions:(long)chatid resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置群组扩展权限
- (void)settingExtendedPermissions:(NSDictionary *)paramsdic resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//停用邀请链接
- (void)stopGroupInviteLink:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//设置群屏蔽关键字
- (void)settingGroupShieldWords:(NSArray *)wordsarr withchtid:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//查询群屏蔽关键字
- (void)queryGroupShieldWordsWithchtid:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取具体哪一条消息
- (void)getMessageWithChatid:(long)chatid withMessageid:(long)messageid result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
// 正在输入
- (void)sendChatAction:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//取消 正在输入
- (void)sendChatActionCancle:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取预览消息
- (void)getWebPagePreview:(NSString *)text resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//通讯录
- (void)importContactsWithArray:(NSArray *)contacts resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//第二次通讯录
- (void)changeImportedContactsWithArray:(NSArray *)contacts resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送名片
- (void)sendContentMessage:(long)chatId withRwa:(OrgUserInfo *)obj withChatInfo:(id)chatInfo resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)sendFireContentMessage:(long)chatId withRwa:(OrgUserInfo *)obj withChatInfo:(id)chatInfo fireLimie:(NSString *)fireLimie resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//发送收藏的表情
- (void)sendCollectGifPhotoMessage:(long)chatId collectEmoji:(AnimationInfo *)collectModel resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取收藏的表情
- (void)getSavedAnimationsWithresultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//移除收藏的某个表情
- (void)removeSavedAnimation:(NSString *)remoteId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//授权电脑端登录
- (void)authComputerLogin:(NSString *)url resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取人员信息
- (void)getUserSimpleInfo_inline:(long)userId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//关联在线状态
- (void)setOnlineState:(NSString *)state result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
#pragma mark - 开关会话

- (void)openChat:(long)chat_id resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
- (void)closeChat:(long)chat_id resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

-(void)resetClicent;


//设置群简介的
- (void)setChatDescription:(long)chatId description:(NSString *)description resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
//获取群简介的
- (void)getChatDescription:(long)chatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;

#pragma mark - 附近的人相关
// 封装了一个对象方法供外部调用
- (void)tdRequestWithParams:(NSDictionary *)params task:(TgTaskBlock)taskBlock resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock;
@end
