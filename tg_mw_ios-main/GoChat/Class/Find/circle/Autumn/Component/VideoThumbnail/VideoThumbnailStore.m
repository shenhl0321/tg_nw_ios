//
//  VideoThumbnailStore.m
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import "VideoThumbnailStore.h"

@implementation VideoThumbnailStore

+ (BOOL)storeImage:(UIImage *)image withVideoName:(NSString *)name {
    name = [name componentsSeparatedByString:@"."].firstObject;
    NSData *data = [image compressToDataWithMaxLength:200 * 1024];
    NSString *path = UserThumbnailPath(UserInfo.shareInstance._id);
    NSString *imagePath = [path stringByAppendingPathComponent:name];
    if ([NSFileManager.defaultManager fileExistsAtPath:imagePath]) {
        return NO;
    }
    return [data writeToFile:imagePath atomically:YES];
}

+ (UIImage *)imageWithVideoName:(NSString *)name {
    name = [name componentsSeparatedByString:@"."].firstObject;
    NSString *path = UserThumbnailPath(UserInfo.shareInstance._id);
    NSString *imagePath = [path stringByAppendingPathComponent:name];
    return [UIImage imageWithContentsOfFile:imagePath];
}

@end
