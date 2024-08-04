//
//  ChatEmojiView.m
//  GoChat
//
//  Created by wangyutao on 2021/2/23.
//

#import "ChatEmojiView.h"
#import "ZyPlayerView.h"
#import "MNEmojisCell.h"

@interface ChatEmojiView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *emojisList;
@property (nonatomic, assign) BOOL isCollectEmojis;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *emojiBtn;
@property (nonatomic, weak) IBOutlet UIButton *collectBtn;

@property (nonatomic) UIEdgeInsets collectionViewSpace;
@property (nonatomic) CGSize itemSize;
@end

@implementation ChatEmojiView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.emojisList = [[EmojiManager shareInstance] emojiListCopy];

    //init size
    self.collectionViewSpace = UIEdgeInsetsMake(5, 15, 0, 15);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
//    [self.collectionView registerNib:[UINib nibWithNibName:@"MNEmojisCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"emojisCell"];
//    [self.collectionView registerNib:[UINib nibWithNibName:@"MNCollectCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"collectCell"];
    [self.collectionView registerClass:NSClassFromString(@"MNEmojisCell") forCellWithReuseIdentifier:@"emojisCell"];
    [self.collectionView registerClass:NSClassFromString(@"MNCollectCell") forCellWithReuseIdentifier:@"collectCell"];
    CGFloat itemWidth = (SCREEN_WIDTH - self.collectionViewSpace.left - self.collectionViewSpace.right - 15*7)/8;
    CGFloat itemHeight = itemWidth+5;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (IBAction)click_send:(id)sender
{
    if([self.delegate respondsToSelector:@selector(ChatEmojiView_Send:)])
    {
        [self.delegate ChatEmojiView_Send:self];
    }
}
- (IBAction)emojiAction:(UIButton *)sender {
    self.isCollectEmojis = false;
    CGFloat itemWidth = (SCREEN_WIDTH - self.collectionViewSpace.left - self.collectionViewSpace.right - 15*7)/8;
    CGFloat itemHeight = itemWidth+5;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    [self.collectionView reloadData];
}
- (IBAction)collectAction:(UIButton *)sender {
    self.isCollectEmojis = true;
    CGFloat itemWidth = (SCREEN_WIDTH - self.collectionViewSpace.left - self.collectionViewSpace.right - 15*3)/4;
    CGFloat itemHeight = itemWidth+5;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    [self.collectionView reloadData];
}

- (void)setCollectList:(NSArray *)collectList {
    _collectList = collectList;
    if (self.isCollectEmojis) {
        [self.collectionView reloadData];
    }
}

#pragma mark - collection view data source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return !self.isCollectEmojis?self.emojisList.count:self.collectList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (!self.isCollectEmojis) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojisCell" forIndexPath:indexPath];
        NSDictionary *obj = [self.emojisList objectAtIndex:indexPath.row];
        ((MNEmojisCell *)cell).aLabel.text = [[EmojiManager shareInstance] toString:obj];
       
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectCell" forIndexPath:indexPath];
        if (cell.contentView.subviews.count != 0) {
            for (UIView *view in cell.contentView.subviews) {
                [view removeFromSuperview];
            }
        }
        AnimationInfo *videoInfo = self.collectList[indexPath.row];
        UIImage *coverImage = nil;
        if(videoInfo.thumbnail != nil)
        {
            ThumbnailInfo *thumbnailInfo = videoInfo.thumbnail;
            if(thumbnailInfo.isThumbnailDownloaded)
            {
                coverImage = [UIImage imageWithContentsOfFile:thumbnailInfo.file.local.path];
            }
        }
        UIButton *deletBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deletBtn.frame = CGRectMake(0, 0, 22, 22);
        [deletBtn setImage:[UIImage imageNamed:@"MsgDelete"] forState:UIControlStateNormal];
        deletBtn.tag = indexPath.row;
        [deletBtn addTarget:self action:@selector(deletEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        ZyPlayerView *animationV = [[ZyPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.itemSize.width, self.itemSize.height) duration:videoInfo.duration totalLength:videoInfo.totalSize downloadLength:videoInfo.donwloadSize localPath:videoInfo.localVideoPath isSound:NO coverImage:coverImage placeHodlerImage:@"gif_holder" completed:videoInfo.animation.local.is_downloading_completed];
        [cell.contentView addSubview:animationV];
        [cell.contentView addSubview:deletBtn];
    }
    
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
    if (!self.isCollectEmojis) {
        NSDictionary *obj = [self.emojisList objectAtIndex:indexPath.row];
        if([self.delegate respondsToSelector:@selector(ChatEmojiView_Choose:emoji:)])
        {
            [self.delegate ChatEmojiView_Choose:self emoji:[[EmojiManager shareInstance] toString:obj]];
        }
    }else {
        AnimationInfo *videoInfo = self.collectList[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(ChatCollectEmojiView_Choose:)]) {
            [self.delegate ChatCollectEmojiView_Choose:videoInfo];
        }
    }
    
    
}

- (void)deletEvent:(UIButton *)button {
    NSLog(@"deletEvent indexpath");
    AnimationInfo *videoInfo = self.collectList[button.tag];
    if ([self.delegate respondsToSelector:@selector(ChatCollectEmojiView_Delete:)]) {
        [self.delegate ChatCollectEmojiView_Delete:videoInfo];
    }
}

@end
