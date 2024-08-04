//
//  ChatHistorySearchRecord.m
//  GoChat
//
//  Created by Autumn on 2022/3/14.
//

#import "ChatHistorySearchRecord.h"

static NSString *const RecordUDKey = @"RecordUNKey";

@implementation ChatHistorySearchRecord

+ (NSArray<NSString *> *)getRecordsForChatId:(long)chatId {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSString *json = [ud objectForKey:RecordUDKey];
    NSDictionary *recordsDic = json.mj_JSONObject;
    NSArray *records = recordsDic[@(chatId).stringValue];
    return records ? : @[];
}

+ (void)removeRecordsForChatId:(long)chatId {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSString *json = [ud objectForKey:RecordUDKey];
    NSMutableDictionary *recordsDic = [json.mj_JSONObject mutableCopy];
    [recordsDic setObject:@[] forKey:@(chatId).stringValue];
    [ud setObject:recordsDic forKey:RecordUDKey];
    [ud synchronize];
}

+ (void)saveRecord:(NSString *)text forChatId:(long)chatId {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    NSString *json = [ud objectForKey:RecordUDKey];
    NSMutableDictionary *recordsDic = [json.mj_JSONObject mutableCopy];
    if (!recordsDic) {
        recordsDic = NSMutableDictionary.dictionary;
    }
    NSMutableArray *records = [recordsDic[@(chatId).stringValue] mutableCopy];
    if (!records) {
        records = NSMutableArray.array;
    }
    if ([records containString:text]) {
        [records exchangeObjectAtIndex:0 withObjectAtIndex:[records indexOfObject:text]];
    } else {
        [records insertObject:text atIndex:0];
    }
    recordsDic[@(chatId).stringValue] = records;
    json = recordsDic.mj_JSONString;
    [ud setObject:json forKey:RecordUDKey];
    [ud synchronize];
}

+ (void)removeAllRecords {
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    [ud removeObjectForKey:RecordUDKey];
    [ud synchronize];
}

@end
