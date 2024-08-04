//
//  NSString+Local.m
//  CoulisseV2
//
//  Created by XMJ on 2019/3/27.
//  Copyright © 2019 Mona's Pro. All rights reserved.
//

#import "NSString+Local.h"

@implementation NSString (Local)

- (NSString *)mn_localizedString {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = languages[0];
    //yi
//    if (!([currentLanguage containsString:@"zh"])) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
//        NSBundle *languageBundle = [NSBundle bundleWithPath:path];
//        return [languageBundle localizedStringForKey:[Util objToStr:self] value:@"" table:nil];
//    }
    return NSLocalizedString([Util objToStr:self], nil);
}

@end
