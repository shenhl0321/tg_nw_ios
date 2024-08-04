//
//  FileInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/11/8.
//

#import "FileInfo.h"

@implementation FileInfoLocal

- (BOOL)isExist
{
    return !IsStrEmpty(self.path) && [[NSFileManager defaultManager] fileExistsAtPath:self.path];
}

@end

@implementation FileInfoRemote

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id"};
}

@end

@implementation FileInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id"};
}

@end

