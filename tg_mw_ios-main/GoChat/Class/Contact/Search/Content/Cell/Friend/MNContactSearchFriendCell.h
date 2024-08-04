//
//  MNContactSearchFriendCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactSearchFriendCell : BaseTableCell

@property (nonatomic,strong) UIImageView *iconImagV;
@property (nonatomic, strong) UILabel *titleLabel;

- (void)resetUserInfo:(UserInfo *)user;
- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask;
- (void)resetGroupInfo:(ChatInfo *)chat;
- (void)resetChatInfo:(id)chat;
@end

NS_ASSUME_NONNULL_END
