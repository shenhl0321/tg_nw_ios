//
//  VoiceTransferRequest.m
//  GoChat
//
//  Created by apple on 2022/2/17.
//

#import "VoiceTransferRequest.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "FileStreamOperation.h"

#define LFASR_HOST   @"http://raasr.xfyun.cn/api"


@implementation VoiceTransferRequest

+ (AFHTTPSessionManager *)manager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 默认解析模式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 配置请求序列化
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    [serializer setRemovesKeysWithNullValues:YES];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval = 600;
    // 配置响应序列化
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                              @"text/json",
                                                                              @"text/javascript",
                                                                              @"text/html",
                                                                              @"text/plain",
                                                                              nil];
    return manager;
}


+ (NSURLSessionTask *)postWithURL:(NSString *)url
                           params:(NSDictionary *)params
                          success:(XFResponseSuccessBlock)success
                          failure:(XFResponseFailureBlock)failure
{
    __block NSURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self manager];
    NSDictionary *rqHeader = manager.requestSerializer.HTTPRequestHeaders;
    
    session = [manager POST:url parameters:params headers:rqHeader progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    return session;
}


+(NSURLSessionUploadTask *)uploadFileWithURL:(NSString *)urlString params:(NSDictionary *)params fileKey:(NSString *)fileKey fileData:(NSData *)fileData filePath:(NSString *)filePath success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure{
    
    NSURL *URL = [[NSURL alloc]initWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:URL cachePolicy:(NSURLRequestUseProtocolCachePolicy) timeoutInterval:30];
    NSString *boundary = @"wfWiEWrgEFA9A78512weF7106A";

    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = @{
                                    @"Content-Type":[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary]
                                    };

    //multipart/form-data格式按照构建上传数据
    NSMutableData *postData = [[NSMutableData alloc]init];
    for (NSString *key in params) {
        NSString *pair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n",boundary,key];
        [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];

        id value = [params objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
        }else if ([value isKindOfClass:[NSData class]]){
            [postData appendData:value];
        }
        [postData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }

    //文件部分
    NSString *filename = [filePath lastPathComponent];
    NSString *contentType = AFContentTypeForPathExtension([filePath pathExtension]);

    NSString *filePair = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\";Content-Type=%@\r\n\r\n",boundary,fileKey,filename,contentType];
    [postData appendData:[filePair dataUsingEncoding:NSUTF8StringEncoding]];


    [postData appendData:fileData]; //加入文件的数据

    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    request.HTTPBody = postData;
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionUploadTask *updataTask = [session uploadTaskWithRequest:request fromData:postData completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (success) {
                success(data);
            }
        }else{
            if (failure) {
                failure(error);
            }
        }

    }];

    [updataTask resume];
    
    return updataTask;
    
}


static inline NSString * AFContentTypeForPathExtension(NSString *extension) {
#ifdef __UTTYPE__
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) {
        return @"audio/x-wav";
    } else {
        return contentType;
    }
#else
#pragma unused (extension)
    return @"audio/x-wav";
#endif
}


+ (NSURLSessionTask *)prepareWithLen:(NSInteger)fileLen fileName:(NSString *)fileName success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure {
    
    NSMutableDictionary *params = [self getBaseAuthParam:nil];
    params[@"file_len"] = @(fileLen);
    params[@"file_name"] = fileName;
    params[@"slice_num"] = @((fileLen/FileFragmentMaxSize) + (fileLen % FileFragmentMaxSize == 0 ? 0 : 1));
    
    NSString *url = [NSString stringWithFormat:@"%@/prepare", LFASR_HOST];
    return [self postWithURL:url params:params success:^(NSDictionary *response) {
        NSString *status = [NSString stringWithFormat:@"%@", response[@"ok"]];
        if ([status isEqualToString:@"0"]) {
            NSString *taskId = [NSString stringWithFormat:@"%@", response[@"data"]];
            if (success) {
                success(taskId);
                return;
            }
        }
        NSString *errorMsg = [NSString stringWithFormat:@"%@", response[@"failed"]];
        NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
        // 其他按异常情况处理
        if (failure) {
            failure(error);
        }
    } failure:failure];
}



+ (NSURLSessionUploadTask *)uploadWithTaskId:(NSString *)taskId sliceId:(NSString *)sliceId content:(NSData *)content filePath:(NSString *)filePath success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure {
    if (!content) {
        return nil;
    }
    NSMutableDictionary *params = [self getBaseAuthParam:taskId];
    params[@"slice_id"] = sliceId;
    
    NSString *url = [NSString stringWithFormat:@"%@/upload", LFASR_HOST];
    
    
    return [self uploadFileWithURL:url params:params fileKey:@"content" fileData:content filePath:filePath success:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *status = [NSString stringWithFormat:@"%@", dic[@"ok"]];
            if ([status isEqualToString:@"0"]) {
                if (success) {
                    success(dic);
                    return;
                }
            }
            NSString *errorMsg = [NSString stringWithFormat:@"%@", dic[@"failed"]];
            NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
            // 其他按异常情况处理
            if (failure) {
                failure(error);
            }
            return;
        }
        NSString *errorMsg = [NSString stringWithFormat:@"%@", @"数据错误".lv_localized];
        NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
        // 其他按异常情况处理
        if (failure) {
            failure(error);
        }
    } failure:failure];
    
    
}

+ (NSURLSessionTask *)mergeWithTaskId:(NSString *)taskId  success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure{
    NSMutableDictionary *params = [self getBaseAuthParam:taskId];
    
    NSString *url = [NSString stringWithFormat:@"%@/merge", LFASR_HOST];
    return [self postWithURL:url params:params success:^(NSDictionary *response) {
        NSString *status = [NSString stringWithFormat:@"%@", response[@"ok"]];
        if ([status isEqualToString:@"0"]) {
            if (success) {
                success(response);
                return;
            }
        }
        NSString *errorMsg = [NSString stringWithFormat:@"%@", response[@"failed"]];
        NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
        // 其他按异常情况处理
        if (failure) {
            failure(error);
        }
    } failure:failure];
}

+ (NSURLSessionTask *)getProgressWithTaskId:(NSString *)taskId  success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure{
    NSMutableDictionary *params = [self getBaseAuthParam:taskId];
    
    NSString *url = [NSString stringWithFormat:@"%@/getProgress", LFASR_HOST];
    return [self postWithURL:url params:params success:^(NSDictionary *response) {
        NSString *status = [NSString stringWithFormat:@"%@", response[@"ok"]];
        if ([status isEqualToString:@"0"]) {
            NSString *data = [NSString stringWithFormat:@"%@", response[@"data"]];
            NSDictionary *dic = [data mj_JSONObject];
            NSString *status = [NSString stringWithFormat:@"%@",dic[@"status"]];
            
            if (success) {
                NSMutableDictionary *par = [NSMutableDictionary dictionary];
                par[@"status"] = status;
                success(status);
            }
            return;
        }
        NSString *errorMsg = [NSString stringWithFormat:@"%@", response[@"failed"]];
        NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
        // 其他按异常情况处理
        if (failure) {
            failure(error);
        }
    } failure:failure];
}
+ (NSURLSessionTask *)getResultWithTaskId:(NSString *)taskId  success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure{
    NSMutableDictionary *params = [self getBaseAuthParam:taskId];
    
    NSString *url = [NSString stringWithFormat:@"%@/getResult", LFASR_HOST];
    return [self postWithURL:url params:params success:^(NSDictionary *response) {
        NSString *status = [NSString stringWithFormat:@"%@", response[@"ok"]];
        if ([status isEqualToString:@"0"]) {
            NSString *data = [NSString stringWithFormat:@"%@", response[@"data"]];
            NSArray *res = [data mj_JSONObject];
            
            if (success) {
                success(res);
            }
            return;
        }
        NSString *errorMsg = [NSString stringWithFormat:@"%@", response[@"failed"]];
        NSError *error = [NSError errorWithDomain:@"ErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey:errorMsg}];
        // 其他按异常情况处理
        if (failure) {
            failure(error);
        }
    } failure:failure];
}



+ (NSMutableDictionary *)getBaseAuthParam:(NSString *)taskId{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *timeStr = [NSString stringWithFormat:@"%.0f", time];
    param[@"app_id"] = XF_AppId;
    param[@"ts"] = timeStr;
    param[@"signa"] = [self xfSigna:timeStr];
    if (!IsStrEmpty(taskId)) {
        param[@"task_id"] = taskId;
    }
    return param;
}

+ (NSString *)xfSigna:(NSString *)time{
    
    NSString *baseString = [NSString stringWithFormat:@"%@%@", XF_AppId, time];
    NSString *md5Str = [Common md5:baseString];

    NSString *signa = [self HmacSHA1EncryptWithData:md5Str key:XF_SecretKey];
    return signa ;
    
}

+(NSString *)HmacSHA1EncryptWithData:(NSString *)data key:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    //Sha256:
    // unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    //CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
      
    //sha1
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
  
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
      
    NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
    return hash;
}

@end

