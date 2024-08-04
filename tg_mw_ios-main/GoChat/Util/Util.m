//
//  Util.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/4.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "Util.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreLocation/CoreLocation.h>

UIWindow *tp_mainWindow() {
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    }
    else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }
    return nil;
}

UIViewController *tp_topMostViewController() {
    UIViewController *topViewController = tp_mainWindow().rootViewController;
    UIViewController *temp = nil;
    
    while (YES) {
        temp = nil;
        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            temp = ((UINavigationController *)topViewController).visibleViewController;
            
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            temp = ((UITabBarController *)topViewController).selectedViewController;
        }
        else if (topViewController.presentedViewController != nil) {
            temp = topViewController.presentedViewController;
        }
        
        if (temp != nil) {
            topViewController = temp;
        } else {
            break;
        }
    }
    
    return topViewController;
}

UINavigationController *tp_mainNavigationController() {
    return (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
}

@implementation Util

+(NSString *)objToStr:(id)obj{
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@",obj];
}

//+ (NSString *)getISOcountryCode {
//    NSString *ISOcountryCode;
//    
//    CTTelephonyNetworkInfo *network_Info = [CTTelephonyNetworkInfo new];
//    CTCarrier *carrier = network_Info.subscriberCellularProvider;
//    ISOcountryCode = carrier.isoCountryCode;
//    
//    if (ISOcountryCode.length == 0) {
//        NSLocale *locale = [NSLocale currentLocale];
//        ISOcountryCode = [locale objectForKey:NSLocaleCountryCode];
//    }
//    
//    return [ISOcountryCode uppercaseString];
//}

/**
 *    @brief    回跳至指定页面
 *
 *  @para   vc 当前VC
 *          specifyVCClass 指定页面类
 *
 *  @return 如果页面不存在，则返回False 否则True
 *
 */
+ (BOOL)skipToSpecifyVCWithVC:(UIViewController*) vc
               specifyVCClass:(id) specifyVCClass{
    BOOL isExist = NO;
    for (UIViewController* view in vc.navigationController.viewControllers){
        if ([view isKindOfClass:specifyVCClass]){
            isExist = YES;
            [vc.navigationController popToViewController:view animated:YES];
        }
    }
    
    return isExist;
}

+ (UIViewController *)navViewControllersContainVC:(Class)vcClass currentVC:(UIViewController *)currentVC{
    UIViewController *aVC;
    for (UIViewController* vc in currentVC.navigationController.viewControllers){
        if ([vc isKindOfClass:vcClass]){
            aVC = vc;
            break;
        }
    }
    return aVC;
}
/**
 *  @brief  校验邮箱合法性
 *
 **/
+ (BOOL)validateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**
 获取当前链接WIFI帐号
 
 @return WI-FI帐号
 */
+ (NSString *)getSSID{
    id info = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSString *ssid = @"";
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        ssid = info[@"SSID"];
    }
    return ssid;
}


//直接调用这个方法就行
+(int)checkIsHaveNumAndLetter:(NSString*)password{
    //数字条件
    NSRegularExpression *tNumRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合数字条件的有几个字节
    NSUInteger tNumMatchCount = [tNumRegularExpression numberOfMatchesInString:password
                                                                       options:NSMatchingReportProgress
                                                                         range:NSMakeRange(0, password.length)];
    
    //英文字条件
    NSRegularExpression *tLetterRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    //符合英文字条件的有几个字节
    NSUInteger tLetterMatchCount = [tLetterRegularExpression numberOfMatchesInString:password options:NSMatchingReportProgress range:NSMakeRange(0, password.length)];
    
    if (tNumMatchCount == password.length) {
        //全部符合数字，表示沒有英文
        return 1;
    } else if (tLetterMatchCount == password.length) {
        //全部符合英文，表示沒有数字
        return 2;
    } else if (tNumMatchCount + tLetterMatchCount == password.length) {
        //符合英文和符合数字条件的相加等于密码长度
        return 3;
    } else {
        return 4;
        //可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误
    }
    
}

///经纬度有效范围判断
+ (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate
{
    //经度最大是180° 最小是0°
    CGFloat longitude = coordinate.longitude;
    if (-180 > longitude || 180.0 < longitude)
    {
        return NO;
    }
    
    //纬度最大是90° 最小是0°
    CGFloat latitude = coordinate.latitude;
    if (-90 > latitude || 90.0 < latitude)
    {
        return NO;
    }
    
    return YES;

}


#pragma mark - calculate distance  根据2个经纬度计算距离

#define PI 3.1415926
+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = PI*lat1/180.0f;
    double radlat2 = PI*lat2/180.0f;
    //now long.
    double radlong1 = PI*lon1/180.0f;
    double radlong2 = PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}


+ (NSData *)UTF8Data:(NSData *)data {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:data.length];
    
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = data.bytes;
    
    long dataLength = (long) data.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t firstChar = bytes[index];
        
        // 1个字节
        if ((firstChar & 0x80) == 0 && (firstChar == 0x09 || firstChar == 0x0A || firstChar == 0x0D || (0x20 <= firstChar && firstChar <= 0x7E))) {
            len = 1;
        }
        // 2字节
        else if ((firstChar & 0xE0) == 0xC0 && (0xC2 <= firstChar && firstChar <= 0xDF)) {
            if (index + 1 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                if (0x80 <= secondChar && secondChar <= 0xBF) {
                    len = 2;
                }
            }
        }
        // 3字节
        else if ((firstChar & 0xF0) == 0xE0) {
            if (index + 2 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                
                if (firstChar == 0xE0 && (0xA0 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (((0xE1 <= firstChar && firstChar <= 0xEC) || firstChar == 0xEE || firstChar == 0xEF) && (0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (firstChar == 0xED && (0x80 <= secondChar && secondChar <= 0x9F) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                }
            }
        }
        // 4字节
// 4字节
        else if ((firstChar & 0xF8) == 0xF0) {
            if (index + 3 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                uint8_t fourthChar = bytes[index + 3];
                
                if (firstChar == 0xF0) {
                    if ((0x90 <= secondChar & secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if ((0xF1 <= firstChar && firstChar <= 0xF3)) {
                    if ((0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if (firstChar == 0xF3) {
                    if ((0x80 <= secondChar && secondChar <= 0x8F) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                }
            }
        }
// 5个字节
        else if ((firstChar & 0xFC) == 0xF8) {
            len = 0;
        }
        // 6个字节
        else if ((firstChar & 0xFE) == 0xFC) {
            len = 0;
        }
        
        if (len == 0) {
            index++;
            [resData appendData:replacement];
        } else {
            [resData appendBytes:bytes + index length:len];
            index += len;
        }
    }
    
    return resData;
}



+ (NSCalendar *)calendar {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return calendar;
}

//当前周的第一天的时间
+ (NSDate *)firstWeekFromDate:(NSDate *)date{
    NSCalendar *calendar = [Util calendar];
    [calendar setFirstWeekday:2];//以周一作为第一天
    NSCalendarUnit units = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday;
    NSDateComponents *compoments = [self.calendar
                   components:units fromDate:date];
    NSInteger weekday = compoments.weekday;//可以获取是周几，然后来计算
    
    NSInteger preDay;//往前几天
    preDay = (weekday-2+7)%7;//需要往前几天
    NSDate *firstWeakDay = [NSDate dateWithTimeInterval:- preDay * 24*60*60 sinceDate:date];//前一天
    return firstWeakDay;
}
//当前周最后一天的时间
+ (NSDate *)lastWeekDayFromDate:(NSDate *)date {
    NSDate *firstDate = [Util firstWeekFromDate:date];
    NSDate *lastWeakDay = [NSDate dateWithTimeInterval:6 * 24*60*60 sinceDate:firstDate];//前一天
    return lastWeakDay;
}

//距离当前周是第几周
+ (NSString *)weekPositionFromDate:(NSDate *)date currenDate:(NSDate *)currentDate{
    NSString *a = @"";
//    NSCalendar *calendar = [Util calendar];
//    [calendar setFirstWeekday:2];//以周一作为第一天
//    NSCalendarUnit units = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekOfYear;
//    NSDateComponents *compoments = [self.calendar
//                   components:units fromDate:date];
//    NSDateComponents *compomentsCurrent = [self.calendar
//                   components:units fromDate:currentDate];
//    NSInteger weekOfYear = compoments.weekOfYear;
//    NSInteger weekOfYearCurrent = compomentsCurrent.weekOfYear;
//    NSInteger offset = weekOfYearCurrent-weekOfYear;
//    if (offset == 0) {
//        a = LocalString(localCurrentWeek);
//        
//    }else if (offset<0){
//        a = [NSString stringWithFormat:LocalString(localCountWeeksPer),abs(offset)];
//    }else{
//        a = [NSString stringWithFormat:LocalString(localCountWeeksNext),abs(offset)];
//    }
    return a;
    
}



@end
