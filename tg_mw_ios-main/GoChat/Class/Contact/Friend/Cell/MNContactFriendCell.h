//
//  MNContactFriendCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/2.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactFriendCell : BaseTableCell
@property (nonatomic, strong) UIImageView *chooseImageView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *stateLabel;//记录最近是否上线
- (void)resetUserInfo:(UserInfo *)user;
- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask;
@end

NS_ASSUME_NONNULL_END
