//
//  DYCollectionViewController.h
//  FireControl
//
//  Created by 帝云科技 on 2019/5/28.
//  Copyright © 2019 帝云科技. All rights reserved.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface DYCollectionViewController : BaseVC<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, weak) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *sectionArray0;
@property (nonatomic, strong) NSMutableArray *sectionArray1;
@property (nonatomic, strong) NSMutableArray *sectionArray2;
@property (nonatomic, strong) NSMutableArray *sectionArray3;
@property (nonatomic, strong) NSMutableArray *sectionArray4;

@property (nonatomic, copy) NSString *emptyTitle;
@property (nonatomic, copy) NSString *emptyImageName;

/** 初始化数据 */
- (void)dy_configureData;
/** 初始化数据 */
- (void)dy_configureDataWithModel:(DYModel *)model;

- (void)dy_cellResponse:(__kindof DYCollectionViewCellItem *)item indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
