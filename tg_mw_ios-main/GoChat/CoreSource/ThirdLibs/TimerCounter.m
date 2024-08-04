//
//  TimerCounter.m
//  sendVolt
//
//  Created by wangyutao on 2017/11/15.
//  Copyright © 2017年 wangyutao. All rights reserved.
//

#import "TimerCounter.h"

@interface TimerCounter ()
@property(nonatomic, strong) NSTimer *runTimer;
@end

@implementation TimerCounter

- (void)runCountProcess
{
    if([self.delegate respondsToSelector:@selector(TimerCounter_RunCountProcess:)])
    {
        [self.delegate TimerCounter_RunCountProcess:self];
    }
}

- (void)startCountProcess:(NSTimeInterval)sec repeat:(BOOL)repeat
{
    self.runTimer = [NSTimer scheduledTimerWithTimeInterval:sec
                                                     target:self
                                                   selector:@selector(runCountProcess)
                                                   userInfo:nil
                                                    repeats:repeat];
}

- (void)stopCountProcess
{
    if(_runTimer)
    {
        if([_runTimer isValid])
        {
            [_runTimer invalidate];
        }
        _runTimer = nil;
    }
}

@end
