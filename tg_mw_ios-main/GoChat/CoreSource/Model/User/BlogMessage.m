//
//  BlogMessage.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "BlogMessage.h"
#import "TimeFormatting.h"
#import "UserinfoHelper.h"
#import "TimelineHelper.h"

@implementation BlogMessage

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
        @"atType": @"@type",
        @"extra": @"@extra",
        @"bId": @"id"
    };
}

- (BOOL)isLikeMessage {
    return [self.atType isEqualToString:@"blogMessageLiked"] && self.bId.blog_id > 0;
}

- (BOOL)isLikeReply {
    return [self.atType isEqualToString:@"blogMessageLiked"] && self.bId.reply_id > 0;
}

- (BOOL)isBlogMessage {
    return [self.atType isEqualToString:@"blogMessageBlog"];
}

- (BOOL)isReplyMessage {
    return [self.atType isEqualToString:@"blogMessageReply"];
}


- (NSInteger)userid {
    if (self.isBlogMessage) {
        return self.blog.user_id;
    }
    else if (self.isLikeMessage || self.isLikeReply) {
        return self.user_date.user_id;
    }
    else if (self.isReplyMessage) {
        return self.reply.user_id;
    }
    return 0;
}

- (NSInteger)_blogId {
    if (self.blog_id > 0) {
        return self.blog_id;
    }
    if (self.isBlogMessage) {
        return self.blog.ids;
    }
    else if (self.isLikeMessage) {
        return self.bId.blog_id;
    }
    else if (self.isReplyMessage) {
        return self.blog_id;
    }
    return 0;
}

- (NSString *)time {
    NSInteger timestamp = 0;
    if (self.isBlogMessage) {
        timestamp = self.blog.date;
    }
    else if (self.isLikeMessage || self.isLikeReply) {
        timestamp = self.user_date.date;
    }
    else if (self.isReplyMessage) {
        timestamp = self.reply.date;
    }
    return [TimeFormatting formatTimeWithTimeInterval:timestamp];
}

- (NSString *)content {
    if (self.isBlogMessage) {
        return @"发布了一个新动态 提到了你".lv_localized;
    }
    else if (self.isLikeMessage) {
        return @"点赞了你的动态".lv_localized;
    }
    else if (self.isLikeReply) {
        return [NSString stringWithFormat:@"点赞了%ld的评论".lv_localized, self.reply_user_id];
    }
    else if (self.isReplyMessage) {
        if (self.reply.isReplyBlog) {
            return [NSString stringWithFormat:@"评论了你的动态：%@".lv_localized, self.reply.text];
        }
        return [NSString stringWithFormat:@"回复了%ld：%@".lv_localized, self.reply.reply_user_id, self.reply.text];
    }
    return @"";
}

- (BOOL)isSubReply {
    return self.isReplyMessage && self.reply.isReplyReply;
}

- (void)subReplyContent:(void(^)(NSAttributedString *))result {
    if (self.isSubReply) {
        [UserinfoHelper getUsernames:@[@(self.reply.reply_user_id)] completion:^(NSArray * _Nonnull names) {
            NSString *name = names.firstObject;
            NSString *content = [NSString stringWithFormat:@"回复了%@：%@".lv_localized, name, self.reply.text];
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:content];
            [attribute setAttributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium],
                NSForegroundColorAttributeName: HEX_COLOR(@"#00C69B")}
                               range:NSMakeRange(3, name.length)];
            !result ? : result(attribute);
        }];
        return;
    }
    if (self.isLikeReply) {
        [UserinfoHelper getUsernames:@[@(self.reply_user_id)] completion:^(NSArray * _Nonnull names) {
            NSString *name = names.firstObject;
            NSString *content = [NSString stringWithFormat:@"点赞了%@的评论".lv_localized, name];
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:content];
            [attribute setAttributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium],
                NSForegroundColorAttributeName: HEX_COLOR(@"#00C69B")}
                               range:NSMakeRange(3, name.length)];
            !result ? : result(attribute);
        }];
        return;
    }
}

- (void)fetchBlogInfo:(dispatch_block_t)completion {
    if (self.blog) {
        !completion ? : completion();
        return;
    }
    [TimelineHelper queryTimelineInfo:self._blogId completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        if (blogs.count > 0) {
            self.blog = blogs.firstObject;
        }
        !completion ? : completion();
    }];
}

@end
