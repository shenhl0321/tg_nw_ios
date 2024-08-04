//
//  CA_HBaseViewController.h
//  InvestNote_iOS
//
//  Created by wf on 2017/11/20.
//  Copyright © 2017年 wf. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseVC.h"
#import "BaseTableVC.h"
#import "EmptyView.h"

@interface CA_HBaseViewController : BaseVC

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@property (nonatomic) BOOL isLoadMore;
@property (nonatomic) BOOL needLoadMore;
- (void)stopLoadMore;

//空页面
@property (nonatomic, strong) EmptyView *emptyView;

- (void)gotoBack;
@end

@interface CA_HBaseTableViewController : BaseTableVC

@property (nonatomic) BOOL isLoadMore;
@property (nonatomic) BOOL needLoadMore;
- (void)stopLoadMore;

//空页面
@property (nonatomic, strong) EmptyView *emptyView;
- (EmptyView *)emptyViewForShare;
@end
