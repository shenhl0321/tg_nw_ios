//
//  TimelineMessageHelper.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineMessageHelper.h"

@implementation TimelineMessageHelper

+ (void)fetchMessagesCompletion:(MessagesCompletion)completion {
    NSDictionary *params = @{@"@type": @"getBlogMessages"};
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogMessages"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[@"messages"];
        NSArray *messages = [BlogMessage mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(messages);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)clearMessagesSuccessful:(dispatch_block_t)completion {
    NSDictionary *params = @{@"@type": @"clearBlogMessages"};
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if ([response[@"@type"] isEqualToString:@"ok"]) {
            !completion ? : completion();
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

@end
