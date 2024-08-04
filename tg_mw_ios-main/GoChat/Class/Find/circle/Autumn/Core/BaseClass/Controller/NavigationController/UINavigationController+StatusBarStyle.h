//
//  UINavigationController+StatusBarStyle.h
//  Aoyo
//
//  Created by 帝云科技 on 2019/3/7.
//  Copyright © 2019 帝云科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DYNavigationBarStyle) {
    DYNavigationBarStyleDefault = 0,
    DYNavigationBarStyleClear,
    DYNavigationBarStyleImage
};

@interface UINavigationController (StatusBarStyle)

- (void)dy_setNavigationBarStyle:(DYNavigationBarStyle)style;

@end

NS_ASSUME_NONNULL_END
