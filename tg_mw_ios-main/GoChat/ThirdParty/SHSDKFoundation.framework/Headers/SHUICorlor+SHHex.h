//
//  SHUICorlor+SHHex.h
//  ShareInstallSDK
//
//  Created by 朱云宽 on 2019/8/1.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SHHex)

+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
