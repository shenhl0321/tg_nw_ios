//
//  TimelineUserFollowHelper.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineUserFollowHelper.h"


@implementation TimelineUserFollowHelper

+ (void)fetchUserFollows:(NSInteger)userid completion:(UsersCompletion)completion {
    NSDictionary *params = @{
        @"@type": @"getBlogFollows", @"user_id": @(userid),
        @"offset": @0, @"limit": @9999
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogUserDates"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[@"user_dates"];
        NSArray *users = [BlogUserDate mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(users);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)fetchUserFans:(NSInteger)userid completion:(UsersCompletion)completion {
    NSDictionary *params = @{
        @"@type": @"getBlogFans", @"user_id": @(userid),
        @"offset": @0, @"limit": @9999
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogUserDates"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[@"user_dates"];
        NSArray *users = [BlogUserDate mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(users);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

@end
