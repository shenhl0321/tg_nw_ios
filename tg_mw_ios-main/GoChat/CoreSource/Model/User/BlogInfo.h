//
//  BlogInfo.h
//  GoChat
//
//  Created by mac on 2021/11/3.
//

#import "JWModel.h"
#import "PhotoInfo.h"
#import "VideoInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class Blog, BlogLocation, BlogLocationList, BlogContent, BlogUserDates, BlogUserDate, BlogRepays, BlogRepayList, BlogEntities, BlogEntity, BlogEntityType;

@interface BlogInfo : JWModel

/// 媒体内容：图片、视频
@property (nonatomic, strong) BlogContent *content;

/// 位置信息
@property (nonatomic, strong) BlogLocation *location;

/// 点赞数量
@property (nonatomic, assign) NSInteger like_count;

/// 置顶
@property (nonatomic, assign) BOOL pinned;

/// 是否点赞
@property (nonatomic, assign) BOOL liked;

/// 评论数量
@property (nonatomic, assign) NSInteger reply_count;

/// 被 @
@property (nonatomic, assign) BOOL mentioned;

/// 文本内容
@property (nonatomic, copy) NSString *text;

/// 用户 id
@property (nonatomic, assign) NSInteger user_id;

/// 赏金
@property (nonatomic, assign) CGFloat rewarded;

/// 文本类型（针对 `#` 和 `@`）
@property (nonatomic, strong) BlogEntities *entities;

@property (nonatomic, assign) NSInteger date;

@end

@interface BlogLocation : JWModel

/// 地址
@property (nonatomic, copy) NSString *address;

/// 定位信息
@property (nonatomic, strong) BlogLocationList *location;

@end

@interface BlogLocationList : JWModel

@property (nonatomic, assign) NSInteger horizontal_accuracy;

/// 纬度
@property (nonatomic, assign) float latitude;

/// 精度
@property (nonatomic, assign) float longitude;

@end

@interface BlogContent : JWModel

/// 图片数组
@property (nonatomic, strong) NSArray<PhotoInfo *> *photos;

/// 视频
@property (nonatomic, strong) VideoInfo *video;

- (BOOL)isPhotoContent;

- (BOOL)isVideoContent;

@end

@interface BlogUserDates : JWModel

/// 点赞数
@property (nonatomic, assign) NSInteger total_count;

/// 点赞列表
@property (nonatomic, strong) NSArray<BlogUserDate *> *user_dates;

@end

@interface BlogUserDate : JWModel

/// 用户 id
@property (nonatomic, assign) NSInteger user_id;

///
@property (nonatomic, assign) NSInteger date;

@end

@interface BlogRepays : JWModel

/// 评论数
@property (nonatomic, assign) NSInteger total_count;

/// 评论列表
@property (nonatomic, strong) NSArray<BlogRepayList *> *replys;

@end

@interface BlogRepayList : JWModel

/// 用户 id
@property (nonatomic, assign) NSInteger user_id;

///
@property (nonatomic, assign) NSInteger date;

/// 评论内容
@property (nonatomic, copy) NSString *text;

/// 点赞
@property (nonatomic, assign) BOOL liked;

@end

@interface BlogId : JWModel

/// 帖子 id
@property (nonatomic, assign) NSInteger blog_id;

/// 回复 id
@property (nonatomic, assign) NSInteger reply_id;

@end

@interface BlogEntities : JWModel

@property (nonatomic, strong) NSArray<BlogEntity *> *entities;

@end

@interface BlogEntity : JWModel

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) BlogEntityType *type;

@end

@interface BlogEntityType : JWModel

@property (nonatomic, assign) NSInteger user_id;

@property (nonatomic, copy) NSString *text;

- (NSString *)topicText;

- (BOOL)isAt;
- (BOOL)isTopic;

@end

NS_ASSUME_NONNULL_END
