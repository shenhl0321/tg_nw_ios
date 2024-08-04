//
//  UIFont+Constant.m
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "UIFont+Constant.h"



@implementation UIFont (Constant)
+ (UIFont *)ttFontOfSize:(CGFloat)size weight:(NSUInteger)weight {
    NSString *fontName = @"AlibabaPuHuiTi_2_";
    NSString *houzhui = @"";
    switch (weight) {
        case 35:
            houzhui = @"Thin";
            break;
        case 45:
            houzhui = @"Light";
        case 55:
            houzhui = @"Regular";
        case 65:
            houzhui = @"Medium";
        case 75:
            houzhui = @"SemiBold";
        case 85:
            houzhui = @"Bold";
        case 95:
            houzhui = @"ExtraBold";
        case 105:
            houzhui = @"Heavy";
            break;
        case 115:
            houzhui = @"Black";
        default:
            break;
    }
    if (houzhui.length) {
        fontName = [NSString stringWithFormat:@"%@%ud_%@",fontName,weight,houzhui];
    }
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (font == nil) {
        font = [UIFont systemFontOfSize:size weight:weight];
    }
    return font;
}

+ (UIFont *)blackCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:115];
    }else{
        
    }
    
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)extraBoldCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:95];
    }else{
        font = [UIFont fontWithName:@"AlibabaPuHuiTi-Bold" size:fontSize];
    }
    
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)semiBoldCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:75];
    }else{
        font = [UIFont fontWithName:@"PingFangSC-Semibold" size:fontSize];
    }
    
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)lightCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:45];
    }else{
        font = [UIFont fontWithName:@"AlibabaPuHuiTi-Bold" size:fontSize];
    }
    
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)thinCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:35];
    }else{
        font = [UIFont fontWithName:@"AlibabaPuHuiTi-Bold" size:fontSize];
    }
    
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)boldCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:85];
    }else{
        font = [UIFont fontWithName:@"AlibabaPuHuiTi-Bold" size:fontSize];
    }
    
    if (font == nil) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)heavyCustomFontOfSize:(CGFloat)fontSize{
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:105];
    }else{
        font = [UIFont fontWithName:@"AlibabaPuHuiTi-Heavy" size:fontSize];
    }
    if (font == nil) {
        font = [UIFont italicSystemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)mediumCustomFontOfSize:(CGFloat)fontSize{
//    AlibabaPuHuiTi-Medium
    UIFont* font;
    if (TT) {
        font = [UIFont ttFontOfSize:fontSize weight:85];
    }else{
        font = [UIFont fontWithName:@"AlibabaPuHuiTi-Medium" size:fontSize];
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}

+ (UIFont *)helveticaFontOfSize:(CGFloat)fontSize{
//    AlibabaPuHuiTi-Regular
    UIFont* font;
    font = [UIFont fontWithName:@"Helvetica" size: fontSize];
    if (font == nil) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}


+ (UIFont *)regularCustomFontOfSize:(CGFloat)fontSize{
//    AlibabaPuHuiTi-Regular
    UIFont* font;
    font = [UIFont fontWithName:@"PingFangSC-Regular" size:fontSize];
    if (font == nil) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    return font;
}
//Helvetica
@end
