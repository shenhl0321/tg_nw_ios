//
//  AppConfigInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/6/17.
//

#import "AppConfigInfo.h"

@implementation AppConfigInfo

static AppConfigInfo *sharedInstance = nil;

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
        sharedInstance.can_see_explore_bar = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_see_explore_bar"];
        sharedInstance.can_see_discovery_bar = [[NSUserDefaults standardUserDefaults] boolForKey:@"can_see_discovery_bar"];
    });
    return sharedInstance;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithBool:self.onlyFriendChat] forKey:@"onlyFriendChat"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.onlyWhiteAddFriend] forKey:@"onlyWhiteAddFriend"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.permitModifyUserName] forKey:@"permitModifyUserName"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    AppConfigInfo *config = [[AppConfigInfo alloc] init];
    config.onlyFriendChat = [[aDecoder decodeObjectForKey:@"onlyFriendChat"] boolValue];
    config.onlyWhiteAddFriend = [[aDecoder decodeObjectForKey:@"onlyWhiteAddFriend"] boolValue];
    config.permitModifyUserName = [[aDecoder decodeObjectForKey:@"permitModifyUserName"] boolValue];
    return config;
}

- (id)copyWithZone:(NSZone *)zone
{
    AppConfigInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.onlyFriendChat = self.onlyFriendChat;
        copy.onlyWhiteAddFriend = self.onlyWhiteAddFriend;
        copy.permitModifyUserName = self.permitModifyUserName;
    }
    return copy;
}

#pragma mark - userdefault save or get
+ (AppConfigInfo *)getAppConfigInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"AppConfigInfo"];
    if(data)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        unarchiver.requiresSecureCoding = NO;
        return [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    }
    return nil;
}

+ (void)saveAppConfigInfo:(AppConfigInfo *)info
{
    if(info != nil)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info requiringSecureCoding:NO error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"AppConfigInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
