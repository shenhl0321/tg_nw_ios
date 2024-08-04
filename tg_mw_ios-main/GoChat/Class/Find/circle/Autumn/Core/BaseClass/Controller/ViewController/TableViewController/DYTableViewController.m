//
//  DYTableViewController.m
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "DYTableViewController.h"

@interface DYTableViewController ()

@end

@implementation DYTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dy_initData {
    [super dy_initData];
    _style = UITableViewStylePlain;
    
    self.emptyImageName = @"icon_nosearchdata";
    self.emptyTitle = @"暂无数据~".lv_localized;
}

- (void)dy_initUI {
    [super dy_initUI];
    [self.view addSubview:self.tableView];
}

- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *items = self.dataArray[section];
    return items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DYTableViewCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    DYTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellIdentifier forIndexPath:indexPath];
    cell.item = item;
    if (self.isHideSectionLastCellLine && !cell.hideSeparatorLabel) {
        NSMutableArray *items = self.dataArray[indexPath.section];
        cell.hideSeparatorLabel = items.count == indexPath.row + 1;
    }
    @weakify(self);
    cell.responseBlock = ^{@strongify(self); [self dy_cellResponse:item indexPath:indexPath];};
    return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return ({
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return ({
        UIView *view = [[UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DYTableViewCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    if (item.cellHeight > 0) {
        return item.cellHeight;
    }else {
        HYBCacheHeight cache = nil;
        if (item.cacheKey) {
            cache = ^NSDictionary *{
                return @{kHYBCacheUniqueKey: item.cacheKey, kHYBCacheStateKey: item.cacheKey};
            };
        }
        return [item.cellClass hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
            DYTableViewCell *cell = (DYTableViewCell *)sourceCell;
            cell.item = item;
        } cache:cache];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor xhq_assist];
    attributes[NSFontAttributeName] = [UIFont xhq_font14];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.emptyTitle attributes:attributes];
    return attributedString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:self.emptyImageName];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return self.tableView.backgroundColor;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -100.f;
}

#pragma mark - DZNEmptyDataSetDelegate
- (void)emptyDataSetWillAppear:(UIScrollView *)scrollView {
    scrollView.contentOffset = CGPointZero;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}


#pragma mark - configureData
- (void)dy_configureData {
    
}

- (void)dy_configureDataWithModel:(DYModel *)model {
    
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = CGRectMake(0, kNavigationStatusHeight(), kScreenWidth(), kScreenHeight() - kNavigationStatusHeight());
        _tableView = [[UITableView alloc] initWithFrame:frame style:_style];
        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            self->_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        });
        
        [_tableView xhq_registerCell:[DYTableViewCell class]];
        _tableView.backgroundColor = [UIColor xhq_section];
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth(), CGFLOAT_MIN)];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
    }
    return _tableView;
}

- (NSMutableArray *)sectionArray0 {
    if (!_sectionArray0) {
        _sectionArray0 = [[NSMutableArray alloc]init];
    }
    return _sectionArray0;
}

- (NSMutableArray *)sectionArray1 {
    if (!_sectionArray1) {
        _sectionArray1 = [[NSMutableArray alloc]init];
    }
    return _sectionArray1;
}

- (NSMutableArray *)sectionArray2 {
    if (!_sectionArray2) {
        _sectionArray2 = [[NSMutableArray alloc]init];
    }
    return _sectionArray2;
}

- (NSMutableArray *)sectionArray3 {
    if (!_sectionArray3) {
        _sectionArray3 = [[NSMutableArray alloc]init];
    }
    return _sectionArray3;
}

- (NSMutableArray *)sectionArray4 {
    if (!_sectionArray4) {
        _sectionArray4 = [[NSMutableArray alloc]init];
    }
    return _sectionArray4;
}
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}


@end
