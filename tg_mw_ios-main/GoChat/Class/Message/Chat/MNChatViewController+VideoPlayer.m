//
//  MNChatViewController+VideoPlayer.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/26.
//

#import "MNChatViewController+VideoPlayer.h"
#import "VideoResourceLoadManager.h"
#import "UIImageView+VideoThumbnail.h"
#import "VideoThumbnailManager.h"

@implementation MNChatViewController (VideoPlayer)


- (ZFPlayerController *)player {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPlayer:(ZFPlayerController *)player {
    objc_setAssociatedObject(self, @selector(player), player, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZFPlayerControlView *)controlView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setControlView:(ZFPlayerControlView *)controlView {
    objc_setAssociatedObject(self, @selector(controlView), controlView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)scrollViewScrollToBottom {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setScrollViewScrollToBottom:(BOOL)scrollViewScrollToBottom {
    objc_setAssociatedObject(self, @selector(scrollViewScrollToBottom), @(scrollViewScrollToBottom), OBJC_ASSOCIATION_ASSIGN);
}


- (void)setupPlayerWithScrollView:(UIScrollView *)scrollView {
    ZFPlayerControlView *controlView = [ZFPlayerControlView new];
    controlView.fastViewAnimated = YES;
    controlView.effectViewShow = YES;
    controlView.prepareShowLoading = YES;
    controlView.hidden = YES;
    controlView.bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    controlView.bgImgView.clipsToBounds = YES;
    self.controlView = controlView;
    
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    playerManager.scalingMode = ZFPlayerScalingModeAspectFit;
    ZFPlayerController *player = [ZFPlayerController playerWithScrollView:scrollView playerManager:playerManager containerViewTag:10000];
    player.controlView = self.controlView;
    player.playerDisapperaPercent = 0;
    player.playerApperaPercent = 1;
    player.WWANAutoPlay = YES;
    /// 续播
    player.resumePlayRecord = YES;
    /// 禁止掉滑动手势
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan;
    /// 竖屏的全屏
    player.orientationObserver.fullScreenMode = ZFFullScreenModePortrait;
    /// 隐藏全屏的状态栏
    player.orientationObserver.fullScreenStatusBarHidden = YES;
    player.orientationObserver.fullScreenStatusBarAnimation = UIStatusBarAnimationNone;

    /// 全屏的填充模式（全屏填充、按视频大小填充）
    player.orientationObserver.portraitFullScreenMode = ZFPortraitFullScreenModeScaleAspectFit;
    /// 禁用竖屏全屏的手势（点击、拖动手势）
    player.orientationObserver.disablePortraitGestureTypes = ZFDisablePortraitGestureTypesNone;

    @weakify(player)
    player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(player)
        [player.currentPlayerManager replay];
    };
    /// 滚动中播放
    @weakify(self)
    player.zf_playerShouldPlayInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if ([indexPath compare:self.player.playingIndexPath] != NSOrderedSame && !self.scrollViewScrollToBottom) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
        }
    };
    /// 滚动结束播放
//    player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
//        @strongify(self)
//        if (!self.player.playingIndexPath) {
//            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
//        }
//    };
    player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        @strongify(player)
        asset.muted = YES;
        [self saveVideoThumbnailInPlayerReadyToPlay:player.playingIndexPath];
    };
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        @strongify(player)
        if (loadState == ZFPlayerLoadStatePrepare) {
            ZFPlayerControlView *controlView = (ZFPlayerControlView *)player.controlView;
            controlView.effectView.hidden = YES;
        }
    };
    self.player = player;
}

- (void)prepareToPlay {
    @weakify(self);
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self);
        if (!self.player.playingIndexPath) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
        }
    }];
}

/// 播放视频
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollAnimated:(BOOL)animated {
    MessageInfo *msg = nil;
    //收藏
    BOOL isMyFov = (!self.chatInfo.isGroup && self.chatInfo._id == [UserInfo shareInstance]._id);
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {
        //群聊
        msg = [self.messageList objectAtIndex:indexPath.row];
    } else {
        //私聊
        if (indexPath.row == 0) {
            return;
        } else {
            msg = [self.messageList objectAtIndex:indexPath.row-1];
        }
    }
    if (msg.messageType != MessageType_Video) {
        [self.player stopCurrentPlayingCell];
        return;
    }
    VideoInfo *video = msg.content.video;
    NSURL *url;
    if (video.isVideoDownloaded && !IsStrEmpty(video.localVideoPath)) {
        url = [NSURL fileURLWithPath:video.localVideoPath];
    } else {
        NSString *appUrl = [NSString stringWithFormat:@"app://video/%ld/%ld/%@", video.video._id, video.video.expected_size, video.mime_type];
        url = [NSURL URLWithString:appUrl];
        VideoResourceLoadManager *manager = [[VideoResourceLoadManager alloc] init];
        self.player.resourceLoaderDelegate = manager;
    }
    if (animated) {
         [self.player playTheIndexPath:indexPath assetURL:url scrollPosition:ZFPlayerScrollViewScrollPositionCenteredVertically animated:YES];
     } else {
         [self.player playTheIndexPath:indexPath assetURL:url];
     }
    self.controlView.portraitControlView.titleLabel.text = video.file_name;
    [self.controlView.bgImgView setThumbnailImage:video];
    
}

/// 在视频播放的时候保存保存封面
- (void)saveVideoThumbnailInPlayerReadyToPlay:(NSIndexPath *)indexPath {
    ZFAVPlayerManager *manager = (ZFAVPlayerManager *)self.player.currentPlayerManager;
    if (!manager.isPreparedToPlay) {
        return;
    }
    ZFPlayerControlView *controlView = (ZFPlayerControlView *)self.player.controlView;
    NSString *name = controlView.portraitControlView.titleLabel.text;
    @weakify(self);
    [VideoThumbnailManager.manager saveThumbnailAsset:manager.asset forVideoName:name completion:^{
        @strongify(self);
        MessageViewBaseCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (![cell isKindOfClass:VideoMessageCell.class]) {
            return;
        }
        [((VideoMessageCell *)cell) resetVideoThumbnail];
    }];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIScrollViewDelegate 列表播放必须实现

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
    /// 处理滑动到最底部时，多个视频存在导致最后一个视频不播放的问题
    CGFloat distance = scrollView.contentSize.height - scrollView.contentOffset.y;
    BOOL isScrollBottom = floor(distance) <= floor(scrollView.xhq_height);
    self.scrollViewScrollToBottom = isScrollBottom;
    if (isScrollBottom) {
        NSIndexPath *indexPath = [self getScrollToBottomCanPlayCellIndexPath];
        if (!indexPath) {
            return;
        }
        if ([indexPath compare:self.player.playingIndexPath] != NSOrderedSame) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}


@end
