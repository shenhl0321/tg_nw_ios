//
//  VideoPreviewItemViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/28.
//

#import "VideoPreviewItemViewController.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "ZFPlayerConst.h"
#import "VideoResourceLoadManager.h"

@interface VideoPreviewItemViewController ()<BusinessListenerProtocol,AVAssetResourceLoaderDelegate>
@property (nonatomic, weak) IBOutlet UIView *videoContainerView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,assign) BOOL isPlay;
@property (nonatomic, strong) VideoResourceLoadManager *videoLoadManager;

@property (strong, nonatomic) IBOutlet UIView *landscapeVideoContainer;
@property (nonatomic, assign, getter=isLandscapeVideo) BOOL landscapeVideo;

@end

@implementation VideoPreviewItemViewController

- (void)dealloc {
    [self releasePlayer];
    _videoLoadManager = nil;
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self releasePlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.player.viewControllerDisappear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.player.viewControllerDisappear = NO;
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];

    self.view.backgroundColor = [UIColor blackColor];
    self.videoContainerView.backgroundColor = [UIColor blackColor];
    self.landscapeVideoContainer.backgroundColor = UIColor.blackColor;
    self.landscapeVideoContainer.hidden = YES;
    
    if (self.video_message.messageType == MessageType_Video) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(longPressAction:)];
        [self.controlView.portraitControlView addGestureRecognizer:longPress];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        !self.longPressBlock ? : self.longPressBlock();
    }
}

- (void)loadData {
    if (self.video_message.messageType == MessageType_Video) {
        [self loadVideo];
    } else if (self.video_message.messageType == MessageType_Animation) {
        [self loadAnimation];
    } else {
        [self loadDocumentVideo];
    }
}

- (void)loadVideo {
    /// 横视频
    self.landscapeVideo = _video_message.content.video.width > _video_message.content.video.height;
    self.landscapeVideoContainer.hidden = !self.landscapeVideo;
    self.videoContainerView.hidden = self.landscapeVideo;
    _videoLoadManager = [[VideoResourceLoadManager alloc]init];
    //先停止加载过程
    [self stopWaiting];
    VideoInfo *videoInfo = self.video_message.content.video;
    if (!videoInfo.isVideoDownloaded) {
        NSString *appUrl = [NSString stringWithFormat:@"app://video/%ld/%ld/%@", videoInfo.video._id,videoInfo.video.expected_size,videoInfo.mime_type];
        [self setupPlayer:appUrl];
    } else {
        [self setupPlayer:videoInfo.localVideoPath];
    }
}

- (void)loadAnimation {
    //先停止加载过程
    [self stopWaiting];
    AnimationInfo *videoInfo = self.video_message.content.animation;
    if (!videoInfo.animation.local.is_downloading_completed) {
        [self startWaiting];
        if(![[TelegramManager shareInstance] isFileDownloading:videoInfo.animation._id type:FileType_Message_Animation]
           && videoInfo.animation.remote.unique_id.length > 1) {
            //NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.video_message.chat_id, self.video_message._id];
            //[[TelegramManager shareInstance] DownloadFile:key fileId:videoInfo.animation._id download_offset:0 //type:FileType_Message_Animation];
            NSString *appUrl = [NSString stringWithFormat:@"app://video/%ld/%ld/%@", videoInfo.animation._id,videoInfo.animation.expected_size,videoInfo.mime_type];
            [self setupGifPlayer:appUrl];
        }
    } else {
        [self setupGifPlayer:videoInfo.localVideoPath];
    }
}

- (void)loadDocumentVideo {
    //先停止加载过程
    [self stopWaiting];
    DocumentInfo *documentInfo = self.video_message.content.document;
    if (!documentInfo.isFileDownloaded) {//未下载，启动下载
        [self startWaiting];
        if (![[TelegramManager shareInstance] isFileDownloading:documentInfo.document._id type:FileType_Message_Document]
            && documentInfo.document.remote.unique_id.length > 1) {
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.video_message._id, documentInfo.document._id];
            [[TelegramManager shareInstance] DownloadFile:key fileId:documentInfo.document._id download_offset:0 type:FileType_Message_Document];
        }
    } else {
        [self setupPlayer:documentInfo.localFilePath];
    }
}

- (void)setupPlayer:(NSString *)localPath {
    if (IsStrEmpty(localPath)) {
        return;
    }
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    playerManager.player.automaticallyWaitsToMinimizeStalling = NO;
    playerManager.shouldAutoPlay = YES;
    UIView *containerView = self.isLandscapeVideo ? self.landscapeVideoContainer : self.videoContainerView;
    self.controlView.portraitControlView.fullScreenBtn.hidden = !self.isLandscapeVideo;
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:containerView];
    self.player.disableGestureTypes = (ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch);
    self.player.controlView = self.controlView;
    self.player.WWANAutoPlay = YES;
    self.player.pauseWhenAppResignActive = YES;
    NSURL *filrurl = [NSURL fileURLWithPath:localPath];
    if (self.video_message.content.video.isVideoDownloaded) {
        self.player.assetURL = filrurl;
    } else {
        self.player.resourceLoaderDelegate = self.videoLoadManager;
        self.player.assetURL = [NSURL URLWithString:localPath];
    }
    [self.player playTheIndex:0];
    self.player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        [asset replay];
    };
    /// 当播放失败时候调用.
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        [asset play];
    };
    /// 当加载状态改变时候调用.
    self.player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        if (loadState == ZFPlayerLoadStatePrepare) {//ZFPlayerLoadStatePrepare
            [asset play];
        }
    };
    @weakify(self);
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        ((AppDelegate *)[UIApplication.sharedApplication delegate]).allowOrentitaionRotation = isFullScreen;
        if (isFullScreen) {
            self.player.disableGestureTypes = ZFPlayerDisableGestureTypesNone;
            self.controlView.landScapeControlView.lockBtn.hidden = YES;
        } else {
            self.player.disableGestureTypes = (ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch);
        }
    };
}

- (void)setupGifPlayer:(NSString *)localPath {
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    playerManager.player.automaticallyWaitsToMinimizeStalling = NO;
    playerManager.shouldAutoPlay = YES;
    // 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.videoContainerView];
    self.player.controlView = self.controlView;
    self.player.WWANAutoPlay = YES;
    self.player.pauseWhenAppResignActive = YES;
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesAll;
//    self.player.allowOrentitaionRotation = NO;
    NSURL *filrurl = [NSURL fileURLWithPath:localPath];
    NSLog(@"filrurl : %@",filrurl);
    if(self.video_message.content.animation.animation.local.is_downloading_completed){
        self.player.assetURL = filrurl;
    } else {
        self.isPlay = YES;
        self.player.resourceLoaderDelegate = self.videoLoadManager;
        self.player.assetURL = filrurl;//[NSURL URLWithString:localPath];
    }
    [self.player playTheIndex:0];
    self.player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        [asset replay];
    };
    /// 当播放失败时候调用.
    self.player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        [asset play];
    };
    /// 当加载状态改变时候调用.
    self.player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        if (loadState == ZFPlayerLoadStatePrepare) {
            [asset play];
        }
    };
}

- (void)releasePlayer {
    if (self.player) {
        [self.player stop];
        //self.player = nil;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
        _controlView.fastViewAnimated = YES;/// 快进视图是否显示动画，默认NO.
        _controlView.effectViewShow = NO;/// 视频之外区域是否高斯模糊显示，默认YES.
        _controlView.prepareShowLoading = YES;/// prepare时候是否显示loading,默认 NO.
        _controlView.fullScreenMode = ZFFullScreenModeAutomatic;
    }
    return _controlView;
}

- (void)startWaiting
{
    if (!self.activityIndicator)
    {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.view addSubview:activityIndicator];
        activityIndicator.hidesWhenStopped = YES;
        self.activityIndicator = activityIndicator;
    }
    self.activityIndicator.center = self.view.center;
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopWaiting
{
    [self.activityIndicator stopAnimating];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Message_Video_Ok):
        {//@{@"task":task, @"file":fileInfo}
            //            FileInfo *obj = inParam;
            //            if (self.video_message.content.video.video._id == obj._id) {
            //                self.video_message.content.video.video = obj;
            //                if(obj.local.is_downloading_completed){
            //                    self.isPlay = NO;
            //                }
            //                [self loadData];
            //            }

            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                // FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(fileInfo != nil)
                {
                    if(![self.videoLoadManager onUpdateFile:(int)fileInfo._id fileInfo:fileInfo]){
                        if (self.video_message.content.video.video._id == fileInfo._id) {
                            self.video_message.content.video.video = fileInfo;
                            if(fileInfo.local.is_downloading_completed){
                                self.isPlay = NO;
                            }
                            [self loadData];
                        }
                    }
                }
            } else {
                FileInfo *fileInfo = inParam;
                if (self.video_message.content.video.video._id == fileInfo._id) {
                    self.video_message.content.video.video = fileInfo;
                }
                return;
                if(![self.videoLoadManager onUpdateFile:(int)fileInfo._id fileInfo:fileInfo]){
                    if (self.video_message.content.video.video._id == fileInfo._id) {
                        self.video_message.content.video.video = fileInfo;
                        if(fileInfo.local.is_downloading_completed){
                            self.isPlay = NO;
                        }
                        [self loadData];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Animation_Ok):
        {//@{@"task":task, @"file":fileInfo}
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long msgId = [list.lastObject longLongValue];
                        if(self.video_message._id == msgId)
                        {
                            self.self.video_message.content.animation.animation = fileInfo;
                            [self loadData];
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Document_Ok):
        {//@{@"task":task, @"file":fileInfo}
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long msgId = [list.firstObject longLongValue];
                        if(self.video_message._id == msgId)
                        {
                            long fileId = [list.lastObject longLongValue];
                            if(self.video_message.content.document.document._id == fileId)
                            {
                                self.self.video_message.content.document.document = fileInfo;
                                [self loadData];
                            }
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}


@end
