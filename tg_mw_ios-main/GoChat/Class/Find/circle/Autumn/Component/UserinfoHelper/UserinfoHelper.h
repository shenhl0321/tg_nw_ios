//
//  UserinfoHelper.h
//  GoChat
//
//  Created by Autumn on 2021/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserinfoHelper : NSObject

/// 加载用户名
+ (void)setUsername:(NSInteger)userid inLabel:(UILabel *)label;

/// 加载用户头像
+ (void)setUserAvatar:(NSInteger)userid inImageView:(UIImageView *)imageView;

/// 获取用户名
+ (void)getUsernames:(NSArray *)ids completion:(void(^)(NSArray *names))completion;

+ (void)getUserinfos:(NSArray *)ids completion:(void(^)(NSArray *userinfos))completion;

/// 获取用户拓展信息（生日、性别、地区等）
+ (void)getUserExtInfo:(long)userid completion:(void(^)(UserInfoExt *ext))completion;

@end

NS_ASSUME_NONNULL_END
