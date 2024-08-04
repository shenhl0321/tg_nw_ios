//
//  MNChatUtil.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNChatUtil : NSObject

+ (void)headerImgV:(UIImageView *)headerImgV chat:(ChatInfo *)chat size:(CGSize)size;

+ (NSString *)titleFromChat:(ChatInfo *)chat;

+ (NSMutableAttributedString *)contentFromChat:(ChatInfo *)chat;
@end

NS_ASSUME_NONNULL_END
