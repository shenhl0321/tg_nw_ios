//
//  MNAuthorizedAddressView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNAuthorizedAddressView : UIView
@property (nonatomic, copy) void (^goToAuthorizationBlock)(UIButton *sender);
@end

NS_ASSUME_NONNULL_END
