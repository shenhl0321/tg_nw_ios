//
//  PublishTimeline.h
//  GoChat
//
//  Created by Autumn on 2021/11/6.
//

#import "JWModel.h"
#import "BlogInfo.h"
#import "BlogUserGroup.h"
#import <AMapSearchKit/AMapSearchKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VisibleType) {
    VisibleTypePublic,
    VisibleTypePrivate,
    VisibleTypeAllow,
    VisibleTypeNotAllow,
};

@class PublishTimelineVisible, PublishTimelineContent, PublishTimelineContentVideo, PublishTimelineContentPhoto, PublishTimelineContentFile, PublishTimelineLocation, PublishTimelineLocationInfo, PublishTimelineEntities, PublishTimelineEntity, PublishTimelineEntityType;
@interface PublishTimeline : JWModel

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) NSArray *mention_ids;

@property (nonatomic, strong) NSArray<UserInfo *> *metions;

@property (nonatomic, strong) PublishTimelineVisible *visible;

@property (nonatomic, strong) PublishTimelineContent *contents;

@property (nonatomic, strong) PublishTimelineEntities *entities;

@property (nonatomic, strong, nullable) PublishTimelineLocation *location;

- (NSDictionary *)jsonObject;

- (void)fetchSelectedGroupMembersCompletion:(dispatch_block_t)completion;

@end

@interface PublishTimelineVisible : JWModel

@property (nonatomic, assign) VisibleType visibleType;

@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSArray *groups;

@property (nonatomic, strong) NSMutableArray *groupIds;

- (NSDictionary *)jsonObject;

- (void)fetchSelectedGroupMembersCompletion:(dispatch_block_t)completion;

- (NSString *)visibleTypeTitle;
- (NSString *)visibleTypeSubTitle;

+ (NSString *)visibleTypeTitle:(VisibleType)type;
+ (NSString *)visibleTypeSubTitle:(VisibleType)type;

- (NSArray<NSString *> *)groupNames;
- (NSArray<NSString *> *)userNames;
- (NSArray<NSNumber *> *)tagIds;

@end



@interface PublishTimelineContent : JWModel

@property (nonatomic, strong) NSMutableArray<UIImage *> *images;

@property (nonatomic, strong) NSArray<PublishTimelineContentPhoto *> *photos;
@property (nonatomic, strong, nullable) PublishTimelineContentVideo *video;

- (NSDictionary *)jsonObject;

@end


@interface PublishTimelineContentPhoto : JWModel

@property (nonatomic, strong) PublishTimelineContentFile *file;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

- (NSDictionary *)jsonObject;

@end

@interface PublishTimelineContentVideo : JWModel

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) PublishTimelineContentFile *thumbnailFile;
@property (nonatomic, strong) PublishTimelineContentFile *file;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

@property (nonatomic, copy) NSString *outputPath;

- (NSDictionary *)jsonObject;

- (BOOL)isValid;

@end

@interface PublishTimelineContentFile : JWModel

@property (nonatomic, copy) NSString *path;

- (NSDictionary *)jsonObject;

@end

@interface PublishTimelineLocation : JWModel

@property (nonatomic, strong) PublishTimelineLocationInfo *location;
@property (nonatomic, copy, nullable) NSString *address;
@property (nonatomic, strong, nullable) AMapPOI *poi;

- (NSDictionary *)jsonObject;

@end

@interface PublishTimelineLocationInfo : JWModel

/// 纬度
@property (nonatomic, assign) CGFloat latitude;

/// 精度
@property (nonatomic, assign) CGFloat longitude;

- (NSDictionary *)jsonObject;

@end

@interface PublishTimelineEntities : JWModel

@property (nonatomic, strong) NSMutableArray<PublishTimelineEntity *> *entities;

/// 删除标签
- (void)removeEntityWithRange:(NSRange)range;

/// 添加 #提醒 标签
- (void)addAtUser:(long)userid range:(NSRange)range;
/// 添加 #话题 标签
- (void)addTopic:(NSString *)topic range:(NSRange)range;

/// 更新标签位置
- (void)replaceRange:(NSRange)oRange withNewRange:(NSRange)nRange;

- (NSDictionary *)jsonObject;

/// 话题数组
- (NSArray<PublishTimelineEntity *> *)topicEntities;

@end

@interface PublishTimelineEntity : JWModel

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) PublishTimelineEntityType *type;

- (instancetype)initWithOffset:(NSInteger)offset length:(NSInteger)length type:(PublishTimelineEntityType *)type;

- (NSDictionary *)jsonObject;

- (BOOL)isTopic;

@end

@interface PublishTimelineEntityType : JWModel

@property (nonatomic, assign) NSInteger user_id;

@property (nonatomic, copy) NSString *text;

- (instancetype)initWithUserid:(NSInteger)userid;
- (instancetype)initWithText:(NSString *)text;

- (NSDictionary *)jsonObject;

@end

NS_ASSUME_NONNULL_END
