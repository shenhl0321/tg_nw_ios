//
//  BlogMessage.h
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "JWModel.h"
#import "BlogInfo.h"
#import "BlogReply.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlogMessage : JWModel
/// 动态
@property (nonatomic, strong) BlogInfo *blog;

/// 评论
@property (nonatomic, strong) BlogReply *reply;
@property (nonatomic, assign) NSInteger blog_id;

/// 点赞
@property (nonatomic, strong) BlogUserDate *user_date;
@property (nonatomic, strong) BlogId *bId;
/// 点赞的评论用户
@property (nonatomic, assign) NSInteger reply_user_id;


/// 用户id
- (NSInteger)userid;
/// 时间
- (NSString *)time;

- (NSString *)content;

/// 回复子评论，需要单独处理
- (BOOL)isSubReply;

- (void)subReplyContent:(void(^)(NSAttributedString *))result;

- (void)fetchBlogInfo:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
