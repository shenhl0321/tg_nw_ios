//
//  TabExMenuInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/6/17.
//

#import "TabExMenuInfo.h"

@implementation TabExMenuInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    [aCoder encodeObject:@(self.id) forKey:@"site_id"];
    [aCoder encodeObject:self.site_url forKey:@"site_url"];
    [aCoder encodeObject:self.site_name forKey:@"site_name"];
    [aCoder encodeObject:self.site_logo forKey:@"site_logo"];
    [aCoder encodeObject:self.created_at forKey:@"created_at"];
    [aCoder encodeObject:self.updated_at forKey:@"updated_at"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    TabExMenuInfo *menu = [[TabExMenuInfo alloc] init];
    menu.status = [[aDecoder decodeObjectForKey:@"status"] boolValue];
    menu.id = [[aDecoder decodeObjectForKey:@"site_id"] integerValue];
    menu.site_url = [aDecoder decodeObjectForKey:@"site_url"];
    menu.site_name = [aDecoder decodeObjectForKey:@"site_name"];
    menu.site_logo = [aDecoder decodeObjectForKey:@"site_logo"];
    menu.created_at = [aDecoder decodeObjectForKey:@"created_at"];
    menu.updated_at = [aDecoder decodeObjectForKey:@"updated_at"];
    return menu;
}
- (id)copyWithZone:(NSZone *)zone
{
    TabExMenuInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.status = self.status;
        copy.id = self.id;
        copy.site_name = [self.site_name copy];
        copy.site_url = self.site_url;
        copy.site_logo = self.site_logo;
        copy.created_at = self.created_at;
        copy.updated_at = self.updated_at;
    }
    return copy;
}

- (BOOL)isValid
{
    return self.status;
//    return !IsStrEmpty(self.site_name) && !IsStrEmpty(self.site_url);
}

#pragma mark - userdefault save or get
+ (TabExMenuInfo *)getTabExMenuInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"TabExMenuInfo"];
    if(data)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        unarchiver.requiresSecureCoding = NO;
        return [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    }
    return nil;
}

+ (void)saveTabExMenuInfo:(TabExMenuInfo *)info
{
    if(info != nil)
    {
        TabExMenuInfo *curMenuInfo = [TabExMenuInfo getTabExMenuInfo];
        //保存
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:info requiringSecureCoding:NO error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"TabExMenuInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //比较
        if(curMenuInfo == nil)
        {
            if([info isValid])
            {
                //tab菜单变化
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Tab_Ex_Menu_Changed) withInParam:nil];
            }
        }
        else
        {
            if([info isValid] != [curMenuInfo isValid])
            {
                //tab菜单变化
                [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Tab_Ex_Menu_Changed) withInParam:nil];
            }
            if([info isValid] && [curMenuInfo isValid])
            {
                if(![info.site_name isEqualToString:curMenuInfo.site_name] || ![info.site_url isEqualToString:curMenuInfo.site_url])
                {
                    //tab菜单变化
                    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Tab_Ex_Menu_Changed) withInParam:nil];
                }
            }
        }
    }
}

@end
