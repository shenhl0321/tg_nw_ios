//
//  NetworkManage.h
//  BaseChat
//
//  Created by hongliang shen on 2024/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define AppLaunchPageType1 0
#define AppLaunchPageType2 0


@interface NetworkManage : NSObject

@property(nonatomic,copy)NSArray *backup_ips;
@property(nonatomic,copy)NSArray *main_ips;
@property(nonatomic,copy)NSString *main_ip;
@property(nonatomic,copy)NSString *backup_ip;
+ (instancetype)sharedInstance;
- (void)syncTabExMenuComplete:(void(^)(void))block;

- (NSString *)setNetworkMainApiWithAppend:(NSString *)append;

- (NSString *)setNetworkBackupApiWithAppend:(NSString *)append;
@end

NS_ASSUME_NONNULL_END
