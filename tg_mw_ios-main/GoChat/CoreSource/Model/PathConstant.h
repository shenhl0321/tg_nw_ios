//
//  PathConstant.h
//
//  Created by wyy on 9/4/14.
//  Copyright (c) 2014 suning. All rights reserved.
//

#ifndef GoChat_Mac_PathConstant_h
#define GoChat_Mac_PathConstant_h

static inline void CreateDirectory(NSString *path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL isExist = [fileManager fileExistsAtPath:path
                                     isDirectory:&isDir];
    if (!isExist)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
}

//公共图像、语音、视频文件目录
//static inline NSString *PublicMediaPath()
//{
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache/public/medias"];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

//公共本地文件目录
//static inline NSString *PublicLocalFilePath()
//{
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache/public/media/files"];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

//公共偏好设置、数据库等目录
static inline NSString *PublicPreferencesPath()
{
    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache/public/preferences"];
    CreateDirectory(mediaPath);
    return mediaPath;
}

static inline NSString *AuthUserPath(NSString *name)
{
    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"cache/auth/%@", name]];
    CreateDirectory(mediaPath);
    return mediaPath;
}

//用户图片目录
static inline NSString *UserImagePath(long userId)
{
    if (userId<=0)
    {
        return @"";
    }

    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld/media/images", userId]];
    CreateDirectory(mediaPath);
    return mediaPath;
}

//用户视频目录
static inline NSString *UserVideoPath(long userId)
{
    if (userId<=0)
    {
        return @"";
    }

    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld/media/videos", userId]];
    CreateDirectory(mediaPath);
    return mediaPath;
}

//用户文件目录
static inline NSString *UserFilePath(long userId)
{
    if (userId<=0)
    {
        return @"";
    }

    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld/media/files", userId]];
    CreateDirectory(mediaPath);
    return mediaPath;
}

/// 用户缩略图目录
static inline NSString *UserThumbnailPath(long userId)
{
    if (userId<=0)
    {
        return @"";
    }

    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
                           (NSLibraryDirectory, NSUserDomainMask, YES)
                           objectAtIndex:0];
    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld/media/thumbnail", userId]];
    CreateDirectory(mediaPath);
    return mediaPath;
}

//用户本地文件目录
//static inline NSString *UserLocalFilePath()
//{
//    NSString *jid = [UserInfo shareInstance].jid;
//    if (IsStrEmpty(jid))
//    {
//        return @"";
//    }
//
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
//    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/media/file", jid]];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

//用户缩略图目录
//static inline NSString *UserThumbnailImagePath()
//{
//    NSString *jid = [UserInfo shareInstance].jid;
//    if (IsStrEmpty(jid))
//    {
//        return @"";
//    }
//
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
//    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/media/image_thumbnail", jid]];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

//用户语音目录
//static inline NSString *UserVoicePath()
//{
//    NSString *jid = [UserInfo shareInstance].jid;
//    if (IsStrEmpty(jid))
//    {
//        return @"";
//    }
//
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
//    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/media/voice", jid]];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

//用户自定义表情
//static inline NSString *UserEmotionPath()
//{
//    NSString *jid = [UserInfo shareInstance].jid;
//    if (IsStrEmpty(jid))
//    {
//        return @"";
//    }
//
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
//    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/Emotion/Custom", jid]];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

//用户偏好设置、数据库等目录
//static inline NSString *UserPreferencesPath()
//{
//    NSString *jid = [UserInfo shareInstance].jid;
//    if (IsStrEmpty(jid))
//    {
//        return @"";
//    }
//    
//    NSString *mediaPath = [NSSearchPathForDirectoriesInDomains
//                           (NSLibraryDirectory, NSUserDomainMask, YES)
//                           objectAtIndex:0];
//    mediaPath = [mediaPath stringByAppendingPathComponent:@"cache"];
//    mediaPath = [mediaPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/preferences", jid]];
//    CreateDirectory(mediaPath);
//    return mediaPath;
//}

#endif
