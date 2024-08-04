//
//  ZyHttpResponse.h
//
//  Created by wang yutao on 14-8-7.
//  Copyright (c) 2014年 wangyutao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZyHttpResponse;
//typedef void (^RequestFinishedBlock)(AFHTTPRequestOperation *operation, ZyHttpResponse *response);
typedef void (^UploadProgressBlock)(float progress);

typedef enum {
    ZY_HTTP_ERROR_CODE_SUCCESS = 1,
    ZY_HTTP_ERROR_CODE_FAILED,
    ZY_HTTP_ERROR_CODE_SYS_ERROR,
} ZY_HTTP_ERROR_CODE;

@interface ZyHttpResponse : NSObject
@property (nonatomic) ZY_HTTP_ERROR_CODE errorCode;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) id UserData;
@property (nonatomic, strong) id UserExData;

+ (instancetype)GeneralError;
+ (instancetype)ParamerError;
+ (instancetype)NetworkError;
+ (instancetype)SysError;
@end
