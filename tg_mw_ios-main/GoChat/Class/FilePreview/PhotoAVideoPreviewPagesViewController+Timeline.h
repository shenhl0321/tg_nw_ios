//
//  PhotoAVideoPreviewPagesViewController+Timeline.h
//  GoChat
//
//  Created by Autumn on 2022/1/3.
//

#import "PhotoAVideoPreviewPagesViewController.h"
#import "ChatChooseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoAVideoPreviewPagesViewController (Timeline)<ChatChooseViewControllerDelegate>

@property (nonatomic, assign, getter=isFromTimeline) BOOL fromTimeline;

- (NSArray *)timelineItems;

/// 转发
- (void)forward;

/// 收藏
- (void)collect;

@end

NS_ASSUME_NONNULL_END
