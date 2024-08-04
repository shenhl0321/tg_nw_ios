
//
//  DYCollectionViewController.m
//  FireControl
//
//  Created by 帝云科技 on 2019/5/28.
//  Copyright © 2019 帝云科技. All rights reserved.
//

#import "DYCollectionViewController.h"

@interface DYCollectionViewController ()

@end

@implementation DYCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dy_initData {
    [super dy_initData];
    
    self.emptyImageName = @"pic_nodata";
    self.emptyTitle = @"暂无数据~".lv_localized;
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.view addSubview:self.collectionView];
}

- (void)dy_cellResponse:(__kindof DYCollectionViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSMutableArray *items = self.dataArray[section];
    return items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DYCollectionViewCellItem *item = self.dataArray[indexPath.section][indexPath.item];
    DYCollectionViewCell *cell = [collectionView xhq_dequeueCell:item.cellClass indexPath:indexPath];
    cell.item = item;
    @weakify(self);
    cell.responseBlock = ^{@strongify(self); [self dy_cellResponse:item indexPath:indexPath];};
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    DYCollectionViewCellItem *item = self.dataArray[indexPath.section][indexPath.item];
    return item.cellSize;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView xhq_dequeueHeaderView:[UICollectionReusableView class] indexPath:indexPath];
        header.backgroundColor = [UIColor colorTextForE5EAF0];
        return header;
    }
    UICollectionReusableView *footer = [collectionView xhq_dequeueFooterView:[UICollectionReusableView class] indexPath:indexPath];
    footer.backgroundColor = [UIColor colorTextForE5EAF0];
    return footer;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth() - 50, 0.01);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth() - 50, 0.01);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 11.0, *)) {
        if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            view.layer.zPosition = 0;
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor xhq_assist];
    attributes[NSFontAttributeName] = [UIFont regularCustomFontOfSize:14];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.emptyTitle attributes:attributes];
    return attributedString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:self.emptyImageName];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return self.collectionView.backgroundColor;
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
- (void)dy_configureData {}

- (void)dy_configureDataWithModel:(DYModel *)model {}


#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            self.collectionLayout = layout;
            layout;
        });
        _collectionView = ({
            CGRect frame = CGRectMake(0, kNavigationStatusHeight(), kScreenWidth(), kScreenHeight() - kNavigationStatusHeight());
            UICollectionView *collection = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
            collection.delegate = self;
            collection.dataSource = self;
            collection.backgroundColor = UIColor.whiteColor;
            [collection xhq_registerCell:[DYCollectionViewCell class]];
            [collection xhq_registerHeaderView:[UICollectionReusableView class]];
            [collection xhq_registerFooterView:[UICollectionReusableView class]];
            if (@available(iOS 11.0, *)) {
                collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            collection;
        });
    }
    return _collectionView;
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
