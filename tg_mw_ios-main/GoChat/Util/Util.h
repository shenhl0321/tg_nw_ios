//
//  Util.h
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/4.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

UIWindow *tp_mainWindow();

UIViewController *tp_topMostViewController();

UINavigationController *tp_mainNavigationController();

@interface Util : NSObject
+(NSString *)objToStr:(id)obj;
//+ (NSString *)getISOcountryCode;
+ (BOOL)skipToSpecifyVCWithVC:(UIViewController*) vc
               specifyVCClass:(id) specifyVCClass;
/**
 *  @brief  校验邮箱合法性
 *
 **/
+ (BOOL)validateEmail:(NSString *)email;
/**
 获取当前链接WIFI帐号
 
 @return WI-FI帐号
 */
+ (NSString *)getSSID;

//直接调用这个方法就行
+(int)checkIsHaveNumAndLetter:(NSString*)password;
///经纬度有效范围判断
+ (BOOL)isValidCoordinate:(CLLocationCoordinate2D)coordinate;

+(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2;

+ (NSData *)UTF8Data:(NSData *)data;

+ (UIViewController *)navViewControllersContainVC:(Class)vcClass currentVC:(UIViewController *)currentVC;

+ (NSCalendar *)calendar ;
//当前周的第一天的时间
+ (NSDate *)firstWeekFromDate:(NSDate *)date;

//当前周最后一天的时间
+ (NSDate *)lastWeekDayFromDate:(NSDate *)date;

//距离当前周是第几周
+ (NSString *)weekPositionFromDate:(NSDate *)date currenDate:(NSDate *)currentDate;


@end

NS_ASSUME_NONNULL_END
