//
//  TF_BlogNotSeeUsersVC.h
//  GoChat
//
//  Created by apple on 2022/2/7.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface TF_BlogNotSeeUsersVC : BaseVC

/// 类型 1-不让谁看 2 - 不看谁
@property (nonatomic,assign) NSInteger type;
/// 用户id数组
@property (nonatomic,strong) NSArray *userIds;
/// <#code#>
@property (nonatomic,copy) void(^changeCall)(void);
@end

NS_ASSUME_NONNULL_END
