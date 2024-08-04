//
//  AudioInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/30.
//

#import "AudioInfo.h"

@implementation AudioInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (NSString *)localAudioPath
{
    //
    if(self.audio.local.isExist)
    {
        return self.audio.local.path;
    }
    //
    if(self.file_name.length>0)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return path;
    }
    return nil;
}

- (BOOL)isAudioDownloaded
{
    //
    if(self.audio.local.isExist)
    {
        return YES;
    }
    //
    if(self.file_name.length>0)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return YES;
    }
    return NO;
}

@end

@implementation VoiceInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (NSString *)localAudioPath
{
    //
    if(self.voice.local.isExist)
    {
        return self.voice.local.path;
    }
    //
    if(self.file_name.length>0)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return path;
    }
    return nil;
}

- (BOOL)isAudioDownloaded
{
    //
    if(self.voice.local.isExist)
    {
        return YES;
    }
    //
    if(self.file_name.length>0)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return YES;
    }
    return NO;
}

@end
