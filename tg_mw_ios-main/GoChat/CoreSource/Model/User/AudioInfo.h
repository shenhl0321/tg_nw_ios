//
//  AudioInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/11/30.
//

#import <Foundation/Foundation.h>

@interface AudioInfo : NSObject
//@audio
@property (nonatomic, copy) NSString *type;
@property (nonatomic) int duration;
@property (nonatomic, strong) FileInfo *audio;
//file_name : "DDD5669709F4450BB8F88A2DF910558D.wav"
@property (nonatomic, copy) NSString *file_name;
/// 是否显示转换
@property (nonatomic,assign, getter=isShowTransfer) BOOL showTransfer;
/// 语言转换的文字
@property (nonatomic,copy) NSString *transferText;

- (NSString *)localAudioPath;
- (BOOL)isAudioDownloaded;
@end

@interface VoiceInfo : NSObject
//@audio
@property (nonatomic, copy) NSString *type;
@property (nonatomic) int duration;
@property (nonatomic, strong) FileInfo *voice;
//file_name : "DDD5669709F4450BB8F88A2DF910558D.wav"
@property (nonatomic, copy) NSString *file_name;
/// 是否显示转换
@property (nonatomic,assign, getter=isShowTransfer) BOOL showTransfer;
/// 语言转换的文字
@property (nonatomic,copy) NSString *transferText;
@property (nonatomic,strong) NSString *waveform;

- (NSString *)localAudioPath;
- (BOOL)isAudioDownloaded;
@end
