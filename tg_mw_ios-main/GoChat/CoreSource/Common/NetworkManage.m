//
//  NetworkManage.m
//  BaseChat
//
//  Created by hongliang shen on 2024/8/6.
//

#import "NetworkManage.h"

@implementation NetworkManage

static NetworkManage *sharedInstance = nil;
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}

- (AFHTTPSessionManager *)manager {
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

- (void)syncTabExMenuComplete:(void(^)(void))block
{
    MJWeakSelf
    AFHTTPSessionManager *manager = [self manager];
    [manager GET:@"http://chat.uukkim.cc:7070/api/client/ips" parameters:@{} headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        NSDictionary *data = responseObject[@"data"];
        weakSelf.backup_ips = [data objectForKey:@"backup_ips"];
        weakSelf.main_ips = [data objectForKey:@"main_ips"];
        [weakSelf mainIsValid:0 withBlock:^{
            block();
        }];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
//        [SVProgressHUD showErrorWithStatus:@"数据请求失败"];
    }];
}


- (void)mainIsValid:(NSInteger)index withBlock:(void(^)(void))block{
    MJWeakSelf
    AFHTTPSessionManager *manager = [self manager];
    NSString *main_ip = weakSelf.main_ips[index];
    if(![main_ip hasPrefix:@"http"]){
        main_ip = [NSString stringWithFormat:@"http://%@",main_ip];
    }
    NSString *new_main_ip = [NSString stringWithFormat:@"%@/api/client/ips",main_ip];
    [manager GET:new_main_ip parameters:@{} headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        //
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        weakSelf.main_ip = main_ip;
        block();
        //block();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
//        [SVProgressHUD showErrorWithStatus:@"数据请求失败"];
        if(index + 1 <= weakSelf.main_ips.count){
            [weakSelf mainIsValid:index + 1 withBlock:block];
        }
        
    }];
    
}

- (NSString *)setNetworkMainApiWithAppend:(NSString *)append{
    if(![self.main_ip hasPrefix:@"http"]){
        self.main_ip = [NSString stringWithFormat:@"http://%@",self.main_ip];
    }
    return [NSString stringWithFormat:@"%@%@",self.main_ip,append];
}

@end
