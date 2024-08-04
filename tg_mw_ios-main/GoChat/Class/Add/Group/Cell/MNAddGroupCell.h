//
//  MNAddGroupCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNAddGroupCell : BaseTableCell
@property (nonatomic, strong) UIImageView *chooseImageView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *titleLabel;
- (void)resetUserInfo:(UserInfo *)user;
- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask;
@end

NS_ASSUME_NONNULL_END
