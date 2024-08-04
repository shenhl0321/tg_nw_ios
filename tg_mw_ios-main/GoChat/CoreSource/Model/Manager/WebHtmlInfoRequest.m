//
//  WebHtmlInfoRequest.m
//  GoChat
//
//  Created by apple on 2021/12/28.
//

#import "WebHtmlInfoRequest.h"
#import "TFHpple.h"
#import "AFNetworking.h"

@interface WebHtmlInfoRequest ()
/// 缓存信息，url为key
@property (nonatomic,strong) NSMutableDictionary *cacheInfo;
@end

@implementation WebHtmlInfoRequest

+ (WebHtmlInfoRequest *)shareInstance{
    return [[self alloc] init];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

- (NSMutableDictionary *)cacheInfo{
    if (!_cacheInfo) {
        _cacheInfo = [NSMutableDictionary dictionary];
    }
    return _cacheInfo;
}



- (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 默认解析模式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    // 配置请求序列化
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    
    [serializer setRemovesKeysWithNullValues:YES];
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    // 配置响应序列化
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                              @"text/json",
                                                                              @"text/javascript",
                                                                              @"text/html",
                                                                              nil];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager.securityPolicy setValidatesDomainName:NO];
    
//    [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36" forHTTPHeaderField:@"User-Agent"];//平台
    [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"User-Agent"];//平台
    
    return manager;
}

- (void)getWebHtml:(NSString *)urlStr success:(void(^)(id response, NSString *dataStr))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    if (IsStrEmpty(urlStr)) {
        if (failure) {
            NSError *error = [[NSError alloc] initWithDomain:@"url is empty" code:400 userInfo:@{@"msg":@"请求地址为空".lv_localized}];
            failure(nil, error);
        }
        return;
    }
    
    
    if (![urlStr hasPrefix:@"http"]) { // 不是以http开头
        NSArray *subS = [urlStr componentsSeparatedByString:@"."];
        if (subS.count < 3) { // 只有两部分，应该就是没有前面的头，手动拼接一下
            urlStr = [NSString stringWithFormat:@"www.%@", urlStr];
        }
        urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
    }
//    if (![CZCommonTool checkUrlWithString:urlStr]) {
//        if (failure) {
//            NSError *error = [[NSError alloc] initWithDomain:@"url is illegality" code:400 userInfo:@{@"msg":@"链接错误"}];
//            failure(nil, error);
//        }
//        return;
//    }
//    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet]];
    
    [[self manager] GET:urlStr parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *dataStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (success) {
            success(responseObject, dataStr);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}



- (void)getWebHtmlHeaderInfo:(NSString *)urlStr success:(void(^)(id response, NSDictionary *dataInfo))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    __block NSString *realUrl = [self preDealUrl:urlStr];
    
    NSDictionary *cacheValue = self.cacheInfo[realUrl];
    if (cacheValue != nil && [cacheValue isKindOfClass:[NSDictionary class]] && cacheValue.count > 0) {
        if (success) {
            success(nil, cacheValue);
        }
        return;
    }
    
    MJWeakSelf
    [self getWebHtml:realUrl success:^(id  _Nonnull response, NSString * _Nonnull dataStr) {
        
        TFHpple *Hpple = [[TFHpple alloc]initWithHTMLData:response];
        
        NSArray *array =[Hpple searchWithXPathQuery:@"//meta"]; //获取描述
        
        NSArray *titleA =[Hpple searchWithXPathQuery:@"//title"]; //获取标题
        
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        
        for (TFHppleElement *element in titleA) {
            NSString *title = [element content];
            if ([title containsString:@"文件".lv_localized]) {
                title = @"文件".lv_localized;
            }
            content[@"title"] = title;
        }
        
        for (TFHppleElement *element in array) {
            
            NSDictionary *dic = element.attributes;
            if ([dic[@"name"] isEqualToString:@"description"] || [dic[@"name"] isEqualToString:@"Description"]) {
                content[@"description"] = dic[@"content"];
                break;
            }
        }
        content[@"icon"] = [NSString stringWithFormat:@"%@/favicon.ico", realUrl];
        weakSelf.cacheInfo[realUrl] = content;
        
        if (content.count < 2) { // 只有一个icon信息，没有请求到其他的
            NSString *newUrl = @"";
            for (TFHppleElement *element in array) {
                NSDictionary *dic = element.attributes;
                if ([dic[@"http-equiv"] isEqualToString:@"refresh"]) {
                    NSString *con = dic[@"content"];
                    NSArray *arr = [con componentsSeparatedByString:@"url="];
                    if (arr.count == 2) {
                        newUrl = arr[1];
                    }
                    break;
                }
            }
            if (!IsStrEmpty(newUrl)) {
                [[WebHtmlInfoRequest shareInstance] getWebHtmlHeaderInfo:newUrl success:success failure:failure];
                return;
            }
        }
        
        if (success) {
            success(response, content);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

- (NSString *)preDealUrl:(NSString *)urlStr{
    if (![urlStr hasPrefix:@"http"]) { // 不是以http开头
        NSArray *subS = [urlStr componentsSeparatedByString:@"."];
        if (subS.count < 3) { // 只有两部分，应该就是没有前面的头，手动拼接一下
            urlStr = [NSString stringWithFormat:@"www.%@", urlStr];
        }
        urlStr = [NSString stringWithFormat:@"http://%@", urlStr];
    }
    return urlStr;
}

@end
