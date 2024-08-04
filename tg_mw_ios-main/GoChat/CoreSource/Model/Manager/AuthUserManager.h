//
//  AuthUserManager.h
//  GoChat
//
//  Created by wangyutao on 2021/1/18.
//

#import <Foundation/Foundation.h>

@interface AuthUserInfo : NSObject
@property (nonatomic) long userId;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *data_directory;
@property (nonatomic) long lastLoginTime;
@property (nonatomic) BOOL isCurrentLoginUser;

- (NSString *)data_directoryPath;
- (BOOL)isThisPhone:(NSString *)phone;
@end

@interface AuthUserManager : NSObject
+ (AuthUserManager *)shareInstance;

//当前登录用户，可能为空
- (AuthUserInfo *)currentAuthUser;
//根据号码获取认证用户信息，可能为空
- (AuthUserInfo *)authUser:(NSString *)phone;
//除当前登录用户之外，用户列表
- (NSArray *)authListWithoutCurrentAuthUser;
//初始化一个数据目录
- (NSString *)create_data_directory;
//用户-登录
- (void)login:(NSString *)phone data_directory:(NSString *)data_directory;
//更新当前用户userid
- (void)updateCurrentUserId:(long)userId;
//更新当前用户phone
- (void)updateCurrentUserPhone:(NSString *)phone;
//当前用户-退出登录
- (void)logout;
//登录新账号
- (void)loginOtherAccount;
//清理垃圾数据-登录成功时进行
+ (void)cleanDestroyFolder;
@end
