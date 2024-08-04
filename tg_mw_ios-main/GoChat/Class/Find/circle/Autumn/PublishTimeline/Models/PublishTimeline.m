//
//  PublishTimeline.m
//  GoChat
//
//  Created by Autumn on 2021/11/6.
//

#import "PublishTimeline.h"
#import "MNChatViewController.h"

@implementation PublishTimeline

- (NSString *)atType {
    return @"sendBlog";
}

- (NSArray *)mention_ids {
    NSMutableArray *ids = NSMutableArray.array;
    for (UserInfo *info in self.metions) {
        [ids addObject:@(info._id)];
    }
    if (self.entities.entities.count > 0) {
        for (PublishTimelineEntity *e in self.entities.entities) {
            if (e.type.user_id > 0) {
                [ids addObject:@(e.type.user_id)];
            }
        }
    }
    return ids;
}

- (NSArray<UserInfo *> *)metions {
    if (!_metions) {
        _metions = NSArray.array;
    }
    return _metions;
}

- (PublishTimelineVisible *)visible {
    if (!_visible) {
        _visible = PublishTimelineVisible.new;
        [_visible setVisibleType:VisibleTypePublic];
    }
    return _visible;
}

- (PublishTimelineContent *)contents {
    if (!_contents) {
        _contents = PublishTimelineContent.new;
    }
    return _contents;
}

- (PublishTimelineLocation *)location {
    if (!_location) {
        _location = PublishTimelineLocation.new;
    }
    return _location;
}

- (PublishTimelineEntities *)entities {
    if (!_entities) {
        _entities = PublishTimelineEntities.new;
    }
    return _entities;
}

- (NSDictionary *)jsonObject {
    NSMutableDictionary *obj = @{
        @"@type": self.atType,
        @"mention_ids": self.mention_ids,
        @"text": self.text ? : @""
    }.mutableCopy;
    [obj setObject:self.visible.jsonObject forKey:@"visible"];
    [obj setObject:self.contents.jsonObject forKey:@"contents"];
    [obj setObject:self.location.jsonObject forKey:@"location"];
    [obj setObject:self.entities.jsonObject forKey:@"entities"];
    return obj.copy;
}

- (void)fetchSelectedGroupMembersCompletion:(dispatch_block_t)completion {
    [self.visible fetchSelectedGroupMembersCompletion:completion];
}

@end


@implementation PublishTimelineVisible

- (NSDictionary *)jsonObject {
    NSMutableDictionary *obj = @{@"@type": self.atType}.mutableCopy;
    NSMutableArray *users = self.groupIds.mutableCopy;
    if (self.users.count > 0) {
        [users addObjectsFromArray:self.userIds];
    }
    if (users.count > 0) {
        obj[@"users"] = [NSOrderedSet orderedSetWithArray:users].array;
    }
    if (self.tags.count > 0) {
        obj[@"tags"] = self.tagIds;
    }
    return obj.copy;
}

- (void)fetchSelectedGroupMembersCompletion:(dispatch_block_t)completion {
    if (self.groups.count == 0) {
        [self.groupIds removeAllObjects];
        !completion ? : completion();
        return;
    }
    NSString *type = @"supergroupMembersFilterRecent";
    NSMutableArray *userIds = NSMutableArray.array;
    dispatch_group_t group = dispatch_group_create();
    for (ChatInfo *chat in self.groups) {
        dispatch_group_enter(group);
        [TelegramManager.shareInstance getSuperGroupMembers:chat.superGroupId type:type keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            NSArray *members = (NSArray *)obj;
            for (GroupMemberInfo *member in members) {
                [userIds addObject:@(member.user_id)];
            }
            dispatch_group_leave(group);
        } timeout:^(NSDictionary *request) {
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.groupIds = [NSOrderedSet orderedSetWithArray:userIds].array.mutableCopy;
        !completion ? : completion();
    });
}

- (NSArray *)groups {
    if (!_groups) {
        _groups = NSArray.array;
    }
    return _groups;
}

- (NSArray *)users {
    if (!_users) {
        _users = NSArray.array;
    }
    return _users;
}

- (NSMutableArray *)tags {
    if (!_tags) {
        _tags = NSMutableArray.array;
    }
    return _tags;
}

- (NSMutableArray *)groupIds {
    if (!_groupIds) {
        _groupIds = NSMutableArray.array;
    }
    return _groupIds;
}

- (void)setVisibleType:(VisibleType)visibleType {
    _visibleType = visibleType;
    switch (visibleType) {
        case VisibleTypePublic:
            self.atType = @"visibleTypePublic";
            break;
        case VisibleTypePrivate:
            self.atType = @"visibleTypePrivate";
            break;
        case VisibleTypeAllow:
            self.atType = @"visibleTypeAllow";
            break;
        case VisibleTypeNotAllow:
            self.atType = @"visibleTypeNotAllow";
            break;
    }
    [_tags removeAllObjects];
    _users = @[];
    _groups = @[];
}

- (NSString *)visibleTypeTitle {
    switch (_visibleType) {
        case VisibleTypePublic:
            return @"公开".lv_localized;
        case VisibleTypePrivate:
            return @"私密".lv_localized;
        case VisibleTypeAllow:
            return @"部分可见".lv_localized;
        case VisibleTypeNotAllow:
            return @"不给谁看".lv_localized;
    }
}

- (NSString *)visibleTypeSubTitle {
    switch (_visibleType) {
        case VisibleTypePublic:
            return @"所有朋友可见".lv_localized;
        case VisibleTypePrivate:
            return @"仅自己可见".lv_localized;
        case VisibleTypeAllow:
            return @"选中的朋友可见".lv_localized;
        case VisibleTypeNotAllow:
            return @"选中的朋友不可见".lv_localized;
    }
}

+ (NSString *)visibleTypeTitle:(VisibleType)type {
    PublishTimelineVisible *visible = PublishTimelineVisible.new;
    visible.visibleType = type;
    return visible.visibleTypeTitle;
}

+ (NSString *)visibleTypeSubTitle:(VisibleType)type {
    PublishTimelineVisible *visible = PublishTimelineVisible.new;
    visible.visibleType = type;
    return visible.visibleTypeSubTitle;
}

- (NSArray<NSString *> *)groupNames {
    NSMutableArray *names = NSMutableArray.array;
    for (ChatInfo *group in _groups) {
        [names addObject:group.title];
    }
    return names;
}

- (NSArray<NSString *> *)userNames {
    NSMutableArray *names = NSMutableArray.array;
    for (UserInfo *user in _users) {
        [names addObject:user.displayName];
    }
    return names;
}

- (NSArray *)userIds {
    NSMutableArray *ids = NSMutableArray.array;
    for (UserInfo *user in _users) {
        [ids addObject:@(user._id)];
    }
    return ids;
}

- (NSArray<NSNumber *> *)tagIds {
    NSMutableArray *ids = NSMutableArray.array;
    for (BlogUserGroup *group in _tags) {
        [ids addObject:@(group.ids)];
    }
    return ids;
}

@end


@implementation PublishTimelineContent

- (NSDictionary *)jsonObject {
    NSMutableDictionary *obj = @{@"@type": self.atType}.mutableCopy;
    if (self.photos.count > 0) {
        NSMutableArray *photos = NSMutableArray.array;
        for (PublishTimelineContentPhoto *photo in self.photos) {
            [photos addObject:photo.jsonObject];
        }
        obj[@"photos"] = photos;
    }
    if (_video.isValid) {
        obj[@"video"] = _video.jsonObject;
    }
    return obj.copy;
}

- (NSString *)atType {
    if (self.photos.count > 0) {
        return @"inputBlogContentPhoto";
    }
    return @"inputBlogContentVideo";
}

- (NSArray<PublishTimelineContentPhoto *> *)photos {
    if (self.images.count == 0) {
        return 0;
    }
    NSMutableArray *photos = NSMutableArray.array;
    for (UIImage *image in self.images) {
        PublishTimelineContentPhoto *photo = PublishTimelineContentPhoto.new;
        NSString *path = [self localPhotoPath:image];
        PublishTimelineContentFile *file = PublishTimelineContentFile.new;
        file.path = path;
        photo.file = file;
        photo.width = image.size.width;
        photo.height = image.size.height;
        [photos addObject:photo];
    }
    return photos.mutableCopy;
}
- (NSString *)localPhotoPath:(UIImage *)image
{
    NSString *localPath = [NSString stringWithFormat:@"%@/%@.jpg", UserImagePath([UserInfo shareInstance]._id), [Common generateGuid]];
    return [self writeFile2LocalFile:[self imageData:image] path:localPath];
}
- (NSData *)imageData:(UIImage *)image
{
    @autoreleasepool
    {
        NSData *tmpImageData = UIImageJPEGRepresentation(image, 0.8);
        return tmpImageData;
    }
}

- (NSString *)writeFile2LocalFile:(NSData *)data path:(NSString *)imagePath
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage createFileAtPath:imagePath contents:data attributes:nil])
    {
        return imagePath;
    }
    return nil;
}

- (NSMutableArray<UIImage *> *)images {
    if (!_images) {
        _images = NSMutableArray.array;
    }
    return _images;
}

- (PublishTimelineContentVideo *)video {
    if (!_video) {
        _video = [PublishTimelineContentVideo new];
    }
    return _video;;
}

@end


@implementation PublishTimelineContentVideo

- (NSString *)atType {
    return @"inputBlogVideo";
}

- (NSDictionary *)jsonObject {
    return @{
        @"@type": self.atType,
        @"file": self.file.jsonObject,
        @"width": @(self.width),
        @"height": @(self.height),
        @"duration": @(self.duration),
        @"thumbnail": @{
            @"@type": @"inputThumbnail",
            @"thumbnail": self.thumbnailFile.jsonObject,
            @"width": @(self.width),
            @"height": @(self.height),
        }
    };
}

- (BOOL)isValid {
    return _thumbnailImage != nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.width = thumbnailImage.size.width;
    self.height = thumbnailImage.size.height;
}

- (void)setOutputPath:(NSString *)outputPath {
    _outputPath = outputPath;
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:outputPath]];
    CMTime time = [asset duration];
    self.duration = floor(time.value/time.timescale);
    self.file = PublishTimelineContentFile.new;
    self.file.path = outputPath;
}

- (PublishTimelineContentFile *)thumbnailFile {
    if (!_thumbnailFile) {
        _thumbnailFile = PublishTimelineContentFile.new;
        _thumbnailFile.path = [MNChatViewController localPhotoPath:_thumbnailImage];
    }
    return _thumbnailFile;
}

@end


@implementation PublishTimelineContentPhoto

- (NSString *)atType {
    return @"inputBlogPhoto";
}

- (NSDictionary *)jsonObject {
    return @{
        @"@type": self.atType,
        @"width": @(self.width),
        @"height": @(self.height),
        @"file": self.file.jsonObject
    };
}

@end

@implementation PublishTimelineContentFile

- (NSString *)atType {
    return @"inputFileLocal";
}

- (NSDictionary *)jsonObject {
    return @{@"@type": self.atType, @"path": self.path};
}

@end

@implementation PublishTimelineLocation

- (PublishTimelineLocationInfo *)location {
    if (!_location) {
        _location = PublishTimelineLocationInfo.new;
    }
    return _location;
}

- (NSString *)atType {
    return @"BlogLocation";
}

- (NSDictionary *)jsonObject {
    if (!_address) {
        return @{};
    }
    return @{@"@type": self.atType, @"location": self.location.jsonObject, @"address": self.address};
}

@end


@implementation PublishTimelineLocationInfo

- (NSDictionary *)jsonObject {
    return @{@"latitude": [NSNumber numberWithFloat:self.latitude], @"longitude": [NSNumber numberWithFloat:self.longitude]};
}

@end

@implementation PublishTimelineEntities

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"entities": PublishTimelineEntity.class};
}

- (NSString *)atType {
    return @"textEntities";
}

- (void)removeEntityWithRange:(NSRange)range {
    for (PublishTimelineEntity *e in self.entities.reverseObjectEnumerator) {
        if (e.offset == range.location && e.length == range.length) {
            [self.entities removeObject:e];
            return;
        }
    }
}

- (void)replaceRange:(NSRange)oRange withNewRange:(NSRange)nRange {
    for (PublishTimelineEntity *e in self.entities) {
        if (e.offset == oRange.location && e.length == oRange.length) {
            e.offset = nRange.location;
            e.length = nRange.length;
        }
    }
}

- (void)addAtUser:(long)userid range:(NSRange)range {
    PublishTimelineEntityType *type = [[PublishTimelineEntityType alloc] initWithUserid:userid];
    PublishTimelineEntity *entity = [[PublishTimelineEntity alloc] initWithOffset:range.location length:range.length type:type];
    [self.entities addObject:entity];
}

- (void)addTopic:(NSString *)topic range:(NSRange)range {
    PublishTimelineEntityType *type = [[PublishTimelineEntityType alloc] initWithText:topic];
    PublishTimelineEntity *entity = [[PublishTimelineEntity alloc] initWithOffset:range.location length:range.length type:type];
    [self.entities addObject:entity];
}

- (NSArray<PublishTimelineEntity *> *)topicEntities {
    NSMutableArray *topics = NSMutableArray.array;
    [_entities enumerateObjectsUsingBlock:^(PublishTimelineEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isTopic) {
            [topics addObject:obj];
        }
    }];
    return topics;
}

- (NSMutableArray<PublishTimelineEntity *> *)entities {
    if (!_entities) {
        _entities = NSMutableArray.array;
    }
    return _entities;
}

- (NSDictionary *)jsonObject {
    if (self.entities.count == 0) {
        return @{};
    }
    NSMutableArray *entities = NSMutableArray.array;
    for (PublishTimelineEntity *entity in self.entities) {
        [entities addObject:entity.jsonObject];
    }
    return @{
        @"@type": self.atType,
        @"entities": entities
    };
}

@end

@implementation PublishTimelineEntity

- (instancetype)initWithOffset:(NSInteger)offset length:(NSInteger)length type:(PublishTimelineEntityType *)type {
    if (self = [super init]) {
        self.offset = offset;
        self.length = length;
        self.type = type;
    }
    return self;
}

- (NSString *)atType {
    return @"textEntity";
}

- (NSDictionary *)jsonObject {
    return @{
        @"@type": self.atType,
        @"offset": @(self.offset),
        @"length": @(self.length),
        @"type": self.type.jsonObject
    };
}

- (BOOL)isTopic {
    return _type.text.length > 0;
}

@end

@implementation PublishTimelineEntityType

- (NSDictionary *)jsonObject {
    if (_user_id > 0) {
        return @{@"@type": self.atType, @"user_id": @(_user_id)};
    }
    return @{@"@type": self.atType};
}

- (instancetype)initWithText:(NSString *)text {
    if (self = [super init]) {
        self.text = text;
        self.atType = @"textEntityTypeHashtag";
    }
    return self;
}

- (instancetype)initWithUserid:(NSInteger)userid {
    if (self = [super init]) {
        self.user_id = userid;
        self.atType = @"textEntityTypeMentionName";
    }
    return self;
}

@end
