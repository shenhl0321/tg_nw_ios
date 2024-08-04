//
//  TimelineMessageHelper.h
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import <Foundation/Foundation.h>
#import "BlogMessage.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MessagesCompletion)(NSArray<BlogMessage *> *messages);

@interface TimelineMessageHelper : NSObject

+ (void)fetchMessagesCompletion:(MessagesCompletion)completion;

+ (void)clearMessagesSuccessful:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
