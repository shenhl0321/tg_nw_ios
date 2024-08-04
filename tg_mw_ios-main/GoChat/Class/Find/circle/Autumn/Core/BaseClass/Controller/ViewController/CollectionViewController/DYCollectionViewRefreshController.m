//
//  DYCollectionViewRefreshController.m
//  FirePlatform
//
//  Created by 帝云科技 on 2019/9/1.
//  Copyright © 2019 帝云科技. All rights reserved.
//

#import "DYCollectionViewRefreshController.h"
#import "MJRefresh.h"

@interface DYCollectionViewRefreshController ()

@end

NSString *const kCollectionCurrentPageValue = @"0";

@implementation DYCollectionViewRefreshController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dy_initData {
    [super dy_initData];
    self.currentPage = kCollectionCurrentPageValue;
    self.addLoadFooter = NO;
    self.addRefreshHeader = YES;
    self.dropdownRefresh = YES;
}

- (void)dy_initUI {
    [super dy_initUI];
    
    @weakify(self);
    if (self.isAddRefreshHeader) {
        [self.collectionView xhq_refreshHeaderBlock:^{
            @strongify(self);
            [self dy_refresh];
        }];
    }
    if (self.isAddLoadFooter) {
        [self.collectionView xhq_refreshFooterBlock:^{
            @strongify(self);
            [self dy_load];
        }];
        [self dy_hiddenFooter];
    }
}


- (void)dy_refresh {
    self.currentPage = kCollectionCurrentPageValue;
    self.dropdownRefresh = YES;
    [self dy_request];
}

- (void)dy_load {
    self.currentPage = [NSString stringWithFormat:@"%ld", self.currentPage.integerValue + 1];
    [self dy_request];
}

- (void)dy_stopRefresh {
    [self.collectionView xhq_stopRefresh];
}

- (void)dy_collectionViewReloadData {
    [self dy_stopRefresh];
    [self.collectionView reloadData];
    [self dy_footerWithNoMoreData];
    [self dy_hiddenFooter];
    if (self.isDropdownRefresh) {
        self.dropdownRefresh = !self.isDropdownRefresh;
    }
}

#pragma mark - 修改footer显示状态
- (void)dy_footerWithNoMoreData {
    if (!self.isAddLoadFooter) {
        return;
    }
    if (_currentPage.integerValue >= _totalPage.integerValue) {
        [self.collectionView xhq_footerWithNoMoreData];
    }else {
        [self.collectionView xhq_footerResetNoMoreData];
    }
}

#pragma mark - 隐藏上拉加载
- (void)dy_hiddenFooter {
    [self dy_hiddenFooter:self.dataArray];
}

- (void)dy_hiddenFooter:(NSArray *)datas {
    BOOL hidden = NO;
    if (datas.count > 0) {
        id firstObj = datas.lastObject;
        if ([firstObj isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *array = (NSMutableArray *)firstObj;
            hidden = array.count == 0;
        }
    }else {
        hidden = YES;
    }
    [self.collectionView.mj_footer setHidden:hidden];
}

#pragma mark - 清除数据源
- (void)dy_refreshClearData {
    [self dy_refreshClearWithData:self.dataArray];
}

- (void)dy_refreshClearWithData:(NSMutableArray *)data {
    if (self.isDropdownRefresh) {
        NSMutableArray *temp = data ? : self.dataArray;
        [temp removeAllObjects];
        self.dropdownRefresh = !self.isDropdownRefresh;
    }
}

@end
