//
//  SHHttpTool.h
//  SHOpenInstall
//
//  Created by 朱云宽 on 2018/3/7.
//  Copyright © 2018年 smyjw. All rights reserved.
//

#import "SHHTTPSessionManager.h"

//请求成功回调block
typedef void (^requestSuccessBlock)(NSDictionary *dic);

//请求失败回调block
typedef void (^requestFailureBlock)(NSError *error);

//请求方法define
typedef enum {
    GET,
    POST,
} HTTPMethod;


@interface SHHttpTool : SHHTTPSessionManager

+ (instancetype)sharedManager;
- (void)requestWithMethod:(HTTPMethod)method
                 WithPath:(NSString *)path
               WithParams:(NSDictionary*)params
         WithSuccessBlock:(requestSuccessBlock)success
          WithFailurBlock:(requestFailureBlock)failure;

//encrypt 1:大数据加密 2:PHP加密 0:不加密
- (void)requestWithMethod:(HTTPMethod)method
        WithPath:(NSString *)path
      WithParams:(NSDictionary*)params WithEncrypt:(NSString *)encrypt
WithSuccessBlock:(requestSuccessBlock)success
 WithFailurBlock:(requestFailureBlock)failure;

@end
