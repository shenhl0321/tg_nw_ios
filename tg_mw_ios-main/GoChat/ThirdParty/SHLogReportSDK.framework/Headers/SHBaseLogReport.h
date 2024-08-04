//
//  SHBaseLogReport.h
//  SHLogReportSDK
//
//  Created by 朱云宽 on 2019/10/15.
//  Copyright © 2019 路鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SHBaseLogReport : NSObject

+(instancetype)getInstance;

//初始化日志上报方法
-(void)initWithLogReport;


//安装量统计
-(void)installLogReportCompletion:(void(^)(NSDictionary *dic , NSError *error))completion;
//覆盖安装
-(void)coverinstall;
//活跃量统计
-(void)activeLogReportCompletion:(void(^)(NSDictionary *dic , NSError *error))completion;
//在线时长统计
-(void)onlineLogReportWithCompletion:(void(^)(NSDictionary *dic ,NSError*error))completion;

-(void)onlineLogReoprtWithOnlineTime:(NSString *)onlinetime completion:(void(^)(NSDictionary *dic ,NSError*error))completion;

//注册量统计
-(void)registerLogReport;


//活动上报接口
/**
 * v1.2.3 SDK新增打点统计方法
 * @ param actentryid  活动入口id，保证唯一性
 * @ param entrytype 站内传活动入口id对应的类型：分享收徒传share,活动内点击传actclick,进入活动传entry；站外不传
 * @ param visitplatform 站内不传 ；站外访问分享页的平台（如：weixin,weibo等）
 * @ param actid  自定义事件id
 * @ param subactid 自定义事件下的参数
 * @ param materialid 自定义事件参数下的参数值
 * @ param type 展示传"show"、点击传"click"、关闭传"close"
 **/
+(void)dotStatisticalWithActentryid:(NSString *)actentryid entrytype:(NSString *)entrytype visitplatform:(NSString *)visitplatform actid:(NSString *)actid subactid:(NSString *)subactid materialid:(NSString *)materialid type:(NSString *)type;

-(void)activityReport;


@end

NS_ASSUME_NONNULL_END
