//
//  TimerCounter.h
//  sendVolt
//
//  Created by wangyutao on 2017/11/15.
//  Copyright © 2017年 wangyutao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimerCounter;
@protocol TimerCounterDelegate <NSObject>
@optional
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm;
@end

@interface TimerCounter : NSObject
@property (nonatomic, weak) id<TimerCounterDelegate> delegate;

- (void)startCountProcess:(NSTimeInterval)sec repeat:(BOOL)repeat;
- (void)stopCountProcess;

@property (nonatomic, strong) NSString *data;
@end
