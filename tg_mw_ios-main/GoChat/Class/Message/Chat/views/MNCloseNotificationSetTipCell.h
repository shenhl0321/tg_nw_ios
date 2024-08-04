//
//  MNCloseNotificationSetTipCell.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/7.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN
@class MNCloseNotificationSetTipCell;
@protocol MNCloseNotificationSetTipCellDelegate <NSObject>
@optional
- (void)CloseNotificationSetTipCell_Remove:(MNCloseNotificationSetTipCell *)view;
@end

@interface MNCloseNotificationSetTipCell : BaseTableCell

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *aLabel;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, weak) id<MNCloseNotificationSetTipCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
