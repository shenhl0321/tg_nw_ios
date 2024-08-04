//
//  TF_DiskCache.m
//  GoChat
//
//  Created by apple on 2022/2/15.
//

#import "TF_DiskCache.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "SDImageCache.h"
@implementation TF_DiskCache

+ (CGFloat)getCacheSizeInPath:(NSString *)path {
    
    if (!path) {
        return 0;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 目录下的文件计算大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        //SDWebImage的缓存计算
//        size += [[SDImageCache sharedImageCache] totalDiskSize];
        // 将大小转化为M
        return size / 1024.0 / 1024.0;
    }
    return size;
}

+ (void)clearCacheInPath:(NSString *)path {
    if (!path) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            /* 判断是否存在该文件路径, 存在就清除 */
            NSError *error = nil;
            if ([fileManager fileExistsAtPath:absolutePath]) {
                [fileManager removeItemAtPath:absolutePath error:&error];
            }
        }
    }
    //SDWebImage的清除功能
    [[SDImageCache sharedImageCache] clearMemory];
    
}

+ (double)getDeviceAvailableMemory{

    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }

    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;

}

+ (NSString *)freeDiskSpaceInGB
{
    return [NSByteCountFormatter stringFromByteCount:self.freeDiskSpaceInBytes countStyle:NSByteCountFormatterCountStyleDecimal];
}

+ (CGFloat )freeDiskSpaceInMB
{
    return ((self.freeDiskSpaceInBytes) / 1024.0) / 1024.0;
}

+ (NSString *)MBFormatter:(long long)byte
{
    NSByteCountFormatter * formater = [[NSByteCountFormatter alloc]init];
    formater.allowedUnits = NSByteCountFormatterUseGB;
    formater.countStyle = NSByteCountFormatterCountStyleDecimal;
    formater.includesUnit = false;
    return [formater stringFromByteCount:byte];
}

+ (long)freeDiskSpaceInBytes
{
    if (@available(iOS 11.0, *)) {
        [NSURL alloc];
        NSURL * url = [[NSURL alloc]initFileURLWithPath:[NSString stringWithFormat:@"%@",NSHomeDirectory()]];
        NSError * error = nil;
        NSDictionary<NSURLResourceKey, id> * dict = [url resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:&error];
        if (error) {
            return 0;
        }
        long long space = [dict[NSURLVolumeAvailableCapacityForImportantUsageKey] longLongValue];
        return space;
    } else {
        NSError * error = nil;
        NSDictionary<NSFileAttributeKey, id> * systemAttributes =  [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
        if (error) {
            return 0;
        }
        long long space = [systemAttributes[NSFileSystemFreeSize] longLongValue];
        return space;
    }
}

+ (CGFloat )goChatCacheSize{
    
    NSArray *paths = [self goChatCachePaths];
    CGFloat total = 0;
    for (NSString *filePath in paths) {
        total += [TF_DiskCache getCacheSizeInPath:filePath];
    }
    
    return total;
}

+ (void)goChatCacheClear{

    NSArray *paths = [self goChatCachePaths];
    for (NSString *filePath in paths) {
        [TF_DiskCache clearCacheInPath:filePath];
    }
}

+ (NSArray *)goChatCachePaths{
    NSMutableArray *filePaths = [NSMutableArray array];
    
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *Cookies = [libraryPath stringByAppendingPathComponent:@"Cookies"];
    
    [filePaths addObject:Cookies];
    
    NSString *cache = [libraryPath stringByAppendingPathComponent:@"cache"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cache]) {
        NSArray *childrenFiles = [fileManager contentsOfDirectoryAtPath:cache error:nil];
        for (NSString *fileName in childrenFiles) {
            NSString *absolutePath = [cache stringByAppendingPathComponent:fileName];
            // Library/cache/2962CB73A77E421E8238125C089F19E2/photos/1479291952597323776_3.jpg
            if ([fileName isEqualToString:@"auth"]) {
                // 2962CB73A77E421E8238125C089F19E2
                NSArray *authChilds = [fileManager contentsOfDirectoryAtPath:absolutePath error:nil];
                // photos videos
                for (NSString *authChildFN in authChilds) {
                    NSString *authChildABPath = [absolutePath stringByAppendingPathComponent:authChildFN];
                    NSArray *lastChilds = [fileManager contentsOfDirectoryAtPath:authChildABPath error:nil];
                    for (NSString *lastFN in lastChilds) {
                        
                        
//                        [lastFN isEqualToString:@"profile_photos"] ||
                        if ([lastFN isEqualToString:@"photos"] ||
                            [lastFN isEqualToString:@"videos"] ||
                            [lastFN isEqualToString:@"voice"] ||
                            [lastFN isEqualToString:@"music"] ||
                            [lastFN isEqualToString:@"thumbnails"]
                            ) {
                            NSString *lastPath = [authChildABPath stringByAppendingPathComponent:lastFN];
                            
                            [filePaths addObject:lastPath];
                        }
                        
                    }
                    
                }
            } else if (![fileName isEqualToString:@"public"]) {
                [filePaths addObject:absolutePath];
            }
            
        }
    }
    
    return filePaths;
}
@end
