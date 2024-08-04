//
//  MNContactSearchChatCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactSearchChatCell : BaseTableCell
@property (nonatomic,strong) UIImageView *iconImagV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

- (void)resetMessageInfo:(MessageInfo *)info;
@end

NS_ASSUME_NONNULL_END
