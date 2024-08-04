//
//  AuthorizedAddressView.h
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthorizedAddressView : UIView
@property (nonatomic, copy) void (^goToAuthorizationBlock)(UIButton *sender);
@end

NS_ASSUME_NONNULL_END
