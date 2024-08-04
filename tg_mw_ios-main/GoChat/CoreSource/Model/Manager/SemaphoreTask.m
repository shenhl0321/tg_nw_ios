//
//  SemaphoreTask.m
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import "SemaphoreTask.h"
//#import <objc/runtime.h>
//#import <libkern/OSAtomic.h>
#import <stdatomic.h>

@implementation SemaphoreTask
{
    atomic_int atomicFlags;
    dispatch_semaphore_t semaphore;
}
static const atomic_int receipt_unknown = 0 << 0;
static const atomic_int receipt_failure = 1 << 0;
static const atomic_int receipt_success = 1 << 1;

- (id)init
{
    if ((self = [super init]))
    {
        atomicFlags = receipt_unknown;
        semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)signalSuccess
{
    atomic_int mask = receipt_success;
    atomic_fetch_or(&atomicFlags, mask);
    
    dispatch_semaphore_signal(semaphore);
}

- (void)signalFailure
{
    atomic_int mask = receipt_failure;
    atomic_fetch_or(&atomicFlags, mask);
    
    dispatch_semaphore_signal(semaphore);
}

- (BOOL)wait:(NSTimeInterval)timeout_seconds
{
    atomic_int mask = 0;
    atomic_int flags = atomic_fetch_or(&atomicFlags, mask);
    
    if (flags != receipt_unknown) return (flags == receipt_success);
    
    dispatch_time_t timeout_nanos;
    
    if (isless(timeout_seconds, 0.0))
        timeout_nanos = DISPATCH_TIME_FOREVER;
    else
        timeout_nanos = dispatch_time(DISPATCH_TIME_NOW, (timeout_seconds * NSEC_PER_SEC));
    
    // dispatch_semaphore_wait
    //
    // Decrement the counting semaphore. If the resulting value is less than zero,
    // this function waits in FIFO order for a signal to occur before returning.
    //
    // Returns zero on success, or non-zero if the timeout occurred.
    //
    // Note: If the timeout occurs, the semaphore value is incremented (without signaling).
    
    long result = dispatch_semaphore_wait(semaphore, timeout_nanos);
    
    if (result == 0)
    {
        flags = atomic_fetch_or(&atomicFlags, mask);
        
        return (flags == receipt_success);
    }
    else
    {
        // Timed out waiting...
        return NO;
    }
}

- (void)dealloc
{
    #if !OS_OBJECT_USE_OBJC
    dispatch_release(semaphore);
    #endif
}

@end
