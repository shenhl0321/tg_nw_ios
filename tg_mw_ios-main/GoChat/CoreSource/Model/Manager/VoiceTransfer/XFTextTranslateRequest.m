//
//  XFTextTranslateRequest.m
//  GoChat
//
//  Created by apple on 2022/2/20.
//

#import "XFTextTranslateRequest.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonHMAC.h>
#import "FileStreamOperation.h"
#import "NSDate+Extend.h"

#define LFASR_HOST   @"http://itrans.xf-yun.com/v1/its"


@implementation XFTextTranslateRequest

+ (NSMutableDictionary *)buildBody:(NSString *)text{
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *header = [NSMutableDictionary dictionary];
    header[@"app_id"] = XF_AppId;
    header[@"status"] = @(3);
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSMutableDictionary *its = [NSMutableDictionary dictionary];
    its[@"from"] = @"en";
    its[@"to"] = @"cn";
    its[@"result"] = [NSMutableDictionary dictionary];
    parameter[@"its"] = its;
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    NSMutableDictionary *inputData = [NSMutableDictionary dictionary];
    inputData[@"encoding"] = @"utf8";
    inputData[@"status"] = @(3);
    inputData[@"text"] = [self base64String:text];
    payload[@"input_data"] = inputData;

    body[@"header"] = header;
    body[@"parameter"] = parameter;
    body[@"payload"] = payload;
    return body;
}

+ (NSString *)buildUrl{
    
    NSURL *url = [NSURL URLWithString:LFASR_HOST];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    
    NSMutableString *signature_origin = [NSMutableString stringWithFormat:@"host: %@\n", url.host];
    [signature_origin appendString:[NSString stringWithFormat:@"date: %@\n", dateStr]];
    [signature_origin appendString:[NSString stringWithFormat:@"POST %@ HTTP/1.1", url.path]];
    NSString *signature = [self hmacSHA256WithSecret:XF_TranslateASK content:signature_origin];
    
    NSString *authorization_origin = [NSString stringWithFormat:@"api_key=\"%@\", algorithm=\"%@\", headers=\"%@\", signature=\"%@\"", XF_TranslateAK, @"hmac-sha256", @"host date request-line", signature];
    NSString *authorization = [self base64String:authorization_origin];
    
    NSString *authorizationEncode = [authorization stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *dateStrEncode = [dateStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@?authorization=%@&host=%@&date=%@", LFASR_HOST, authorizationEncode, url.host, dateStrEncode];
    
}
/**
 *  加密方式,MAC算法: HmacSHA256
 *
 *  @param secret       秘钥
 *  @param content 要加密的文本
 *
 *  @return 加密后的字符串
 */
+ (NSString *)hmacSHA256WithSecret:(NSString *)secret content:(NSString *)content
{
    
    NSString* key = secret;
    NSString* data = content;
    
    const char *cKey = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    return [self base64forData:hash];
}

+ (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    NSInteger i;
    for (i=0; i < length; i += 3) {
    NSInteger value = 0;
    NSInteger j;
    for (j = i; j < (i + 3); j++) {
    value <<= 8;
    if (j < length) {  value |= (0xFF & input[j]);  }  }  NSInteger theIndex = (i / 3) * 4;  output[theIndex + 0] = table[(value >> 18) & 0x3F];
    output[theIndex + 1] = table[(value >> 12) & 0x3F];
    output[theIndex + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
    output[theIndex + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
}
 
+ (NSString *)base64String:(NSString *)str{
    // 进行base64加密
    NSData *textData =[str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Str = [textData base64EncodedStringWithOptions:0];
    
    return base64Str;
}

+ (NSString *)base64DecodeString:(NSString *)str{
    // 进行base64解密
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    NSString *res = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return res;
}


+ (void)translateText:(NSString *)text success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure{
    
    NSDictionary *body = [self buildBody:text];
    NSString *url = [self buildUrl];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];

    request.timeoutInterval = 600.f;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:jsonData];

    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary *responseObject, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *orgResult = responseObject[@"payload"][@"result"];
            NSString *encodeText = orgResult[@"text"];
            
            NSDictionary *decodeDic = [[self base64DecodeString:encodeText] mj_JSONObject];
            NSDictionary *transResult = decodeDic[@"trans_result"];
            NSString *resStr = transResult[@"dst"];
            if (success) {
                success(resStr);
            }
        } else {
            if (failure) {
                failure(error);
            }
        }
    }];
    [task resume];
}






@end

