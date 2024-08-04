//
//  TF_RequestManager.m
//  GoChat
//
//  Created by apple on 2021/12/20.
//

#import "TF_RequestManager.h"
#import "BlogInfo.h"
#import "TelegramManager.h"
#import "ChatsNearby.h"
@implementation TF_RequestManager

+ (void)setLocation:(BlogLocationList *)location result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"setLocation";
    params[@"location"] = location.mj_keyValues;
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(resultBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request,response);
            });
        }
    } timeout:timeoutBlock];
}

+ (void)searchChatsNearby:(BlogLocationList *)location result:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"searchChatsNearby";
    NSMutableDictionary *loca = location.mj_keyValues.mutableCopy;
    loca[@"@extra"] = nil;
    loca[@"id"] = nil;
    params[@"location"] = loca;
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = [response objectForKey:@"@type"];

        if([type isKindOfClass:[NSString class]] && [type isEqualToString:@"chatsNearby"])
        {
            
            ChatsNearby *chatsNearby = [ChatsNearby mj_objectWithKeyValues:response];
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, chatsNearby);
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
}


/// 加入群聊
+ (void)joinChatWithId:(long )chatId result:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"joinChat";
    params[@"chat_id"] = @(chatId);
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(resultBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request,response);
            });
        }
    } timeout:timeoutBlock];
}

+ (void)searchPublicChatsWithQuery:(NSDictionary *)param resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
//    params[@"ver"] = @"1";
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:3];
    json[@"ver"] = @(1);
    json[@"offset"] = @(0);
    json[@"limit"] = @(20);
//
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"searchPublicChats";
    params[@"query"] = [json mj_JSONString];
    [UserInfo shareInstance].inOpenGroup = YES;
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo shareInstance].inOpenGroup = NO;
        if(![TelegramManager isResultError:response])
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
    
    
    
    
}


/// 切换群是否公开的属性
+ (void)toggleChannelPublicWithId:(long )supergroupId open:(BOOL)open resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"toggleChannelPublic";
    params[@"supergroup_id"] = @(supergroupId);
    params[@"is_public"] = [NSNumber numberWithBool:open];
//    params[@"is_public"] = @"true";
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(resultBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request,response);
            });
        }
    } timeout:timeoutBlock];
    
}

+ (void)searchChatMessagesWithType:(NSInteger)type userId:(NSString *)userId startId:(NSInteger)startId chatId:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:7];
    
    params[@"chat_id"] = @(chatId);
    params[@"offset"] = @(0);
    params[@"limit"] = @"50";
    params[@"message_thread_id"] = @"0";
    params[@"from_message_id"] = @(startId);
    if (userId.length > 0) {
        params[@"sender"] = @{@"@type" : @"messageSenderUser", @"user_id" : userId};
    }
//    params[@"sender"] = @{@"@type" : @"messageSenderChat", @"chat_id" : @(chatId)};
    
    params[@"@type"] = @"searchChatMessages";
    
    switch (type) {
        case 1:
            // 媒体
            params[@"filter"] = @{@"@type" :@"searchMessagesFilterPhotoAndVideo"};
            break;
        case 2:
            // 文件
            params[@"filter"] = @{@"@type" :@"searchMessagesFilterDocument"};
            break;
        case 3:
            // 语音
            params[@"filter"] = @{@"@type" :@"searchMessagesFilterVoiceNote"};
            break;
        case 4:
            // 链接
            params[@"filter"] = @{@"@type" :@"searchMessagesFilterUrl"};
            break;
        case 5:
            // gif
            params[@"filter"] = @{@"@type" :@"searchMessagesFilterAnimation"};
            break;
            
        default:
            break;
    }
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {

        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]])
            {
                NSMutableArray *mut = [NSMutableArray arrayWithCapacity:40];
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
//                    [mut insertObject:msg atIndex:0];
                    [mut addObject:msg];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, mut);
                });
                
            }
        }else{
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
                });
            }
        }
    } timeout:timeoutBlock];
}

+ (void)getGroupsInCommonWithId:(long)userId offsetChatId:(long)offsetChatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"getGroupsInCommon";
    params[@"user_id"] = @(userId);
    params[@"offset_chat_id"] = @(offsetChatId);
    params[@"limit"] = @(50);
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
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
        if(resultBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, nil);
            });
        }
        
    } timeout:timeoutBlock];
    
}

+ (void)createNewSecretChatWithUserId:(long)userId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    NSArray *chatList = [[TelegramManager shareInstance] getChatList];
    for (ChatInfo *historyChat in chatList) {
        if (historyChat.isSecretChat && historyChat.type.user_id == userId && ![historyChat.secretChatInfo.state isEqualToString:@"secretChatStateClosed"]) {
            if (resultBlock) {
                resultBlock(nil, nil, historyChat);
            }
            return;
        }
    }
    
    params[@"@type"] = @"createNewSecretChat";
    params[@"user_id"] = @(userId);
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
//            NSArray *chatIds = [response objectForKey:@"chat_ids"];
            if(resultBlock != nil)
            {
                __block ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:response];
//                NSArray *chatList = [[TelegramManager shareInstance] getChatList];
//                for (ChatInfo *historyChat in chatList) {
//                    if (historyChat.isSecretChat && historyChat.type.user_id == chat.type.user_id) {
//                        chat = historyChat;
//                        break;
//                    }
//                }
                
                [TF_RequestManager getSecretChatWithSecretId:chat.type.secret_chat_id resultBlock:^(NSDictionary *request, NSDictionary *response, SecretChat *obj) {
                    chat.secretChatInfo = obj;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resultBlock(request, response, chat);
                    });

                } timeout:timeoutBlock];
                
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
    
}

/// 关闭私密聊天
/// @param secretChatId 聊天id
+ (void)closeSecretChatWithId:(long)secretChatId resultBlock:(TgResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
   
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"closeSecretChat";
    params[@"secret_chat_id"] = [NSNumber numberWithLong:secretChatId];
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(resultBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request,response);
            });
        }
    } timeout:timeoutBlock];
}

+ (void)getChatWithId:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"getChat";
    params[@"chat_id"] = @(chatId);
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
//            NSArray *chatIds = [response objectForKey:@"chat_ids"];
            if(resultBlock != nil)
            {
                ChatInfo *chat = [ChatInfo mj_objectWithKeyValues:response];
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, chat);
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
}

/// 获取私密聊天信息
/// @param chatId 私密聊天id
+ (void)getSecretChatWithSecretId:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"getSecretChat";
    params[@"secret_chat_id"] = @(chatId);
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                SecretChat *chat = [SecretChat mj_objectWithKeyValues:response];
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, chat);
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
}

+ (void)requestOnlieNumberWithChannelID:(long)channelID resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"sendCustomRequest";
    params[@"method"] = @"channel.countOnline";
    params[@"parameters"] = [@{@"channelID":@(channelID)} mj_JSONString];
    
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                NSDictionary *result = [response[@"result"] mj_JSONObject];
                if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
                    NSString *code = [NSString stringWithFormat:@"%@", result[@"code"]];
                    if ([code isEqualToString:@"200"]) {
                        NSDictionary *data = result[@"data"];
                        if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
                            NSString *count = [NSString stringWithFormat:@"%@",data[@"count"]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, count);
                            });
                            return;
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
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
}

/// 搜索群
/// @param query 关键字
+ (void)searchChatsWithQuery:(NSString *)query resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"searchChats";
    params[@"limit"] = @(40);
    params[@"query"] = query;
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
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
        if(resultBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, nil);
            });
        }
        
    } timeout:timeoutBlock];
}


/// 获取聊天的最后一条消息
/// @param chatId 回话id
+ (void)getLastChatMsg:(long)chatId resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    
//    NSDictionary *funQuery = @{@"@type" : @"getChatHistory",
//                               @"chat_id" : [NSNumber numberWithLong:chatId],
//                               @"from_message_id" : [NSNumber numberWithInt:0],
//                               @"offset" : [NSNumber numberWithInt:0],
//                               @"limit" : [NSNumber numberWithInt:100],
//                               @"only_local" : [NSNumber numberWithBool:YES],
//                               @"@extra" : [NSNumber numberWithInt:rtId]};
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"getChatHistory";
    params[@"chat_id"] = @(chatId);
    params[@"from_message_id"] = @(0);
    params[@"offset"] = @(0);
    params[@"limit"] = @(1);
    params[@"only_local"] = [NSNumber numberWithBool:NO];
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSLog(@"====%@", response);
//            NSArray *chatIds = [response objectForKey:@"chat_ids"];
            NSArray *msgList = [MessageInfo mj_objectArrayWithKeyValuesArray:response[@"messages"]];
            if (msgList.count > 0) {
                MessageInfo *msg = msgList.firstObject;
                
                [TelegramManager parseMessageContent:[response[@"messages"] firstObject][@"content"] message:msg];
                if(resultBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        resultBlock(request, response, msg);
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
}


+ (void)changeUserPrivacySettingsRule:(NSString *)ruleType settingRule:(NSString *)settingRule resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    
    if (IsStrEmpty(ruleType)) {
        return;
    }
    if (IsStrEmpty(settingRule)) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    params[@"@type"] = @"setUserPrivacySettingRules";
    params[@"setting"] = @{@"@type":ruleType};
    params[@"rules"] = @{@"@type" : @"userPrivacySettingRules",
                         @"rules" : @[@{@"@type":settingRule}]
                        };
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, response);
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
    
    
    
}


+ (void)getUserPrivacySettingWithRuleType:(NSString *)ruleType resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    if (IsStrEmpty(ruleType)) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];
    params[@"@type"] = @"getUserPrivacySettingRules";
    params[@"setting"] = @{@"@type":ruleType};
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, response);
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
    
}

+ (void)getAllCustomPrivacySettingResultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"sendCustomRequest";
    params[@"method"] = @"blogs.getAllPrivacy";
    params[@"parameters"] = [[NSMutableDictionary dictionary] mj_JSONString];
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                NSDictionary *result = [response[@"result"] mj_JSONObject];
                if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
                    NSString *code = [NSString stringWithFormat:@"%@", result[@"code"]];
                    if ([code isEqualToString:@"200"]) {
                        NSDictionary *data = result[@"data"];
                        if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
                            NSArray *privacyList = data[@"privacyList"];
                            if (privacyList != nil && [privacyList isKindOfClass:[NSArray class]]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    resultBlock(request, response, privacyList);
                                });
                            }
                            return;
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
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
}


+ (void)setCustomPrivacyOfTimeRange:(NSInteger)days resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"sendCustomRequest";
    params[@"method"] = @"blogs.setPrivacy";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"rule"] = @(3);
    dic[@"days"] = @(days);
    params[@"parameters"] = [@{@"privacy":@{@"key" : @(3), @"rules" : @[dic] }} mj_JSONString];
    
    
    [self setCustomPrivacyWithParams:params resultBlock:resultBlock timeout:timeoutBlock];
}

+ (void)setCustomPrivacyOfNumberRange:(NSInteger)number resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"sendCustomRequest";
    params[@"method"] = @"blogs.setPrivacy";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (number == 0) {
        dic[@"rule"] = @(1);
    } else {
        dic[@"rule"] = @(4);
    }
    dic[@"counts"] = @(number);
    params[@"parameters"] = [@{@"privacy":@{@"key" : @(4), @"rules" : @[dic] }} mj_JSONString];
    
    
    [self setCustomPrivacyWithParams:params resultBlock:resultBlock timeout:timeoutBlock];
}

+ (void)setCustomPrivacyWithParams:(NSMutableDictionary *)params resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                NSDictionary *result = [response[@"result"] mj_JSONObject];
                if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
                    NSString *code = [NSString stringWithFormat:@"%@", result[@"code"]];
                    if ([code isEqualToString:@"200"]) {
                        NSDictionary *data = result[@"data"];
                        if (data != nil && [data isKindOfClass:[NSDictionary class]]) {
                            NSString *count = [NSString stringWithFormat:@"%@",data[@"count"]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                resultBlock(request, response, count);
                            });
                            return;
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
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
}

+ (void)setCustomPrivacyChangeUserAuthority:(NSArray *)userIds isAdding:(BOOL)isAdding type:(NSInteger)type resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"sendCustomRequest";
    params[@"method"] = @"blogs.modifyPrivacyUsers";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"key"] = @(type);
    dic[@"isAdding"] = @(isAdding);
    dic[@"users"] = userIds;
    params[@"parameters"] = [dic mj_JSONString];
    
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            if(resultBlock != nil)
            {
                NSDictionary *result = [response[@"result"] mj_JSONObject];
                if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
                    NSString *code = [NSString stringWithFormat:@"%@", result[@"code"]];
                    if ([code isEqualToString:@"200"]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            resultBlock(request, response, response);
                        });
                        return;
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, nil);
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
}

+ (void)uploadTestLocalPath:(NSString *)localPath resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    fileDic[@"@type"] = @"inputFileLocal";
    fileDic[@"path"] = localPath;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"uploadTest";
    params[@"object_name"] = @"testUpload";
    params[@"file"] = fileDic;
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSLog(@"==测试上传成功==%@", response);
            
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, response);
                });
            }
            return;
            
        }
        if(resultBlock != nil)
        {
            NSLog(@"==测试上传失败==%@", response);
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, nil);
            });
        }
        
    } timeout:timeoutBlock];
    
}


+ (void)downloadTestWithPath:(NSString *)path fileName:(NSString *)fileName resultBlock:(TgObjectResultBlock)resultBlock timeout:(TgTimeoutBlock)timeoutBlock
{
    
    NSMutableDictionary *fileDic = [NSMutableDictionary dictionary];
    fileDic[@"@type"] = @"inputFileLocal";
    fileDic[@"path"] = path;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4];

    params[@"@type"] = @"downloadTest";
    params[@"object_name"] = fileName;
    params[@"file"] = fileDic;
    
    [[TelegramManager shareInstance] tdRequestWithParams:params task:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSLog(@"==测试上传成功==%@", response);
            
            if(resultBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    resultBlock(request, response, response);
                });
            }
            return;
            
        }
        if(resultBlock != nil)
        {
            NSLog(@"==测试上传失败==%@", response);
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(request, response, nil);
            });
        }
        
    } timeout:timeoutBlock];
    
}

@end
