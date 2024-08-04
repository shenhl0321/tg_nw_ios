//
//  BlogReply.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "BlogReply.h"

@implementation BlogReply

- (BOOL)isReplyBlog {
    return [self.blog_id.atType isEqualToString:@"inputBlogIdBlog"];
}

- (BOOL)isReplyReply {
    return [self.blog_id.atType isEqualToString:@"inputBlogIdReply"];
}

@end

@implementation BlogReplyId

@end
