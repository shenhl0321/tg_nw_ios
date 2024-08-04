//
//  TF_SecreatChatTipV.h
//  GoChat
//
//  Created by apple on 2022/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TF_SecreatChatTipV : UIView
/// 用户信息
@property (nonatomic,strong) UserInfo *userInfo;
/// <#code#>
@property (nonatomic,strong) ChatInfo *chatInfo;
@end

NS_ASSUME_NONNULL_END
