//
//  Common.h
//  
//
//  Created by wang yutao on 2017/6/28.
//  Copyright © 2017 zy technologies inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Common : NSObject

+ (NSString *)generateGuid;
+ (NSString *)deviceId;

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)imageSize;

+ (BOOL)validateEmail:(NSString *)email;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

+ (NSString *)priceFormat:(CGFloat)price;

+ (NSString *)timeFormatted_m:(int)totalSeconds;
+ (NSString *)timeFormatted:(int)totalSeconds;
+ (NSString *)timeFormatted_cn:(int)totalSeconds;
+ (NSString *)timeFormatted_cn_d:(int)totalSeconds;
+ (NSString *)timeFormattedForRp:(int)totalSeconds;

//yyyy-MM-dd HH:mm:ss - [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"]
+ (NSString *)dateFromServerTime:(NSString *)time;
+ (NSString *)dateFromServerTime_d:(NSString *)time;
//返回秒 yyyy-MM-dd HH:mm:ss
+ (CGFloat)intervalWithStart:(NSString *)start end:(NSString *)end;
//
+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate;
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate;

//+ (NSString*)encodeString:(NSString*)unencodedString;
+ (NSString*)md5:(NSString*)str;
+ (CAGradientLayer *)setGradualChangingColor:(CGRect)rect fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

+ (NSString *)getDistance:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to;

+ (NSString *)minFormat:(int)totalMin;

#pragma mark - time convert
+ (NSString*)getFullMessageTime:(NSTimeInterval)time showDetail:(BOOL)showDetail;
+ (NSString*)getMessageTime:(NSTimeInterval)time;
+ (NSString*)getMessageDay:(NSTimeInterval)time;
+ (BOOL)isSameDay:(NSTimeInterval)time1 time2:(NSTimeInterval)time2;

//
+ (BOOL)fileIsExist:(NSString *)filePath;

//
+ (NSString *)bytesToAvaiUnit:(unsigned long long)bytes showDecimal:(BOOL)showDecimal;

//
+ (NSString *)appVersion;
+ (NSString *)appName;
+ (NSString *)systemVersion;
+ (NSString *)deviceModel;
+ (NSString *)language;

//号码格式化
+ (NSString *)phoneFormat:(NSString *)phone;
@end
