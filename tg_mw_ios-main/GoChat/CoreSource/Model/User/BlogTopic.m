//
//  BlogTopic.m
//  GoChat
//
//  Created by Autumn on 2022/3/1.
//

#import "BlogTopic.h"

@implementation BlogTopic


+ (instancetype)topicWithKeyword:(NSString *)keyword {
    BlogTopic *topic = BlogTopic.model;
    topic.name = [NSString stringWithFormat:@"%@", keyword];
    topic.ranking = 0;
    return topic;
}

@end
