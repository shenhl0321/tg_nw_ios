//
//  BlogReply.h
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@class BlogReplyId;
@interface BlogReply : JWModel

@property (nonatomic, strong) BlogReplyId *blog_id;
@property (nonatomic, assign) NSInteger date;
@property (nonatomic, assign) NSInteger like_count;
@property (nonatomic, assign) BOOL liked;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSInteger reply_count;
@property (nonatomic, assign) NSInteger reply_id;
@property (nonatomic, assign) NSInteger reply_user_id;
@property (nonatomic, assign) NSInteger user_id;

- (BOOL)isReplyBlog;
- (BOOL)isReplyReply;

@end

@interface BlogReplyId : JWModel

@property (nonatomic, assign) NSInteger blog_id;
@property (nonatomic, assign) NSInteger reply_id;

@end

NS_ASSUME_NONNULL_END
