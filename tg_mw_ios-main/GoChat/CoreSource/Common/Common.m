//
//  Common.m
//  
//
//  Created by wang yutao on 2017/6/28.
//  Copyright © 2017 zy technologies inc. All rights reserved.
//

#import "Common.h"
#import "PDKeyChain.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>
#import "NBPhoneNumberUtil.h"

@implementation Common

+ (NSString *)deviceId
{
    NSString *key = [PDKeyChain keyChainLoad];
    if(key && [key isKindOfClass:[NSString class]] && key.length>0)
    {
        return key;
    }
    key = [Common generateGuid];
    [PDKeyChain keyChainSave:key];
    return key;
}

+ (NSString *)generateGuid
{
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    NSString	*uuidString = nil;
    if (uuidObj == NULL)
    {
        uuidString = [self createIdentifier];
        return uuidString;
    }
    //get the string representation of the UUID
    CFStringRef uuidCFString = CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    if (uuidCFString == NULL)
    {
        uuidString = [self createIdentifier];
        return uuidString;
    }
    uuidString = (__bridge NSString *)(uuidCFString);
    uuidString = [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuidCFString);
    
    return uuidString;
}

+ (NSString *)createIdentifier{
    NSString *source = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *identifier = [[NSMutableString alloc] initWithCapacity:8];
    
    while ([identifier length] < 8)
    {
        NSUInteger index = arc4random()%62;
        unichar random = [source characterAtIndex:index];
        [identifier appendFormat:@"%c", random];
    }
    
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    [identifier appendFormat:@"%.0f", nowTime];
    
    return identifier;
}

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)imageSize
{
    CGRect rect=CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (BOOL)validateEmail:(NSString *)email
{//Ä-196,Ö-214,Ü-220,ß-223,ä-228,ö-246,ü-252
    NSString *emailRegex = @"[A-Z0-9a-z._%+-ÄÖÜßäöü]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (NSString *)priceFormat:(CGFloat)price
{
//    if (fmodf(price, 1)==0)
//    {
//        return [NSString stringWithFormat:@"%.0f", price];
//    }
//    else if (fmodf(price*10, 1)==0)
//    {
//        return [NSString stringWithFormat:@"%.1f", price];
//    }
//    else
    {
        return [NSString stringWithFormat:@"%.2f", price];
    }
}

+ (NSString *)timeFormatted_m:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60);
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

+ (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if(hours>0)
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    else
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

+ (NSString *)timeFormatted_cn:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if(hours>0)
        return [NSString stringWithFormat:@"%02dh:%02dm:%02ds",hours, minutes, seconds];
    else
        return [NSString stringWithFormat:@"%02dm:%02ds", minutes, seconds];
}

+ (NSString *)timeFormatted_cn_d:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = ((totalSeconds / 60) / 60) % 24;
    int days = totalSeconds/(3600*24);
    if(days>0)
        return [NSString stringWithFormat:@"%d d %d h %d m %d s", days, hours, minutes, seconds];
    else
        return [Common timeFormatted_cn:totalSeconds];
}

+ (NSString *)timeFormattedForRp:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if(hours>0)
    {
        return [NSString stringWithFormat:@"%02d小时%02d分钟%02d秒".lv_localized,hours, minutes, seconds];
    }
    else
    {
        if(minutes>0 && seconds<=0)
        {
            return [NSString stringWithFormat:@"%02d分钟".lv_localized, minutes];
        }
        else if(minutes<=0 && seconds>0)
        {
            return [NSString stringWithFormat:@"%02d秒".lv_localized, seconds];
        }
        else
        {
            return [NSString stringWithFormat:@"%02d分钟%02d秒".lv_localized, minutes, seconds];
        }
    }
}

+ (NSString *)dateFromServerTime:(NSString *)time
{
    if(time.length>0)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSDate *recordDate = [formatter dateFromString:time];
        [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        NSString *time = [formatter stringFromDate:recordDate];
        if(time)
            return time;
    }
    return @"";
}

+ (NSString *)dateFromServerTime_d:(NSString *)time
{
    if(time.length>0)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSDate *recordDate = [formatter dateFromString:time];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        NSString *time = [formatter stringFromDate:recordDate];
        if(time)
            return time;
    }
    return @"";
}

//返回秒 yyyy-MM-dd HH:mm:ss
+ (CGFloat)intervalWithStart:(NSString *)start end:(NSString *)end
{
    if(start.length>0 && end.length>0)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *startTime = [formatter dateFromString:start];
        NSDate *endTime = [formatter dateFromString:end];
        if(startTime && endTime)
        {
            double intervalTime = [endTime timeIntervalSinceReferenceDate] - [startTime timeIntervalSinceReferenceDate];
            return intervalTime;
        }
        else
        {
            return MAXFLOAT;
        }
    }
    return MAXFLOAT;
}

+ (NSString *)getUTCFormateLocalDate:(NSString *)localDate
{
    if(localDate.length>0)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //输入格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSDate *dateFormatted = [dateFormatter dateFromString:localDate];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setTimeZone:timeZone];
        //输出格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
        return dateString;
    }
    return localDate;
}

//将UTC日期字符串转为本地时间字符串
+ (NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    if(utcDate.length>0)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //输入格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setTimeZone:timeZone];
        NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
        //输出格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
        [dateFormatter setTimeZone:localTimeZone];
        NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
        return dateString;
    }
    return utcDate;
}

+ (NSString*)md5:(NSString*)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}

//+ (NSString*)encodeString:(NSString*)unencodedString
//{
//    NSString *encodedString = (NSString *)
//    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
//                                                              (CFStringRef)unencodedString,
//                                                              NULL,
//                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                              kCFStringEncodingUTF8));
//    return encodedString;
//}

//绘制渐变色颜色的方法
+ (CAGradientLayer *)setGradualChangingColor:(CGRect)rect fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = rect;
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor, (__bridge id)toColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0.5, 0);
    gradientLayer.endPoint = CGPointMake(0.5, 1);
    gradientLayer.locations = @[@0,@1];
    return gradientLayer;
}

+ (NSString *)FormatDistance:(CGFloat)distance
{
    if (distance >= 1000)
    {
        return [NSString stringWithFormat:@"%0.1f %@", distance/1000, NSLocalizedString(@"KM", nil)];
    }
    else
    {
        return [NSString stringWithFormat:@"%0.0f %@", distance, NSLocalizedString(@"meter", nil)];
    }
}

+ (NSString *)getDistance:(CLLocationCoordinate2D)from to:(CLLocationCoordinate2D)to
{
    CLLocation *orig=[[CLLocation alloc] initWithLatitude:from.latitude  longitude:from.longitude];
    CLLocation* dist=[[CLLocation alloc] initWithLatitude:to.latitude longitude:to.longitude];
    CLLocationDistance meters = [orig distanceFromLocation:dist];
    return [Common FormatDistance:meters];
}

+ (NSString *)minFormat:(int)totalMin
{
    if (totalMin <= 0)
    {
        return NSLocalizedString(@"min_zero_des", nil);
    }
    else
    {
        int minutes = totalMin % 60;
        int hours = (totalMin / 60) % 24;
        int days = totalMin / (60 * 24);
        NSMutableString *str = [NSMutableString new];
        if (days > 0)
        {
            [str appendFormat:@"%d %@", days, NSLocalizedString(@"days", nil)];
        }
        if (hours > 0)
        {
            if(str.length>0)
                [str appendString:@" "];
            [str appendFormat:@"%d %@", hours, NSLocalizedString(@"hours", nil)];
        }
        if (minutes > 0)
        {
            if(str.length>0)
                [str appendString:@" "];
            [str appendFormat:@"%d %@", minutes, NSLocalizedString(@"minutes", nil)];
        }
        return str;
    }
}

#pragma mark - time convert
+ (NSString*)getFullMessageTime:(NSTimeInterval)time showDetail:(BOOL)showDetail
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    
    NSInteger hour = msgDateComponents.hour;
    double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数

//    result = [Common getPeriodOfTime:hour withMinute:msgDateComponents.minute];
//    if (hour > 12)
//    {
//        hour = hour - 12;
//    }
    
    BOOL isSameMonth = (nowDateComponents.year == msgDateComponents.year) && (nowDateComponents.month == msgDateComponents.month);
    
    if(isSameMonth && (nowDateComponents.day == msgDateComponents.day)) //同一天,显示时间
    {
        result = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)hour, (int)msgDateComponents.minute];
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+1)))//昨天
    {
        result = showDetail?  [[NSString alloc] initWithFormat:@"昨天 %02d:%02d".lv_localized, (int)hour,(int)msgDateComponents.minute] : @"昨天".lv_localized;
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+2))) //前天
    {
        result = showDetail? [[NSString alloc] initWithFormat:@"前天 %02d:%02d".lv_localized, (int)hour,(int)msgDateComponents.minute] : @"前天".lv_localized;
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [Common weekdayStr:msgDateComponents.weekday];
        result = showDetail? [weekDay stringByAppendingFormat:@" %02d:%02d", (int)hour,(int)msgDateComponents.minute] : weekDay;
    }
    else//显示日期
    {
        NSString *day = [NSString stringWithFormat:@"%zd-%zd-%zd", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
        result = showDetail? [day stringByAppendingFormat:@" %02d:%02d", (int)hour,(int)msgDateComponents.minute]:day;
    }
    return result;
}

+ (NSString*)getMessageTime:(NSTimeInterval)time
{
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    NSInteger hour = msgDateComponents.hour;
    return [[NSString alloc] initWithFormat:@"%02d:%02d", (int)hour, (int)msgDateComponents.minute];;
}

+ (NSString*)getMessageDay:(NSTimeInterval)time
{
    //今天的时间
    NSDate * nowDate = [NSDate date];
    NSDate * msgDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *result = nil;
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents *nowDateComponents = [[NSCalendar currentCalendar] components:components fromDate:nowDate];
    NSDateComponents *msgDateComponents = [[NSCalendar currentCalendar] components:components fromDate:msgDate];
    
    double OnedayTimeIntervalValue = 24*60*60;  //一天的秒数
    BOOL isSameMonth = (nowDateComponents.year == msgDateComponents.year) && (nowDateComponents.month == msgDateComponents.month);
    if(isSameMonth && (nowDateComponents.day == msgDateComponents.day)) //同一天,显示时间
    {
        result = @"今天".lv_localized;
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+1)))//昨天
    {
        result = @"昨天".lv_localized;
    }
    else if(isSameMonth && (nowDateComponents.day == (msgDateComponents.day+2))) //前天
    {
        result = @"前天".lv_localized;
    }
    else if([nowDate timeIntervalSinceDate:msgDate] < 7 * OnedayTimeIntervalValue)//一周内
    {
        NSString *weekDay = [Common weekdayStr:msgDateComponents.weekday];
        result = weekDay;
    }
    else//显示日期
    {
        result = [NSString stringWithFormat:@"%zd-%02ld-%02ld", msgDateComponents.year, msgDateComponents.month, msgDateComponents.day];
    }
    result = [NSString stringWithFormat:@"%@ %02ld:%02ld", result, msgDateComponents.hour, msgDateComponents.minute];
    return result;
}

+ (BOOL)isSameDay:(NSTimeInterval)time1 time2:(NSTimeInterval)time2
{
    NSDate * date1 = [NSDate dateWithTimeIntervalSince1970:time1];
    NSDate * date2 = [NSDate dateWithTimeIntervalSince1970:time2];
    NSCalendarUnit components = (NSCalendarUnit)(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay);
    NSDateComponents *date1Components = [[NSCalendar currentCalendar] components:components fromDate:date1];
    NSDateComponents *date2Components = [[NSCalendar currentCalendar] components:components fromDate:date2];
    return date1Components.year == date2Components.year &&
    date1Components.month == date2Components.month &&
    date1Components.day == date2Components.day;
}

//+ (NSString *)getPeriodOfTime:(NSInteger)time withMinute:(NSInteger)minute
//{
//    NSInteger totalMin = time *60 + minute;
//    NSString *showPeriodOfTime = @"";
//    if (totalMin > 0 && totalMin <= 5 * 60)
//    {
//        showPeriodOfTime = @"凌晨";
//    }
//    else if (totalMin > 5 * 60 && totalMin < 12 * 60)
//    {
//        showPeriodOfTime = @"上午";
//    }
//    else if (totalMin >= 12 * 60 && totalMin <= 18 * 60)
//    {
//        showPeriodOfTime = @"下午";
//    }
//    else if ((totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0)
//    {
//        showPeriodOfTime = @"晚上";
//    }
//    return showPeriodOfTime;
//}

+(NSString*)weekdayStr:(NSInteger)dayOfWeek
{
    static NSDictionary *daysOfWeekDict = nil;
    daysOfWeekDict = @{@(1):@"星期日".lv_localized,
                       @(2):@"星期一".lv_localized,
                       @(3):@"星期二".lv_localized,
                       @(4):@"星期三".lv_localized,
                       @(5):@"星期四".lv_localized,
                       @(6):@"星期五".lv_localized,
                       @(7):@"星期六".lv_localized,};
    return [daysOfWeekDict objectForKey:@(dayOfWeek)];
}

+ (BOOL)fileIsExist:(NSString *)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    return [manager fileExistsAtPath:filePath];
}

//大小单位转换
+ (NSString *)bytesToAvaiUnit:(unsigned long long)bytes showDecimal:(BOOL)showDecimal
{
    if(bytes < 1024)        // B
    {
        return [NSString stringWithFormat:@"%lluB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024)    // KB
    {
        if(showDecimal)
            return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
        return [NSString stringWithFormat:@"%.0fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)    // MB
    {
        if(showDecimal)
            return [NSString stringWithFormat:@"%.1fMB", (double)bytes / (1024 * 1024)];
        return [NSString stringWithFormat:@"%.0fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        if(showDecimal)
            return [NSString stringWithFormat:@"%.1fGB", (double)bytes / (1024 * 1024 * 1024)];
        return [NSString stringWithFormat:@"%.0fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}

#pragma mark -
+ (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    if (machine == NULL)
    {
        return nil;
    }
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)deviceModel
{
    NSString *modelStr = nil;
    NSString *platform = [Common platform];
    if(!IsStrEmpty(platform))
    {
        NSString *listInfoPath = [[NSBundle mainBundle] pathForResource:@"DeviceInfo" ofType:@"plist"];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:listInfoPath];
        modelStr = [dic objectForKey:platform];
    }
    else
    {
        modelStr = [UIDevice currentDevice].model;
    }
    if(IsStrEmpty(modelStr))
        return @"ios";
    else
        return modelStr;
}

+ (NSString *)language
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defs objectForKey:@"AppleLanguages"];
    NSString *preferredLang = [languages objectAtIndex:0];
    //NSLog(@"Preferred Language:%@", preferredLang);
    if([preferredLang hasPrefix:@"zh-Hans"])
        return @"cn";
    else if([preferredLang hasPrefix:@"zh-Hant"])
        return @"cn";
    else
        return @"en";
}

//号码格式化
+ (NSString *)phoneFormat:(NSString *)phone
{
    if(!IsStrEmpty(phone))
    {
        NSError *anError = nil;
        NBPhoneNumber *phoneNumber = [[NBPhoneNumberUtil sharedInstance] parseWithPhoneCarrierRegion:phone error:&anError];
        if(anError == nil)
        {
            return [[NBPhoneNumberUtil sharedInstance] format:phoneNumber
                                                 numberFormat:NBEPhoneNumberFormatINTERNATIONAL
                                                        error:&anError];
        }
    }
    return phone;
}

@end
