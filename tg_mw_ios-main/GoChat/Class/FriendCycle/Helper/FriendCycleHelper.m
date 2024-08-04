//
//  FriendCycleHelper.m
//  GoChat
//
//  Created by Autumn on 2021/11/2.
//

#import "FriendCycleHelper.h"

@implementation FriendCycleHelper

+ (void)queryCycleList:(FriendCycleType)type offset:(int)offset completion:(CycleListBlock)completion {
    NSString *typeString = [self stringOfFriendCycelType:type];
    [TelegramManager.shareInstance queryTimelineWithType:typeString offset:offset result:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (!obj) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray <BlogInfo *>*blogs = [BlogInfo mj_objectArrayWithKeyValuesArray:obj];
        !completion ? : completion(blogs);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}








+ (NSString *)stringOfFriendCycelType:(FriendCycleType)type {
    switch (type) {
        case FriendCycleType_Hot:
            return @"visibleTypePublic";
        case FriendCycleType_Follow:
            return @"visibleTypeFollow";
        case FriendCycleType_Friend:
            return @"visibleTypeFriend";
    }
}

@end
