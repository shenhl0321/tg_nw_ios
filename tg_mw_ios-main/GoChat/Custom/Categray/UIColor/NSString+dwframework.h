//
//  NSString+jojo.h
//  PoBar
//
//  Created by jojo on 6/8/14.
//  Copyright (c) 2014 jojo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (dwframework)

- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber; // 固话+手机

/**
 * 固话
 */
- (BOOL)isValidTelephoneNumber;

/**
 * 手机
 */
- (BOOL)isValidMobilePhoneNumber;

- (BOOL)deptNumInputShouldNumber:(NSString *)str;

/// 验证是否为银行卡号
- (BOOL)isBankCard;

- (NSString *)trim;
- (NSString *)firstLowerCaseLetterString;

- (NSString *)stringFromMD5;
- (BOOL)containsString:(NSString *)subString;

// remove html tag
- (NSString *)stringByStrippingHTML;

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

@interface NSString (SNURLEncodingAdditions)
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
+ (NSString *)getNowTimeTimestamp;
+ (NSString *)timeStampToTime:(NSString *)timeStr formatter:(NSString *)dataformatterStr;

+ (CGSize)sizeWithmaxSize:(CGSize)size anText:(NSString *)anString;

@end
