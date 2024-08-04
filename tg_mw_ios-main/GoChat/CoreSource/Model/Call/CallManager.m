//
//  CallManager.m
//  GoChat
//
//  Created by wangyutao on 2021/3/1.
//

#import "CallManager.h"
#import "AvFloatingView.h"
#import "C2CCallViewController.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

static CallManager *g_callManager = nil;

#define OUTING_RING_ID          1
#define INCOMING_RING_ID        2

@interface CallManager()<AgoraRtcEngineDelegate, TimerCounterDelegate>
@property (nonatomic, strong) LocalCallInfo *curCallInfo;
@property (nonatomic, strong) AvFloatingView *callFv;

//声网sdk
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;

//超时处理
@property (nonatomic, strong) TimerCounter *refresh_Timer;

//本地是否静音
@property (nonatomic) BOOL isLocalVoiceMute;
@property (nonatomic) BOOL isUserControlLocalVoiceMute;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation CallManager

+ (CallManager *)shareInstance
{
    if(g_callManager == nil)
    {
        g_callManager = [[CallManager alloc] init];
    }
    return g_callManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:AgoraRtc_AppId delegate:self];
        AVAudioSession *avSession = [AVAudioSession sharedInstance];
        [avSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [avSession setActive:YES error:nil];
//
//
        //添加设备（耳机）插入|拔出检测
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChangeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
        //
        self.refresh_Timer = [TimerCounter new];
        self.refresh_Timer.delegate = self;
    }
    return self;
}

- (void)reset
{
    
}

//新来电
- (void)newIncomingCall:(RemoteCallInfo *)remoteCall
{
   
    if(remoteCall == nil)
    {
        return;
    }
    
    if(remoteCall.isTimeOut)
    {//通话超时
        //消息显示未接来电
        [[TelegramManager shareInstance] sendLocalCustomMessage:[remoteCall getRealChatId] text:[remoteCall done_jsonForMessage] sender:remoteCall.from resultBlock:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
        }];
        return;
    }
    if([self canNewCall])
    {
        if([self isInCalling])
        {//通话中
            //直接取消
            [[TelegramManager shareInstance] sendLocalCustomMessage:[remoteCall getRealChatId] text:[remoteCall done_jsonForMessage] sender:remoteCall.from resultBlock:^(NSDictionary *request, NSDictionary *response) {
            } timeout:^(NSDictionary *request) {
            }];
        }
        else
        {
            [self playRingtone];
            //语音静音管理
            self.isLocalVoiceMute = NO;
            self.isUserControlLocalVoiceMute = NO;
            //发送接收应答
            [[TelegramManager shareInstance] callInviteAsk:remoteCall.callId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            } timeout:^(NSDictionary *request) {
            }];
            
            self.curCallInfo = [LocalCallInfo callWithRemote:remoteCall];
            if(self.curCallInfo.isMeetingAV)
            {//视频会议模式
                
            }
            else
            {//1vs1语音视频通话
                [self toFullC2CCallView:nil];
            }
            //开启超时处理机制
            [self.refresh_Timer stopCountProcess];
            [self.refresh_Timer startCountProcess:0.5 repeat:YES];
            NSLog(@"添加好友 - 5555555555");
        }
    }
}

//对方取消通话
- (void)cancelCall:(RemoteCallInfo *)remoteCall
{
    if([self isInCalling] && self.curCallInfo.callId == remoteCall.callId)
    {
        self.curCallInfo.callState = CallingState_C2C_Canceled;
        [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"对方已取消视频通话".lv_localized:@"对方已取消语音通话".lv_localized];
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
        [self.callFv resetCallInfo];
        [self destroyCall];
    }
}

//对方离开通话
- (void)leaveCall:(RemoteCallInfo *)remoteCall
{
    if([self isInCalling] && self.curCallInfo.callId == remoteCall.callId)
    {
        if(self.curCallInfo.isMeetingAV)
        {//会议
            
        }
        else
        {
            if(self.curCallInfo.callState == CallingState_In_Calling)
            {
                self.curCallInfo.callState = CallingState_Call_End;
                [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"对方已结束视频通话".lv_localized:@"对方已结束语音通话".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
            }
            else
            {
                self.curCallInfo.callState = CallingState_C2C_Canceled;
                [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"对方已取消视频通话".lv_localized:@"对方已取消语音通话".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
            }
        }
    }
}

//接听电话
- (void)acceptNewCall
{
    if(self.curCallInfo.callState != CallingState_Incoming_Prepare)
    {
        //准备中
        self.curCallInfo.callState = CallingState_Incoming_Prepare;
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
        [self.callFv resetCallInfo];
        //第一步，生成rtc token
        [self newCall_step1_createRtcToken];
    }
}

//是否可以发起新call
- (BOOL)canNewCall
{
    return YES;
}

//是否正在通话
- (BOOL)isInCalling
{
    if(self.curCallInfo != nil)
    {
        if(self.curCallInfo.callState != CallingState_None &&
           self.curCallInfo.callState != CallingState_Outgoing_Prepare_error &&
           self.curCallInfo.callState != CallingState_Canceled &&
           self.curCallInfo.callState != CallingState_Canceled_2_Timeout &&
           self.curCallInfo.callState != CallingState_C2C_Canceled &&
           self.curCallInfo.callState != CallingState_Call_End)
        {
            return YES;
        }
    }
    return NO;
}

- (void)newCall:(LocalCallInfo *)call fromView:(UIViewController *)from
{
    if([self canNewCall] && ![self isInCalling])
    {
        //语音静音管理
        self.isLocalVoiceMute = NO;
        self.isUserControlLocalVoiceMute = NO;
        //
        self.curCallInfo = call;
        //准备中
        self.curCallInfo.callState = CallingState_Outgoing_Prepare;
        if(call.isMeetingAV)
        {//视频会议模式
            
        }
        else
        {//1vs1语音视频通话
            [self toFullC2CCallView:from];
        }
        //第一步，生成rtc token
        [self newCall_step1_createRtcToken];
    }
}

- (void)newCall_step1_createRtcToken
{
    [[TelegramManager shareInstance] createRtcToken:self.curCallInfo.channelName uid:[UserInfo shareInstance]._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(self.curCallInfo.callState == CallingState_Outgoing_Prepare)
        {
            NSString *tokenStr = obj;
            if(!IsStrEmpty(tokenStr))
            {
                self.curCallInfo.rtcToken = tokenStr;
                //下一步
                [self newCall_step2_createCallRequest];
            }
            else
            {
                self.curCallInfo.callState = CallingState_Outgoing_Prepare_error;
                [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"发起视频通话失败".lv_localized:@"发起语音通话失败".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
            }
        }
        if(self.curCallInfo.callState == CallingState_Incoming_Prepare)
        {
            NSString *tokenStr = obj;
            if(!IsStrEmpty(tokenStr))
            {
                self.curCallInfo.rtcToken = tokenStr;
                //下一步
                [self newCall_step2_joinRoom];
            }
            else
            {
                self.curCallInfo.callState = CallingState_Canceled;
                [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"接听视频通话失败".lv_localized:@"接听语音通话失败".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
            }
        }
    } timeout:^(NSDictionary *request) {
        //超时,结束通话
        if(self.curCallInfo.callState == CallingState_Outgoing_Prepare)
        {
            self.curCallInfo.callState = CallingState_Outgoing_Prepare_error;
            [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"发起视频通话失败".lv_localized:@"发起语音通话失败".lv_localized];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            [self destroyCall];
        }
        if(self.curCallInfo.callState == CallingState_Incoming_Prepare)
        {
            self.curCallInfo.callState = CallingState_Canceled;
            [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"接听视频通话失败".lv_localized:@"接听语音通话失败".lv_localized];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            [self destroyCall];
        }
    }];
}

- (void)newCall_step2_createCallRequest
{
    CallBaseInfo *baseInfo = [CallBaseInfo new];
    baseInfo.channelName = self.curCallInfo.channelName;
    baseInfo.from = self.curCallInfo.from;
    baseInfo.to = [NSArray arrayWithArray:self.curCallInfo.to];
    baseInfo.chatId = self.curCallInfo.chatId;
    baseInfo.isMeetingAV = self.curCallInfo.isMeetingAV;
    baseInfo.isVideo = self.curCallInfo.isVideo;
    [[TelegramManager shareInstance] createCall:baseInfo resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(self.curCallInfo.callState == CallingState_Outgoing_Prepare)
        {
            if(obj != nil && [obj isKindOfClass:[NSNumber class]])
            {
                NSNumber *callIdNumber = obj;
                self.curCallInfo.callId = [callIdNumber longValue];
                //进入声网频道
                [self resetAgoraConfig];
                [self.agoraKit joinChannelByToken:self.curCallInfo.rtcToken channelId:self.curCallInfo.channelName info:nil uid:[UserInfo shareInstance]._id joinSuccess:nil];
                [self resetSpeakerMode];
            }
            else
            {
                self.curCallInfo.callState = CallingState_Outgoing_Prepare_error;
                if(obj != nil && [obj isKindOfClass:[NSString class]])
                    [UserInfo showTips:nil des:obj];
                else
                    [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"发起视频通话失败".lv_localized:@"发起语音通话失败".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
            }
        }
    } timeout:^(NSDictionary *request) {
        //超时,结束通话
        if(self.curCallInfo.callState == CallingState_Outgoing_Prepare)
        {
            self.curCallInfo.callState = CallingState_Outgoing_Prepare_error;
            [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"发起视频通话失败".lv_localized:@"发起语音通话失败".lv_localized];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            [self destroyCall];
        }
    }];
}

- (void)newCall_step2_joinRoom
{
    //进入声网频道
    [self resetAgoraConfig];
    [self.agoraKit joinChannelByToken:self.curCallInfo.rtcToken channelId:self.curCallInfo.channelName info:nil uid:[UserInfo shareInstance]._id joinSuccess:nil];
    [self resetSpeakerMode];
}

- (void)destroyCall
{
    //移除近距离传感器通知
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    //
    [self.refresh_Timer stopCountProcess];
    [self stopRingtone];
    //停止呼叫铃声
    [self.agoraKit stopAllEffects];
    
    //离开声网频道
    [self.agoraKit leaveChannel:nil];
    //移除小窗口
    [self removeSmallTopView];
    //生成本地消息
    if(!self.curCallInfo.isSendedLocalMsg)
    {
        self.curCallInfo.isSendedLocalMsg = YES;
        self.curCallInfo.endTime = [NSDate new].timeIntervalSince1970;
        [[TelegramManager shareInstance] sendLocalCustomMessage:[self.curCallInfo getRealChatId] text:[self.curCallInfo done_jsonForMessage] sender:self.curCallInfo.from resultBlock:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
        }];
    }
}

//结束call
- (void)endCurrentCall
{
    if(self.curCallInfo != nil)
    {
        if([self isInCalling])
        {
            if(self.curCallInfo.callState == CallingState_In_Calling)
            {//通话中
                self.curCallInfo.callState = CallingState_Call_End;
                [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"视频通话已结束".lv_localized:@"语音通话已结束".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
                //发出结束通话报文
                [[TelegramManager shareInstance] stopCall:self.curCallInfo.callId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                } timeout:^(NSDictionary *request) {
                }];
                return;
            }
            else
            {
                self.curCallInfo.callState = CallingState_Canceled;
                [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"视频通话已取消".lv_localized:@"语音通话已取消".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
                //发出取消通话报文
                if([self isIncoming])
                {//来电
                    [[TelegramManager shareInstance] stopCall:self.curCallInfo.callId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    } timeout:^(NSDictionary *request) {
                    }];
                }
                else
                {
                    [[TelegramManager shareInstance] cancelCall:self.curCallInfo.callId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    } timeout:^(NSDictionary *request) {
                    }];
                }
                return;
            }
        }
    }
    [self destroyCall];
}

//获得当前通话状态
- (CallingState)currentCallState
{
    if(self.curCallInfo != nil)
    {
        return self.curCallInfo.callState;
    }
    return CallingState_None;
}

//获得c2c user
- (UserInfo *)c2cUser
{
    if(self.curCallInfo != nil && !self.curCallInfo.isMeetingAV)
    {
        if(![self isIncoming])
        {
            if(self.curCallInfo.to != nil && self.curCallInfo.to.count==1)
            {
                NSNumber *userId = self.curCallInfo.to.firstObject;
                return [[TelegramManager shareInstance] contactInfo:[userId longValue]];
            }
        }
        else
        {
            return [[TelegramManager shareInstance] contactInfo:self.curCallInfo.from];
        }
    }
    return nil;
}

//获得c2c userid
- (long)c2cUserId
{
    if(self.curCallInfo != nil && !self.curCallInfo.isMeetingAV)
    {
        if(![self isIncoming])
        {
            if(self.curCallInfo.to != nil && self.curCallInfo.to.count==1)
            {
                NSNumber *userId = self.curCallInfo.to.firstObject;
                return userId.longValue;
            }
        }
        else
        {
            return self.curCallInfo.from;
        }
    }
    return 0;
}

//是否视频
- (BOOL)isVideo
{
    return self.curCallInfo.isVideo;
}

//是否来电
- (BOOL)isIncoming
{
    return self.curCallInfo.from != [UserInfo shareInstance]._id;
}

#pragma mark - 设置声网配置
- (void)resetAgoraConfig
{
    [self.agoraKit setChannelProfile:AgoraChannelProfileCommunication];
    if(self.isVideo)
    {//视频
        int i = [self.agoraKit enableVideo];
        NSLog(@"enableVideo:%d", i);
        [self.agoraKit muteLocalVideoStream:YES];
    }
    else
    {//语音
        int i = [self.agoraKit disableVideo];
        NSLog(@"disableVideo:%d", i);
        i = [self.agoraKit enableAudio];
        NSLog(@"enableAudio:%d", i);
        [self.agoraKit muteLocalAudioStream:YES];
    }
}

- (void)resetSpeakerMode
{
    if(self.isVideo)
    {//视频
        if([self hasHeadset])
        {//已插入耳机
            [self.agoraKit setEnableSpeakerphone:NO];
        }
        else
        {
            //默认麦克风模式
            [self.agoraKit setEnableSpeakerphone:YES];
        }
    }
    else
    {//语音
        //默认听筒模式
        [self.agoraKit setEnableSpeakerphone:NO];
    }
}

//检测耳机是否可用
- (BOOL)hasHeadset
{
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

- (void)routeChangeNotification:(NSNotification *)notification
{//监听设备（耳机）插拔通知
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *reason = [userInfo objectForKey:AVAudioSessionRouteChangeReasonKey];
    AVAudioSessionRouteChangeReason routeChangeReason = [reason integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable
        || routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Headset_State_Changed) withInParam:nil];
    }
}

//切换麦克风模式
- (void)enableSpeaker:(BOOL)speaker
{
    [self.agoraKit setEnableSpeakerphone:speaker];
}

- (BOOL)isEnableSpeaker
{
    return [self.agoraKit isSpeakerphoneEnabled];
}

//是否静音
- (void)muteLocalAudio
{
    self.isUserControlLocalVoiceMute = YES;
    self.isLocalVoiceMute = !self.isLocalVoiceMute;
    if(self.currentCallState == CallingState_In_Calling)
    {
        [self.agoraKit muteLocalAudioStream:self.isLocalVoiceMute];
    }
    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_Local_Voice_Mute_Changed) withInParam:nil];
}

- (BOOL)isMuteLocalAudio
{
    return self.isLocalVoiceMute;
}

//是否禁止本地视频
- (void)muteLocalVideo:(BOOL)mute
{
    [self.agoraKit muteLocalVideoStream:mute];
}

//摄像头切换
- (void)toggleCamera
{
    [self.agoraKit switchCamera];
}

//显示本地视频
- (void)showLocalVideoToView:(UIView *)view
{
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = 0;
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    videoCanvas.view = view;
    int i = [self.agoraKit setupLocalVideo:videoCanvas];
    NSLog(@"setupLocalVideo:%d", i);
}

//显示本地视频
- (void)showRemoteVideoToView:(UIView *)view
{
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = [self c2cUserId];
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    videoCanvas.view = view;
    int i = [self.agoraKit setupRemoteVideo:videoCanvas];
    NSLog(@"showRemoteVideoToView:%d", i);
}

//获取通话时间
- (NSString *)callDisplayTime
{
    return self.curCallInfo.displayCallTime;
}

#pragma mark - 大窗口
- (void)toFullC2CCallView:(UIViewController *)from
{
    [self hideSmallTopView];
    C2CCallViewController *callCV = [[UIStoryboard storyboardWithName:@"Call" bundle:nil] instantiateInitialViewController];
    callCV.hidesBottomBarWhenPushed = YES;
    callCV.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    callCV.modalPresentationStyle = UIModalPresentationFullScreen;
    if(from != nil)
    {
//        [from.navigationController pushViewController:v animated:YES];
        [from presentViewController:callCV animated:YES completion:nil];
    }
    else
    {
//        [[self getCurrentVC].navigationController pushViewController:v animated:YES];
        [[self getCurrentVC] presentViewController:callCV animated:YES completion:nil];
    }
    
    //    [[CallManager shareInstance] playRingtone];
    

}

#pragma mark - 小窗口
//显示置顶小窗口
- (void)showSmallTopView
{
    if(self.callFv)
    {
        self.callFv.hidden = NO;
    }
    else
    {
        AvFloatingView *fv = [[[UINib nibWithNibName:@"AvFloatingView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
        fv.center = CGPointMake(SCREEN_WIDTH-45, 200);
        fv.clickDragViewBlock = ^(FloatingView *dragView) {
            if(self.curCallInfo.isMeetingAV)
            {
                
            }
            else
            {
                [self toFullC2CCallView:nil];
            }
        };
        [[UIApplication sharedApplication].delegate.window addSubview:fv];
        [[UIApplication sharedApplication].delegate.window bringSubviewToFront:fv];
        self.callFv = fv;
        [self.callFv resetCallInfo];
    }
}

//隐藏置顶小窗口
- (void)hideSmallTopView
{
    if(self.callFv)
    {
        self.callFv.hidden = YES;
    }
}

//关闭置顶小窗口
- (void)removeSmallTopView
{
    if(self.callFv != nil)
    {
        [self.callFv removeFromSuperview];
        self.callFv = nil;
    }
}

//是否存在了置顶小窗口
- (BOOL)isHaveSmallTopView
{
    return self.callFv != nil;
}

//小窗口目前的rect
- (CGRect)smallTopViewRect
{
    if(self.callFv != nil)
    {
        return self.callFv.frame;
    }
    return CGRectMake(SCREEN_WIDTH-90, 200, 90, 90);
}

- (void)outingRingtone {
//    播放呼叫铃声
    NSString *soundPath =  [[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"mp3"];
    [self.agoraKit playEffect:OUTING_RING_ID filePath:soundPath loopCount:0 pitch:1.0f pan:1.0f gain:100.0f publish:NO startPos:0];
    [self playRingtone];
}



- (void)playRingtone {
   
    if (!self.audioPlayer) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"ringtone" withExtension:@"mp3"];
        NSError *error;
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        self.audioPlayer = player;
        self.audioPlayer.volume = 0.3f;
        [player prepareToPlay];
    }
    [self.audioPlayer play];
}

- (void)stopRingtone {
    //停止呼叫铃声
    [self.agoraKit stopEffect:OUTING_RING_ID];
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}


#pragma mark - 获取当前视图
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController])
    {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]])
    {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]])
    {
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    }
    else
    {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

#pragma mark - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOccurError:(AgoraErrorCode)errorCode
{
    NSLog(@"AgoraRtc->didOccurError:%ld", errorCode);
    //    - `-2`(`AgoraErrorCodeInvalidArgument`): The parameter is invalid.
    //    - `-3`(`AgoraErrorCodeNotReady`): The SDK fails to be initialized. You can try re-initializing the SDK.
    //    - `-5`(`AgoraErrorCodeRefused`): The request is rejected. This may be caused by the following:
    if(self.curCallInfo.callState == CallingState_Outgoing_Prepare)
    {
        if(errorCode == AgoraErrorCodeInvalidArgument ||
           errorCode == AgoraErrorCodeNotReady ||
           errorCode == AgoraErrorCodeRefused)
        {
            self.curCallInfo.callState = CallingState_Outgoing_Prepare_error;
            [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"发起视频通话失败".lv_localized:@"发起语音通话失败".lv_localized];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            [self destroyCall];
        }
    }
    if(self.curCallInfo.callState == CallingState_Incoming_Prepare)
    {
        if(errorCode == AgoraErrorCodeInvalidArgument ||
           errorCode == AgoraErrorCodeNotReady ||
           errorCode == AgoraErrorCodeRefused)
        {
            self.curCallInfo.callState = CallingState_Canceled;
            [UserInfo showTips:nil des:self.curCallInfo.isVideo?@"接听视频通话失败".lv_localized:@"接听语音通话失败".lv_localized];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            [self destroyCall];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{//当前用户加入频道
    NSLog(@"AgoraRtc->didJoinChannel:%@,%ld,%ld", channel, uid, elapsed);
    if(!IsStrEmpty(channel) && [channel isEqualToString:self.curCallInfo.channelName])
    {//当前通话，已成功加入频道
        if(self.curCallInfo.isMeetingAV)
        {//会议
        }
        else
        {//单聊
            if(self.curCallInfo.callState == CallingState_Outgoing_Prepare)
            {
                //呼叫中
                self.curCallInfo.callState = CallingState_Outgoing_Calling;
                self.curCallInfo.callTime = [NSDate new].timeIntervalSince1970;
                //开启超时处理机制
                [self.refresh_Timer stopCountProcess];
                [self.refresh_Timer startCountProcess:0.5 repeat:YES];
                NSLog(@"添加好友 - 6666666666");
                //通知页面刷新
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                //呼叫铃声
                [self outingRingtone];
            }
            else if(self.curCallInfo.callState == CallingState_Incoming_Prepare)
            {
                
                self.curCallInfo.incoming_join_time = [NSDate new].timeIntervalSince1970;
                //开启超时处理机制
                [self.refresh_Timer stopCountProcess];
                [self.refresh_Timer startCountProcess:0.5 repeat:YES];
                NSLog(@"添加好友 - 66666666666");
            }
            else
            {//异常处理
            }
        }
    }
    else
    {//异常处理
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didRejoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{//当前用户重新加入频道
    NSLog(@"AgoraRtc->didRejoinChannel:%@,%ld,%ld", channel, uid, elapsed);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didLeaveChannelWithStats:(AgoraChannelStats * _Nonnull)stats
{//当前用户离开频道
    NSLog(@"AgoraRtc->didLeaveChannelWithStats:%@", stats);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{//对方加入频道
    NSLog(@"AgoraRtc->didJoinedOfUid:%ld,%ld", uid, elapsed);
    if(self.curCallInfo.isMeetingAV)
    {//会议
    }
    else
    {//单聊
        if(self.isIncoming)
        {//来电
            if(self.curCallInfo.callState == CallingState_Incoming_Prepare)
            {
                //已加入通话
                //停止呼叫铃声
                [self stopRingtone];
                
                [[TelegramManager shareInstance] startCall:self.curCallInfo.callId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                } timeout:^(NSDictionary *request) {
                }];
                //
                self.curCallInfo.callState = CallingState_In_Calling;
                self.curCallInfo.startTime = [NSDate new].timeIntervalSince1970;
                //开启通话时间刷新机制
                [self.refresh_Timer stopCountProcess];
                [self.refresh_Timer startCountProcess:0.5 repeat:YES];
                NSLog(@"添加好友 - 8888888888");
                //通知页面刷新
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                
                //添加近距离传感器通知
                [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerForProximityState:) name:UIDeviceProximityStateDidChangeNotification object:nil];
                //开启本地语音或者视频
                if(self.isVideo)
                {//视频
                    [self.agoraKit muteLocalVideoStream:NO];
                }
                else
                {//语音
                    if(self.isUserControlLocalVoiceMute)
                    {
                        [self.agoraKit muteLocalAudioStream:self.isLocalVoiceMute];
                    }
                    else
                    {
                        self.isLocalVoiceMute = NO;
                        [self.agoraKit muteLocalAudioStream:self.isLocalVoiceMute];
                    }
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_Local_Voice_Mute_Changed) withInParam:nil];
                }
            }
            else
            {//异常处理
            }
        }
        else
        {//呼出-等待对方进入则会话开始
            //已加入通话
            [[TelegramManager shareInstance] startCall:self.curCallInfo.callId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            } timeout:^(NSDictionary *request) {
            }];
            //
            self.curCallInfo.callState = CallingState_In_Calling;
            self.curCallInfo.startTime = [NSDate new].timeIntervalSince1970;
            //通知页面刷新
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            //停止呼叫铃声
            [self stopRingtone];
            //添加近距离传感器通知
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerForProximityState:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            //开启本地语音或者视频
            if(self.isVideo)
            {//视频
                [self.agoraKit muteLocalVideoStream:NO];
            }
            else
            {//语音
                if(self.isUserControlLocalVoiceMute)
                {
                    [self.agoraKit muteLocalAudioStream:self.isLocalVoiceMute];
                }
                else
                {
                    self.isLocalVoiceMute = NO;
                    [self.agoraKit muteLocalAudioStream:self.isLocalVoiceMute];
                }
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_Local_Voice_Mute_Changed) withInParam:nil];
            }
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{//对方离开频道
    NSLog(@"AgoraRtc->didJoinedOfUid:%ld,%ld", uid, reason);
    if(self.curCallInfo.callState == CallingState_In_Calling)
    {
        if(self.curCallInfo.isMeetingAV)
        {//会议
        }
        else
        {
            self.curCallInfo.callState = CallingState_C2C_Canceled;
            [UserInfo showTips:nil des:@"对方已挂断".lv_localized];
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
            [self.callFv resetCallInfo];
            [self destroyCall];
        }
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didAudioRouteChanged:(AgoraAudioOutputRouting)routing
{
    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Headset_State_Changed) withInParam:nil];
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didAudioPublishStateChange:(NSString *_Nonnull)channel oldState:(AgoraStreamPublishState)oldState newState:(AgoraStreamPublishState)newState elapseSinceLastState:(NSInteger)elapseSinceLastState
{
    NSLog(@"AgoraRtc->didAudioPublishStateChange:%@,%ld,%ld", channel, oldState, newState);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed
{
    NSLog(@"AgoraRtc->firstLocalVideoFrameWithSize:%@,%ld", NSStringFromCGSize(size), elapsed);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed
{
    NSLog(@"AgoraRtc->firstRemoteVideoDecodedOfUid:%ld,%@,%ld", uid, NSStringFromCGSize(size), elapsed);
}

#pragma mark - TimerCounterDelegate
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    if(self.curCallInfo.callState == CallingState_In_Calling)
    {//通话中
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Refresh_Call_Time) withInParam:nil];
        [self.callFv resetCallInfo];
    }
    else
    {
        if(self.curCallInfo.callState == CallingState_Outgoing_Calling)
        {//呼叫中-超时检测
            if(self.curCallInfo.callTime>0)
            {
                int intervel = [NSDate new].timeIntervalSince1970 - self.curCallInfo.callTime;
                if(intervel>30)
                {//已超时
                    self.curCallInfo.callState = CallingState_Canceled_2_Timeout;
                    [UserInfo showTips:nil des:@"对方无应答".lv_localized];
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                    [self.callFv resetCallInfo];
                    [self destroyCall];
                }
            }
        }
        if(self.curCallInfo.callState == CallingState_Incoming_Waiting)
        {//来电-超时检测
            if(self.curCallInfo.callTime>0)
            {
                int intervel = [NSDate new].timeIntervalSince1970 - self.curCallInfo.callTime;
                if(intervel>30)
                {//已超时
                    self.curCallInfo.callState = CallingState_Canceled_2_Timeout;
                    [UserInfo showTips:nil des:@"接听超时".lv_localized];
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                    [self.callFv resetCallInfo];
                    [self destroyCall];
                }
            }
        }
        if(self.curCallInfo.incoming_join_time>0 && self.curCallInfo.callState == CallingState_Incoming_Prepare)
        {
            int intervel = [NSDate new].timeIntervalSince1970 - self.curCallInfo.callTime;
            if(intervel>3)
            {//已超时
                self.curCallInfo.callState = CallingState_Canceled_2_Timeout;
                [UserInfo showTips:nil des:@"接听超时".lv_localized];
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Call_State_Changed) withInParam:nil];
                [self.callFv resetCallInfo];
                [self destroyCall];
            }
        }
    }
}

//侦测系统发出的屏幕与热源距离变化的通知的处理
-(void)observerForProximityState:(NSNotification *)notification
{
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        [[UIScreen mainScreen] setWantsSoftwareDimming:NO];
    }
    else
    {
        [[UIScreen mainScreen] setWantsSoftwareDimming:YES];
    }
}

@end
