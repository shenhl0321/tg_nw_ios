//
//  MNSubInfoMediaVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoMediaVC.h"
#import "MNSubInfoMediaCell.h"
#import "PlayAudioManager.h"
#import "PhotoAVideoPreviewPagesViewController.h"


@interface MNSubInfoMediaVC ()
<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation MNSubInfoMediaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView removeFromSuperview];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView registerClass:[MNSubInfoMediaCell class] forCellWithReuseIdentifier:NSStringFromClass([MNSubInfoMediaCell class])];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    self.collectionView.mj_footer = [self addFooterRefresh];

}

-(void)initDataCompleteFunc{
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView reloadData];
}
#pragma mark - collectionView -
#if 0
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(20, 15, 20, 15);
        flowLayout.minimumLineSpacing = 9;
        flowLayout.minimumInteritemSpacing = 9;
        NSInteger count = 3;
        CGFloat itemWidth = floorf((APP_SCREEN_WIDTH - 2*15 - 9*(count-1))/count);
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
       
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 100) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
        [_collectionView registerClass:[MNSubInfoMediaCell class] forCellWithReuseIdentifier:NSStringFromClass([MNSubInfoMediaCell class])];
      
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}
#endif
#pragma mark - collectionView相关代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MNSubInfoMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MNSubInfoMediaCell class]) forIndexPath:indexPath];
    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
    [cell fillDataWithMessageInfo:msg];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
    v.previewList = self.dataArray;
    v.curIndex = (int)indexPath.row;
    [tp_topMostViewController().navigationController pushViewController:v animated:YES];
}


@end
