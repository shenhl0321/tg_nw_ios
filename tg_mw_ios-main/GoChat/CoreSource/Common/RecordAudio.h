//
//  RecordAudio.h

@class RecordAudio;
@protocol RecordAudioDelegate <NSObject>
@optional

//定制功能
//录音时间超过55s的剩余时间
- (void)timeRemained:(RecordAudio *)recordAudio remainedTime:(double)remainedTime;

//录音时间被用完了 60s时候回调
- (void)timeIsOver:(RecordAudio *)recordAudio;

//已经录了多长时间的回调
- (void)recordAudio:(RecordAudio *)recordAudio recordTime:(NSTimeInterval)time;

//录音结束了一般,内部中断导致的结束等，手动调用stopRecord也会进入
- (void)recordStop:(RecordAudio *)recordAudio;
@end

@interface RecordAudio : NSObject <AVAudioRecorderDelegate>
//录完的文件名称
@property (strong, nonatomic, readonly) NSString *fileName;
//时长
@property (assign, nonatomic, readonly) NSTimeInterval duration;

@property (assign, nonatomic) id<RecordAudioDelegate>delegate;

@property (assign, readonly, getter = isRecording) BOOL recording;

//外部调用该类录音前，需要优先调用该方法，available表示是否可用，shouldIgnore表示可以忽略该block，因为ios7之前的版本默认可用
+ (void)testMicrophone:(void (^)(BOOL available, BOOL shouldIgnore))block;

//开始录音
- (void)beginRecord;

//外部调用，由外部终止录音
- (void)stopRecord;

@end
