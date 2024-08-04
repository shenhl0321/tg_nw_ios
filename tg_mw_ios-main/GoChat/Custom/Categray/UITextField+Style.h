//
//  UITextField+Style.h
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/10.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (Style)
- (void)mn_defalutStyle;
- (void)mn_defalutStyleWithFont:(UIFont *)font;
- (void)mn_defalutStyleWithFont:(UIFont *)font leftMargin:(CGFloat)leftMargin;
- (void)mn_countryCodeStyle;
@end

NS_ASSUME_NONNULL_END
