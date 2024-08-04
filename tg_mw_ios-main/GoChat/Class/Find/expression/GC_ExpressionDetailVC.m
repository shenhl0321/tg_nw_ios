//
//  GC_ExpressionDetailVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_ExpressionDetailVC.h"
#import "GC_ExpressionDetailTopView.h"
#import "GC_ExpressionCollectionCell.h"

@interface GC_ExpressionDetailVC ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong)GC_ExpressionDetailTopView *topView;
@property (nonatomic, strong)UICollectionView *collectionV;

@end

@implementation GC_ExpressionDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.contentView addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(190);
    }];
    
    [self.contentView addSubview:self.collectionV];
    [self.collectionV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(25);
        make.right.mas_equalTo(-25);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(25);
    }];
    
    [self.customNavBar setTitle:@"表情详情".lv_localized];
    // Do any additional setup after loading the view from its nib.
}
- (GC_ExpressionDetailTopView *)topView{
    if (!_topView) {
        _topView = [[GC_ExpressionDetailTopView alloc] init];
    }
    return _topView;
}

- (UICollectionView *)collectionV{
    if (!_collectionV) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 125)/4., (SCREEN_WIDTH - 125)/4.);
        
        flowLayout.minimumInteritemSpacing = 25;
        flowLayout.minimumLineSpacing = 25;
        
        _collectionV = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionV.delegate = self;
        _collectionV.dataSource = self;
        [_collectionV registerNib:[UINib nibWithNibName:@"GC_ExpressionCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
        
        
    }
    return _collectionV;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 12;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GC_ExpressionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageV.layer.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
