//
//  MNGroupInfoTopCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "BaseTableCell.h"
#import "ASwitch.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNGroupInfoTopCell : BaseTableCell
@property (nonatomic, strong) UILabel *lcLabel;
@property (nonatomic, strong) ASwitch *rcSwitch;

@end

NS_ASSUME_NONNULL_END
