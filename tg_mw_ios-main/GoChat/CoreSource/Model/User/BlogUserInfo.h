//
//  BlogUserInfo.h
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlogUserInfo : JWModel
///
@property (nonatomic, assign) NSInteger user_id;
/// 动态数量
@property (nonatomic, assign) NSInteger blogs;
/// 关注数量
@property (nonatomic, assign) NSInteger follows;
/// 粉丝数量
@property (nonatomic, assign) NSInteger fans;
/// 获赞数量
@property (nonatomic, assign) NSInteger likes;
/// 是否已关注
@property (nonatomic, assign) BOOL followed;

@end

NS_ASSUME_NONNULL_END
