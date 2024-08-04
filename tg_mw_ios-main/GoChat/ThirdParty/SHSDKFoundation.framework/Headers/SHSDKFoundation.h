//
//  SHSDKFoundation.h
//  SHSDKFoundation
//
//  Created by 路鹏 on 2019/10/15.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHMacro.h"
#import "SHHttpTool.h"
#import "SHRequestManager.h"
#import "SHSIRequest.h"
#import "SHUICorlor+SHHex.h"
#import "UIView+SHExtension.h"
#import "CALayer+SHLoginLayer.h"
#import "SHGetAppInfoTool.h"
#import "SHSITool.h"
#import "SHCustomNetReachabilityManager.h"
#import "SHHTTPSessionManager.h"
#import "SHGzipRequestSerializer.h"
#import "SHURLSessionManager.h"
#import "SHURLResponseSerialization.h"
#import "SHURLRequestSerialization.h"
#import "SHSecurityPolicy.h"
#import "SHNetworkReachabilityManager.h"
#import "SHUIDeviceHardware.h"
#import "SHSDKTaskReport.h"
#import "SHSendNotice.h"
#import "SHWebModel.h"
#import "SHNoticeModel.h"


@interface SHSDKFoundation : NSObject
+(instancetype)getInstance;
-(void)initFoundationSDK;

@end

