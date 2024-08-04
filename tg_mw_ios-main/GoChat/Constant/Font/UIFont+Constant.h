//
//  UIFont+Constant.h
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//




NS_ASSUME_NONNULL_BEGIN

@interface UIFont (Constant)
//下面的都是默认
+ (UIFont *)ttFontOfSize:(CGFloat)size weight:(NSUInteger)weight;

+ (UIFont *)blackCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)extraBoldCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)semiBoldCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)lightCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)thinCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)boldCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)heavyCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)mediumCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)regularCustomFontOfSize:(CGFloat)fontSize;

+ (UIFont *)helveticaFontOfSize:(CGFloat)fontSize;


@end

NS_ASSUME_NONNULL_END
