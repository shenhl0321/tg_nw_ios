//
//  MNThemeManager.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "MNThemeManager.h"

@implementation MNThemeManager

static MNThemeManager *manager;

+ (MNThemeManager *)shareInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[MNThemeManager alloc] init];
    });
    return manager;
}

@end
//主题的单例
MNThemeManager *MNThemeMgr(){
    return [MNThemeManager shareInstance];
}
