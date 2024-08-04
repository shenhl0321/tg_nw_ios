//
//  SHNetReachabilityManager.h
//  SHSDKFoundation
//
//  Created by 路鹏 on 2019/8/31.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const SHCustomNetworkingReachabilityStatNotification = @"SHCustomNetworkingReachabilityStatNotification";

@interface SHCustomNetReachabilityManager : NSObject
+ (SHCustomNetReachabilityManager *)share;
- (void)startReachability;
@end
