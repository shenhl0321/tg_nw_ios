//
//  TimelineListCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "DYTableViewCell.h"
#import "TimelineHelper.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TimelineResponse) {
    TimelineResponse_Comment,
    TimelineResponse_Play,
    TimelineResponse_More,
    
    /// 点赞中
    TimelineResponse_Liking,
    /// 点赞结束
    TimelineResponse_Liked,
    /// 视频阅览
    TimelineResponse_BrowseVideo,
};

@interface TimelineListCellItem : DYTableViewCellItem

@property (nonatomic, assign, getter=isDisplayInDetail) BOOL displayInDetail;

@property (nonatomic, assign, readonly) TimelineResponse response;

@end

@interface TimelineListCell : DYTableViewCell

- (void)resetVideoThumbnail;
/// <#code#>
@property (nonatomic,copy) void(^photoCall)(TimelineListCell *cell, NSInteger index);
@end

NS_ASSUME_NONNULL_END
