//
//  MNContactDetailSearchVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNContactDetailSearchVC.h"
#import "MNContactSearchTextVC.h"
#import "MNSubInfoLinkVC.h"
#import "MNSubInfoMediaVC.h"
#import "MNSubInfoDocumentVC.h"

#import "MNContactDetailSearchCell.h"
#import "MNContactDetailSearchLayout.h"

#import "MNContactDetailSearchReusableView.h"
#import "NSString+Height.h"
#import "ChatHistorySearchRecord.h"

@interface MNContactDetailSearchVC ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
MNContactSearchBarDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *sizeArray;

@property (nonatomic, weak) MNContactDetailSearchLayout *layout;


@end

@implementation MNContactDetailSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"查找聊天内容".lv_localized];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self reloadData];
}

- (void)reloadData {
    _dataArray = [[ChatHistorySearchRecord getRecordsForChatId:self.chatId] mutableCopy];
    
    NSMutableArray *tempSize = [[NSMutableArray alloc] init];
    for (NSString *str in self.dataArray) {
        CGFloat width = [str widthWithfont:fontRegular(16)]+25;
        
        [tempSize addObject:[NSNumber numberWithFloat:width]];
    }
    self.sizeArray = tempSize;
    self.layout.maximumSpacing = _dataArray.count == 0 ? 0 : 15;
    self.layout.sectionInset = _dataArray.count == 0 ? UIEdgeInsetsMake(20, 0, 20, 15) : UIEdgeInsetsMake(20, 15, 20, 15);
}

- (void)fillData{
    
}

- (void)initUI{
    UILabel *aLabel = [[UILabel alloc] init];
    aLabel.textColor = [UIColor colorTextForA9B0BF];
    aLabel.font = fontRegular(15);
    aLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:aLabel];
}
#pragma mark collectionView -
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        MNContactDetailSearchLayout *flowLayout = [[MNContactDetailSearchLayout alloc] init];
        flowLayout.maximumSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
        flowLayout.minimumLineSpacing = 9;
        flowLayout.minimumInteritemSpacing = 9;
        self.layout = flowLayout;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 100) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
        _collectionView.alwaysBounceVertical = YES;
        [_collectionView registerClass:[MNContactDetailSearchCell class] forCellWithReuseIdentifier:NSStringFromClass([MNContactDetailSearchCell class])];
        [_collectionView registerClass:[MNContactDetailSearchReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([MNContactDetailSearchReusableView class])];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (void)searchText:(NSString *)text {
    [ChatHistorySearchRecord saveRecord:text forChatId:self.chatId];
    [self reloadData];
    [self.collectionView reloadData];
    MNContactSearchTextVC *result = [[MNContactSearchTextVC alloc] init];
    result.chatId = @(self.chatId);
    result.keyword = text;
    [self.navigationController pushViewController:result animated:YES];
}

- (void)clearData {
    [ChatHistorySearchRecord removeRecordsForChatId:self.chatId];
    [self reloadData];
    [self.collectionView reloadData];
}

- (void)showDetailWithIndex:(NSInteger)index {
    /// 链接
    if (index == 0) {
        MNSubInfoLinkVC *link = [[MNSubInfoLinkVC alloc] initWithUser:nil type:4];
        link.history = YES;
        link.chatId = self.chatId;
        [link.customNavBar setTitle:@"链接".lv_localized];
        [self.navigationController pushViewController:link animated:YES];
    }
    /// 媒体
    else if (index == 1) {
        MNSubInfoMediaVC *media = [[MNSubInfoMediaVC alloc] initWithUser:nil type:1];
        media.history = YES;
        media.chatId = self.chatId;
        [media.customNavBar setTitle:@"媒体".lv_localized];
        [self.navigationController pushViewController:media animated:YES];
    }
    /// 文件
    else if (index == 2) {
        MNSubInfoDocumentVC *doc = [[MNSubInfoDocumentVC alloc] initWithUser:nil type:2];
        doc.history = YES;
        doc.chatId = self.chatId;
        [doc.customNavBar setTitle:@"文件".lv_localized];
        [self.navigationController pushViewController:doc animated:YES];
    }
}

#pragma mark - MNContactSearchBarDelegate
- (void)searchBar:(ContactSearchBar *)bar textFieldShouldReturn:(UITextField *)textField {
    [self searchText:textField.text];
}

#pragma mark - collectionView相关代理
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    MNContactDetailSearchReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([MNContactDetailSearchReusableView class]) forIndexPath:indexPath];
    header.searchBar.delegate = self;
    [header.clearBtn addTarget:self action:@selector(clearData) forControlEvents:UIControlEventTouchUpInside];
    @weakify(self);
    header.block = ^(NSInteger index) {
        @strongify(self);
        [self showDetailWithIndex:index];
    };
    return header;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MNContactDetailSearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MNContactDetailSearchCell class]) forIndexPath:indexPath];
    cell.aLabel.text = self.dataArray[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSString *text = self.dataArray[indexPath.row];
    [self searchText:text];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = [self.sizeArray[indexPath.row] floatValue];
    return CGSizeMake(width, 41);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(APP_SCREEN_WIDTH, 303);
}



@end
