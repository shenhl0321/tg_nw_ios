//
//  JoinChatInviteLinkViewController.h
//  GoChat
//
//  Created by mac on 2021/7/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JoinChatInviteLinkViewController : UIViewController
@property (nonatomic,strong) NSString *inviteLink;
@property (nonatomic,strong) ChatInviteLinkInfo *inviteInfo;
@end

NS_ASSUME_NONNULL_END
