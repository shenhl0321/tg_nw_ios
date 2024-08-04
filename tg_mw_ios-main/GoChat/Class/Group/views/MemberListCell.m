//
//  MemberListCell.m
//  GoChat
//
//  Created by wangyutao on 2020/12/10.
//

#import "MemberListCell.h"

@interface MemberListCell ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *membersList;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) UIEdgeInsets collectionViewSpace;
@property (nonatomic) CGSize itemSize;
@end

@implementation MemberListCell

+ (CGFloat)cellHeight:(NSArray *)members canAdd:(BOOL)canAdd canDelete:(BOOL)canDelete
{
    int count = (int)members.count;
    if(canAdd) count++;
    if(canDelete) count++;
    
    CGFloat itemWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
    CGFloat itemHeight = itemWidth+35;
    int line = count/5+(count%5>0?1:0);
    line = MIN(3, line);
    if(line>0)
    {
        return line*itemHeight+60+5;
    }
    else
    {
        return 0;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //init size
    self.collectionViewSpace = UIEdgeInsetsMake(0, 15, 0, 15);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    CGFloat itemWidth = (SCREEN_WIDTH - self.collectionViewSpace.left - self.collectionViewSpace.right - 20*4)/5;
    CGFloat itemHeight = itemWidth+35;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)resetMembersList:(NSArray *)list canAdd:(BOOL)canAdd canDelete:(BOOL)canDelete
{
    NSMutableArray *lt = [NSMutableArray array];
    if(list.count>0)
    {
        int max = 15;
        if(canAdd) max--;
        if(canDelete) max--;
        for(int i=0; i<list.count&&i<max; i++)
        {
            [lt addObject:[list objectAtIndex:i]];
        }
    }
    if(canAdd)
    {
        [lt addObject:@"add"];
    }
    if(canDelete)
    {
        [lt addObject:@"delete"];
    }
    self.membersList = lt;
    [self.collectionView reloadData];
}

- (void)resetTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

#pragma mark - collection view data source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MIN(self.membersList.count, 15);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSObject *obj = [self.membersList objectAtIndex:indexPath.row];
    UIImageView *headerImageView = [cell viewWithTag:1];
    [headerImageView setClipsToBounds:YES];
    [headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    UILabel *titleLabel = [cell viewWithTag:2];
    if([obj isKindOfClass:[GroupMemberInfo class]])
    {
        GroupMemberInfo *info = (GroupMemberInfo *)obj;
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.user_id];
        if(user != nil)
        {
            if(user.profile_photo != nil)
            {
                if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
                {
                    [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                    //本地头像
                    headerImageView.image = nil;
                    unichar text = [@" " characterAtIndex:0];
                    if(user.displayName.length>0)
                    {
                        text = [[user.displayName uppercaseString] characterAtIndex:0];
                    }
                    [UserInfo setColorBackgroundWithView:headerImageView withSize:CGSizeMake(self.itemSize.width, self.itemSize.width) withChar:text];
                }
                else
                {
                    [UserInfo cleanColorBackgroundWithView:headerImageView];
                    headerImageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
                }
            }
            else
            {
                //本地头像
                headerImageView.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:headerImageView withSize:CGSizeMake(self.itemSize.width, self.itemSize.width) withChar:text];
            }
            titleLabel.text = user.displayName;
        }
        else
        {
            titleLabel.text = [NSString stringWithFormat:@"u%ld", info.user_id];
            //本地头像
            headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(titleLabel.text.length>0)
            {
                text = [[titleLabel.text uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:headerImageView withSize:CGSizeMake(self.itemSize.width, self.itemSize.width) withChar:text];
        }
    }
    if([obj isKindOfClass:[NSString class]])
    {
        if([@"add" isEqualToString:(NSString *)obj])
        {
            [UserInfo cleanColorBackgroundWithView:headerImageView];
            headerImageView.image = [UIImage imageNamed:@"icon_add"];
            titleLabel.text = @"   ";
        }
        if([@"delete" isEqualToString:(NSString *)obj])
        {
            [UserInfo cleanColorBackgroundWithView:headerImageView];
            headerImageView.image = [UIImage imageNamed:@"icon_delete"];
            titleLabel.text = @"   ";
        }
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
    NSObject *obj = [self.membersList objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[GroupMemberInfo class]])
    {
        if([self.delegate respondsToSelector:@selector(MemberListCell_Click_Member:member:)])
        {
            [self.delegate MemberListCell_Click_Member:self member:(GroupMemberInfo *)obj];
        }
    }
    if([obj isKindOfClass:[NSString class]])
    {
        if([@"add" isEqualToString:(NSString *)obj])
        {
            if([self.delegate respondsToSelector:@selector(MemberListCell_AddMember:)])
            {
                [self.delegate MemberListCell_AddMember:self];
            }
        }
        if([@"delete" isEqualToString:(NSString *)obj])
        {
            if([self.delegate respondsToSelector:@selector(MemberListCell_DeleteMember:)])
            {
                [self.delegate MemberListCell_DeleteMember:self];
            }
        }
    }
}

@end
