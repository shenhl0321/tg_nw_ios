//
//  UITextField+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/6/22.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UITextField+Ext.h"

@implementation UITextField (Ext)

- (BOOL)input:(NSString *)number limit:(NSString *)limit {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:limit];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void)substringToIndex:(NSInteger)index {
    if (self.text.length > index) {
        self.text = [self.text substringToIndex:index];
    }
}

- (void)setNumbersKeyboard {
    self.keyboardType = UIKeyboardTypeNumberPad;
}

- (void)setNumbersPunctuationKeyBoard {
    self.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
}

@end
