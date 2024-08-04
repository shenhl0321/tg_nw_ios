//
//  CZSedRegisterViewController.h
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^QTChangeLoginPasswordSuccessBlock)(void);
@interface QTChangeLoginPasswordVC : BaseVC
@property (nonatomic,assign) BOOL   hasPwd;

@property (strong, nonatomic) QTChangeLoginPasswordSuccessBlock successBlock;

@end

NS_ASSUME_NONNULL_END
