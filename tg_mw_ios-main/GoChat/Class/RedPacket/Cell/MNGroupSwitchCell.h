//
//  MNGroupSwitchCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNGroupSwitchCell : BaseTableCell
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;

@end

NS_ASSUME_NONNULL_END
