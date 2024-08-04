//  PlayAudioManager.m

#import "PlayAudioManager.h"

NSString *const IMAudioPlayFinishedNotification = @"GoChat.AudioPlayFinishedNotification";
@interface PlayAudioManager ()
@property (nonatomic, strong) AVAudioPlayer *musicPlayer;
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic) long msgId;
@property (nonatomic) long chatId;
@end

@implementation PlayAudioManager

- (void)dealloc
{
    //移除近距离传感器通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    //移除设备（耳机）插入|拔出检测
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [self stopPlayAudioWithError:nil resume:YES];
}

+ (PlayAudioManager *)sharedPlayAudioManager
{
    //在主线程上初始化
    static PlayAudioManager *sharedAudioPlay = nil;
    if (sharedAudioPlay)
    {
        return sharedAudioPlay;
    }
    dispatch_block_t block = ^{
        if (sharedAudioPlay == nil)
        {
            sharedAudioPlay = [[PlayAudioManager alloc] init];
        }
    };
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    return sharedAudioPlay;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //添加近距离传感器通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerForProximityState:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        //添加设备（耳机）插入|拔出检测
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChangeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)routeChangeNotification:(NSNotification *)notification
{//监听设备（耳机）插拔通知
    NSDictionary *userInfo = [notification userInfo];
    
    NSNumber *reason = [userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
    AVAudioSessionRouteChangeReason routeChangeReason = [reason integerValue];
    //有设备拔出或者插入
    if (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable
        || routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        if ([self hasHeadset])
        {//耳机可用，不启用侦测
            [self enableProximityMonitoring:NO];
        }
        else
        {//否则，如果正在播放，则启用
            [self enableProximityMonitoring:self.isPlaying];
        }
    }
}

//是否要启用屏幕离热源距离侦测
- (void)enableProximityMonitoring:(BOOL)enable
{
    [UIDevice currentDevice].proximityMonitoringEnabled = enable;
}

//侦测系统发出的屏幕与热源距离变化的通知的处理
-(void)observerForProximityState:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if (self.isPlaying)
    {
        [self stopPlayAudioWithError:nil resume:YES];
    }
}

- (BOOL)hasHeadset
{//检测耳机是否可用
    AVAudioSessionRouteDescription *routeDescription = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *outputDescription in routeDescription.outputs)
    {
        if ([[outputDescription portType] isEqualToString:AVAudioSessionPortHeadphones])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isPlaying
{
    return self.musicPlayer.isPlaying;
}

- (void)playAudio:(NSString *)localPath chatId:(long)chatId msgId:(long)msgId
{
    if (self.isPlaying)
    {
        [self stopPlayAudioWithError:nil resume:NO];
    }
    self.chatId = chatId;
    self.msgId = msgId;
    self.localPath = localPath;
    [self startPlayAudioAtPath:localPath];
}

- (void)startPlayAudioAtPath:(NSString *)path
{
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    //激活当前会话
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
    {
        [self stopPlayAudioWithError:error resume:YES];
        return;
    }
    NSURL *pathUrl = [NSURL fileURLWithPath:path];
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:pathUrl error:&error];
    if (error)
    {
        [self stopPlayAudioWithError:error resume:YES];
        return;
    }
    self.musicPlayer.delegate = self;
    //self.musicPlayer.volume = 1;
    [self.musicPlayer prepareToPlay];
    self.musicPlayer.currentTime = 0.0f;
    [self.musicPlayer play];
    [self enableProximityMonitoring:![self hasHeadset]];
}

- (void)stopPlayAudioWithError:(NSError *)error resume:(BOOL)yesOrNo
{
    if (error)
    {
        NSLog(@"%@", error);
    }
    [self enableProximityMonitoring:NO];
    self.musicPlayer.delegate = nil;
    [self.musicPlayer stop];
    self.musicPlayer = nil;
    
    //恢复其他应用的后台播放，入系统的音乐等
    if (yesOrNo)
    {
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(setActive:withOptions:error:)])
        {
            [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:NULL];
        }
    }
    
    //播放完成后，初始化
    long pre_chatId = self.chatId;
    self.chatId = 0;
    self.msgId = 0;
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:IMAudioPlayFinishedNotification object:[NSNumber numberWithLong:pre_chatId]];
}

- (void)stopPlayAudio:(BOOL)needResume
{
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"%@",error);
    }
    [self stopPlayAudioWithError:nil resume:needResume];
}

#pragma mark AVAudioPlayer Delegate
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self stopPlayAudioWithError:error resume:YES];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlayAudioWithError:nil resume:YES];
}

- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player
{
    [self enableProximityMonitoring:NO];
    [player pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [player play];
    [self enableProximityMonitoring:![self hasHeadset]];
}

- (long)getPlayingMsgId
{
    return self.msgId;
}

- (long)getPlayingChatId
{
    return self.chatId;
}

@end
