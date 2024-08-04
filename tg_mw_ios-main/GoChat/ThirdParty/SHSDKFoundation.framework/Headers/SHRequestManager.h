//
//  SHRequestManager.h
//  SHOpenInstall
//
//  Created by 朱云宽 on 2018/4/26.
//  Copyright © 2018年 smyjw. All rights reserved.
//

#import "SHHTTPSessionManager.h"
//请求成功回调block
typedef void (^requestManagerSuccessBlock)(NSDictionary *dic);

//请求失败回调block
typedef void (^requestManagerFailureBlock)(NSError *error);

//请求方法define
typedef enum {
    get,
    post,
} HTTPMethods;

@interface SHRequestManager : SHHTTPSessionManager

+(instancetype) sharedResquestManager;

- (void)requestWithMethod:(HTTPMethods)method
                 WithPath:(NSString *)path
               WithParams:(NSDictionary*)params
         WithSuccessBlock:(requestManagerSuccessBlock)success
          WithFailurBlock:(requestManagerFailureBlock)failure;

//encrypt 1:大数据加密 2:PHP加密 0:不加密
- (void)requestWithMethod:(HTTPMethods)method
        WithPath:(NSString *)path
      WithParams:(NSDictionary*)params WithEncrypt:(NSString *)encrypt
WithSuccessBlock:(requestManagerSuccessBlock)success
 WithFailurBlock:(requestManagerFailureBlock)failure;

@end
