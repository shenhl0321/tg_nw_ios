//
//  MNDetailDynamicView.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/15.
//

#import "MNDetailDynamicView.h"
#import "MNDetailDynamicCollectCell.h"
#import "MNDynamicFlowLayout.h"

@interface MNDetailDynamicView ()
<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation MNDetailDynamicView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}
-(void)fillDataWithArray:(NSMutableArray *)array{
    if (array) {
        _dataArray = array;
    }else{
        _dataArray = [[NSMutableArray alloc] init];
    }
    [self.collectionView reloadData];
}

- (void)initUI{
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        MNDynamicFlowLayout *flowLayout = [[MNDynamicFlowLayout alloc] init];
        flowLayout.maximumSpacing = 10;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 10, 15, 10);
//        flowLayout.minimumLineSpacing = 10;
//        flowLayout.minimumInteritemSpacing = 10;
//        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        flowLayout.itemSize = CGSizeMake(70, 70);
       
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH-82, 100) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.delaysContentTouches = false;
        [_collectionView registerClass:[MNDetailDynamicCollectCell class] forCellWithReuseIdentifier:NSStringFromClass([MNDetailDynamicCollectCell class])];
      
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _collectionView;
}

#pragma mark - collectionView相关代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MNDetailDynamicCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MNDetailDynamicCollectCell class]) forIndexPath:indexPath];
//    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];
//    [cell fillDataWithMessageInfo:msg];
    BlogInfo *blog = self.dataArray[indexPath.row];
    [cell fillDataWithBlog:blog];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
   

    MessageInfo *msg = [self.dataArray objectAtIndex:indexPath.row];

//    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
//    v.previewList = self.dataArray;
//    v.curIndex = indexPath.row;
//
//    [tp_topMostViewController().navigationController pushViewController:v animated:YES];
}

//- (NSArray *)getCurrentPhotoList
//{
//    NSMutableArray *list = [NSMutableArray array];
//    for(MessageInfo *msg in self.dataArray)
//    {
//        if(msg.messageType == MessageType_Photo)
//        {
//            [list addObject:msg];
//        }
//    }
//    return list;
//}

@end
