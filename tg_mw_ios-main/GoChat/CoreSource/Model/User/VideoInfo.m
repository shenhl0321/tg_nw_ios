//
//  VideoInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/30.
//

#import "VideoInfo.h"
#import "UIImage+Ext.h"
@implementation VideoInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (NSString *)totalSize
{
    return [Common bytesToAvaiUnit:self.video.expected_size showDecimal:YES];
}

- (NSString *)donwloadSize
{
    return [Common bytesToAvaiUnit:self.video.local.downloaded_size showDecimal:YES];
}

- (NSString *)localVideoPath {
    if (self.video.local.isExist && self.video.local.is_downloading_completed) {
        return self.video.local.path;
    }
    if (self.file_name.length>0) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return path;
    }
    return nil;
}

- (BOOL)isVideoDownloaded {
    //
//    if (self.video.local.isExist) {
//        return YES;
//    }
    //
    if (self.video.local.is_downloading_completed) {
        return YES;
    }
    NSString *ext = self.video.local.path.pathExtension;
    if (ext && ext.length > 0) {
        if([[NSFileManager defaultManager] fileExistsAtPath:self.video.local.path])
            return YES;
    }
    if (self.file_name.length>0) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.file_name];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
            return YES;
    }
    return NO;
}


- (UIImage *)coverImg{
    if (!_coverImg) {
        if (self.localVideoPath == nil) {
            return nil;
        }
        _coverImg = [UIImage thumbnailForVideoPath:self.localVideoPath];
    }
    return _coverImg;
}

- (NSString *)durationTime{
    if (!_durationTime) {
        _durationTime = [Common timeFormatted:self.duration];
    }
    return _durationTime;
}

@end

