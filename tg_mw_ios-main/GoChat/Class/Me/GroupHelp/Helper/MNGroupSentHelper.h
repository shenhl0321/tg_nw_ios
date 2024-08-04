//
//  MNGroupSentHelper.h
//  GoChat
//
//  Created by Autumn on 2022/2/22.
//

#import <Foundation/Foundation.h>
#import "GroupSentMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GroupSentMessagesCompletion)(NSArray<GroupSentMessage *> *messages);

@interface MNGroupSentHelper : NSObject

+ (NSArray<GroupSentMessage *> *)getMessages;

+ (BOOL)saveMessage:(GroupSentMessage *)message;

@end


@interface MNGroupSentHelper (MessageSend)

+ (void)sendTextMessage:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
