//
//  MNContactDetailVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactDetailVC : BaseTableVC

@property (nonatomic, strong) UserInfo *user;

@property (nonatomic) BOOL toShowInvidePath;
@property (nonatomic) long chatId;
/// 此为群组功能
@property (nonatomic) BOOL blockContact;
/// 是否添加好友
@property (nonatomic) BOOL isAddFriend;

@end

NS_ASSUME_NONNULL_END
