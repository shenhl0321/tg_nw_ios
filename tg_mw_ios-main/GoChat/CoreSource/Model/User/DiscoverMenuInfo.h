//
//  DiscoverMenuInfo.h
//  GoChat
//
//  Created by wangyutao on 2021/5/11.
//

#import <Foundation/Foundation.h>

@interface DiscoverMenuInfo : NSObject
//菜单标题
@property (nonatomic, copy) NSString *title;
//菜单图标
@property (nonatomic, copy) NSString *icon;
//菜单跳转的URL
@property (nonatomic, copy) NSString *url;
@end

@interface DiscoverMenuSectionInfo : NSObject
//分组标题
@property (nonatomic, copy) NSString *title;
//菜单列表 - DiscoverMenuInfo
@property (nonatomic, strong) NSArray *menus;

//本地缓存
+ (NSArray *)getDiscoverSections;
+ (void)saveDiscoverSections:(NSArray *)list;

+ (DiscoverMenuSectionInfo *)timeline;
+ (DiscoverMenuSectionInfo *)scan;

@end
