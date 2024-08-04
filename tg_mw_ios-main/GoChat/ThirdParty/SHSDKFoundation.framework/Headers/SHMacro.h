//
//  Macro.h
//  SHSmartInstallKit
//
//  Created by smyjw on 2017/11/28.
//  Copyright © 2017年 smyjw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Macro : NSObject

//第一次安装统计量统计
#define SHfirstInstallValue @"SHfirstInstallStatisticsa"
#define SHfirstInstallKey @"SHfirstInstallStatistics"

#define SHfirstInstallAppValue @"SHfirstInstalla"
#define SHfirstInstallAppKey @"SHfirstInstall"

//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))


//判断 iOS 9 或更高的系统版本
#define IOS_VERSION_9_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=9.0)? (YES):(NO))


#define SH_SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define SH_SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SH_SCREEN_SIZE_MAX     MAX(SH_SCREEN_HEIGHT,SH_SCREEN_WIDTH)
#define SH_TARGET_IPHONE_X           (SH_SCREEN_SIZE_MAX == 812)
#define SH_NAV_BAR_HEIGHT            (SH_TARGET_IPHONE_X ? 88 : 64)

#define SH_ISVERTICAL_SCREEN [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown
#define SH_ISIPHONEX (SH_SCREEN_WIDTH/SH_SCREEN_HEIGHT < 0.5) || (SH_SCREEN_WIDTH/SH_SCREEN_HEIGHT > 2.0)
#define SH_NAV_HEIGHT (SH_ISVERTICAL_SCREEN ? ((SH_ISIPHONEX ? 88 : 64)) : 64)
#define SH_STATUS_HEIGHT SH_ISIPHONEX ? 44 : 20




@end
