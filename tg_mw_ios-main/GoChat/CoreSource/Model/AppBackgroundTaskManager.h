//
//  AppBackgroundTaskManager.h
//  GoChat
//
//  Created by zlp&hj on 2022/5/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppBackgroundTaskManager : NSObject

+(instancetype)shareInstance;

- (void)startBackgroundTaskWithApp:(UIApplication *)app;

- (void)stopBackgroundTask;

@end

NS_ASSUME_NONNULL_END
