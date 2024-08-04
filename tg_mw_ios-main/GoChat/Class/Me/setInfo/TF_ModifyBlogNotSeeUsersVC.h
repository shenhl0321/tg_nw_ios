//
//  TF_ModifyBlogNotSeeUsersVC.h
//  GoChat
//
//  Created by apple on 2022/2/7.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface TF_ModifyBlogNotSeeUsersVC : BaseTableVC
/// 用户id数组
@property (nonatomic,strong) NSArray *userIds;
/// 是否添加
@property (nonatomic,assign) BOOL isAdding;
/// 1 - 不让谁看  2 - 不看谁
@property (nonatomic,assign) NSInteger type;
/// <#code#>
@property (nonatomic,copy) void(^changeCall)(void);
@end

NS_ASSUME_NONNULL_END
