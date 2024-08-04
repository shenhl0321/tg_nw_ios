//
//  DLGetAppInfoTool.h
//  NativeEastNews
//
//  Created by user on 15/8/28.
//  Copyright (c) 2015年 Gaoxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SHGetAppInfoTool : NSObject



/**
 *  获取当前设备的语言环境
 *
 *  @return 英语 en，zh-Hans是简体中文，zh-Hant是繁体中文。。。（详见百度）
 */
+ (NSString*)getPreferredLanguage;
/**
 *  获取 去除特殊符号的 IME
 */
+ (NSString *)deviceIMEandRomeveSymbol;
/**
 *  获取 设备唯一标示符(idfv ,存在钥匙串中)
 */
+ (NSString *)identifierOfVender;

///**
// *  用户是否开启了限制广告追踪
// */
//+ (BOOL)advertising_TrackingEnabled;
///**
// *  获取 广告标示符IDFV
// */
//+ (NSString *)identifierForAdvertising;

/**
 *  获取app verion版本 1.1.6
 */
+ (NSString *)getAppVersion;
/**
 *  获取app verion版本 010106 / 100606
 */
+ (NSString *)getIntTypeAppVersion;
/**
 *  获取 ios系统版本
 */
+ (NSString *)getSystemVersion;
/**
 *  获取 bundle id
 */
+ (NSString *)getAppBundleId;
/**
 *  获取联网方式 conn: 连网方式（-1:NotReachable  0：Unknown，1：WiFi，2：2G， 3：3G，4：4G）
 */
+ (NSInteger)getAppConnectType;
/**
 * 	carrier: 运营商（0：Unknown，1：移动，2：联通，3：电信）
 */
+ (NSString *)getAppCarrier;
/**
 *  device: 设备品牌和型号，UrlEncode 编码
 */
+ (NSString *)deviceModel;
/**
 * 	density：屏幕密度 ,,高分屏 就是2 ,普通屏 是1
 */
+ (NSString *)getAppDeviceDensity;
/**
 * 	MD5加密 32位
 */
+ (NSString *)md5HexDigest:(NSString *)input;
/**
 *  获取设备分辨率
 */
+ (NSString *)getAppResolution;

/* wifi信息*/
+ (NSDictionary *)getWifiInfo;


/**
 *  根据颜色 生成一个图片
 */
+ (UIImage *)createImageWithColor: (UIColor*) color;
/**
 *  获取 远程推送授权
 *
 *  @return YES 已授权 、 NO 未授权
 */
+ (BOOL)getRemotePushStatue;

/**
 *
 * 获取秘钥
 */
+ (NSArray *)getSecretKeys;
/**
 *
 * 获取地方头条秘钥
 */
+ (NSArray *)getSecretKeysDF;
///**
// *  base64加密
// */
//- (NSString *)encodeBase64:(NSString *)str;
///**
// *  base64解密
// */
//- (NSString *)decodeBase64:(NSString *)str;

//SHA-1 加密
+ (NSString *)sha1Digest:(NSString *)input;

@end
