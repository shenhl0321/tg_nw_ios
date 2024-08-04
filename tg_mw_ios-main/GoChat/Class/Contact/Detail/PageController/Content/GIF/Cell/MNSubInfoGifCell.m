//
//  MNSubInfoGifCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoGifCell.h"
#import "UIView+Corner.h"
#import "ZyPlayerView.h"

@interface MNSubInfoGifCell ()

@property (nonatomic, strong) ZyPlayerView *contentVideoView;

@end

@implementation MNSubInfoGifCell

- (void)fillDataWithMessageInfo:(MessageInfo *)message{
    if(message.messageType == MessageType_Animation){
        UIImage *coverImage = nil;

        if(message.content.animation.thumbnail != nil)
        {
            ThumbnailInfo *thumbnailInfo = message.content.animation.thumbnail;
            if(thumbnailInfo.isThumbnailDownloaded)
            {
                coverImage = [UIImage imageWithContentsOfFile:thumbnailInfo.file.local.path];
            }
        }
        CGRect contentFrame;
        CGFloat videoWidth = floor(self.frame.size.width);
        CGFloat videoHeight = floor(self.frame.size.height);
        if(videoWidth>0 && videoHeight>0)
        {
            CGFloat scale = [self ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(videoWidth, videoHeight)];
            contentFrame = CGRectMake(0, 0, MIN(MAX(40, scale*videoWidth), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, scale*videoHeight)));
        }
        else
        {
            contentFrame = CGRectMake(0, 0, MIN(MAX(40, MESSAGE_CELL_PHOTO_DEFAULT_WIDTH), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT)));
        }

        AnimationInfo *videoInfo = message.content.animation;
        self.contentVideoView = [[ZyPlayerView alloc] initWithFrame:contentFrame duration:videoInfo.duration totalLength:videoInfo.totalSize downloadLength:videoInfo.donwloadSize localPath:videoInfo.localVideoPath isSound:NO coverImage:coverImage placeHodlerImage:@"gif_holder" completed:videoInfo.animation.local.is_downloading_completed];
        [self.iconImgV addSubview:self.contentVideoView];
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
    [self.contentView addSubview:self.gifBgView];
    [self.contentView addSubview:self.gifLabel];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.gifBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 20.5));
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    [self.gifLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 20.5));
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
        [_iconImgV mn_iconStyleWithRadius:13];
        _iconImgV.backgroundColor = HexRGB(0xD5D6D6);
    }
    return _iconImgV;
}

-(UILabel *)gifLabel{
    if (!_gifLabel) {
        _gifLabel = [[UILabel alloc] init];
        _gifLabel.font = fontRegular(14);
        _gifLabel.textColor = [UIColor colorTextForFFFFFF];
        _gifLabel.textAlignment = NSTextAlignmentCenter;
        _gifLabel.text = @"GIF".lv_localized;
    }
    return _gifLabel;
}

-(UIImageView *)gifBgView{
    if (!_gifBgView) {
        _gifBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 20.5)];
//        [_gifBgView addRoundedCorners:UIRectCornerTopLeft radius:13];
        [_gifBgView addRoundedCorners:UIRectCornerTopLeft|UIRectCornerBottomRight radius:13];
        _gifBgView.backgroundColor = [UIColor colorTextFor000000_:0.5];
    }
    return _gifBgView;
}


- (CGFloat)ScaleFromCompassToSize:(CGSize)toSize fromSize:(CGSize)fromSize
{
    float scale = 1.0f;
    if (fromSize.width >= fromSize.height)
    {
        if (fromSize.width > toSize.width)
        {
            scale =  toSize.width / fromSize.width;
        }
    }
    else if (fromSize.height > fromSize.width)
    {
        if (fromSize.height > toSize.height)
        {
            scale =  toSize.height / fromSize.height;
        }
    }
    return scale;
}

@end
