//
//  CZMediaDetailCollectionViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/29.
//

#import "CZMediaDetailCollectionViewCell.h"
#import "ZyPlayerView.h"
#import "UIView+Corner.h"
#import "UIImage+Ext.h"
#import "PhotoImageView.h"
#import "UIImageView+VideoThumbnail.h"
#import "FLAnimatedImage.h"
@interface CZMediaDetailCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *gifLabel;
@property (nonatomic, strong) ZyPlayerView *contentVideoView;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIView *gifView;
@property (strong, nonatomic) IBOutlet UIView *container;

/// 视频持续时间
@property (nonatomic,strong) UILabel *timeL;

@property (nonatomic, strong) PhotoImageView *mediaImageView;
/// <#code#>
@property (nonatomic, strong) FLAnimatedImageView *gifPlayV;
@end

@implementation CZMediaDetailCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self resetting];
}

- (void)resetting{
    _cellInfo = nil;
    self.mainImageView.image = nil;
    self.gifView.hidden = YES;
    if (self.contentVideoView && [self.contentVideoView superview]) {
        [self.contentVideoView removeFromSuperview];
        self.contentVideoView = nil;
    }
}

- (UILabel *)timeL{
    if (!_timeL) {
        //时间
        _timeL = [[UILabel alloc] init];
        [self.contentView addSubview:_timeL];
        
        _timeL.backgroundColor = [UIColor clearColor];
        _timeL.font = fontRegular(9);
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

- (UIImageView *)gifPlayV{
    if (!_gifPlayV) {
        _gifPlayV = [[FLAnimatedImageView alloc] init];
        _gifPlayV.hidden = YES;
    }
    return _gifPlayV;
}

- (PhotoImageView *)mediaImageView {
    if (!_mediaImageView) {
        _mediaImageView = [[PhotoImageView alloc] init];
    }
    return _mediaImageView;
}

- (void)setCellInfo:(MessageInfo *)cellInfo {
    self.gifView.hidden = YES;
    self.mediaImageView.hidden = NO;
    self.mainImageView.hidden = YES;
    self.gifPlayV.hidden = YES;
    self.gifLabel.hidden = YES;
    if (!_cellInfo) {
        _cellInfo = cellInfo;
        if (cellInfo.messageType == MessageType_Photo) {
            self.timeL.hidden = YES;
            _mediaImageView.photo = cellInfo.content.photo;
        } else if (cellInfo.messageType == MessageType_Video) {
            [_mediaImageView setThumbnailImage:cellInfo.content.video];
            VideoInfo *videoInfo = cellInfo.content.video;
            self.timeL.text = videoInfo.durationTime;
            self.timeL.hidden = NO;
        } else if (cellInfo.messageType == MessageType_Animation) {
            self.timeL.hidden = YES;
            self.mediaImageView.hidden = YES;
            self.mainImageView.hidden = NO;
            self.gifView.hidden = NO;
            self.gifPlayV.hidden = NO;
            self.gifLabel.hidden = NO;
            UIImage *coverImage = nil;
            if (cellInfo.content.animation.thumbnail != nil) {
                ThumbnailInfo *thumbnailInfo = cellInfo.content.animation.thumbnail;
                if(thumbnailInfo.isThumbnailDownloaded)
                {
                    coverImage = [UIImage imageWithContentsOfFile:thumbnailInfo.file.local.path];
                }
            }
            CGRect contentFrame;
            CGFloat videoWidth = fabs((SCREEN_WIDTH - 40)/3);
            CGFloat videoHeight = videoWidth;
            if(videoWidth>0 && videoHeight>0)
            {
                CGFloat scale = [CZMediaDetailCollectionViewCell ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(videoWidth, videoHeight)];
                contentFrame = CGRectMake(0, 0, MIN(MAX(40, scale*videoWidth), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, scale*videoHeight)));
            }
            else
            {
                contentFrame = CGRectMake(0, 0, MIN(MAX(40, MESSAGE_CELL_PHOTO_DEFAULT_WIDTH), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT)));
            }

            AnimationInfo *videoInfo = cellInfo.content.animation;
            NSString *path = videoInfo.localVideoPath;
            
            self.contentVideoView = [[ZyPlayerView alloc] initWithFrame:contentFrame duration:videoInfo.duration totalLength:videoInfo.totalSize downloadLength:videoInfo.donwloadSize localPath:videoInfo.localVideoPath isSound:NO coverImage:coverImage placeHodlerImage:@"gif_holder" completed:videoInfo.animation.local.is_downloading_completed];
            [self.mainImageView addSubview:self.contentVideoView];
            
            if ([path hasSuffix:@".gif"]) {
                NSData *imageData = [NSData dataWithContentsOfFile:path];

                FLAnimatedImage *fadImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                self.gifPlayV.animatedImage = fadImage;
                self.gifPlayV.frame = contentFrame;
//                self.mainImageView.hidden = YES;
//                self.gifPlayV.hidden = NO;
            }
//            else {
//                self.mainImageView.hidden = NO;
//                self.gifPlayV.hidden = YES;
//
//
//            }
            
//            self.contentVideoView = [[ZyPlayerView alloc] initWithFrame:contentFrame duration:videoInfo.duration totalLength:videoInfo.totalSize downloadLength:videoInfo.donwloadSize localPath:videoInfo.localVideoPath isSound:NO coverImage:coverImage placeHodlerImage:@"gif_holder" completed:videoInfo.animation.local.is_downloading_completed];
//            [self.mainImageView addSubview:self.contentVideoView];
        }
    }
}

+ (CGFloat)ScaleFromCompassToSize:(CGSize)toSize fromSize:(CGSize)fromSize
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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.contentView.layer.cornerRadius = 13;
    self.contentView.layer.masksToBounds = YES;
    self.gifView.backgroundColor = [UIColor colorTextFor000000_:0.5];
    [self.gifView addRoundedCorners:UIRectCornerTopLeft|UIRectCornerBottomRight radius:13];
    self.gifLabel.font = fontRegular(14);
    self.gifLabel.textColor = [UIColor whiteColor];
    [self.container insertSubview:self.mediaImageView belowSubview:self.gifView];
    self.contentVideoView.hidden = YES;
    self.mainImageView.hidden = YES;
    [self.mainImageView addSubview:self.gifPlayV];
    [self timeL];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_mediaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

@end
