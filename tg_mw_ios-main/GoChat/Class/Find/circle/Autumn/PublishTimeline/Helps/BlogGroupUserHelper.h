//
//  BlogGroupUserHelper.h
//  GoChat
//
//  Created by Autumn on 2021/11/6.
//

#import <Foundation/Foundation.h>
#import "BlogUserGroup.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlogGroupListBlock)(NSArray <BlogUserGroup *>*groups);

typedef void(^BlogGroupBOOLCompletion)(BOOL success);

@interface BlogGroupUserHelper : NSObject

+ (void)queryGroupsCompletion:(BlogGroupListBlock)completion;

+ (void)createGroup:(NSString *)title users:(NSArray *)users completion:(BlogGroupBOOLCompletion)completion;

+ (void)deleteGroup:(NSInteger)ids completion:(BlogGroupBOOLCompletion)completion;

@end

NS_ASSUME_NONNULL_END
