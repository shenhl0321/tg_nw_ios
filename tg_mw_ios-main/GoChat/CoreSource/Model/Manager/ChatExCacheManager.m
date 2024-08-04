//
//  ChatExCacheManager.m
//  GoChat
//
//  Created by wangyutao on 2021/5/13.
//

#import "ChatExCacheManager.h"

static ChatExCacheManager *g_chatManager = nil;

@implementation ChatExInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithLong:self.chatId] forKey:@"chatId"];
    [aCoder encodeObject:self.chatBg forKey:@"chatBg"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    ChatExInfo *ex = [[ChatExInfo alloc] init];
    ex.chatId = [[aDecoder decodeObjectForKey:@"chatId"] longValue];
    ex.chatBg = [aDecoder decodeObjectForKey:@"chatBg"];
    return ex;
}

- (id)copyWithZone:(NSZone *)zone
{
    ChatExInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.chatId = self.chatId;
        copy.chatBg = [self.chatBg copy];
    }
    return copy;
}

@end

@interface ChatExCacheManager()
@property (nonatomic, strong) NSMutableDictionary *chatExCacheDic;
@end

@implementation ChatExCacheManager

+ (ChatExCacheManager *)shareInstance
{
    if(g_chatManager == nil)
    {
        g_chatManager = [[ChatExCacheManager alloc] init];
        [g_chatManager load];
    }
    return g_chatManager;
}

+ (void)reset
{
    g_chatManager = nil;
}

- (NSMutableDictionary *)chatExCacheDic
{
    if(_chatExCacheDic == nil)
    {
        _chatExCacheDic = [NSMutableDictionary dictionary];
    }
    return _chatExCacheDic;
}

- (void)load
{
    NSDictionary *dic = [ChatExCacheManager getChatExCacheDic];
    if(dic != nil && [dic isKindOfClass:[NSDictionary class]])
    {
        if(dic.count>0)
        {
            [self.chatExCacheDic addEntriesFromDictionary:dic];
        }
    }
}

//群组相关
- (void)setGroupMemberCount:(long)chatId count:(int)count
{
    ChatExInfo *info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:chatId]];
    if(info != nil)
    {
        info.groupMemberCount = count;
    }
    else
    {
        info = [ChatExInfo new];
        info.chatId = chatId;
        info.groupMemberCount = count;
        [self.chatExCacheDic setObject:info forKey:[NSNumber numberWithLong:chatId]];
    }
    //保存
    [ChatExCacheManager saveChatExCacheDic:self.chatExCacheDic];
}

- (int)getGroupMemberCount:(long)chatId
{
    ChatExInfo *info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:chatId]];
    if(info != nil)
    {
        return info.groupMemberCount;
    }
    return 0;
}

//聊天背景图片相关
//app内置会话背景列表，返回类型：NSString，图片来自Assets目录
+ (NSArray *)localChatBgList
{
    return @[@"",@"chat_bg_1", @"chat_bg_2", @"chat_bg_3", @"chat_bg_4", @"chat_bg_5", @"chat_bg_6", @"chat_bg_7"];
}

//设置会话背景，chatBg可以是一个路径，可以是Assets中的名称
- (void)setChatBgWithChatId:(long)chatId chatBg:(NSString *)chatBg
{
    ChatExInfo *info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:chatId]];
    if(info != nil)
    {
        info.chatBg = chatBg;
    }
    else
    {
        info = [ChatExInfo new];
        info.chatId = chatId;
        info.chatBg = chatBg;
        [self.chatExCacheDic setObject:info forKey:[NSNumber numberWithLong:chatId]];
    }
    //保存
    [ChatExCacheManager saveChatExCacheDic:self.chatExCacheDic];
    //发送通知
    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Bg_Changed) withInParam:[NSNumber numberWithLong:chatId]];
}

- (void)cleanChatBgWithChatId:(long)chatId
{
    ChatExInfo *info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:chatId]];
    if(info != nil)
    {
        info.chatBg = nil;
    }
    //保存
    [ChatExCacheManager saveChatExCacheDic:self.chatExCacheDic];
    //发送通知
    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Chat_Bg_Changed) withInParam:[NSNumber numberWithLong:chatId]];
}

//所有聊天窗口应用全局背景
- (void)applyGlobalBgToAllChatView
{
    if([self chatBg:CHAT_GLOBAL_ID] != nil)
    {//前提是，已经设置了全局背景
        NSArray *chatSettingsList = self.chatExCacheDic.allValues;
        for(ChatExInfo *set in chatSettingsList)
        {
            if(set.chatId != CHAT_GLOBAL_ID)
            {
                set.chatBg = nil;
            }
        }
        //保存
        [ChatExCacheManager saveChatExCacheDic:self.chatExCacheDic];
    }
}

//获取会话背景
- (NSString *)chatBg:(long)chatId
{
    if(CHAT_GLOBAL_ID == chatId)
    {//全局
        ChatExInfo *info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:chatId]];
        if(info != nil)
        {
            return info.chatBg;
        }
        return nil;
    }
    else
    {
        //优先当前会话设置
        ChatExInfo *info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:chatId]];
        if(info != nil && !IsStrEmpty(info.chatBg))
        {
            return info.chatBg;
        }
        //然后全局设置
        info = [self.chatExCacheDic objectForKey:[NSNumber numberWithLong:CHAT_GLOBAL_ID]];
        if(info != nil)
        {
            return info.chatBg;
        }
        return nil;
    }
}

//会话背景-是否Assets背景
- (BOOL)chatBgIsFromAssets:(long)chatId
{
    NSString *bg = [self chatBg:chatId];
    if(!IsStrEmpty(bg))
    {
        return [bg hasPrefix:@"chat_bg_"];
    }
    return NO;
}

//会话背景-是否本地文件
- (BOOL)chatBgIsFromLocalFile:(long)chatId
{
    NSString *bg = [self chatBg:chatId];
    if(!IsStrEmpty(bg))
    {
        return ![bg hasPrefix:@"chat_bg_"];
    }
    return NO;
}

#pragma mark - userdefault save or get
+ (NSDictionary *)getChatExCacheDic
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:[[AuthUserManager shareInstance] currentAuthUser].data_directory];
    if(data)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        unarchiver.requiresSecureCoding = NO;
        return [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    }
    return nil;
}

+ (void)saveChatExCacheDic:(NSDictionary *)dic
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[[AuthUserManager shareInstance] currentAuthUser].data_directory];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
