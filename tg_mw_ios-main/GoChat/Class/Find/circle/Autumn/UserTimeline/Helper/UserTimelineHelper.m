//
//  UserTimelineHelper.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineHelper.h"

@implementation UserTimelineHelper

+ (void)fetchBlogUserinfo:(NSInteger)userid completion:(BlogUserinfoCompletion)completion {
    NSDictionary *params = @{@"@type": @"getBlogUser", @"user_id": @(userid)};
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogUserInfo"]) {
            !completion ? : completion(BlogUserInfo.new);
            return;
        }
        BlogUserInfo *info = [BlogUserInfo mj_objectWithKeyValues:response];
        !completion ? : completion(info);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(BlogUserInfo.new);
    }];
}


+ (void)fetchUserBlogs:(NSInteger)userid offset:(int)offset completion:(BlogsCompletion)completion {
    NSDictionary *params = @{
        @"@type": @"getHistory",
        @"from_blog_id": @(offset),
        @"visible": @{@"@type": @"visibleTypeUser", @"user_id": @(userid)},
        @"offset": @(0),
        @"limit": @20
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogs"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[@"blogs"];
        NSArray<BlogInfo *> *blogs = [BlogInfo mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(blogs);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)fetchUserBlogs:(NSInteger)userid offset:(int)offset limit:(int)limit completion:(BlogsCompletion)completion {
    NSDictionary *params = @{
        @"@type": @"getHistory",
        @"from_blog_id": @(offset),
        @"visible": @{@"@type": @"visibleTypeUser", @"user_id": @(userid)},
        @"offset": @(0),
        @"limit": @(limit)
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogs"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[@"blogs"];
        NSArray<BlogInfo *> *blogs = [BlogInfo mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(blogs);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)fetchUserDesc:(NSInteger)userid completion:(DescriptionCompletion)completion {
    [TelegramManager.shareInstance requestContactFullInfo:userid resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:[UserFullInfo class]]) {
            UserFullInfo *full = (UserFullInfo *)obj;
            !completion ? : completion(full.bio);
            return;
        }
        !completion ? : completion(@"");
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@"");
    }];
}

@end
