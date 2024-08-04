//
//  BlogGroupUserHelper.m
//  GoChat
//
//  Created by Autumn on 2021/11/6.
//

#import "BlogGroupUserHelper.h"

static NSString *const BlogUserGroupKey = @"BlogUserGroupKey";

@implementation BlogGroupUserHelper

+ (void)queryGroupsCompletion:(BlogGroupListBlock)completion {
    [TelegramManager.shareInstance blogUserGroupIndex:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (!obj) {
            !completion ? : completion(@[]);
            return;
        }
        NSMutableArray *groups = NSMutableArray.array;
        for (NSDictionary *list in obj) {
            BlogUserGroup *group = [BlogUserGroup mj_objectWithKeyValues:list];
            if (group.users.count > 0) {
                [groups addObject:group];
            }
        }
        !completion ? : completion(groups);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)createGroup:(NSString *)title users:(NSArray *)users completion:(BlogGroupBOOLCompletion)completion {
    [TelegramManager.shareInstance BlogUserGroupCreate:title users:users result:^(NSDictionary *request, NSDictionary *response) {
//        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
//        !completion ? : completion(isSuccess);
        } timeout:^(NSDictionary *request) {
            !completion ? : completion(NO);
        }];
}

+ (void)deleteGroup:(NSInteger)ids completion:(BlogGroupBOOLCompletion)completion {
    [TelegramManager.shareInstance BlogUserGroupDelete:(int)ids result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}


@end
