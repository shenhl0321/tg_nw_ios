//
//  PhotoImageView.m
//  GoChat
//
//  Created by Autumn on 2021/11/21.
//

#import "PhotoImageView.h"
#import "PhotoInfo.h"

@interface PhotoImageView ()<BusinessListenerProtocol>

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation PhotoImageView

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    _indicator = [[UIActivityIndicatorView alloc] init];
    self.image = [UIImage imageNamed:@"image_default_2"];
    [self addSubview:_indicator];
    [BusinessFramework.defaultBusinessFramework registerBusinessListener:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];
}

- (void)setPhoto:(PhotoInfo *)photo {
    _photo = photo;
    if (!photo.messagePhoto) {
        self.image = [UIImage imageNamed:@"image_default_2"];
        return;
    }
    if (!photo.messagePhoto.isPhotoDownloaded) {
        [self downloadImage:photo.messagePhoto.photo._id];
        return;
    }
    self.image = [UIImage imageWithContentsOfFile:photo.messagePhoto.photo.local.path];
}

- (void)setThumbnail:(ThumbnailInfo *)thumbnail {
    _thumbnail = thumbnail;
    self.image = [UIImage imageNamed:@"image_default_2"];
    if (!thumbnail.file) {
        return;
    }
    if (!thumbnail.isThumbnailDownloaded) {
        [self downloadImage:thumbnail.file._id];
        return;
    }
    self.image = [UIImage imageWithContentsOfFile:thumbnail.file.local.path];
}

- (void)reset {
    self.image = [UIImage imageNamed:@"image_default_2"];
}

- (void)downloadImage:(long)ids {
    if([[TelegramManager shareInstance] isFileDownloading:ids type:FileType_Message_Photo]) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", ids];
    [[FileDownloader instance] downloadImage:key fileId:ids type:FileType_Message_Photo];
}

- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Td_Message_Photo_Ok): {
            NSDictionary *obj = inParam;
            if (!obj || ![obj isKindOfClass:NSDictionary.class]) {
                return;
            }
            FileTaskInfo *task = [obj objectForKey:@"task"];
            FileInfo *fileInfo = [obj objectForKey:@"file"];
            if (!task || !fileInfo) {
                return;
            }
            if (_photo) {
                NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", _photo.messagePhoto.photo._id];
                if ([key isEqualToString:task._id]) {
                    _photo.messagePhoto.photo = fileInfo;
                    [self setPhoto:_photo];
                }
            } else if (_thumbnail) {
                NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", _thumbnail.file._id];
                if ([key isEqualToString:task._id]) {
                    _thumbnail.file = fileInfo;
                    [self setThumbnail:_thumbnail];
                    return;
                }
            }
        }
            break;
        default:
            break;
    }
}

@end
