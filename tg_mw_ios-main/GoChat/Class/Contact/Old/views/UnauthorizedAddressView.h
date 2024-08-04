//
//  UnauthorizedAddressView.h
//  GoChat
//
//  Created by Demi on 2021/9/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnauthorizedAddressView : UIView

@property (nonatomic, copy) void (^authorizedAddressBlock)(UIButton *sender);

@end

NS_ASSUME_NONNULL_END
