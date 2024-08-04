//
//  MNSubInfoMediaCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoMediaCell.h"
#import "ZyPlayerView.h"
#import "PhotoImageView.h"
#import "UIImageView+VideoThumbnail.h"

@interface MNSubInfoMediaCell ()

@property (nonatomic, strong) ZyPlayerView *contentVideoView;
@property (nonatomic, strong) PhotoImageView *mediaImageView;

/// 视频持续时间
@property (nonatomic,strong) UILabel *timeL;

@end
@implementation MNSubInfoMediaCell


- (void)fillDataWithMessageInfo:(MessageInfo *)message {
    if (message.messageType == MessageType_Photo) {
        self.timeL.hidden = YES;
        _mediaImageView.photo = message.content.photo;
    } else if(message.messageType == MessageType_Video) {

        VideoInfo *videoInfo = message.content.video;
        [_mediaImageView setThumbnailImage:videoInfo];
        self.timeL.text = videoInfo.durationTime;
        self.timeL.hidden = NO;
    }
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    [self.contentView addSubview:self.mediaImageView];
//    [self.contentView addSubview:self.iconImgV];
    [self timeL];
    [self.mediaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
}

- (PhotoImageView *)mediaImageView {
    if (!_mediaImageView) {
        _mediaImageView = [[PhotoImageView alloc] init];
    }
    return _mediaImageView;
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
        [_iconImgV mn_iconStyleWithRadius:13];
        _iconImgV.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgV.backgroundColor = HexRGB(0xd5d6d6);
        
    }
    return _iconImgV;
}
- (UILabel *)timeL{
    if (!_timeL) {
        //时间
        _timeL = [[UILabel alloc] init];
        [self.contentView addSubview:_timeL];
        
        _timeL.backgroundColor = [UIColor clearColor];
        _timeL.font = [UIFont systemFontOfSize:9];
        _timeL.textColor = [UIColor whiteColor];
        _timeL.textAlignment = NSTextAlignmentCenter;
        _timeL.backgroundColor = RGBA(0, 0, 0, 0.5);
        [_timeL.layer setMasksToBounds:YES];
        [_timeL.layer setCornerRadius:8];
        [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(36);
            make.height.mas_equalTo(16);
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-10);
        }];
        _timeL.hidden = YES;
    }
    return _timeL;
}


@end
