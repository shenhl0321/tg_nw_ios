//
//  MNGroupSentHelper.m
//  GoChat
//
//  Created by Autumn on 2022/2/22.
//

#import "MNGroupSentHelper.h"


@implementation MNGroupSentHelper



+ (void)getMessages:(int)fromId completion:(GroupSentMessagesCompletion)completion {
    
    NSDictionary *parameters = @{
        @"@type": @"sendCustomRequest",
        @"method": @"messages.getBatchSend",
        @"parameters": @{
            @"limit": @(1000),
            @"fromId": @(fromId)
        }.mj_JSONString
    };
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        NSString *result = response[@"result"];
        if ([result isKindOfClass:NSString.class]) {
            NSDictionary *resp = result.mj_JSONObject;
            NSArray *messages = [GroupSentMessage mj_objectArrayWithKeyValuesArray:resp[@"data"]];
            !completion ? : completion(messages);
            return;
        }
        !completion ? : completion(@[]);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
    
}

+ (NSString *)cacheKey {
    NSString *uid = [NSString stringWithFormat:@"%ld", UserInfo.shareInstance._id];
    return [NSString stringWithFormat:@"GroupSentArrayKey_%@", [Common md5:uid]];
}

+ (NSArray<GroupSentMessage *> *)getMessages  {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSMutableArray *lists = [ud objectForKey:self.cacheKey];
    NSMutableArray *msgs = [GroupSentMessage mj_objectArrayWithKeyValuesArray:lists];
    return [[msgs reverseObjectEnumerator] allObjects];
}

+ (BOOL)saveMessage:(GroupSentMessage *)message {
    NSString *key = self.cacheKey;
    message.time = NSDate.date.timeIntervalSince1970;
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSMutableArray *msgs = [[ud objectForKey:key] mutableCopy];
    if (!msgs) {
        msgs = NSMutableArray.array;
    }
    [msgs addObject:message.mj_JSONObject];
    [ud setObject:msgs forKey:key];
    [ud synchronize];
    return YES;
}

@end


@implementation MNGroupSentHelper (MessageSend)

+ (void)sendTextMessage:(NSString *)text {
    
}

@end
