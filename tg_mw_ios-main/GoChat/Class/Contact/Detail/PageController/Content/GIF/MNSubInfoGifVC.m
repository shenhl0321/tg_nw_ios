//
//  MNSubInfoGifVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoGifVC.h"
#import "MNSubInfoGifCell.h"
#import "PhotoAVideoPreviewPagesViewController.h"

@interface MNSubInfoGifVC ()
<UICollectionViewDelegate,UICollectionViewDataSource>
//@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation MNSubInfoGifVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView removeFromSuperview];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView registerClass:[MNSubInfoGifCell class] forCellWithReuseIdentifier:NSStringFromClass([MNSubInfoGifCell class])];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
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
        [_collectionView registerClass:[MNSubInfoGifCell class] forCellWithReuseIdentifier:NSStringFromClass([MNSubInfoGifCell class])];
      
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
    MNSubInfoGifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MNSubInfoGifCell class]) forIndexPath:indexPath];
    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
    [cell fillDataWithMessageInfo:msg];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
    if(msg.messageType == MessageType_Animation){
        PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
        v.previewList = @[msg];
        v.curIndex = 0;
        [tp_topMostViewController().navigationController pushViewController:v animated:YES];
    }
    
}


@end
