//
//  QTChooseFriendCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface QTChooseFriendCell : BaseTableCell

@property (nonatomic,strong) UIImageView *iconImagV;
@property (nonatomic, strong) UILabel *titleLabel;
/// 是否处于编辑状态（默认不是编辑状态）
@property (assign, nonatomic) BOOL isEdit;

- (void)resetUserInfo:(UserInfo *)user;
- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask;
- (void)resetGroupInfo:(ChatInfo *)chat;
- (void)resetChatInfo:(id)chat;
@end

NS_ASSUME_NONNULL_END
