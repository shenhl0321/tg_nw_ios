//
//  AppDelegate.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/19.
//

#import <UIKit/UIKit.h>

@interface NSObject(CategoryWithLimitCount)
@property (nonatomic, strong) NSNumber *mylimitCount;
@end

@interface LimitInput : NSObject
@end

@interface RightAlignedNoSpaceFixTextField : UITextField
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong,nonatomic) UIWindow *window;
@property (nonatomic, assign, getter=isAllowOrentitaionRotation) BOOL allowOrentitaionRotation;

/// App启动只进行一次 ping 域名
@property (nonatomic, assign, getter=isPingHost) BOOL pingHost;

- (void)gotoCheckUserView;
- (void)gotoHomeView;
- (void)gotoLoginView;
+ (void)gotoChatView:(NSObject *)chat;
+ (void)gotoChatView:(NSObject *)chat destMsgId:(long)destMsgId;
- (void)getApplicationConfigSettingLoginStyle;
//邀请进群
- (void)addGroupWithInviteLink;

@end

