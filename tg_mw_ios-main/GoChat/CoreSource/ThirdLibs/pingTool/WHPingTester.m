//
//  WHPingTester.m
//  BigVPN
//
//  Created by wanghe on 2017/5/11.
//  Copyright © 2017年 wanghe. All rights reserved.
//

#import "WHPingTester.h"

@interface WHPingTester()<SimplePingDelegate>
{
    NSTimer* _timer;
    NSDate* _beginDate;
}
@property(nonatomic, strong) SimplePing* simplePing;

@property(nonatomic, strong) NSMutableArray<WHPingItem*>* pingItems;

@property (nonatomic, assign, getter=isPinging) BOOL pinging;

@end

@implementation WHPingTester

- (instancetype) initWithHostName:(NSString*)hostName
{
    if(self = [super init])
    {
        self.simplePing = [[SimplePing alloc] initWithHostName:hostName];
        self.simplePing.delegate = self;
        self.simplePing.addressStyle = SimplePingAddressStyleAny;
        self.timeout = 1.0;
        self.pingItems = @[].mutableCopy;
    }
    return self;
}

- (void)startPing {
    
    self.pinging = YES;
    _beginDate = NSDate.date;
    [self.simplePing start];
    [self performSelector:@selector(pingTimeOut) withObject:nil afterDelay:self.timeout];
}

- (void)stopPing {
    [_timer invalidate];
    _timer = nil;
    [self.simplePing stop];
    self.simplePing = nil;
}


- (void)actionTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendPingData) userInfo:nil repeats:YES];
}

- (void)sendPingData {
    [self.simplePing sendPingWithData:nil];
}

- (void)endWithFlag:(BOOL)isSuccess {
    if (!self.isPinging) {
        return;
    }
    self.pinging = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pingTimeOut) object:nil];
    float delayTime = isSuccess ? [NSDate.date timeIntervalSinceDate:_beginDate] * 1000 : 0;
    NSError *error = isSuccess ? nil : [NSError errorWithDomain:NSURLErrorDomain code:111 userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)]) {
        [self.delegate didPingSucccessWithTime:delayTime withError:error];
    }
}

- (void)pingTimeOut {
    if (!self.isPinging) {
        return;
    }
    self.pinging = NO;
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:111 userInfo:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)]) {
        [self.delegate didPingSucccessWithTime:0 withError:error];
    }
}


#pragma mark Ping Delegate
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [self sendPingData];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    ChatLog(@"ping失败--->%@", error);
    [self endWithFlag:NO];
    return;
    [self.delegate didPingSucccessWithTime:0 withError:[NSError errorWithDomain:NSURLErrorDomain code:111 userInfo:nil]];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    
    return;
    WHPingItem* item = [WHPingItem new];
    item.sequence = sequenceNumber;
    [self.pingItems addObject:item];
    
    _beginDate = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([self.pingItems containsObject:item]) {
            ChatLog(@"超时---->");
            [self.pingItems removeObject:item];
            if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)]) {
                [self.delegate didPingSucccessWithTime:0 withError:[NSError errorWithDomain:NSURLErrorDomain code:111 userInfo:nil]];
            }
        }
    });
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    ChatLog(@"发包失败--->%@", error);
    [self endWithFlag:NO];
    return;
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)]) {
        [self.delegate didPingSucccessWithTime:0 withError:error];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [self endWithFlag:YES];
    return;
    float delayTime = [[NSDate date] timeIntervalSinceDate:_beginDate] * 1000;
    [self.pingItems enumerateObjectsUsingBlock:^(WHPingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.sequence == sequenceNumber) {
            [self.pingItems removeObject:obj];
        }
    }];
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)]) {
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:packet options:NSJSONReadingAllowFragments error:nil];
        NSString * str = [[NSString alloc] initWithData:packet encoding:NSUTF8StringEncoding];
        [self.delegate didPingSucccessWithTime:delayTime withError:nil];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {

}


@end

@implementation WHPingItem

@end
