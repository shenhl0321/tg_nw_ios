//
//  NSArray+CZTool.m
//  GoChat
//
//  Created by mac on 2021/7/15.
//

#import "NSArray+CZTool.h"

@implementation NSArray (CZTool)

- (BOOL)containString:(NSString *)str{
    for (NSString *item in self) {
        if ([str isEqualToString:item]) {
            return YES;
        }
    }
    return NO;
}

@end
