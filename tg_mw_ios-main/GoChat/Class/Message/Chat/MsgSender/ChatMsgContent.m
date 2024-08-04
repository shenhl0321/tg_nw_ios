//
//  ChatMsgContent.m
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgContent.h"

@implementation ChatMsgContent

- (NSDictionary *)jsonObject {
    NSDictionary *textDic = @{
        @"@type" : @"formattedText",
        @"text" : @"123456",
        @"entities" : @[]
    };
    return @{@"@type" : @"inputMessageText",
             @"text" : textDic,
             @"disable_web_page_preview" : @(NO),
             @"clear_draft" : @(NO)
    };
}

@end
