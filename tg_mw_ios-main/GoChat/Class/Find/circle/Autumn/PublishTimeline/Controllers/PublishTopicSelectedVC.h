//
//  PublishTopicSelectedVC.h
//  GoChat
//
//  Created by Autumn on 2022/3/1.
//

#import "DYTableViewController.h"
#import "BlogTopic.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TopicSelectedDelegate <NSObject>

@optional
- (void)selectedTopic:(BlogTopic *)topic;
- (void)topicClose;

@end

typedef void(^TopicSelectedBlock)(BlogTopic *topic);
@interface PublishTopicSelectedVC : DYTableViewController

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, weak) id<TopicSelectedDelegate> delegate;

- (void)hide;

@property (nonatomic, copy) TopicSelectedBlock block;

@end

NS_ASSUME_NONNULL_END
