//
//  ChatUserControlCell.h
//  GoChat
//
//  Created by apple on 2021/12/22.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ChatUserControlCell : UITableViewCell
/// 用户信息
@property (nonatomic,strong) UserInfo *userInfo;

/// 聊天信息
@property (nonatomic,strong) ChatInfo *chatInfo;

/// 添加好友的回调
@property (nonatomic,copy) void(^callBack)(NSInteger type);

@end

NS_ASSUME_NONNULL_END
