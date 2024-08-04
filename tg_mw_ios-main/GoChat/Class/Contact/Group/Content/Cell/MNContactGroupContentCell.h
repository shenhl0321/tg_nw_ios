//
//  MNContactGroupContentCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactGroupContentCell : BaseTableCell
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *titleLabel;
- (void)resetGroupInfo:(ChatInfo *)chat;

@end

NS_ASSUME_NONNULL_END
