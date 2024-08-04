//
//  MNDetailDynamicCollectCell.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/15.
//

#import "MNDetailDynamicCollectCell.h"
#import "UIImageView+VideoThumbnail.h"

@implementation MNDetailDynamicCollectCell


- (void)fillDataWithBlog:(BlogInfo *)blog{
    self.iconImgV.photo = PhotoInfo.new;
    if (blog.content.isPhotoContent) {
        self.iconImgV.photo = blog.content.photos.firstObject;
        self.playImgV.hidden = YES;
    } else if (blog.content.isVideoContent) {
        [self.iconImgV setThumbnailImage:blog.content.video];
        self.playImgV.hidden = NO;
    } else {
        [self.iconImgV reset];
        self.playImgV.hidden = YES;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.playImgV];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.center.mas_equalTo(0);
    }];
    [self.playImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.center.mas_equalTo(0);
    }];
}

-(PhotoImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[PhotoImageView alloc] init];
        _iconImgV.layer.cornerRadius = 3;
        _iconImgV.layer.masksToBounds = YES;
    }
    return _iconImgV;
}

-(UIImageView *)playImgV{
    if (!_playImgV) {
        _playImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_video_play"]];
    }
    return _playImgV;
}

@end
