//
//  MNNotificationSetCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/29.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNNotificationSetCell : BaseTableCell
@property (nonatomic, strong) UIImageView *iconTipNotice;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *btn;
@end

NS_ASSUME_NONNULL_END
