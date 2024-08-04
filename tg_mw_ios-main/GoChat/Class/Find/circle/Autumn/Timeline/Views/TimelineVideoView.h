//
//  TimelineVideoView.h
//  GoChat
//
//  Created by Autumn on 2021/11/24.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN

@class VideoInfo, PhotoImageView;
@interface TimelineVideoView : DYView

@property (nonatomic, strong) VideoInfo *video;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) PhotoImageView *thumbnailView;
@property (nonatomic, strong) UIView *clearMaskView;

@end

NS_ASSUME_NONNULL_END
