//
//  TimelineUserFollowHelper.h
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import <Foundation/Foundation.h>
#import "BlogInfo.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^UsersCompletion)(NSArray<BlogUserDate *> *users);

@interface TimelineUserFollowHelper : NSObject

+ (void)fetchUserFollows:(NSInteger)userid completion:(UsersCompletion)completion;

+ (void)fetchUserFans:(NSInteger)userid completion:(UsersCompletion)completion;

@end

NS_ASSUME_NONNULL_END
