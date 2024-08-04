//
//  PermenantThread.h
//  GoChat
//
//  Created by apple on 2022/1/21.
//

#import <Foundation/Foundation.h>

typedef void (^PermenantThreadTask)(void);

NS_ASSUME_NONNULL_BEGIN

@interface PermenantThread : NSObject

/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(PermenantThreadTask)task;

/**
 结束线程
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
