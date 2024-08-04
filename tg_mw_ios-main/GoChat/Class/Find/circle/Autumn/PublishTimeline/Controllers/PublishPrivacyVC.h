//
//  PublishPrivacyVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/5.
//

#import "DYTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PublishTimeline;
@interface PublishPrivacyVC : DYTableViewController

@property (nonatomic, strong) PublishTimeline *timeline;

@property (nonatomic, copy) dispatch_block_t confirmBlock;

@end

NS_ASSUME_NONNULL_END
