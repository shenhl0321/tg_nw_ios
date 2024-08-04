//
//  NSArray+XHQSafe.m
//  Cafu
//
//  Created by 帝云科技 on 2018/6/4.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import "NSArray+XHQSafe.h"
#import <objc/runtime.h>
#import "XHQ.h"

@implementation NSArray (XHQSafe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzedMethod];
    });
}

+ (void)swizzedMethod
{
    [objc_getClass("__NSArray0") xhq_swizzlingOriginalSEL:@selector(objectAtIndex:)
                                               swizzedSEL:@selector(xhq_zeroObjectAtIndex:)];
    [objc_getClass("__NSSingleObjectArrayI") xhq_swizzlingOriginalSEL:@selector(objectAtIndex:)
                                                           swizzedSEL:@selector(xhq_singleObjectAtIndex:)];
    [objc_getClass("__NSArrayI") xhq_swizzlingOriginalSEL:@selector(objectAtIndex:)
                                               swizzedSEL:@selector(xhq_objectAtIndex:)];
    if (@available(iOS 11.0, *))
    {
        [objc_getClass("__NSArrayI") xhq_swizzlingOriginalSEL:@selector(objectAtIndexedSubscript:)
                                                   swizzedSEL:@selector(xhq_objectAtIndexedSubscript:)];
    }
}

- (id)xhq_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        XHQLog(@"数组越界:object");
        return nil;
    }
    return [self xhq_objectAtIndex:index];
}

- (id)xhq_zeroObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        XHQLog(@"数组越界:zero");
        return nil;
    }
    return [self xhq_zeroObjectAtIndex:index];
}

- (id)xhq_objectAtIndexedSubscript:(NSUInteger)index
{
    if (index >= self.count) {
        XHQLog(@"数组越界:subscript");
        return nil;
    }
    return [self xhq_objectAtIndexedSubscript:index];
}

- (id)xhq_singleObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        XHQLog(@"数组越界:single");
        return nil;
    }
    return [self xhq_singleObjectAtIndex:index];
}

@end




@implementation NSMutableArray (XHQSafe)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzedMethod];
    });
}

+ (void)swizzedMethod
{
    [objc_getClass("__NSArrayM") xhq_swizzlingOriginalSEL:@selector(objectAtIndex:)
                                               swizzedSEL:@selector(xhq_objectAtIndex:)];
    if (@available(iOS 11.0, *))
    {
        [objc_getClass("__NSArrayM") xhq_swizzlingOriginalSEL:@selector(objectAtIndexedSubscript:)
                                                   swizzedSEL:@selector(xhq_objectAtIndexedSubscript:)];
    }
    [objc_getClass("__NSArrayM") xhq_swizzlingOriginalSEL:@selector(addObject:)
                                               swizzedSEL:@selector(xhq_addObject:)];
    [objc_getClass("__NSArrayM") xhq_swizzlingOriginalSEL:@selector(removeObjectAtIndex:)
                                               swizzedSEL:@selector(xhq_removeObjectAtIndex:)];
    [objc_getClass("__NSArrayM") xhq_swizzlingOriginalSEL:@selector(insertObject:atIndex:)
                                               swizzedSEL:@selector(xhq_insertObject:atIndex:)];
    [objc_getClass("__NSArrayM") xhq_swizzlingOriginalSEL:@selector(replaceObjectAtIndex:withObject:)
                                               swizzedSEL:@selector(xhq_replaceObjectAtIndex:withObject:)];
}

- (id)xhq_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        XHQLog(@"数组越界:__NSArrayM");
        return nil;
    }
    return [self xhq_objectAtIndex:index];
}

- (id)xhq_objectAtIndexedSubscript:(NSUInteger)index
{
    if (index >= self.count) {
        XHQLog(@"数组越界:__NSArrayM_Subscript");
        return nil;
    }
    return [self xhq_objectAtIndexedSubscript:index];
}

- (void)xhq_addObject:(id)object
{
    if (!object) {
        return;
    }
    [self xhq_addObject:object];
}

- (void)xhq_removeObjectAtIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return;
    }
    [self xhq_removeObjectAtIndex:index];
}

- (void)xhq_insertObject:(id)object atIndex:(NSUInteger)index
{
    if (index > self.count) {
        return;
    }
    if (!object) {
        return;
    }
    [self xhq_insertObject:object atIndex:index];
}

- (void)xhq_replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    if (index >= self.count) {
        return;
    }
    if (!object) {
        return;
    }
    [self xhq_replaceObjectAtIndex:index withObject:object];
}

@end
