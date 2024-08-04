//
//  SemaphoreTask.h
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import <Foundation/Foundation.h>

@interface SemaphoreTask : NSObject
- (BOOL)wait:(NSTimeInterval)timeout;
- (void)signalSuccess;
- (void)signalFailure;
@end
