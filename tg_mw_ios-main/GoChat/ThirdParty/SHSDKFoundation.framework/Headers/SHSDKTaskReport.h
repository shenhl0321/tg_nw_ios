//
//  SHSDKTaskReport.h
//  SHSDKFoundation
//
//  Created by 朱云宽 on 2019/10/12.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHSDKTaskReport : NSObject

+(instancetype)getInitializeInstance;
-(void)taskConfig;
-(void)checkInitClearLocalData;

@end

NS_ASSUME_NONNULL_END
