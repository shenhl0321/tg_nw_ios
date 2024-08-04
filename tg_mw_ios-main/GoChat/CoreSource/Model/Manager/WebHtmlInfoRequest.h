//
//  WebHtmlInfoRequest.h
//  GoChat
//
//  Created by apple on 2021/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WebHtmlInfoRequest : NSObject<NSCopying>
+ (WebHtmlInfoRequest *)shareInstance;

/// 通过地址，获取对应网站的html元素
/// 会user-agant 会设置成PC的
/// @param urlStr 网站地址
- (void)getWebHtml:(NSString *)urlStr success:(void(^)(id response, NSString *dataStr))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

/// 通过地址，获取对应网站头部的描述信息、标题、图标
/// @param urlStr 网站地址
- (void)getWebHtmlHeaderInfo:(NSString *)urlStr success:(void(^)(id response, NSDictionary *dataInfo))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
