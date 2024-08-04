//
//  MNContactGroupContentCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNContactGroupContentCell.h"

@interface MNContactGroupContentCell ()
@property (nonatomic, strong) ChatInfo *chatInfo;
@end

@implementation MNContactGroupContentCell

- (void)resetGroupInfo:(ChatInfo *)chat
{
    self.chatInfo = chat;
    self.titleLabel.text = self.chatInfo.title;
    if(self.chatInfo.photo != nil)
    {
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.headerImageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0)
            {
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(42, 42) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.headerImageView];
            self.headerImageView.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.headerImageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headerImageView withSize:CGSizeMake(42, 42) withChar:text];
    }
}

- (void)initUI{
    [super initUI];
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImageView.mas_right).with.offset(12);
        make.right.mas_equalTo(-left_margin());
        make.centerY.mas_equalTo(0);
    }];
}

-(UIImageView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc] init];
        [_headerImageView mn_iconStyle];
    }
    return _headerImageView;
}


-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontRegular(16);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}

@end
