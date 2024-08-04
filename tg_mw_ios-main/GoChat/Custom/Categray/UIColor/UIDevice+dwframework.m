//
//  UIDevice+dwframework.m
//  dwframework
//
//  Created by jojo on 7/6/14.
//  Copyright (c) 2014 dw. All rights reserved.
//

#include <net/if.h>
#include <net/if_dl.h>
//获取系统内存
#include <sys/sysctl.h>
#include <mach/mach.h>
//获取系统存储空间
#include <sys/param.h>
#include <sys/mount.h>

// 获取mac地址得到唯一码
#include <sys/socket.h> // Per msqr

#include <sys/stat.h>
#include <dirent.h>

// ad support
//#import <AdSupport/AdSupport.h>

#import "UIDevice+dwframework.h"
#import "NSString+dwframework.h"

@implementation UIDevice (dwframework)

#pragma mark sysctlbyname utils
- (NSString *)getSysInfoByName:(char *)typeSpecifier {
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)platform {
    return [self getSysInfoByName:"hw.machine"];
}


// Thanks, Tom Harrington (Atomicbird)
- (NSString *)hwmodel {
    return [self getSysInfoByName:"hw.model"];
}

#pragma mark sysctl utils
- (NSUInteger)getSysInfo:(uint)typeSpecifier {
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &results, &size, NULL, 0);
    return (NSUInteger) results;
}

- (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency {
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)cpuCount {
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger)totalMemory {
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)userMemory {
    return [self getSysInfo:HW_USERMEM];
}

- (NSUInteger)maxSocketBufferSize {
    return [self getSysInfo:KIPC_MAXSOCKBUF];
}

#pragma mark file system -- Thanks Joachim Bean!

/*
 extern NSString *NSFileSystemSize;
 extern NSString *NSFileSystemFreeSize;
 extern NSString *NSFileSystemNodes;
 extern NSString *NSFileSystemFreeNodes;
 extern NSString *NSFileSystemNumber;
 */

- (NSNumber *)totalDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemSize];
}

- (NSNumber *)freeDiskSpace {
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [fattributes objectForKey:NSFileSystemFreeSize];
}

#pragma mark platform type and name utils
- (NSUInteger)platformType {
    NSString *platform = [self platform];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
    if ([platform isEqualToString:@"iPhone5,1"] ||
        [platform isEqualToString:@"iPhone5,2"])
        return UIDevice5iPhone;
    
    if ([platform isEqualToString:@"iPhone5,3"] ||
        [platform isEqualToString:@"iPhone5,4"])
        return UIDevice5CiPhone;
    
    if ([platform isEqualToString:@"iPhone6,1"] ||
        [platform isEqualToString:@"iPhone6,2"])
        return UIDevice5SiPhone;
    
    if ([platform isEqualToString:@"iPhone7,1"])
        return UIDevice6iPhone;
    
    if ([platform isEqualToString:@"iPhone7,2"])
        return UIDevice6PLUSiPhone;
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    
    // iPad
    if ([platform isEqualToString:@"iPad1,1"])      return UIDevice1GiPad; //@"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])      return UIDevice2GiPad; //@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return UIDevice2GiPad; //@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return UIDevice2GiPad; //@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return UIDevice2GiPad; //@"iPad 2 (Rev A)";
    if ([platform isEqualToString:@"iPad3,1"])      return UIDevice3GiPad; //@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return UIDevice3GiPad; //@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])      return UIDevice3GiPad; //@"iPad 3 (Global)";
    if ([platform isEqualToString:@"iPad3,4"])      return UIDevice4GiPad; //@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return UIDevice4GiPad; //@"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return UIDevice4GiPad; //@"iPad 4 (Global)";
    
    if ([platform isEqualToString:@"iPad4,1"])      return UIDevice5GiPad; //@"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return UIDevice5GiPad; //@"iPad Air (Cellular)";
    
    // iPad mini
    if ([platform isEqualToString:@"iPad2,5"])      return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad2,6"])      return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad2,7"])      return UIDevice1GiPadMini;
    if ([platform isEqualToString:@"iPad4,4"])      return UIDevice2GiPadMini;
    if ([platform isEqualToString:@"iPad4,5"])      return UIDevice2GiPadMini;
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"]) {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
    }
    
    return UIDeviceUnknown;
}

- (NSString *) platformString {
    switch ([self platformType]) {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4SiPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5iPhone: return IPHONE_5_NAMESTRING;
        case UIDevice5CiPhone: return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PLUSiPhone: return IPHONE_6PLUS_NAMESTRING;
        case UIDeviceUnknowniPhone: return IPHONE_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDeviceUnknowniPod: return IPOD_UNKNOWN_NAMESTRING;
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDevice5GiPad : return IPAD_5G_NAMESTRING;
            
        case UIDevice1GiPadMini: return IPAD_MINI_NAMESTRING;
        case UIDevice2GiPadMini: return IPAD_MINI2_NAMESTRING;
            
        case UIDeviceUnknowniPad : return IPAD_UNKNOWN_NAMESTRING;
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceAppleTV3 : return APPLETV_3G_NAMESTRING;
        case UIDeviceAppleTV4 : return APPLETV_4G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceSimulator: return SIMULATOR_NAMESTRING;
        case UIDeviceSimulatoriPhone: return SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceSimulatoriPad: return SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceSimulatorAppleTV: return SIMULATOR_APPLETV_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return IOS_FAMILY_UNKNOWN_DEVICE;
    }
}

- (NSString *)platformStringUpdate {
    
    NSString *platform = [self platform];
    
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5C";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6S";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6S Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5";
    if ([platform isEqualToString:@"iPod7,1"]) return @"iPod Touch 6";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"]) return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini (CDMA)";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"]) return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"]) return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"]) return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"]) return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"]) return @"iPad Air (GSM)";
    if ([platform isEqualToString:@"iPad4,3"]) return @"iPad Air (CDMA)";
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini Retina (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini Retina (Cellular)";
    if ([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4 (Cellular)";
    if ([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7-inch (WiFi)";
    if ([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9-inch (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch (Cellular)";
    
    if ([platform isEqualToString:@"iPhone Simulator"] || [platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
}

- (BOOL)hasRetinaDisplay {
    return ([UIScreen mainScreen].scale > 1.0f);
}

- (UIDeviceFamily)deviceFamily {
    NSString *platform = [self platform];
    if ([platform hasPrefix:@"iPhone"]) return UIDeviceFamilyiPhone;
    if ([platform hasPrefix:@"iPod"]) return UIDeviceFamilyiPod;
    if ([platform hasPrefix:@"iPad"]) return UIDeviceFamilyiPad;
    if ([platform hasPrefix:@"AppleTV"]) return UIDeviceFamilyAppleTV;
    
    return UIDeviceFamilyUnknown;
}


#pragma mark MAC addy
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to mlamb.
- (NSString *)macaddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Error: Memory allocation error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2\n");
        free(buf); // Thanks, Remy "Psy" Demerest
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    free(buf);
    return outstring;
}
// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macAddress {
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *)uniqueDeviceIdentifier{
    NSString *macAddress = [[UIDevice currentDevice] macAddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macAddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash stringFromMD5];
    
    return uniqueIdentifier;
}

//- (NSString *) uniqueGlobalDeviceIdentifier{
//    NSString *macAddress = [[UIDevice currentDevice] macAddress];
//    NSString *uniqueIdentifier = [macAddress stringFromMD5];
//    
//    if ([uniqueIdentifier length] == 0) {
//        // 在某些越狱机器上  拿不到mac地址  所以可以用client id作为区分设备的唯一id
//        NSString *savedUid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
//        if (savedUid.length) {
//            savedUid = [NSString stringWithFormat:@"com.sohu.newspaper%@", savedUid];
//            NSString *encodeUid = [[savedUid dataUsingEncoding:NSUTF8StringEncoding] base64String];
//            uniqueIdentifier = [encodeUid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
//        }
//    }
//    
//    if (!uniqueIdentifier) {
//        uniqueIdentifier = @"";
//    }
//    
//    return uniqueIdentifier;
//}

+ (double)getAvailableMemory{
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

+ (void)reportMemory {
    static unsigned last_resident_size=0;
    static unsigned greatest = 0;
    static unsigned last_greatest = 0;
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        int diff = (int)info.resident_size - (int)last_resident_size;
        unsigned latest = (unsigned)info.resident_size;
        if( latest > greatest   )   greatest = latest;  // track greatest mem usage
        int greatest_diff = greatest - last_greatest;
        int latest_greatest_diff = latest - greatest;
        NSLog(@"Mem: %10u (%10d) : %10d :   greatest: %10u (%d)", (unsigned int)info.resident_size, diff,
              latest_greatest_diff,
              greatest, greatest_diff  );
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    last_resident_size = (unsigned)info.resident_size;
    last_greatest = greatest;
}

+ (void)printDeviceMemInfo {
    int mem;
    int mib[2];
    mib[0] = CTL_HW;
    mib[1] = HW_PHYSMEM;
    size_t length = sizeof(mem);
    sysctl(mib, 2, &mem, &length, NULL, 0);
    NSLog(@"Physical memory: %.2fMB", mem/1024.0f/1024.0f);
    
    mib[1] = HW_USERMEM;
    length = sizeof(mem);
    sysctl(mib, 2, &mem, &length, NULL, 0);
    NSLog(@"User memory: %.2fMB", mem/1024.0f/1024.0f);
}

+ (float)getFreeDiskSpace {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	struct statfs tStats;
	statfs([[paths lastObject] UTF8String], &tStats);
	float freeSpace = (float)(tStats.f_bsize * tStats.f_bfree);
	
	return freeSpace/(1024.0 * 1024.0);
}

+ (float)getTotalDiskSpace {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	struct statfs tStats;
	statfs([[paths lastObject] UTF8String], &tStats);
	float totalSpace = (float)(tStats.f_blocks * tStats.f_bsize);
	
	return totalSpace/(1024.0 * 1024.0);
}

+ (float)getFreeDiskSpaceBySDK {
	float freeSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
	
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];
        freeSpace = [fileSystemSizeInBytes floatValue]/(1024.0 * 1024.0);
    } else {
        NSLog(@"getTotalDiskSpaceBySDK,Error Obtaining File System Info, Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
	
    return freeSpace;
}

+ (float)getTotalDiskSpaceBySDK {
	float totalSpace = 0.0f;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
	
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes floatValue]/(1024.0 * 1024.0);
    } else {
        NSLog(@"getTotalDiskSpaceBySDK,Error Obtaining File System Info, Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
	
    return totalSpace;
}

+ (unsigned long long int)getFolderSize:(NSString*)folderPath {
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}

+ (long long) _folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        int folderPathLength = (int)strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
		}
	}
    closedir(dir);
    return folderSize;
}

+ (BOOL)isJailbroken {
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

+ (BOOL)isIPhone6Plus {
    return [UIScreen mainScreen].scale == 3.0f;
}

+ (BOOL)isIPhone4OrEarlier {
    if ([UIScreen mainScreen].scale < 2.0f) {
        return YES;
    }
    
    return [UIScreen mainScreen].bounds.size.height <= 480;
}

+ (BOOL)isIPhoneX {
    if (self.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return NO;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            return YES;
        }
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    
    return CGSizeEqualToSize(screenSize, CGSizeMake(375, 812)) || CGSizeEqualToSize(screenSize, CGSizeMake(414, 896)) || statusBarSize.height == 44.0;
}

- (void)reportRunningProcesses {
    NSLog(@"runningProcesses %@", [[UIDevice currentDevice] runningProcesses]);
}

//返回所有正在运行的进程的 id，name，占用cpu，运行时间
//使用函数int	sysctl(int *, u_int, void *, size_t *, void *, size_t)
- (NSArray *)runningProcesses {
	//指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
	//CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
	int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL ,0};
    
    
    size_t miblen = 4;
	//值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
	//如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size;
	//返回0，成功；返回-1，失败
    int st = sysctl(mib, (u_int)miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do
	{
		size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess)
		{
			if (process)
			{
                free(process);
				process = NULL;
            }
            return nil;
        }
        
        process = newprocess;
        st = sysctl(mib, (u_int)miblen, process, &size, NULL, 0);
    } while (st == -1 && errno == ENOMEM);
    
    if (st == 0)
	{
        if (size % sizeof(struct kinfo_proc) == 0)
		{
            int nprocess = (int)(size / sizeof(struct kinfo_proc));
            if (nprocess)
			{
                NSMutableArray * array = [[[NSMutableArray alloc] init] autorelease];
                for (int i = nprocess - 1; i >= 0; i--)
				{
					NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
					NSString * processID = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_pid];
                    NSString * processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
					NSString * proc_CPU = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_estcpu];
					double t = [[NSDate date] timeIntervalSince1970] - process[i].kp_proc.p_un.__p_starttime.tv_sec;
					NSString * proc_useTiem = [[NSString alloc] initWithFormat:@"%f",t];
                    
					//NSLog(@"process.kp_proc.p_stat = %c",process.kp_proc.p_stat);
                    
					NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
					[dic setValue:processID forKey:@"ProcessID"];
					[dic setValue:processName forKey:@"ProcessName"];
					[dic setValue:proc_CPU forKey:@"ProcessCPU"];
					[dic setValue:proc_useTiem forKey:@"ProcessUseTime"];
                    
					[processID release];
                    [processName release];
					[proc_CPU release];
					[proc_useTiem release];
                    [array addObject:dic];
                    [dic release];
                    
					[pool release];
                }
                
                free(process);
				process = NULL;
				//NSLog(@"array = %@",array);
                
				return array;
            }
        }
    }
    
    if (process)
    {
        free(process);
        process = NULL;
    }
    
    return nil;
}

// 2013年5月1日，Apple禁用uniqueIdentifier，改用mac地址
// 后来iOS7里mac地址返回一个无效值，所以无法跟踪硬件了。
// 改用advertisingIdentifier，假如用户不让跟踪advertisingIdentifier，再改用identifierForVendor

+ (NSString *)deviceUDID {
    NSString *UDID = nil;
    
    /*
    if (NSClassFromString(@"ASIdentifierManager")) {
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            UDID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        } else {
            UDID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
    } else {
        UDID = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    }
    
    if (UDID.length <= 0) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        UDID = [(NSString *)CFUUIDCreateString (kCFAllocatorDefault,uuidRef) autorelease];
        CFRelease(uuidRef);
    }
     */
    
    return UDID;
}

+ (BOOL)isRetina {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        return [[UIScreen mainScreen] scale] > 1.0f;
    }
    else {
        return NO;
    }
}

+ (CGRect)screenBounds {
    return [UIScreen mainScreen].bounds;
}

@end
