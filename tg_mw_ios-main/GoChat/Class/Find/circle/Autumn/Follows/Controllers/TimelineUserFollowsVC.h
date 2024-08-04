//
//  TimelineUserFollowsVC.h
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "DYViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineUserFollowsVC : DYViewController

@property (nonatomic, assign) NSInteger userid;

/// 位置 0：关注、1：粉丝
@property (nonatomic, assign) NSInteger selectIndex;

@end

NS_ASSUME_NONNULL_END
