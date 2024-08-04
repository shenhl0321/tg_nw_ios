//
//  MNPrivateWaitView.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNPrivateWaitView : UIView
//不知道需不需要点击功能。。定义成按钮比较保险吧。
@property (nonatomic, strong) UIButton *btn;
///
@property (nonatomic,strong) UserInfo *userInfo;
@end

NS_ASSUME_NONNULL_END
