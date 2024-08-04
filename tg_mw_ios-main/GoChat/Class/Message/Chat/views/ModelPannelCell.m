//
//  ModelPannelCell.m
//  GoChat
//
//  Created by wangyutao on 2021/3/30.
//

#import "ModelPannelCell.h"
#import "QTChatItemCell.h"

@implementation ChatModelInfo

+ (instancetype)modelInfoWithType:(ChatModelType)type title:(NSString *)title icon:(NSString *)icon
{
    ChatModelInfo *info = [ChatModelInfo new];
    info.type = type;
    info.title = title;
    info.icon = icon;
    return info;
}

@end

@interface ModelPannelCell ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *modelsList;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIEdgeInsets collectionViewSpace;
@property (nonatomic) CGSize itemSize;
@end

@implementation ModelPannelCell

#define kQTChatItemCell @"QTChatItemCell"
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.backgroundColor = HEXCOLOR(0xF5F9FA);
    //init size
    self.collectionViewSpace = UIEdgeInsetsMake(0, 15, 0, 15);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"ChatModelCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerNib:[UINib nibWithNibName:kQTChatItemCell bundle:nil] forCellWithReuseIdentifier:kQTChatItemCell];
    
    CGFloat itemWidth = (SCREEN_WIDTH - self.collectionViewSpace.left - self.collectionViewSpace.right - 10*3)/4;
    CGFloat itemHeight = 120;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)resetModelsList:(NSArray *)list
{
    self.modelsList = list;
    [self.collectionView reloadData];
}

#pragma mark - collection view data source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MIN(self.modelsList.count, 8);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    UIImageView *iconImageView = [cell viewWithTag:1];
//    UILabel *titleLabel = [cell viewWithTag:2];
//    ChatModelInfo *info = [self.modelsList objectAtIndex:indexPath.row];
//    iconImageView.image = [UIImage imageNamed:info.icon];
//    titleLabel.text = info.title;
//    titleLabel.textColor = [UIColor colorFor878D9A];
//    return cell;
    
    QTChatItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQTChatItemCell forIndexPath:indexPath];
    ChatModelInfo *info = [self.modelsList objectAtIndex:indexPath.row];
    cell.logoImageV.image = [UIImage imageNamed:info.icon];
    cell.titleLab.text = info.title;
    return cell;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.collectionViewSpace;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(ModelPannelCell_Click_Model:model:)])
    {
        [self.delegate ModelPannelCell_Click_Model:self model:[self.modelsList objectAtIndex:indexPath.row]];
    }
}

@end
