//
//  GC_SetPwInputPwAgainVC.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GC_SetPwInputPwAgainVC : BaseVC
@property (nonatomic, copy) NSString *smsCode;
@property (nonatomic, copy) NSString *oldpwdstr;
@property (nonatomic, copy) NSString *password;
@end

NS_ASSUME_NONNULL_END
