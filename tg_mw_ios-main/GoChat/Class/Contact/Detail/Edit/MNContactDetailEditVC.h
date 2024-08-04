//
//  MNContactDetailEditVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactDetailEditVC : BaseTableVC

@property (nonatomic) long chatId;
@property (nonatomic, copy) NSString *prevValueString;
@property (nonatomic, strong) UserInfo *toBeModifyUser;

@end

NS_ASSUME_NONNULL_END
