//
//  DiscoverMenuInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/5/11.
//

#import "DiscoverMenuInfo.h"

@implementation DiscoverMenuInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    DiscoverMenuInfo *menu = [[DiscoverMenuInfo alloc] init];
    menu.title = [aDecoder decodeObjectForKey:@"title"];
    menu.icon = [aDecoder decodeObjectForKey:@"icon"];
    menu.url = [aDecoder decodeObjectForKey:@"url"];
    return menu;
}

- (id)copyWithZone:(NSZone *)zone
{
    DiscoverMenuInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.title = [self.title copy];
        copy.icon = [self.icon copy];
        copy.url = [self.url copy];
    }
    return copy;
}

@end

@implementation DiscoverMenuSectionInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.menus forKey:@"menus"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    DiscoverMenuSectionInfo *menu = [[DiscoverMenuSectionInfo alloc] init];
    menu.title = [aDecoder decodeObjectForKey:@"title"];
    menu.menus = [aDecoder decodeObjectForKey:@"menus"];
    return menu;
}

- (id)copyWithZone:(NSZone *)zone
{
    DiscoverMenuSectionInfo *copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        copy.title = [self.title copy];
        copy.menus = self.menus;
    }
    return copy;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"menus" : @"DiscoverMenuInfo"};
}

#pragma mark - userdefault save or get
+ (NSArray *)getDiscoverSections
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"discover_sections"];
    if(data)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        unarchiver.requiresSecureCoding = NO;
        return [unarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
    }
    return nil;
}

+ (void)saveDiscoverSections:(NSArray *)list
{
    if(list != nil)
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list requiringSecureCoding:NO error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"discover_sections"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (DiscoverMenuSectionInfo *)timeline {
    DiscoverMenuSectionInfo *section = DiscoverMenuSectionInfo.new;
    section.title = @"朋友圈".lv_localized;
    DiscoverMenuInfo *menu = DiscoverMenuInfo.new;
    menu.title = @"朋友圈".lv_localized;
    menu.icon = @"find_ic_friends";
    section.menus = @[menu];
    return section;
}

+ (DiscoverMenuSectionInfo *)scan {
    DiscoverMenuSectionInfo *section = DiscoverMenuSectionInfo.new;
    section.title = @"扫一扫".lv_localized;
    DiscoverMenuInfo *menu = DiscoverMenuInfo.new;
    menu.title = @"扫一扫".lv_localized;
    menu.icon = @"find_scan";
    section.menus = @[menu];
    return section;
}

@end
