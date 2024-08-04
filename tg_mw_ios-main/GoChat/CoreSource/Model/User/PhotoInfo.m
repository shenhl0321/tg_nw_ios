//
//  PhotoInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/26.
//

#import "PhotoInfo.h"

@implementation PhotoSizeInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type", @"size_type" : @"type"};
}

- (BOOL)isPhotoDownloaded
{
    if(self.photo != nil && self.photo.local != nil)
    {
        
        return self.photo.local.is_downloading_completed && !IsStrEmpty(self.photo.local.path) && [[NSFileManager defaultManager] fileExistsAtPath:self.photo.local.path];
    }
    return NO;
}

@end

@implementation PhotoInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"sizes" : @"PhotoSizeInfo"};
}

- (PhotoSizeInfo *)messagePhoto
{
    for(PhotoSizeInfo *info in self.sizes)
    {
        if([@"i" isEqualToString:info.size_type])
        {
            if(info.photo.local.isExist)
                return info;
        }
    }
    for(PhotoSizeInfo *info in self.sizes)
    {
        if([@"x" isEqualToString:info.size_type])
        {
            return info;
        }
    }
    if(self.sizes.count>0)
    {
        return self.sizes.firstObject;
    }
    return nil;
}

- (PhotoSizeInfo *)previewPhoto
{
    for(PhotoSizeInfo *info in self.sizes)
    {
        if([@"i" isEqualToString:info.size_type])
        {
            if(info.photo.local.isExist)
                return info;
        }
    }
    for(PhotoSizeInfo *info in self.sizes)
    {
        if([@"y" isEqualToString:info.size_type])
        {
            return info;
        }
    }
    if(self.sizes.count>0)
        return self.sizes.lastObject;
    return nil;
}

@end

@implementation ThumbnailFormatInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

@end

@implementation ThumbnailInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (BOOL)isThumbnailDownloaded
{
    if(self.file != nil && self.file.local != nil)
    {
        return self.file.local.is_downloading_completed && !IsStrEmpty(self.file.local.path)  && [[NSFileManager defaultManager] fileExistsAtPath:self.file.local.path];
    }
    return NO;
}

@end
