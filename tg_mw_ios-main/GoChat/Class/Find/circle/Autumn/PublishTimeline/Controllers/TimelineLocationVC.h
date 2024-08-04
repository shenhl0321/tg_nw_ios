//
//  TimelineLocationVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/17.
//

#import "DYTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PublishTimelineLocation;

@interface TimelineLocationVC : DYTableViewController

@property (nonatomic, strong, nullable) PublishTimelineLocation *location;

@property (nonatomic, copy) dispatch_block_t block;

@end

NS_ASSUME_NONNULL_END
