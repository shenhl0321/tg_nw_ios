//
//  MessageReactionEmojiView.m
//  GoChat
//
//  Created by Autumn on 2022/3/25.
//

#import "MessageReactionEmojiView.h"

@interface MessageReactionEmojiView ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *emojis;

@property (nonatomic, strong) MessageInfo *msg;


@end

@implementation MessageReactionEmojiView

- (instancetype)initWithMessage:(MessageInfo *)message {
    if (self = [super initWithFrame:CGRectMake(0, 0, 180, 40)]) {
        self.msg = message;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [super initWithFrame:CGRectMake(0, 0, 180, 40)];
}

- (void)dy_initUI {
    [super dy_initUI];
    _emojis = ReactionEmojis();
    [self addSubview:self.collectionView];
    [self xhq_cornerRadius:20];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
            layout.minimumLineSpacing = 0;
            layout.minimumInteritemSpacing = 0;
            layout.itemSize = CGSizeMake(40, 40);
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout;
        });
        _collectionView = ({
            UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collection.delegate = self;
            collection.dataSource = self;
            collection.showsHorizontalScrollIndicator = NO;
            collection.bounces = NO;
            collection.backgroundColor = UIColor.whiteColor;
            [collection xhq_registerCell:[MessageReactionEmojiCell class]];
            if (@available(iOS 11.0, *)) {
                collection.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            collection;
        });
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emojis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageReactionEmojiCell *cell = [collectionView xhq_dequeueCell:MessageReactionEmojiCell.class indexPath:indexPath];
    cell.emojiLabel.text = _emojis[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *emoji = self.emojis[indexPath.item];
    [self.msg reactionWithEmoji:emoji];
    !self.selectedBlock ? : self.selectedBlock();
}

@end




@implementation MessageReactionEmojiCell

- (void)dy_initUI {
    [super dy_initUI];
    
    _emojiLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont xhq_font18];
        label;
    });
    [self addSubview:_emojiLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
}

@end
