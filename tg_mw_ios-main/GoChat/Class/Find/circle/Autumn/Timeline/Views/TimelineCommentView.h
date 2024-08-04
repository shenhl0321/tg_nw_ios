//
//  TimelineCommentView.h
//  GoChat
//
//  Created by Autumn on 2021/11/22.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineCommentView : DYView

- (void)commentBlog:(NSInteger)blogId;
- (void)commentReply:(NSInteger)replyId name:(NSString *)name;

/// 针对评论详情。
- (void)setCommentReplyId:(NSInteger)rId;
- (void)setCommentReplyName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
