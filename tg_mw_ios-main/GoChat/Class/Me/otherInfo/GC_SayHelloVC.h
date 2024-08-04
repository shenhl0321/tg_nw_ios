//
//  GC_SayHelloVC.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/7.
//

#import "BaseVC.h"
#import "ChatsNearby.h"

NS_ASSUME_NONNULL_BEGIN

@interface GC_SayHelloVC : BaseVC
@property (nonatomic,strong) ChatNearby *userInfo;
@end

NS_ASSUME_NONNULL_END
