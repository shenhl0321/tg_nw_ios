//
//  FriendCycleHelper.h
//  GoChat
//
//  Created by Autumn on 2021/11/2.
//

#import <Foundation/Foundation.h>
#import "BlogInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FriendCycleType) {
    FriendCycleType_Hot,
    FriendCycleType_Follow,
    FriendCycleType_Friend,
};

typedef void(^CycleListBlock)(NSArray <BlogInfo *>*blogs);

@interface FriendCycleHelper : NSObject

+ (void)queryCycleList:(FriendCycleType)type offset:(int)offset completion:(CycleListBlock)completion;

@end

NS_ASSUME_NONNULL_END
