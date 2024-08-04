//
//  SHSIRequest.h
//  SHSmartInstallKit
//
//  Created by smyjw on 2017/11/24.
//  Copyright © 2017年 smyjw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHSIRequest : NSObject

/*!@brief 抛出请求 post
 * @param url 接口地址
 * @param paramDic 请求参数
 * @param successBlock 成功回调
 * @param errorBlock 失败回调
 *
 */
+(void)postRequestWithUrl:(NSString *)url withParam:(NSMutableDictionary *)paramDic withSuccessBlock:(void(^)(id response))successBlock withErrorBock:(void(^)(id error))errorBlock;

+(void)postRequestWithUrlFormUrlencoded:(NSString *)url withParam:(NSMutableDictionary *)paramDic withSuccessBlock:(void(^)(id response))successBlock withErrorBock:(void(^)(id error))errorBlock;

//渠道统计
+(void)postRequestWithUrlChannelStatistics:(NSString *)url withParam:(NSMutableDictionary *)paramDic withSuccessBlock:(void(^)(id response))successBlock withErrorBock:(void(^)(id error))errorBlock;

//云控
+(void)postRequestWithCloudControlUrl:(NSString *)url withParam:(NSMutableDictionary *)paramDic withSuccessBlock:(void(^)(id response))successBlock withErrorBock:(void(^)(id error))errorBlock;

@end
