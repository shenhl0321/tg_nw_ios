//
//  BaseTableVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "BaseVC.h"
#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableVC : BaseVC
<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, assign,readonly) UITableViewStyle style;
@property (nonatomic, strong) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
