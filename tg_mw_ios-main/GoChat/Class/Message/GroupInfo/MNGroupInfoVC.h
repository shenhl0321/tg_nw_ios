//
//  MNGroupInfoVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNGroupInfoVC : BaseTableVC
@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,strong) CZPermissionsModel *cusPermissionsModel;
//消息列表
@property (nonatomic, strong) NSMutableArray *messageList;
@end

NS_ASSUME_NONNULL_END
