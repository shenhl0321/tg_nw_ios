//
//  DYRefreshViewController.h
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const kCurrentPageValue;

@interface DYRefreshViewController : DYTableViewController


/** 当前分页数 */
@property (nonatomic, copy) NSString *currentPage;
/** 总分页数 */
@property (nonatomic, copy) NSString *totalPage;

/** 是否进行了下拉刷新 */
@property (nonatomic, assign, getter=isDropdownRefresh) BOOL dropdownRefresh;

/** 是否添加上拉加载 默认: NO */
@property (nonatomic, assign, getter=isAddLoadFooter) BOOL addLoadFooter;

/** 是否添加上拉加载 默认: YES */
@property (nonatomic, assign, getter=isAddRefreshHeader) BOOL addRefreshHeader;


/** 下拉刷新调用 */
- (void)dy_refresh;
/** 上拉加载调用 */
- (void)dy_load;
/** 停止刷新加载动画 */
- (void)dy_stopRefresh;

/** 请求数据结束 下拉刷新要清空数据源 */
- (void)dy_refreshClearData;
- (void)dy_refreshClearWithData:(NSMutableArray *)data;

/** 请求数据结束 刷新页面 重置布局 */
- (void)dy_tableViewReloadData;


/** 根据数据判断是否需要隐藏上拉加载 */
- (void)dy_hiddenFooter:(NSArray *)datas;

@end

NS_ASSUME_NONNULL_END
