//
//  EmojiContainer.m
//  GoChat
//
//  Created by Autumn on 2021/11/29.
//

#import "EmojiContainer.h"
#import "EmojiCell.h"

@interface EmojiContainer ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *emojisList;
@property (nonatomic) UIEdgeInsets collectionViewSpace;
@property (nonatomic) CGSize itemSize;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *delButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation EmojiContainer

+ (instancetype)loadFromNib {
    NSArray *nibs = [NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    return (EmojiContainer *)nibs.firstObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.emojisList = [[EmojiManager shareInstance] emojiListCopy];
    [self.sendButton xhq_cornerRadius:5];
    self.collectionViewSpace = UIEdgeInsetsMake(5, 15, 0, 15);
    [self.collectionView registerNib:[UINib nibWithNibName:@"EmojiCell" bundle:nil] forCellWithReuseIdentifier:@"EmojiCell"];
    [self.collectionView registerClass:UICollectionReusableView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableView"];
    CGFloat itemWidth = (kScreenWidth() - self.collectionViewSpace.left - self.collectionViewSpace.right - 15*6)/7;
    CGFloat itemHeight = itemWidth + 5;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (IBAction)send:(id)sender {
    if ([self.delegate respondsToSelector:@selector(emojiContainer_Send:)]) {
        [self.delegate emojiContainer_Send:self];
    }
}

- (IBAction)del:(id)sender {
    if ([self.delegate respondsToSelector:@selector(emojiContainer_Delete:)]) {
        [self.delegate emojiContainer_Delete:self];
    }
}

#pragma mark - collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emojisList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmojiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojiCell" forIndexPath:indexPath];
    NSDictionary *obj = self.emojisList[indexPath.row];
    cell.textLabel.text = [[EmojiManager shareInstance] toString:obj];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return self.collectionViewSpace;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return nil;
    }
    UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionReusableView" forIndexPath:indexPath];
    footer.backgroundColor = collectionView.backgroundColor;
    return footer;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 40);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *obj = self.emojisList[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(emojiContainer_Choose:emoji:)]) {
        [self.delegate emojiContainer_Choose:self emoji:[[EmojiManager shareInstance] toString:obj]];
    }
    
}

@end
