//
//  ChatMsgObject.m
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "ChatMsgObject.h"

@implementation ChatMsgObject

- (NSDictionary *)jsonObject {
    NSAssert(self.types, @"type 必填".lv_localized);
    return @{@"@type": self.types};
}

@end
