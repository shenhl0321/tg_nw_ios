//
//  NSString+jojo.m
//  PoBar
//
//  Created by jojo on 6/8/14.
//  Copyright (c) 2014 jojo. All rights reserved.
//

#import "NSString+dwframework.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (dwframework)

- (BOOL)isValidateWithPredicstring:(NSString *)predicStr{
    NSPredicate *predic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", predicStr];
    return [predic evaluateWithObject:self];
}

- (BOOL)isValidEmail {
	if ([self length] == 0) {
		return NO;
	}

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    return [self isValidateWithPredicstring:emailRegex];
}

- (BOOL)isValidPhoneNumber {
    return YES;
#if 0
    if ([self length] == 0) {
        return NO;
    }
    return ([self isValidTelephoneNumber] || [self isValidMobilePhoneNumber]);
#endif
}

- (BOOL)isValidTelephoneNumber {
    return YES;
#if 0
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})[-]{0,1}\\d{7,8}$";
    
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if ([regextestphs evaluateWithObject:self] == YES) {
        return YES;
    } else {
        return NO;
    }
#endif
}

- (BOOL)isValidMobilePhoneNumber {
    // 区分国际手机号
    if ([self hasPrefix:@"+"]) {
        NSArray *comp = [self componentsSeparatedByString:@"-"];
        
        return comp.count == 2;
    }
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     * 联通：130,131,132,145,155,156,176,185,186
     * 电信：133,153,177,180,181,189
     */
    NSString * MOBILE = @"^1(3[0-9]|4[5,7]|5[0-35-9]|7[6,7,8]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,145,155,156,176,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,153,177,180,181,189
     22         */
    NSString * CT = @"^1(33|53|77|8[019])\\d{8}$";
    /**
     29         * 国际长途中国区(+86)
     30         * 区号：+86
     31         * 号码：十一位
     32         */
    NSString * IPH = @"^\\+861(3|5|7|8)\\d{9}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestiph = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", IPH];

    if ([regextestmobile evaluateWithObject:self] ||
        [regextestcm evaluateWithObject:self] ||
        [regextestct evaluateWithObject:self] ||
        [regextestcu evaluateWithObject:self] ||
        [regextestiph evaluateWithObject:self]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)deptNumInputShouldNumber:(NSString *)str
{
   if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

- (BOOL)isBankCard {
    if (self.length == 0) {
        return NO;
    }
    
    NSString *trimString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < trimString.length; i++) {
        char c = [trimString characterAtIndex:i];
        if (!isdigit(c)){
            return NO;
        }
    }
    
    return YES;
    
#if 0
    // Luhn 算法只能保证银行卡号是否为符合算法校验的  并不能区分是不是真正的银行卡号
    NSString *digitsOnly = @"";
    char c;
    
    for (int i = 0; i < self.length; i++) {
        c = [self characterAtIndex:i];
        if (isdigit(c)){
            digitsOnly = [digitsOnly stringByAppendingFormat:@"%c",c];
        }
    }
    
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = NO;
    
    for (NSInteger i = digitsOnly.length - 1; i >= 0; i--){
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo){
            addend = digit * 2;
            if (addend > 9) {
                addend -= 9;
            }
        }
        else {
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    
    int modulus = sum % 10;
    
    return modulus == 0;
#endif
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)firstLowerCaseLetterString {
	NSRange flRange = NSMakeRange(0, 1);
	NSString* fl = [self substringWithRange:flRange];
	NSString* fll = [fl lowercaseString];
	NSMutableString *ms = [NSMutableString stringWithString:self];
	[ms replaceCharactersInRange:flRange withString:fll];
	return ms;
}

- (NSString *)stringFromMD5 {
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

- (BOOL)containsString:(NSString *)subString {
    return [self rangeOfString:subString].location != NSNotFound;
}

- (NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [[self copy] autorelease];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

@end


@implementation NSString (SNURLEncodingAdditions)

- (NSString *)URLEncodedString {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (NSString*)URLDecodedString {
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    /// 为何要替换掉 “+” ？？？
//    NSString *resultWithoutPlus = [result stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString *resultWithoutPlus = result;
    [result autorelease];
    return resultWithoutPlus;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];

    return dic;
}
+(NSString *)getNowTimeTimestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

 /** 时间戳转化日期*/
+ (NSString *)timeStampToTime:(NSString *)timeStr formatter:(NSString *)dataformatterStr{
    if (![timeStr isKindOfClass:[NSString class]]) {
        return @"";
    }
    
    if (timeStr.length < 6) {
        return @"";
    }
    // 时间字符串转换时段
    NSTimeInterval time = [timeStr doubleValue];
    // 时段转换时间
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:time];
    // 时间格式
    NSDateFormatter *dataformatter = [[NSDateFormatter alloc] init];
    dataformatter.dateFormat = dataformatterStr;
    // 时间转换字符串
    NSString *resultStr = [dataformatter stringFromDate:date];

    return resultStr;
}

+ (CGSize)sizeWithmaxSize:(CGSize)size anText:(NSString *)anString

{

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:anString];

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];

    [style setLineSpacing:6.0f];

    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [anString length])];

    

        CGSize realSize = CGSizeZero;

   

    CGRect textRect = [anString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style} context:nil];

    realSize = textRect.size;

 

    realSize.width = ceilf(realSize.width);

    realSize.height = ceilf(realSize.height);

    return realSize;

}

@end
