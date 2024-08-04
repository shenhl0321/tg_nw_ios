//
//  CallsSingleTableViewController.h
//  GoChat
//
//  Created by 李标 on 2021/5/22.
//  最近通话单个分类

#import "CA_HBaseViewController.h"
#import "BaseTableVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallsSingleTableViewController : CA_HBaseTableViewController

@property (nonatomic, assign) int type; // 0:呼入和呼出 1:呼出 2:呼入
@end

NS_ASSUME_NONNULL_END
