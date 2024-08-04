//
//  ChatHistorySearchRecord.h
//  GoChat
//
//  Created by Autumn on 2022/3/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatHistorySearchRecord : NSObject

+ (void)saveRecord:(NSString *)text forChatId:(long)chatId;

+ (NSArray<NSString *> *)getRecordsForChatId:(long)chatId;

+ (void)removeRecordsForChatId:(long)chatId;

+ (void)removeAllRecords;

@end

NS_ASSUME_NONNULL_END
