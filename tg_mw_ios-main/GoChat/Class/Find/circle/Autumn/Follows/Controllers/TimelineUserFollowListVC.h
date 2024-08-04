//
//  TimelineUserFollowListVC.h
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "DYRefreshViewController.h"
#import "JXCategoryView.h"

typedef NS_ENUM(NSUInteger, TimelineUserFollowType) {
    TimelineUserFollowType_Follows,
    TimelineUserFollowType_Fans,
};

NS_ASSUME_NONNULL_BEGIN

@interface TimelineUserFollowListVC : DYRefreshViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, assign) NSInteger userid;

@property (nonatomic, assign) TimelineUserFollowType type;

@property (nonatomic, copy) NSString *keyword;

@end

NS_ASSUME_NONNULL_END
