//
//  TimelineReplyVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "DYRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class BlogReply;
@interface TimelineReplyVC : DYRefreshViewController

@property (nonatomic, strong) BlogReply *reply;

@end

NS_ASSUME_NONNULL_END
