//
//  UserTimelineStatisticsCell.h
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "DYCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UserTimelineStatisticsType) {
    /// 动态
    UserTimelineStatisticsType_Blogs,
    /// 关注
    UserTimelineStatisticsType_Followed,
    /// 粉丝
    UserTimelineStatisticsType_Followers,
    /// 获赞
    UserTimelineStatisticsType_Liked,
};

@interface UserTimelineStatisticsCellItem : DYCollectionViewCellItem

@property (nonatomic, assign) UserTimelineStatisticsType type;

@property (nonatomic, assign) NSInteger number;

@property (nonatomic, copy, readonly) NSString *alertMessage;

@end

@interface UserTimelineStatisticsCell : DYCollectionViewCell

@end

NS_ASSUME_NONNULL_END
