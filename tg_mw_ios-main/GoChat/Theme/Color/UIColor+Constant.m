//
//  UIColor+Constant.m
//  Connect
//
//  Created by XMJ on 2020/4/14.
//  Copyright © 2020 MoorgenSmartHome. All rights reserved.
//

#import "UIColor+Constant.h"
//#import "ThemeManager.h"

@implementation UIColor (Constant)


+ (UIColor *)colorMain:(CGFloat)alpha{
    UIColor *color = HexRGBAlpha(0x0DBFC0, alpha);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        color = HexRGBAlpha(0x1679FF, alpha);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
        color = HexRGBAlpha(0xF8B616, alpha);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
        color = HexRGBAlpha(0x00C69B, alpha);
    }
    return color;
    
}
+ (UIColor *)colorMain{
//    UIColor *color = HexRGB(0x0DBFC0);
//    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
//        color = HexRGB(0x1679FF);
//    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
//        color = HexRGB(0xF8B616);
//    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
//        color = HexRGB(0x00C69B);
//    }
//    return color;
    return [UIColor colorMain:1];
}

+ (UIColor *)colorTextFor0DBFC0{
    UIColor *color = HexRGB(0x0DBFC0);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        color = HexRGB(0x1679FF);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
        color = HexRGB(0xF8B616);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
        color = HexRGB(0x00C69B);
    }
   
    return color;
}

+ (UIColor *)colorTextFor23272A{
    UIColor *color = HexRGB(0x23272A);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}
//WF改
+ (UIColor *)colorTextFor777777{
    UIColor *color = HexRGB(0x777777);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextForA9B0BF{
    UIColor *color = HexRGB(0xA9B0BF);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextFor878D9A {
    UIColor *color = HexRGB(0x878D9A);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextForFFFFFF{
    UIColor *color = HexRGB(0xFFFFFF);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextFor188CFF{
    UIColor *color = HexRGB(0x188CFF);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}
//红色删除这些不需要改
+ (UIColor *)colorTextForFD4E57{
    UIColor *color = HexRGB(0xFD4E57);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextFor000000{
    UIColor *color = HexRGB(0x000000);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextFor000000_:(CGFloat)alpha{
    UIColor *color = HexRGBAlpha(0x000000, alpha);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}
//WF改
+ (UIColor *)colorTextForD94545{
    UIColor *color = HexRGB(0xD94545);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}
//线条颜色不用改
+ (UIColor *)colorTextForE5EAF0{
    UIColor *color = HexRGB(0xE5EAF0);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorTextFor010009{
    UIColor *color = HexRGB(0x010009);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}


+ (UIColor *)colorForF5F9FA{
    UIColor *color = HexRGB(0xF5F9FA);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        color = HexRGB(0xF5F9FA);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
        color = HexRGB(0xFAFAFA);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
        color = HexRGB(0xF5F9FA);
    }
   
    return color;
}

//计时的红色
+ (UIColor *)colorforFD4E57{
    UIColor *color = HexRGB(0xFD4E57);
    return color;
}

//免打扰背景色
+ (UIColor *)colorforABACAD{
    UIColor *color = HexRGB(0xABACAD);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        color = HexRGB(0x1679FF);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
        color = HexRGB(0xF8B616);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
        color = HexRGB(0x00C69B);
    }
    return color;
}

+ (UIColor *)colorFor878D9A {
    UIColor *color = HexRGB(0x878D9A);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        
    }
    return color;
}

+ (UIColor *)colorBubbleMe{
    UIColor *color = HexRGB(0xECF8F6);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        color = HexRGB(0xECF8F6);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
        color = HexRGB(0xFFF5DC);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
        color = HexRGB(0xECF8F6);
    }
    return color;
}

+ (UIColor *)colorBubbleOther{
    UIColor *color = HexRGB(0xF5F9FA);
    if (MNThemeMgr().themeStyle == MNThemeStyleBlue) {
        color = HexRGB(0xF5F9FA);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleYellow){
        color = HexRGB(0xFAFAFA);
    }else if (MNThemeMgr().themeStyle == MNThemeStyleGreen){
        color = HexRGB(0xF5F9FA);
    }
    return color;
}

//宝宝消息
+ (UIColor *)colorBubbleRedBubble{
    UIColor *color = HexRGB(0xFF9C33);
    return color;
}

//宝宝消息领取
+ (UIColor *)colorBubbleRedBubbleGot{//领取以后的
    UIColor *color = HexRGB(0xFFCE99);
    return color;
}

//
//链接的颜色 不需要改
+ (UIColor *)colorTextFor4D6EF1{
    UIColor *color = HexRGB(0x4D6EF1);
    return color;
}

+ (UIColor *)colorTextFor999999{
    UIColor *color = HexRGB(0x999999);
    return color;
}

@end
