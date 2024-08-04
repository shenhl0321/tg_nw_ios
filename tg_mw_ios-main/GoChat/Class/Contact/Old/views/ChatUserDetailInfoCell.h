//
//  ChatUserDetailInfoCell.h
//  GoChat
//
//  Created by apple on 2021/12/22.
//

#import <UIKit/UIKit.h>



@interface ChatUserDetailInfoCell : UITableViewCell


/// 点击按钮的回调
@property (nonatomic,copy) void(^callBack)(UIView *view) ;

/// 用户信息
@property (nonatomic,strong) UserInfo *userInfo;

/// 聊天信息
@property (nonatomic,strong) ChatInfo *chatInfo;

@property (nonatomic, strong) OrgUserInfo *orgUserInfo;

@end

