//
//  MulticastDelegate.m
//
//

#import "MulticastDelegate.h"

@implementation MulticastDelegate

- (void)dealloc
{
    #if !OS_OBJECT_USE_OBJC
    dispatch_release(moduleQueue);
    #endif
}

- (id)init
{
    self = [super init];
    if (self)
    {
        NSString *moduleQueueName = [[self moduleName] stringByAppendingString:@"Module"];
        
        moduleQueue = dispatch_queue_create([moduleQueueName UTF8String], NULL);
        
        moduleQueueTag = &moduleQueueTag;
        
        dispatch_queue_set_specific(moduleQueue, moduleQueueTag, moduleQueueTag, NULL);
        
        multicastDelegate = [[GCDMulticastDelegate alloc] init];
    }
    return self;
}

- (dispatch_queue_t)moduleQueue
{
    return moduleQueue;
}

- (void *)moduleQueueTag
{
    return moduleQueueTag;
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else
        dispatch_async(moduleQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously
{
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(moduleQueueTag))
        block();
    else if (synchronously)
        dispatch_sync(moduleQueue, block);
    else
        dispatch_async(moduleQueue, block);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    [self removeDelegate:delegate delegateQueue:delegateQueue synchronously:YES];
}

- (void)removeDelegate:(id)delegate
{
    [self removeDelegate:delegate delegateQueue:NULL synchronously:YES];
}

- (NSString *)moduleName
{
    return NSStringFromClass([self class]);
}

@end
