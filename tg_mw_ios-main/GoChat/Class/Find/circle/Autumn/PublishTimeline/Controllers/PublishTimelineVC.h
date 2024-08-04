//
//  PublishTimelineVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "DYCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class PublishTimeline;
@interface PublishTimelineVC : DYCollectionViewController

@property (nonatomic, strong) PublishTimeline *timeline;

@property (nonatomic, strong) NSMutableArray *selectedAssets;

@end

NS_ASSUME_NONNULL_END
