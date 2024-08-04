//
//  MNEditGroupViewController.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/14.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNEditGroupViewController : BaseTableVC
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,strong) CZPermissionsModel *cusPermissionsModel;
@end

NS_ASSUME_NONNULL_END
