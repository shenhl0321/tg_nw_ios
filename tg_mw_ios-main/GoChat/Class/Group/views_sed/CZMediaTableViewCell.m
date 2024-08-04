//
//  CZMediaTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/29.
//

#import "CZMediaTableViewCell.h"
#import "CZMediaDetailCollectionViewCell.h"
#import "TF_RequestManager.h"
@interface CZMediaTableViewCell ()
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;

@end

@implementation CZMediaTableViewCell

- (void)dealloc{
    [self removeNotificationObserver];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceHasComplet:) name:@"EUser_Td_Message_Source_Ok" object:nil];
}

- (void)setSoureArray:(NSMutableArray *)soureArray{
    if (soureArray) {
        _soureArray = soureArray;
        [self.mainCollectionView reloadData];
    }
}

- (void)sourceHasComplet:(NSNotification *)notification{
    NSDictionary *dic = [notification object];
    if (dic) {
        MessageInfo *msg = [self.soureArray objectAtIndex:[[dic objectForKey:@"targetNum"] intValue]];
        msg = [dic objectForKey:@"msgInfo"];
        NSIndexPath *indexpath = [NSIndexPath indexPathForItem:[[dic objectForKey:@"targetNum"] intValue] inSection:0];
        CZMediaDetailCollectionViewCell *cell = (CZMediaDetailCollectionViewCell *)[self.mainCollectionView cellForItemAtIndexPath:indexpath];
        if (cell) {
            [self.mainCollectionView reloadItemsAtIndexPaths:@[indexpath]];
        }
    }
}

- (void)initUISetting{
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"CZMediaDetailCollectionViewCell"bundle:nil]forCellWithReuseIdentifier:@"CZMediaDetailCollectionViewCell"];
    self.mainCollectionView.scrollEnabled = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUISetting];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -- UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.soureArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CZMediaDetailCollectionViewCell";
    CZMediaDetailCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    MessageInfo *msg = [self.soureArray objectAtIndex:indexPath.row];
    cell.cellInfo = msg;
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat width = floor((SCREEN_WIDTH - 40)/3);
    return CGSizeMake(width, width);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


#pragma mark --UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageInfo *msg = [self.soureArray objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(collectioncellClickWtihArray:withIndex:)]) {
        [_delegate collectioncellClickWtihArray:self.soureArray withIndex:(int)indexPath.item];
    }
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0)){
    MessageInfo *msg = [self.soureArray objectAtIndex:indexPath.row];
    if(msg.messageType == MessageType_Animation){//gif消息
        AnimationInfo *gifInfo = msg.content.animation;
        if(gifInfo != nil)
        {
            if(!gifInfo.isVideoDownloaded)
            {//未下载，启动下载
                if(![[TelegramManager shareInstance] isFileDownloading:gifInfo.animation._id type:FileType_Message_Animation] && gifInfo.animation.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:gifInfo.animation._id download_offset:0 type:FileType_Message_Animation];
                }
            }
        }
    }
   
}


@end
