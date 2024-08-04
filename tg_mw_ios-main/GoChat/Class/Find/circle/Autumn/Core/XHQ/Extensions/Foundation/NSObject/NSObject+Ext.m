//
//  NSObject+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/7/5.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "NSObject+Ext.h"
#import <objc/runtime.h>

@implementation NSObject (Ext)

+ (BOOL)xhq_notNULL:(id)obj {
    if ([obj isEqual:[NSNull null]] ||
        [obj isKindOfClass:[NSNull class]] ||
        !obj) {
        return NO;
    }
    return YES;
}

+ (void)xhq_swizzlingOriginalSEL:(SEL)originalSEL swizzedSEL:(SEL)swizzedSEL {
    
    Method originalMethod = class_getInstanceMethod([self class], originalSEL);
    Method swizzedMethod = class_getInstanceMethod([self class], swizzedSEL);
    
    BOOL isAddMethod = class_addMethod([self class], originalSEL, method_getImplementation(swizzedMethod), method_getTypeEncoding(swizzedMethod));
    
    if (isAddMethod) {
        class_replaceMethod(self, originalSEL, method_getImplementation(swizzedMethod), method_getTypeEncoding(swizzedMethod));
    }else {
        method_exchangeImplementations(originalMethod, swizzedMethod);
    }
}


@end


#pragma mark - +通知
@implementation NSObject (Notification)

/**
 处理通知
 */
- (void)xhq_handleNotification:(NSNotification *)notification {
    
}

/**
 添加通知
 */
- (void)xhq_addObserveNotification:(NSNotificationName)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:nil];
    SEL sel = @selector(xhq_handleNotification:);
    if ([self respondsToSelector:sel]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:sel name:notification object:nil];
    }
}

/**
 发送通知
 */
- (void)xhq_postObserveNotification:(NSNotificationName)notification {
    [self xhq_postObserveNotification:notification withObject:nil];
}

/**
 发送参数通知
 */
- (void)xhq_postObserveNotification:(NSNotificationName)notification withObject:(id)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:object];
}

/**
 移除通知
 */
- (void)xhq_removeObserveNotification:(NSNotificationName)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:nil];
}

/**
 移除全部通知
 */
- (void)xhq_removeAllObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
