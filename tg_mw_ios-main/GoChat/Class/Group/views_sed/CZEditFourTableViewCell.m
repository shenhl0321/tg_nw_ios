//
//  CZEditFourTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/8/5.
//

#import "CZEditFourTableViewCell.h"
#import "CZEditGroupManagerCollectionViewCell.h"

@interface CZEditFourTableViewCell ()
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@end

@implementation CZEditFourTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.groupManagerLabel.font = fontRegular(16);
    self.groupManagerLabel.textColor = [UIColor colorTextFor23272A];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMemberIsManagersList:(NSArray *)memberIsManagersList{
    [self initCreateCollectionView];
    if (memberIsManagersList) {
        _memberIsManagersList = memberIsManagersList;
    }else{
        _memberIsManagersList = [NSArray array];
    }
    [self.mainCollectionView reloadData];
}

-(void)initCreateCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);//top, left, bottom, right
    flowLayout.minimumLineSpacing = 15;
    flowLayout.minimumInteritemSpacing = 15;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//垂直
    self.mainCollectionView.collectionViewLayout = flowLayout;
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"CZEditGroupManagerCollectionViewCell"bundle:nil]forCellWithReuseIdentifier:@"CZEditGroupManagerCollectionViewCell"];
}

#pragma mark -- UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.memberIsManagersList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.memberIsManagersList objectAtIndex:indexPath.row];
    static NSString * CellIdentifier = @"CZEditGroupManagerCollectionViewCell";
    CZEditGroupManagerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.info = obj;
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 15*4)/5;
    return CGSizeMake(cellWidth, cellWidth+20);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 10;
//}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(GLOBAL090ScreenWidth, 10);
//}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(GLOBAL090ScreenWidth, 10);
//}

#pragma mark --UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.memberIsManagersList objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(groupMemberClickwithobject:)]) {
        [_delegate groupMemberClickwithobject:obj];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0)){
    
}

@end
