//
//  ProfilePhoto.m
//  GoChat
//
//  Created by wangyutao on 2020/11/7.
//

#import "ProfilePhoto.h"

@implementation ProfilePhoto

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id"};
}

- (long)fileBigId
{
    if(self.big != nil)
        return self.big._id;
    return 0;
}

- (long)fileSmallId
{
    if(self.small != nil)
        return self.small._id;
    return 0;
}

- (BOOL)isSmallPhotoDownloaded
{
    if(self.small != nil && self.small.local != nil)
    {
        return self.small.local.is_downloading_completed && !IsStrEmpty(self.small.local.path) && [[NSFileManager defaultManager] fileExistsAtPath:self.small.local.path];
    }
    return NO;
}

- (BOOL)isBigPhotoDownloaded
{
    if(self.big != nil && self.big.local != nil)
    {
        return self.big.local.is_downloading_completed && !IsStrEmpty(self.big.local.path) && [[NSFileManager defaultManager] fileExistsAtPath:self.small.local.path];
    }
    return NO;
}

- (NSString *)localBigPath
{
    if(self.big != nil && self.big.local != nil)
        return self.big.local.path;
    return nil;
}

- (NSString *)localSmallPath
{
    if(self.small != nil && self.small.local != nil)
        return self.small.local.path;
    return nil;
}

@end
