//
//  MNLocationNavigationVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNLocationNavigationVC : BaseVC

@property (nonatomic) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, strong) MessageInfo *chatRecordDTO;

@end

NS_ASSUME_NONNULL_END
