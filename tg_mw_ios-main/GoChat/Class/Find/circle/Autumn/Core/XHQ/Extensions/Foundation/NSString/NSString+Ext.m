//
//  NSString+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/7/4.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "NSString+Ext.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (Ext)

- (BOOL)xhq_notEmpty {
    if (self.length == 0) {
        return NO;
    }else {
        NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
        return string.length == 0 ? NO : YES;
    }
}


- (instancetype)xhq_timeIntervalToStringFromatter:(NSString *)formatter {
    if ([self containsString:@"-"]) {
        return self;
    }
    NSInteger time = self.integerValue;
    if (self.length > 10) {
        time = time / 1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:formatter];
    return [dateFormatter stringFromDate:date];
}

/////////////////////////////////////////////////////////////-类方法-//////////////////////////////////////////////////////////////////////

#pragma mark - 检测字符串是否存在
+ (BOOL)xhq_notEmpty:(NSString *)string {
    BOOL res = [self xhq_notNULL:string];
    if (!res) {
        return NO;
    }
    return [string xhq_notEmpty];
}

#pragma mark - 检测字符串是否为空
+ (BOOL)xhq_notNULL:(NSString *)str {
    if ([str isEqual:[NSNull null]] ||
        [str isKindOfClass:[NSNull class]] ||
        [str isEqualToString:@"(null)"] ||
        [str isEqualToString:@"<null>"] ||
        !str) {
        return NO;
    }
    return YES;
}

#pragma mark - MD5加密
+ (NSString *)xhq_MD5Encryption:(NSString *)string {
    BOOL res = [self xhq_notEmpty:string];
    if (!res) {
        return @"";
    }
    
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}

#pragma mark - 隐藏手机号中间位数
+ (NSString *)xhq_hiddenPhoneNumber:(NSString *)number {
    if ([number isEqual:[NSNull null]] ||
        [number isKindOfClass:[NSNull class]] ||
        !number) {
        return @"";
    }
    if (number.length != 11) {
        return number;
    }
    return [number stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
}

#pragma mark - 隐藏身份证号中间位数
+ (NSString *)xhq_hiddenIdCardNumber:(NSString *)number {
    if ([number isEqual:[NSNull null]] ||
        [number isKindOfClass:[NSNull class]] ||
        !number) {
        return @"";
    }
    if (number.length < 14) {
        return number;
    }
    NSString *prefix = [number substringToIndex:2];
    NSString *suffix = [number substringFromIndex:number.length - 2];
    return [NSString stringWithFormat:@"%@**************%@", prefix, suffix];
}

#pragma mark - 隐藏银行卡中间位数
+ (NSString *)xhq_hiddenBankCardNumber:(NSString *)number {
    if ([number isEqual:[NSNull null]] ||
        [number isKindOfClass:[NSNull class]] ||
        !number) {
        return @"";
    }
    if (number.length == 0) {
        return @"";
    }
    if (number.length < 4) {
        return [NSString stringWithFormat:@"****  ****  ****  %@", number];
    }
    NSString *suffix = [number substringFromIndex:number.length - 4];
    return [NSString stringWithFormat:@"****  ****  ****  %@", suffix];
}

@end


#pragma mark - URL
@implementation NSString (XHQURL)

#pragma mark - url解码
+ (NSString*)xhq_URLDecodedString:(NSString*)str {
    NSString*decodedString=(__bridge_transfer NSString*) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef) str,CFSTR(""),CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

#pragma mark - url编码
+ (NSString *)xhq_URLEncodedString:(NSString *)str {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}

@end

@implementation NSString (XHQSize)

- (CGSize)xhq_sizeWithFont:(UIFont *)font withSize:(CGSize)size {
    
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName: font}
                              context:nil].size;
}

@end

