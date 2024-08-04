//
//  ZyPlayerView.m

#import "ZyPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface ZyPlayerView()
@property (nonatomic) BOOL isSound;
@property (nonatomic) int duration;
@property (nonatomic, strong) NSString *totalLength;
@property (nonatomic, strong) NSString *downloadLength;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) UILabel * titleLabel;
@end

@implementation ZyPlayerView

- (void)dealloc
{
    [self stop];
}

- (void)stop
{
    if(_player)
    {
        [self.player pause];
        self.player = nil;
    }
    [self removeNotification];
}

- (id)initWithFrame:(CGRect)frame
           duration:(int)duration
        totalLength:(NSString *)totalLength
     downloadLength:(NSString *)downloadLength
          localPath:(NSString *)localPath
            isSound:(BOOL)isSound
         coverImage:(UIImage *)coverImage
   placeHodlerImage:(NSString *)imagename
          completed:(BOOL)iscompleted
{
    self = [self initWithFrame:frame];
    if(self)
    {
        self.duration = duration;
        self.totalLength = totalLength;
        self.downloadLength = downloadLength;
        self.coverImage = coverImage;
        self.localPath = localPath;
        self.isSound = isSound;
        
        if([self isVideoExist] && iscompleted)
        {//视频已下载
            //[self addTitleLabel:[NSString stringWithFormat:@"%ds''，%@", self.duration, self.totalLength]];
            [self initPlayer];
        }
        else
        {//视频未下载
            [self initDownloadingViewplaceHodlerImage:imagename];
        }
    }
    return self;
}

//-(void)addNotification{
//    //给AVPlayerItem添加播放完成通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
//}
//
//-(void)removeNotification{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//-(void)playbackFinished:(NSNotification *)notification{
//    NSLog(@"视频播放完成.");
//    // 播放完成后重复播放
//    // 跳到最新的时间点开始播放
//    [_player seekToTime:CMTimeMake(0, 1)];
//    [_player play];
//}

- (BOOL)isVideoExist
{
    if(!IsStrEmpty(_localPath))
    {
        return [Common fileIsExist:_localPath];
    }
    return NO;
}

- (void)initPlayer
{
    if(self.localPath == nil){
        return;
    }
        
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.localPath] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    if(self.isSound)
    {
        self.player.volume = 1;
        self.player.muted = NO;
    }
    else
    {
        self.player.volume = 0;
        self.player.muted = YES;
    }
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:playerLayer];
    [self.player play];
    [self addNotification];
}

- (void)initDownloadingViewplaceHodlerImage:(NSString *)imagename;
{
    [self addPlayIconplaceHodlerImage:imagename];
    NSString *str = [NSString stringWithFormat:@"%@，%@/%@，下载中...", [CZCommonTool getFormatTimeStrWith:self.duration], self.downloadLength, self.totalLength];
    NSLog(@"str111111 : %@",str);
    [self addTitleLabel:str];
}
-(void)reloadDownLoadState:(VideoInfo *)videoInfo{

    self.duration = videoInfo.duration;
    self.totalLength = videoInfo.totalSize;
    self.downloadLength = videoInfo.donwloadSize;
    self.localPath = videoInfo.localVideoPath;
    

    NSString *str = [NSString stringWithFormat:@"%@，%@/%@，下载中...", [CZCommonTool getFormatTimeStrWith:self.duration], self.downloadLength, self.totalLength];
    NSLog(@"str111111 : %@",str);
    self.titleLabel.text = str;
}
- (void)addTitleLabel:(NSString *)title
{
    UILabel *titleLabel = [UILabel new];
    titleLabel.frame = CGRectMake(5, 0, self.bounds.size.width-10, 30);
    titleLabel.font = [UIFont systemFontOfSize:11];
    titleLabel.textColor = COLOR_C3;
    titleLabel.text = title;
    titleLabel.numberOfLines = 0;
    self.titleLabel = titleLabel;
    [self addSubview:titleLabel];
}

- (void)addPlayIconplaceHodlerImage:(NSString *)imagename;
{
    UIImageView *playImageView = [UIImageView new];
    playImageView.image = [UIImage imageNamed:imagename];//@"icon_player"
    CGFloat width = 40;
    CGFloat height = 40;
    playImageView.frame = CGRectMake((self.bounds.size.width-width)/2, (self.bounds.size.height-height)/2, width, height);
    [self addSubview:playImageView];
}

-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveCallBack:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundCallBack:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Application State Change Notification Methods
- (void)didBecomeActiveCallBack:(NSNotification *)notification
{
    if(_player)
        [_player play];
}

- (void)didEnterBackgroundCallBack:(NSNotification *)notification
{
    if(_player)
        [_player pause];
}

-(void)playbackFinished:(NSNotification *)notification
{
    if(_player)
    {
        [_player seekToTime:CMTimeMake(0, 1)];
        [_player play];
    }
}

@end
