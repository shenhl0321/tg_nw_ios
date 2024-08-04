//
//  ZyHttpResponse.m
//
//  Created by wang yutao on 14-8-7.
//  Copyright (c) 2014年 wangyutao. All rights reserved.
//

#import "ZyHttpResponse.h"

@implementation ZyHttpResponse

+ (instancetype)GeneralError
{
    //一般性错误
    ZyHttpResponse *response = [[ZyHttpResponse alloc] init];
    response.errorCode = ZY_HTTP_ERROR_CODE_FAILED;
    response.errorMsg = NSLocalizedString(@"request_fail", nil);
    return response;
}

+ (instancetype)ParamerError
{
    //参数错误
    ZyHttpResponse *response = [[ZyHttpResponse alloc] init];
    response.errorCode = ZY_HTTP_ERROR_CODE_FAILED;
    response.errorMsg = NSLocalizedString(@"request_fail", nil);
    return response;
}

+ (instancetype)NetworkError
{
    ZyHttpResponse *response = [[ZyHttpResponse alloc] init];
    response.errorCode = ZY_HTTP_ERROR_CODE_FAILED;
    response.errorMsg = NSLocalizedString(@"request_fail", nil);
    return response;
}

+ (instancetype)SysError
{
    ZyHttpResponse *response = [[ZyHttpResponse alloc] init];
    response.errorCode = ZY_HTTP_ERROR_CODE_SYS_ERROR;
    //系统级别错误，应用层无需处理
    response.errorMsg = @"";
    return response;
}

@end
