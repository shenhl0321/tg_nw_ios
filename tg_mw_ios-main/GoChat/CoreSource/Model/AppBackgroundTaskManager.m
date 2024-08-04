//
//  AppBackgroundTaskManager.m
//  GoChat
//
//  Created by zlp&hj on 2022/5/16.
//

#import "AppBackgroundTaskManager.h"

@interface AppBackgroundTaskManager ()
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, strong) NSTimer *applyTimer;
@property (nonatomic, strong) NSTimer *taskTimer;
/// <#code#>
@property (nonatomic, strong) UIApplication *app;


@end

@implementation AppBackgroundTaskManager

//提供一个全局静态变量
static AppBackgroundTaskManager *_instance;

+ (instancetype)shareInstance{
    return [[self alloc] init];;
}

//当调用alloc的时候会调用allocWithZone
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        _instance.audioEngine = [[AVAudioEngine alloc] init];
        _instance.app = [UIApplication sharedApplication];
    });
    return _instance;
}
//严谨
//遵从NSCopying协议,可以通过copy方式创建对象
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _instance;
}
//遵从NSMutableCopying协议,可以通过mutableCopy方式创建对象
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return _instance;
}



- (void)startBackgroundTaskWithApp:(UIApplication *)app{
    self.bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [self.app endBackgroundTask:self.bgTask];
//        self.bgTask = UIBackgroundTaskIdentifier.invalid
        [self applyForMoreTime];
        
    }];
    [self stopBackgroundTask];
    self.taskTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"doing some thing:%f", [UIApplication sharedApplication].backgroundTimeRemaining);
    }];
}


- (void)stopBackgroundTask{
    [self.applyTimer invalidate];
    self.applyTimer = nil;
    [self.taskTimer invalidate];
    self.taskTimer = nil;
}
- (void)applyForMoreTime{
    
    if (self.app.backgroundTimeRemaining < 30) {
        self.bgTask = [self.app beginBackgroundTaskWithExpirationHandler:^{
            [self.app endBackgroundTask:self.bgTask];
            [self applyForMoreTime];
        }];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Silence" ofType:@"wav"];
        NSURL *filePathUrl = [NSURL fileURLWithPath:path];
        [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault routeSharingPolicy:AVAudioSessionRouteSharingPolicyDefault options:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePathUrl error:nil];
        [self.audioEngine reset];
        [self.audioPlayer play];
        [self.audioPlayer stop];
    }
    
}

@end




