//
//  RecordAudio.m

#import "RecordAudio.h"
#import "VoiceConverter.h"

@interface RecordAudio ()

//录完转码后得到的文件名称 wav
@property (strong, nonatomic, readwrite) NSString *fileName;

@property (weak, nonatomic) NSTimer *timer;

@property (strong, nonatomic) AVAudioRecorder *recorder;

@property (assign, nonatomic, readwrite) NSTimeInterval duration;

@end

@implementation RecordAudio

#pragma mark Init
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRecord];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //注册音频录制中断通知
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(handleNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

//接收录制中断事件通知，并处理相关事件
-(void)handleNotification:(NSNotification *)notification
{
    NSArray *allKeys = notification.userInfo.allKeys;
    // 判断事件类型
    if([allKeys containsObject:AVAudioSessionInterruptionTypeKey])
    {
        if(self.recorder != nil && self.isRecording)
        {
            [self stopRecord];
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordStop:)])
            {
                [self.delegate recordStop:self];
            }
        }
    }
}

- (BOOL)isRecording
{
    return self.recorder.isRecording;
}

#pragma mark Record
//开始录音
- (void)beginRecord
{
    if (NO == [RecordAudio prepareRecord])
    {
        NSLog(@"准备录音失败");
        [self stopRecord];
        return;
    }
    
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (error)
    {
        NSLog(@"激活音频会话失败:%@", error);
        [self stopRecord];
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"设置音频会话能力失败:%@", error);
        [self stopRecord];
        return;
    }
    
    //输入录音文件名称
    self.fileName = [[Common generateGuid] stringByAppendingPathExtension:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.fileName]];
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:[RecordAudio recorderSettings] error:&error];
    if (error)
    {
        NSLog(@"初始化播放器失败:%@", error);
        [self stopRecord];
        return;
    }
    
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    [self.recorder record];
    [self.recorder updateMeters];
    
    //
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hasRecordedTime:) userInfo:nil repeats:YES];
}

- (void)hasRecordedTime:(NSTimer *)timer
{
    if (NO == self.recorder.isRecording)
    {
        return;
    }
    NSTimeInterval  timeInterval = self.recorder.currentTime;
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordAudio:recordTime:)])
    {
        [self.delegate recordAudio:self recordTime:timeInterval];
    }
    //定制功能
    if (timeInterval >= 60)
    {
        [self stopRecord];
        if (self.delegate && [self.delegate respondsToSelector:@selector(timeIsOver:)])
        {
            [self.delegate timeIsOver:self];
        }
    }
    else if (timeInterval >= 55 && timeInterval < 60)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(timeRemained:remainedTime:)])
        {
            [self.delegate timeRemained:self remainedTime:60-timeInterval];
        }
    }
}

//不满足一秒的
- (void)stopRecord
{
    if (self.recorder && self.recorder.isRecording)
    {
        self.duration = self.recorder.currentTime;
        [self.recorder stop];
        if (self.duration <= 1)//定制功能
        {
            self.duration = 0;
            [self.recorder deleteRecording];
        }
    }
    
    self.recorder = nil;
    [self.timer invalidate];
    
    [RecordAudio resumeAudioSession];
    //大于1s的才保存
    if (self.duration > 0)
    {
        //[self getAmr];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordStop:)])
    {
        [self.delegate recordStop:self];
    }
}

//编码错误
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"%@", [error description]);
    [self stopRecord];
}

////被中断了
//- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
//{
//    [self stopRecord];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(recordStop:)])
//    {
//        [self.delegate recordStop:self];
//    }
//}
//
//- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
//{
//    //不处理，因为开始中断的时候已经调用停止命令了
//}

+ (void)testMicrophone:(void (^)(BOOL available, BOOL shouldIgnore))block
{
    //ios7及其以后有限制
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)])
    {
        [audioSession requestRecordPermission:^(BOOL granted) {
            
            if (block)
            {
                if ([NSThread isMainThread])
                {
                    block(granted, NO);
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(granted, NO);
                    });
                }
            }
        }];
    }
    else//其他默认可以使用
    {
        if (block)
        {
            block(YES, YES);
        }
    }
}

//在实际录音前先prepare，防止初次录音时阻塞
+ (BOOL)prepareRecord
{
    //应用程序周期内只需操作一次
    static BOOL PreparedRecord = NO;
    if (PreparedRecord == YES)
    {
        return PreparedRecord;
    }
    //一个临时文件
    NSString *audioPath =  [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), @"prepare.wav"];
    NSURL *url = [NSURL fileURLWithPath:audioPath];
    
    NSError *error = nil;
    AVAudioRecorder *tmpRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:[RecordAudio recorderSettings] error:&error];
    if (error)
    {
        NSLog(@"recorder error:%@", error);
        return NO;
    }
    tmpRecorder.meteringEnabled = YES;
    PreparedRecord = [tmpRecorder prepareToRecord];
    
    return PreparedRecord;
}

+ (void)resumeAudioSession
{
    //恢复其他应用的后台播放，入系统的音乐等
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(setActive:withOptions:error:)])
    {
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:NULL];//NS_AVAILABLE_IOS(6_0);
    }
}

#pragma mark Record Setting
+ (NSDictionary *)recorderSettings
{
    NSDictionary *settings = @{
                               AVSampleRateKey:@8000.0,
                               AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                               AVLinearPCMBitDepthKey:@16,
                               AVNumberOfChannelsKey:@1,
                               AVLinearPCMIsBigEndianKey:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVEncoderAudioQualityKey:[NSNumber numberWithInt:AVAudioQualityMedium]
                               };
    return settings;
}

//转码
//- (void)getAmr
//{
//    //NSString *audioWavPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.audioName];
//    //NSString *audioAmrPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.fileName];
//    //[VoiceConverter wavToAmr:audioWavPath amrSavePath:audioAmrPath];
//    //self.audioName = self.fileName;
//}

@end
