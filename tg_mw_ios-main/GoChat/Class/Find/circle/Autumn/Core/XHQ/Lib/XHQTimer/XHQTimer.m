//
//  XHQTimer.m
//  U-Alley
//
//  Created by 帝云科技 on 2018/2/24.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import "XHQTimer.h"

@interface XHQTimer ()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end

@implementation XHQTimer


+ (nullable NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)aTime target:(nullable id)aTarget selector:(nullable SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    XHQTimer *timer = [[XHQTimer alloc]init];
    timer.target = aTarget;
    timer.selector = aSelector;
    return [NSTimer scheduledTimerWithTimeInterval:aTime target:timer selector:@selector(doing:) userInfo:userInfo repeats:yesOrNo];
}

- (void)doing:(id)obj {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.target performSelector:self.selector withObject:obj];
#pragma clang diagnostic pop
}

@end
