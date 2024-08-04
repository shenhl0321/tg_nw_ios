//
//  UserTimelineHelper.h
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import <Foundation/Foundation.h>
#import "BlogUserInfo.h"
#import "BlogInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BlogUserinfoCompletion)(BlogUserInfo *info);
typedef void(^BlogsCompletion)(NSArray <BlogInfo *>*blogs);
typedef void(^DescriptionCompletion)(NSString *desc);

@interface UserTimelineHelper : NSObject

+ (void)fetchBlogUserinfo:(NSInteger)userid completion:(BlogUserinfoCompletion)completion;

+ (void)fetchUserBlogs:(NSInteger)userid offset:(int)offset completion:(BlogsCompletion)completion;

+ (void)fetchUserBlogs:(NSInteger)userid offset:(int)offset limit:(int)limit completion:(BlogsCompletion)completion;

+ (void)fetchUserDesc:(NSInteger)userid completion:(DescriptionCompletion)completion;

@end

NS_ASSUME_NONNULL_END
