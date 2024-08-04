//
//  SessionDevice.h
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 {
 "@type" : "session",
 "api_id" : 8,
 "application_name" : "",
 "application_version" : "1.0.1, TDLib 1.6.10",
 "country" : ", China",
 "device_model" : "iPhone Simulator",
 "id" : "0",
 "ip" : "112.36.231.67",
 "is_current" : true,
 "is_official_application" : true,
 "is_password_pending" : false,
 "last_active_date" : 0,
 "log_in_date" : 0,
 "platform" : "",
 "region" : "CN",
 "system_version" : "15.2"
 }
 */

/// 登陆的设备信息

@interface SessionDevice : JWModel

@property (nonatomic, assign) NSInteger api_id;
@property (nonatomic, copy) NSString *application_name;
@property (nonatomic, copy) NSString *application_version;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *device_model;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) BOOL is_current;
@property (nonatomic, assign) BOOL is_official_application;
@property (nonatomic, assign) BOOL is_password_pending;
@property (nonatomic, assign) NSInteger last_active_date;
@property (nonatomic, assign) NSInteger log_in_date;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *system_version;

- (UIImage *)deviceIcon;

- (NSString *)versionText;

@end

NS_ASSUME_NONNULL_END
