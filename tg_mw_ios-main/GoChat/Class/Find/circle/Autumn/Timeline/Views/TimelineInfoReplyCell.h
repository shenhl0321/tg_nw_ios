//
//  TimelineInfoReplyCell.h
//  GoChat
//
//  Created by Autumn on 2021/11/19.
//

#import "DYTableViewCell.h"
#import "TimelineHelper.h"

NS_ASSUME_NONNULL_BEGIN



@interface TimelineInfoReplyCellItem : DYTableViewCellItem

/// 子回复
@property (nonatomic, assign, getter=isSubRepay) BOOL subRepay;

/// 评论详情页
@property (nonatomic, assign, getter=isReplyInfo) BOOL replyInfo;

@property (nonatomic, assign) RepayListDisplayMode displayMode;

/// 子回复数量
@property (nonatomic, assign) NSInteger subRepayNumber;

/// 当前 item 所在 section 显示的 cell 数量
@property (nonatomic, assign, readonly) NSInteger showNumber;


@property (nonatomic, copy, readonly) NSString *username;

@end

@interface TimelineInfoReplyCell : DYTableViewCell

@end

NS_ASSUME_NONNULL_END
