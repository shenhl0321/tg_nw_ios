//
//  PlayAudioManager.h

FOUNDATION_EXTERN NSString *const IMAudioPlayFinishedNotification;

@interface PlayAudioManager : NSObject <AVAudioPlayerDelegate>

+ (PlayAudioManager *)sharedPlayAudioManager;

@property (assign, nonatomic, readonly, getter = isPlaying) BOOL playing;

//外部主动调用，是否要恢复其他应用后台播放的音乐(有些停止后，立马要进行下一首播放，或者录音的场景，需要设置为NO)
- (void)stopPlayAudio:(BOOL)needResume;

- (void)playAudio:(NSString *)localPath chatId:(long)chatId msgId:(long)msgId;
- (long)getPlayingChatId;
- (long)getPlayingMsgId;
@end
