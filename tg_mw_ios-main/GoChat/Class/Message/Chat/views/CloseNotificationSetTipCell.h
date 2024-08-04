//
//  CloseNotificationSetTipCell.h
//  GoChat
//
//  Created by wangyutao on 2021/2/22.
//

#import <UIKit/UIKit.h>

@class CloseNotificationSetTipCell;
@protocol CloseNotificationSetTipCellDelegate <NSObject>
@optional
//- (void)CloseNotificationSetTipCell_Remove:(CloseNotificationSetTipCell *)view;
@end

@interface CloseNotificationSetTipCell : UITableViewCell
@property (nonatomic, weak) id<CloseNotificationSetTipCellDelegate> delegate;
@end
