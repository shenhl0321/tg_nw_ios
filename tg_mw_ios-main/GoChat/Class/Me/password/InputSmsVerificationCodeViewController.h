//
//  InputSmsVerificationCodeViewController.h
//  GoChat
//
//  Created by wangyutao on 2020/10/27.
//

#import "BaseViewController.h"
#import "BaseTableVC.h"

@interface InputSmsVerificationCodeViewController : BaseTableVC
@property (nonatomic, strong) NSString *curCountryCode;
@property (nonatomic, strong) NSString *curPhone;
@end
