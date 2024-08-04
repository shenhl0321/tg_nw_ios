//
//  MNThemeManager.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, MNThemeStyle) {
    MNThemeStyleDefault = 0,//默认样式
    MNThemeStyleYellow,
    MNThemeStyleBlue,
    MNThemeStyleGreen,
};

@interface MNThemeManager : NSObject

//@property (nonatomic, assign)
+ (MNThemeManager *)shareInstance;
@property (nonatomic, assign) MNThemeStyle themeStyle;

@end
MNThemeManager *MNThemeMgr();

