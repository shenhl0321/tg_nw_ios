//
//  TimelineVideoView.m
//  GoChat
//
//  Created by Autumn on 2021/11/24.
//

#import "TimelineVideoView.h"
#import "PhotoImageView.h"
#import "VideoInfo.h"
#import "TimelineHelper.h"
#import "UIImageView+VideoThumbnail.h"

@interface TimelineVideoView ()


@end

@implementation TimelineVideoView

- (void)dy_initUI {
    [super dy_initUI];
    
    _thumbnailView = [[PhotoImageView alloc] init];
    _thumbnailView.tag = TimelineHelper.containerTag;
    _playButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
        btn;
    });
    _clearMaskView = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.clearColor;
        view;
    });
    [self addSubview:_thumbnailView];
    [self addSubview:_clearMaskView];
    [_thumbnailView addSubview:_playButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_thumbnailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.size.equalTo(@66);
    }];
    [_clearMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_thumbnailView);
    }];
}

- (void)setVideo:(VideoInfo *)video {
    _video = video;
    [_thumbnailView setThumbnailImage:video];
}


@end
