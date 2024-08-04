//
//  SelectMemberCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/7.
//

#import "SelectMemberCell.h"

@implementation SelectMemberCellItem

- (CGFloat)cellHeight {
    return 60;
}

@end

@interface SelectMemberCell ()

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation SelectMemberCell

- (void)dy_initUI {
    [super dy_initUI];
    
    [self dy_noneSelectionStyle];
    _selectImageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:5];
        iv.backgroundColor = UIColor.xhq_base;
        iv;
    });
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_aTitle;
        label.font = UIFont.xhq_font15;
        label.text = @"Username";
        label;
    });
    
    [self addSubview:_selectImageView];
    [self addSubview:_avatar];
    [self addSubview:_nameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(15);
    }];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_selectImageView.mas_trailing).offset(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(42);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_avatar.mas_trailing).offset(15);
        make.centerY.mas_equalTo(0);
    }];
    
}

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    SelectMemberCellItem *m = (SelectMemberCellItem *)item;
    _selectImageView.image = [UIImage imageNamed:m.isSelected ? @"icon_choose_sel" : @"icon_choose"];
    
    [self reloadWithMember:m.member];
    [self reloadWithGroup:m.group];
    m.image = _avatar.image;
}

- (void)reloadWithMember:(UserInfo *)member {
    if (!member) {
        return;
    }
    _nameLabel.text = member.displayName;
    if (!member.profile_photo) {
        [self loadTextImage:member.displayName];
        return;
    }
    if (!member.profile_photo.isSmallPhotoDownloaded) {
        [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", member._id] fileId:member.profile_photo.fileSmallId type:FileType_Photo];
        [self loadTextImage:member.displayName];
        return;
    }
    [UserInfo cleanColorBackgroundWithView:_avatar];
    _avatar.image = [UIImage imageWithContentsOfFile:member.profile_photo.localSmallPath];
}

- (void)reloadWithGroup:(ChatInfo *)group {
    if (!group) {
        return;
    }
    _nameLabel.text = group.title;
    if (!group.photo) {
        [self loadTextImage:group.title];
        return;
    }
    ProfilePhoto *photo = group.photo;
    if (!photo.isSmallPhotoDownloaded && photo.small.remote.unique_id.length > 1) {
        [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", group._id] fileId:photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
        [self loadTextImage:group.title];
        return;
    }
    
    [UserInfo cleanColorBackgroundWithView:_avatar];
    _avatar.image = [UIImage imageWithContentsOfFile:photo.localSmallPath];
}

- (void)loadTextImage:(NSString *)name {
    _avatar.image = nil;
    unichar text = [@" " characterAtIndex:0];
    if(name.length > 0) {
        text = [[name uppercaseString] characterAtIndex:0];
    }
    [UserInfo setColorBackgroundWithView:_avatar withSize:CGSizeMake(42, 42) withChar:text];
}

@end
