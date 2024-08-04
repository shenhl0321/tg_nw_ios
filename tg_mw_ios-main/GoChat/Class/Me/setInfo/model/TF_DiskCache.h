//
//  TF_DiskCache.h
//  GoChat
//
//  Created by apple on 2022/2/15.
//

#import <Foundation/Foundation.h>


@interface TF_DiskCache : NSObject

/**
 *  获取目录中文件总大小
 *  @param path 目录名
 *  @return 文件总大小 (单位：MB）
 */
+ (CGFloat)getCacheSizeInPath:(NSString *)path;

/**
 *  清理目录中的文件
 *
 *  @param path 目录名
 */
+ (void)clearCacheInPath:(NSString *)path;


/// 获取当前设备可用内存(单位：GB）
+ (NSString *)freeDiskSpaceInGB;

/// 获取当前设备可用内存(单位：MB）
+ (CGFloat )freeDiskSpaceInMB;

/// 获取gochat的缓存大小
+ (CGFloat )goChatCacheSize;

/// 清除gochat的缓存
+ (void)goChatCacheClear;
@end

