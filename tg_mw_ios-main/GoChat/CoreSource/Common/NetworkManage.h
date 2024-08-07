//
//  NetworkManage.h
//  BaseChat
//
//  Created by hongliang shen on 2024/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManage : NSObject

@property(nonatomic,copy)NSArray *backup_ips;
@property(nonatomic,copy)NSArray *main_ips;
@property(nonatomic,copy)NSString *main_ip;
+ (instancetype)sharedInstance;
- (void)syncTabExMenuComplete:(void(^)(void))block;

- (NSString *)setNetworkMainApiWithAppend:(NSString *)append;
@end

NS_ASSUME_NONNULL_END
