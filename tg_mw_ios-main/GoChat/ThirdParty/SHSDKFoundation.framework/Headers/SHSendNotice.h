//
//  SHSendNotice.h
//  SHOpenInstall
//
//  Created by 朱云宽 on 2019/7/10.
//  Copyright © 2019 smyjw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "SHNoticeModel.h"
#import "SHWebModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SHSendNotice : NSObject

+(instancetype)sharedNotice;

-(void)sendNoticeModel:(SHNoticeModel *)noticeModel webModel:(SHWebModel *)webModel;

//iOS10新增：处理前台收到通知的代理方法
-(void)xuserNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;


//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)xuserNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;


@end

NS_ASSUME_NONNULL_END
