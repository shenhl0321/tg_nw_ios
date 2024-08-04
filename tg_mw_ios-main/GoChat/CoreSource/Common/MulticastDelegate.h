//
//  MulticastDelegate.h
//  
//

#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"

@interface MulticastDelegate : NSObject
{
    dispatch_queue_t moduleQueue;
    void *moduleQueueTag;
    
    id multicastDelegate;
}

@property (readonly) dispatch_queue_t moduleQueue;
@property (readonly) void *moduleQueueTag;

- (id)init;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate;

- (NSString *)moduleName;
@end
