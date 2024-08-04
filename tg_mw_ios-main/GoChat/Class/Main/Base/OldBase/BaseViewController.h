//
//  BaseViewController.h
//
//  Created by wang yutao on 15/3/5.
//  Copyright (c) 2015年 wangyutao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "BaseTableVC.h"
#import "EmptyView.h"

@interface BaseViewController : UIViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@property (nonatomic) BOOL isLoadMore;
@property (nonatomic) BOOL needLoadMore;
- (void)stopLoadMore;

//空页面
@property (nonatomic, strong) EmptyView *emptyView;

- (void)gotoBack;
@end

@interface BaseTableViewController : UITableViewController

@property (nonatomic) BOOL isLoadMore;
@property (nonatomic) BOOL needLoadMore;
- (void)stopLoadMore;

//空页面
@property (nonatomic, strong) EmptyView *emptyView;
- (EmptyView *)emptyViewForShare;
@end
