//
//  ChatExCacheManager.h
//  GoChat
//
//  Created by wangyutao on 2021/5/13.
//

#import <Foundation/Foundation.h>

//会话全局设置id，全局背景设置时，代替参数:chatid
#define CHAT_GLOBAL_ID   -1

@interface ChatExInfo : NSObject
//会话id
@property (nonatomic) long chatId;
//会话背景
@property (nonatomic, copy) NSString *chatBg;
//群组人数
@property (nonatomic) int groupMemberCount;
@end

@interface ChatExCacheManager : NSObject

//单例
+ (ChatExCacheManager *)shareInstance;
+ (void)reset;

//群组相关
- (void)setGroupMemberCount:(long)chatId count:(int)count;
- (int)getGroupMemberCount:(long)chatId;

//聊天背景图片相关
//app内置会话背景列表，返回类型：NSString，图片来自Assets目录
+ (NSArray *)localChatBgList;
//设置会话背景，chatBg可以是一个路径，可以是Assets中的名称
- (void)setChatBgWithChatId:(long)chatId chatBg:(NSString *)chatBg;
- (void)cleanChatBgWithChatId:(long)chatId;
//所有聊天窗口应用全局背景
- (void)applyGlobalBgToAllChatView;
//获取会话背景
- (NSString *)chatBg:(long)chatId;
//会话背景-是否Assets背景
- (BOOL)chatBgIsFromAssets:(long)chatId;
//会话背景-是否本地文件
- (BOOL)chatBgIsFromLocalFile:(long)chatId;

@end
