//
//  AnimationInfo.m
//  GoChat
//
//  Created by mac on 2021/7/15.
//

#import "AnimationInfo.h"

@implementation AnimationInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (NSString *)totalSize
{
    return [Common bytesToAvaiUnit:self.animation.expected_size showDecimal:YES];
}

- (NSString *)donwloadSize
{
    return [Common bytesToAvaiUnit:self.animation.local.downloaded_size showDecimal:YES];
}

- (NSString *)localVideoPath
{
    //
    if(self.animation.local.isExist)
    {
        return self.animation.local.path;
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

- (BOOL)isVideoDownloaded
{
    //
    if(self.animation.local.isExist)
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

//- (NSString *)file_name{
//    if (![_file_name hasSuffix:@".gif"]) {
//        _file_name = [_file_name stringByAppendingString:@".gif"];
//    }
//    return _file_name;
//}
//
//- (NSString *)mime_type{
//    if (!_mime_type) {
//        _mime_type = @"image/gif";
//    }
//    return _mime_type;
//}
@end
