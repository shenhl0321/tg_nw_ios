//
//  UIColor+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/6/16.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UIColor+Ext.h"


@implementation UIColor (Ext)

+ (instancetype)xhq_base {
    return UIColor.colorMain;
}

+ (instancetype)xhq_background {
    return XHQHexColor(COLOR_VALUE_BACKGROUND);
}

+ (instancetype)xhq_pur {
    return XHQHexColor(COLOR_VALUE_PUR);
}

+ (instancetype)xhq_orange {
    return XHQHexColor(COLOR_VALUE_ORANGE);
}

+ (instancetype)xhq_red {
    return XHQHexColor(COLOR_VALUE_RED);
}

+ (instancetype)xhq_line {
    return XHQHexColor(COLOR_VALUE_LINE);
}

+ (instancetype)xhq_aTitle {
    return XHQHexColor(COLOR_VALUE_TITLE);
}

+ (instancetype)xhq_content {
    return XHQHexColor(COLOR_VALUE_CONTENT);
}

+ (instancetype)xhq_assist{
    return XHQHexColor(COLOR_VALUE_ASSIST);
}

+ (instancetype)xhq_section {
    return XHQHexColor(COLOR_VALUE_SECTION);
}

+ (instancetype)xhq_randorm {
    return XHQRGB(
                  (arc4random_uniform(256)),
                  (arc4random_uniform(256)),
                  (arc4random_uniform(256))
                  );
}

+ (instancetype)xhq_colorFromHexString:(NSString *)hexStr {
    
    NSString *cString = [[hexStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}


@end
