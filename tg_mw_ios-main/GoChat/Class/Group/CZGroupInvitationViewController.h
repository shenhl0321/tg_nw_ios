//
//  CZGroupInvitationViewController.h
//  GoChat
//
//  Created by mac on 2021/7/9.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CZGroupInvitationViewController : BaseViewController
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic, strong) SuperGroupInfo *super_groupInfo;
@property (nonatomic, strong) SuperGroupFullInfo *super_groupFullInfo;
@end

NS_ASSUME_NONNULL_END
