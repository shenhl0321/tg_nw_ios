//
//  CZShowAllMemberViewController.h
//  GoChat
//
//  Created by mac on 2021/7/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZShowAllMemberViewController : BaseTableVC

@property (nonatomic, strong) ChatInfo *chatInfo;
@property (nonatomic,strong) CZPermissionsModel *cusPermissionsModel;

@end

NS_ASSUME_NONNULL_END
