//
//  GC_SetPwInputNewPwVC.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface GC_SetPwInputNewPwVC : BaseVC
@property (nonatomic,assign)    BOOL    isChange;
@property (nonatomic, copy) NSString *oldpwdstr;
@property (nonatomic, copy) NSString *smsCode;
@end

NS_ASSUME_NONNULL_END
