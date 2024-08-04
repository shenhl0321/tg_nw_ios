//
//  NSObject+Ext.h
//  Excellence
//
//  Created by 帝云科技 on 2017/7/5.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Ext)

/**
 检测对象是否为空

 @param obj 对象
 @return YES or NO
 */
+ (BOOL)xhq_notNULL:(id)obj;

/**
 方法转换
 @param originalSEL 原方法
 @param swizzedSEL 替换方法
 */
+ (void)xhq_swizzlingOriginalSEL:(SEL)originalSEL swizzedSEL:(SEL)swizzedSEL;

@end


#pragma mark - 通知分类类
@interface NSObject (Notification)
/**
 处理通知
 */
- (void)xhq_handleNotification:(NSNotification *)notification;
/**
 添加通知
 */
- (void)xhq_addObserveNotification:(NSNotificationName)notification;
/**
 发送通知
 */
- (void)xhq_postObserveNotification:(NSNotificationName)notification;
/**
 发送参数通知
 */
- (void)xhq_postObserveNotification:(NSNotificationName)notification withObject:(id)object;
/**
 移除通知
 */
- (void)xhq_removeObserveNotification:(NSNotificationName)notification;
/**
 移除全部通知
 */
- (void)xhq_removeAllObserveNotification;

@end
