//
//  GC_OtherPersonalInfoVC.h
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "BaseTableVC.h"
#import "ChatsNearby.h"

NS_ASSUME_NONNULL_BEGIN

@interface GC_OtherPersonalInfoVC : BaseTableVC

@property (nonatomic,strong) ChatNearby *userInfo;
@end

NS_ASSUME_NONNULL_END
