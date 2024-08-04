//
//  MNUnauthorizedAddressView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNUnauthorizedAddressView : UIView
@property (nonatomic, copy) void (^authorizedAddressBlock)(UIButton *sender);
@end

NS_ASSUME_NONNULL_END
