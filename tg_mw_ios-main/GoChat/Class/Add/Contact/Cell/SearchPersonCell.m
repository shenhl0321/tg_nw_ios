//
//  SearchPersonCell.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/30.
//

#import "SearchPersonCell.h"

@interface SearchPersonCell ()
@property (nonatomic, strong) UserInfo * userInfo;
@property (nonatomic, strong) UIImageView * headImageV;
@property (nonatomic, strong) UILabel * nameL;
@end

@implementation SearchPersonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
    }
    return self;
}
-(UIImageView *)headImageV{
    if (!_headImageV) {
        _headImageV = [[UIImageView alloc] init];
        [_headImageV setContentMode:UIViewContentModeScaleAspectFill];
        [_headImageV mn_iconStyleWithRadius:26];
    }
    return _headImageV;
}

-(UILabel *)nameL{
    if (!_nameL) {
        _nameL = [[UILabel alloc] init];
        _nameL.textColor = [UIColor colorTextFor23272A];
        _nameL.font = fontRegular(16);
    }
    return _nameL;
}

-(void)buildUI{
    
    [self.contentView addSubview:self.headImageV];
    [self.contentView addSubview:self.nameL];
    
    [self.headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.width.height.equalTo(@52);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageV.mas_right).offset(12);
        make.right.top.bottom.equalTo(self.contentView);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)resetUserInfo:(UserInfo *)user isChoose:(BOOL)isChoose showMask:(BOOL)showMask
{
    self.userInfo = user;
    if(user.profile_photo != nil)
    {
        if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
            //本地头像
            self.headImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headImageV withSize:CGSizeMake(52, 52) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.headImageV];
            self.headImageV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.headImageV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(user.displayName.length>0)
        {
            text = [[user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headImageV withSize:CGSizeMake(52, 52) withChar:text];
    }
    self.nameL.text = user.displayName;
    
//    if(isChoose)
//    {
//        self.chooseImageView.image = [UIImage imageNamed:@"icon_choose_sel"];
//    }
//    else
//    {
//        self.chooseImageView.image = [UIImage imageNamed:@"icon_choose"];
//    }
//    self.maskView.hidden = !showMask;
}

- (void)resetUserInfo:(UserInfo *)user
{
    [self resetUserInfo:user isChoose:NO showMask:NO];
}

@end
