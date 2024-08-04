//
//  AuthUserManager.m
//  GoChat
//
//  Created by wangyutao on 2021/1/18.
//

#import "AuthUserManager.h"

static AuthUserManager *g_userManager = nil;

@implementation AuthUserInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithLong:self.userId] forKey:@"userId"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.data_directory forKey:@"data_directory"];
    [aCoder encodeObject:[NSNumber numberWithLong:self.lastLoginTime] forKey:@"lastLoginTime"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCurrentLoginUser] forKey:@"isCurrentLoginUser"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    AuthUserInfo *user = [[AuthUserInfo alloc] init];
    user.userId = [[aDecoder decodeObjectForKey:@"userId"] longValue];
    user.phone = [aDecoder decodeObjectForKey:@"phone"];
    user.data_directory = [aDecoder decodeObjectForKey:@"data_directory"];
    user.lastLoginTime = [[aDecoder decodeObjectForKey:@"lastLoginTime"] longValue];
    user.isCurrentLoginUser = [[aDecoder decodeObjectForKey:@"isCurrentLoginUser"] boolValue];
    return user;
}

- (id)copyWithZone:(NSZone *)zone
{
    AuthUserInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.userId = self.userId;
        copy.phone = [self.phone copy];
        copy.data_directory = [self.data_directory copy];
        copy.lastLoginTime = self.lastLoginTime;
        copy.isCurrentLoginUser = self.isCurrentLoginUser;
    }
    return copy;
}

- (NSString *)data_directoryPath
{
    return AuthUserPath(self.data_directory);
}

- (BOOL)isThisPhone:(NSString *)phone
{
    if(!IsStrEmpty(phone))
    {
        //正常比较
        if([phone isEqualToString:self.phone])
        {
            return YES;
        }
        //去除+号比较
        NSString *phone1 = [phone copy];
        NSString *phone2 = [self.phone copy];
        if([phone1 hasPrefix:@"+"])
        {
            phone1 = [phone1 substringFromIndex:1];
        }
        if([phone2 hasPrefix:@"+"])
        {
            phone2 = [phone2 substringFromIndex:1];
        }
        if([phone1 isEqualToString:phone2])
        {
            return YES;
        }
        //去除0比较
        if([phone1 hasPrefix:@"0"])
        {
            phone1 = [phone1 substringFromIndex:1];
        }
        if([phone2 hasPrefix:@"0"])
        {
            phone2 = [phone2 substringFromIndex:1];
        }
        if([phone1 isEqualToString:phone2])
        {
            return YES;
        }
    }
    return NO;
}

@end

@interface AuthUserManager()
@property (nonatomic, strong) NSMutableArray *authUsersList;
@end

@implementation AuthUserManager

+ (AuthUserManager *)shareInstance
{
    if(g_userManager == nil)
    {
        g_userManager = [[AuthUserManager alloc] init];
        [g_userManager load];
    }
    return g_userManager;
}

- (NSMutableArray *)authUsersList
{
    if(_authUsersList == nil)
    {
        _authUsersList = [NSMutableArray array];
    }
    return _authUsersList;
}

- (void)load
{
    NSArray *list = [AuthUserManager getAuthUsers];
    if(list != nil && [list isKindOfClass:[NSArray class]])
    {
        if(list.count>0)
        {
            [self.authUsersList addObjectsFromArray:list];
        }
    }
}

//当前登录用户，可能为空
- (AuthUserInfo *)currentAuthUser
{
    for(AuthUserInfo *auth in self.authUsersList)
    {
        if(auth.isCurrentLoginUser)
        {
            return auth;
        }
    }
    return nil;
}

//根据号码获取认证用户信息，可能为空
- (AuthUserInfo *)authUser:(NSString *)phone
{
    if(!IsStrEmpty(phone))
    {
        for(AuthUserInfo *auth in self.authUsersList)
        {
            if([auth isThisPhone:phone])
            {
                return auth;
            }
        }
    }
    return nil;
}

- (AuthUserInfo *)authUserFromDirectory:(NSString *)data_directory
{
    if(!IsStrEmpty(data_directory))
    {
        for(AuthUserInfo *auth in self.authUsersList)
        {
            if([auth.data_directory isEqualToString:data_directory])
            {
                return auth;
            }
        }
    }
    return nil;
}

//除当前登录用户之外，用户列表
- (NSArray *)authListWithoutCurrentAuthUser
{
    NSMutableArray *list = [NSMutableArray array];
    for(AuthUserInfo *auth in self.authUsersList)
    {
        if(!auth.isCurrentLoginUser)
        {
            [list addObject:auth];
        }
    }
    return list;
}

//初始化一个数据目录
- (NSString *)create_data_directory
{
    return AuthUserPath([Common generateGuid]);
}

- (void)resetAllUserLogout
{
    for(AuthUserInfo *auth in self.authUsersList)
    {
        if(auth.isCurrentLoginUser)
        {
            auth.lastLoginTime = (long)([[NSDate date] timeIntervalSince1970]);
            auth.isCurrentLoginUser = NO;
        }
    }
}

//用户-登录
- (void)login:(NSString *)phone data_directory:(NSString *)data_directory
{
    [self resetAllUserLogout];
    AuthUserInfo *curUser_Directory = [self authUserFromDirectory:[data_directory lastPathComponent]];
    if(curUser_Directory != nil)
    {
        if([curUser_Directory isThisPhone:phone])
        {//同一个
            curUser_Directory.lastLoginTime = (long)([[NSDate date] timeIntervalSince1970]);
            curUser_Directory.isCurrentLoginUser = YES;
        }
        else
        {//不是同一个
            AuthUserInfo *curUser = [self authUser:phone];
            if(curUser)
            {
                [self.authUsersList removeObject:curUser];
            }
            curUser_Directory.phone = phone;
            curUser_Directory.userId = UserInfo.shareInstance._id;
            curUser_Directory.lastLoginTime = (long)([[NSDate date] timeIntervalSince1970]);
            curUser_Directory.isCurrentLoginUser = YES;
        }
    }
    else
    {
        AuthUserInfo *curUser = [self authUser:phone];
        if(curUser)
        {
            curUser.data_directory = [data_directory lastPathComponent];
            curUser.lastLoginTime = (long)([[NSDate date] timeIntervalSince1970]);
            curUser.isCurrentLoginUser = YES;
        }
        else
        {
            curUser = [AuthUserInfo new];
            curUser.userId = UserInfo.shareInstance._id;
            curUser.phone = phone;
            curUser.data_directory = [data_directory lastPathComponent];
            curUser.lastLoginTime = (long)([[NSDate date] timeIntervalSince1970]);
            curUser.isCurrentLoginUser = YES;
            [self.authUsersList addObject:curUser];
        }
    }
    [AuthUserManager saveAuthUsers:self.authUsersList];
}

//更新当前用户userid
- (void)updateCurrentUserId:(long)userId
{
    AuthUserInfo *curUser = [self currentAuthUser];
    if(curUser && curUser.userId==0)
    {
        curUser.userId = userId;
        [AuthUserManager saveAuthUsers:self.authUsersList];
    }
}

//更新当前用户phone
- (void)updateCurrentUserPhone:(NSString *)phone
{
    if(!IsStrEmpty(phone))
    {
        AuthUserInfo *curUser = [self currentAuthUser];
        if(curUser)
        {
            curUser.phone = phone;
            [AuthUserManager saveAuthUsers:self.authUsersList];
        }
    }
}

//当前用户-退出登录
- (void)logout
{
    AuthUserInfo *cur = [self currentAuthUser];
    if(cur != nil)
    {
        [self.authUsersList removeObject:[self currentAuthUser]];
        [self resetAllUserLogout];
        [AuthUserManager saveAuthUsers:self.authUsersList];
    }
}

//登录新账号
- (void)loginOtherAccount
{
    [self resetAllUserLogout];
    [AuthUserManager saveAuthUsers:self.authUsersList];
}

+ (void)cleanDestroyFolder
{
    
}

#pragma mark - userdefault save or get
+ (NSArray *)getAuthUsers
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"auth_users"];
    if(data)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        unarchiver.requiresSecureCoding = NO;
        return [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    }
    return nil;
}

+ (void)saveAuthUsers:(NSArray *)list
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"auth_users"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
