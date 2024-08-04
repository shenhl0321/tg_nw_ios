//
//  SHSITool.h
//  SHSmartInstallKit
//
//  Created by smyjw on 2017/11/24.
//  Copyright © 2017年 smyjw. All rights reserved.
//

#import <Foundation/Foundation.h>

//-1:NotReachable  0：Unknown，1：WiFi，2：2G， 3：3G，4：4G
typedef NS_ENUM(NSInteger, SHNetWorkType) {
    SHNetWorkTypeNotable = -1,
    SHNetWorkTypeUnknown = 0,
    SHNetWorkTypeWifi    = 1,
    SHNetWorkType2G      = 2,
    SHNetWorkType3G      = 3,
    SHNetWorkType4G      = 4,
};

@interface SHSITool : NSObject
@property (nonatomic ,copy)NSString *provinceStr;
@property (nonatomic ,copy)NSString *cityStr;
@property (nonatomic ,copy)NSString *latitude;
@property (nonatomic ,copy)NSString *longitude;
/**  网络状态 */
@property (nonatomic, assign) SHNetWorkType currentNetworkState;

+(NSString *)DataTOjsonString:(id)object;

#pragma mark 屏幕宽度
+(NSString *)screenWeigth;

#pragma mark 屏幕高度
+(NSString *)screenHeight;

#pragma mark 像素
+(NSString *)pixel;

#pragma mark 像素 2.0/3.0格式
+(NSString *)pixel1;

#pragma mark 当前操作系统
+(NSString *)operatingSystem;

#pragma mark 当前framework版本
+(NSString *)frameworkVersion;

#pragma mark json转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

#pragma mark 字典转json
+(NSString *)convertToJsonData:(NSDictionary *)dict;

#pragma mark 获取手机系统版本
+(NSString*)phoneVersion;

#pragma mark 获取app当前版本号
+(NSString *)appVersion;

#pragma mark MD5加密
+(NSString *)MD5:(NSString *)plainText;

#pragma mark 获取公共参数

+(NSString *)getParameters;

+ (NSString *)md5:(NSString *)str;

+ (NSString*)md5Codesign:(NSDictionary*)dict;

+ (NSString *)getIDFA;

+(NSString *)getNowTimeTimestamp;

+(NSString *)getQId;

#pragma mark 获取接口公共参数

+(NSDictionary *)getPublicParameters;

#pragma mark json转json字符串
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

#pragma mark 首次登录
+(void)isFisrtLogin;

#pragma mark 活动activity接口公共参数
+(NSString *)getActivityParames;

#pragma mark 获取经纬度
-(void)getGpsInfo:(void(^)(double lat, double lng))completion;

+(NSDictionary *)getGpsInfo ;

+ (NSString*)jsonStr:(NSObject*)obj ;
@end
