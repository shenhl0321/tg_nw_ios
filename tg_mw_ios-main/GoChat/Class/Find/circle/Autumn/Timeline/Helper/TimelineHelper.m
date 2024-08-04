//
//  TimelineHelper.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "TimelineHelper.h"
#import "PhotoAVideoPreviewPagesViewController.h"
#import "PhotoAVideoPreviewPagesViewController+Timeline.h"
#import "VideoThumbnailManager.h"

@interface TimelineHelper ()

@property (nonatomic, strong) NSMutableArray<BlogUserDate *> *follows;
@property (nonatomic, strong) NSArray<NSNumber *> *followIds;

@property (nonatomic, strong) NSMutableArray *blockedIds;

@end

static NSString *const BlockedBlogIdsKey = @"BlockedBlogIdsKey";

@implementation TimelineHelper


+ (TimelineHelper *)helper {
    static TimelineHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[TimelineHelper alloc] init];
    });
    return helper;
}

- (instancetype)init {
    if ([super init]) {
        [TimelineHelper queryFollows:^{}];
    }
    return self;
}

- (void)blockedBlog:(NSInteger)blogId {
    [self.blockedIds addObject:@(blogId)];
    NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
    [ud setObject:self.blockedIds forKey:BlockedBlogIdsKey];
    [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Blocked_Change) withInParam:@(blogId)];
}

#pragma mark - getter

- (NSMutableArray *)blockedIds {
    if (!_blockedIds) {
        NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
        NSArray *ids = [ud objectForKey:BlockedBlogIdsKey];
        if (ids.count > 0) {
            _blockedIds = ids.mutableCopy;
        } else {
            _blockedIds = NSMutableArray.array;
        }
    }
    return _blockedIds;
}

- (NSArray<NSNumber *> *)followIds {
    NSMutableArray *ids = NSMutableArray.array;
    [self.follows enumerateObjectsUsingBlock:^(BlogUserDate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:@(obj.user_id)];
    }];
    return ids;
}

- (NSArray<NSNumber *> *)blocks {
    return self.blockedIds;
}

- (void)setFollows:(NSMutableArray<BlogUserDate *> *)follows {
    _follows = follows;
    NSMutableArray *ids = NSMutableArray.array;
    [self.follows enumerateObjectsUsingBlock:^(BlogUserDate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:@(obj.user_id)];
    }];
    self.followIds = ids;
}

@end


@implementation TimelineHelper (ClassMethod)

+ (void)queryUnreadCountCompletion:(UnreadCountCompletion)completion {
    [TelegramManager.shareInstance jw_request:@{@"@type": @"getUnreadCount"} result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"unreadCount"]) {
            !completion ? : completion(0);
            return;
        }
        NSInteger count = [response[@"count"] integerValue];
        count = MIN(MAX(0, count), 99);
        !completion ? : completion(count);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(0);
    }];
}

/**
 /// 获取用户的列表
 {"visible":{"@type":"visibleTypeUser","user_id":136817700},"offset":0,"@type":"getHistory","from_blog_id":0,"limit":20,"@extra":5514}
 */

+ (void)queryTimelineList:(TimelineType)type offset:(int)offset completion:(TimelineListBlock)completion {
    [self queryTimelineList:type offset:offset topic:@"" completion:completion];
}

+ (void)queryTimelineList:(TimelineType)type offset:(int)offset topic:(NSString *)topic completion:(TimelineListBlock)completion {
    NSDictionary *visible = [self visibleOfTimelineType:type topic:topic];
    [TelegramManager.shareInstance queryTimelineWithVisible:visible offset:offset result:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (!obj) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray<BlogInfo *> *blogs = [BlogInfo mj_objectArrayWithKeyValuesArray:obj];
        !completion ? : completion(blogs);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)queryTimelineInfo:(NSInteger)blogId completion:(TimelineListBlock)completion {
    NSDictionary *params = @{@"@type": @"getBlogs", @"blog_ids": @[@(blogId)]};
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"blogs"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[type];
        NSArray *blogs = [BlogInfo mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(blogs);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)querySendingBlog:(TimelineListBlock)completion {
    NSDictionary *params = @{@"@type": @"getSendingBlogs"};
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"blogs"]) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray *lists = response[type];
        NSArray *blogs = [BlogInfo mj_objectArrayWithKeyValuesArray:lists];
        !completion ? : completion(blogs);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)resendBlog:(NSInteger)blogId completion:(BOOLCompletion)completion {
    NSDictionary *params = @{@"@type": @"resendBlog", @"blog_id": @(blogId)};
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        NSString *type = response[@"@type"];
        if (![type isEqualToString:@"ok"]) {
            !completion ? : completion(NO);
            return;
        }
        !completion ? : completion(YES);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

+ (void)queryBlogReplys:(NSInteger)blogId offset:(NSInteger)offset completion:(ReplyListCompletion)completion {
    NSDictionary *params = @{
        @"id": @{@"@type": @"inputBlogIdBlog", @"blog_id": @(blogId)},
        @"offset": @(offset),
        @"limit": @20,
        @"@type": @"getBlogReplys"
    };
    [TelegramManager.shareInstance timelineRepay:params result:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (!obj) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray <BlogReply *>*replys = [BlogReply mj_objectArrayWithKeyValuesArray:obj];
        !completion ? : completion(replys);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)querySubReplys:(NSInteger)replyId completion:(ReplyListCompletion)completion {
    NSDictionary *params = @{
        @"id": @{@"@type": @"inputBlogIdReply", @"reply_id": @(replyId)},
        @"offset": @0,
        @"limit": @9999,
        @"@type": @"getBlogReplys"
    };
    [TelegramManager.shareInstance timelineRepay:params result:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (!obj) {
            !completion ? : completion(@[]);
            return;
        }
        NSArray <BlogReply *>*replys = [BlogReply mj_objectArrayWithKeyValuesArray:obj];
        !completion ? : completion(replys);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(@[]);
    }];
}

+ (void)queryFollows:(dispatch_block_t)completion {
    NSDictionary *params = @{
        @"user_id": @(UserInfo.shareInstance._id),
        @"offset": @0,
        @"limit": @1000,
        @"@type": @"getBlogFollows"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        if (![response[@"@type"] isEqualToString:@"blogUserDates"]) {
            !completion ? : completion();
            return;
        }
        NSArray *datas = response[@"user_dates"];
        TimelineHelper.helper.follows = [BlogUserDate mj_objectArrayWithKeyValuesArray:datas];
        !completion ? : completion();
    } timeout:^(NSDictionary *request) {
        !completion ? : completion();
    }];
}

/// 点赞/取消点赞 动态
+ (void)likeBlog:(NSInteger)blogId isLike:(BOOL)isLike completion:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"id": @{@"@type": @"inputBlogIdBlog", @"blog_id": @(blogId)},
        @"liked": @(isLike),
        @"@type": @"likeBlog"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
        if (isSuccess) {
            NSString *desc = isLike ? @"点赞成功".lv_localized : @"取消点赞".lv_localized;
            [UserInfo showTips:nil des:desc];
            [BusinessFramework.defaultBusinessFramework
             broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Info_Liked_Change)
             withInParam:@[@(blogId), @(isLike)]];
        }
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

/// 点赞/取消点赞 评论
+ (void)likeReply:(NSInteger)replyId isLike:(BOOL)isLike completion:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"id": @{@"@type": @"inputBlogIdReply", @"reply_id": @(replyId)},
        @"liked": @(isLike),
        @"@type": @"likeBlog"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
        if (isSuccess) {
            NSString *desc = isLike ? @"点赞成功".lv_localized : @"取消点赞".lv_localized;
            [UserInfo showTips:nil des:desc];
            [BusinessFramework.defaultBusinessFramework
             broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Reply_Liked_Change)
             withInParam:@[@(replyId), @(isLike)]];
        }
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

/// 评论动态
+ (void)commentBlog:(NSInteger)blogId text:(NSString *)text completion:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"id": @{@"@type": @"inputBlogIdBlog", @"blog_id": @(blogId)},
        @"text": text,
        @"@type": @"commentBlog"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

/// 回复评论
+ (void)commentReply:(NSInteger)replyId text:(NSString *)text completion:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"id": @{@"@type": @"inputBlogIdReply", @"reply_id": @(replyId)},
        @"text": text,
        @"@type": @"commentBlog"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

+ (void)deleteBlog:(NSInteger)blogId completion:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"blog_ids": @[@(blogId)],
        @"@type": @"deleteBlog"
    };
    [UserInfo show];
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
        if (isSuccess) {
            [BusinessFramework.defaultBusinessFramework broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Delete_Change) withInParam:@(blogId)];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        !completion ? : completion(NO);
    }];
}

/// 关注用户
+ (void)followBlogUser:(NSInteger)userId isFollow:(BOOL)isFollow completions:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"user_id": @(userId),
        @"followed": @(isFollow),
        @"@type": @"followBlog"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        BOOL isSuccess = [response[@"@type"] isEqualToString:@"ok"];
        !completion ? : completion(isSuccess);
        [self queryFollows:^{
            [BusinessFramework.defaultBusinessFramework
             broadcastBusinessNotify:MakeID(EUserManager, EUser_Timeline_Follows_Change)
             withInParam:nil];
        }];
        if (isSuccess) {
            NSString *desc = isFollow ? @"关注成功".lv_localized : @"取消关注".lv_localized;
            [UserInfo showTips:nil des:desc];
        }
    } timeout:^(NSDictionary *request) {
        !completion ? : completion(NO);
    }];
}

+ (void)rewardBlog:(NSInteger)blogId userId:(NSInteger)userId amout:(CGFloat)amout completion:(BOOLCompletion)completion {
    NSDictionary *params = @{
        @"user_id": @(userId),
        @"blog_id": @(blogId),
        @"amout": @(amout),
        @"password": @"1234561",
        @"@type": @"blogsReward"
    };
    [TelegramManager.shareInstance jw_request:params result:^(NSDictionary *request, NSDictionary *response) {
        NSLog(@"%@", response);
    } timeout:^(NSDictionary *request) {
        
    }];
}

+ (NSString *)stringOfFriendCycelType:(TimelineType)type {
    switch (type) {
        case TimelineType_Hot:
            return @"visibleTypePublic";
        case TimelineType_Follow:
            return @"visibleTypeFollow";
        case TimelineType_Friend:
            return @"visibleTypeFriend";
        case TimelineType_Topic_Hot:
        case TimelineType_Topic_Recommend:
        case TimelineType_Topic_Recently:
            return @"visibleTypeTopic";
    }
}

+ (NSDictionary *)visibleOfTimelineType:(TimelineType)type topic:(NSString *)topic {
    NSString *t;
    int tab = 0;
    switch (type) {
        case TimelineType_Hot:
            t = @"visibleTypePublic";
            break;
        case TimelineType_Follow:
            t = @"visibleTypeFollow";
            break;
        case TimelineType_Friend:
            t = @"visibleTypeFriend";
            break;
        case TimelineType_Topic_Recommend:
            t = @"visibleTypeTopic";
            tab = 1;
            break;
        case TimelineType_Topic_Recently:
            t = @"visibleTypeTopic";
            tab = 2;
            break;
        case TimelineType_Topic_Hot:
            t = @"visibleTypeTopic";
            tab = 3;
            break;
    }
    if (tab > 0) {
        return @{@"@type": t, @"tab": @(tab), @"topic": topic};
    }
    return @{@"@type": t};
}

@end


@implementation TimelineHelper (ZFPlayer)

+ (ZFPlayerController *)playerWithScrollView:(UIScrollView *)scrollView controlView:(UIView<ZFPlayerMediaControl> *)controlView {
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    playerManager.scalingMode = ZFPlayerScalingModeAspectFit;
    ZFPlayerController *player = [ZFPlayerController playerWithScrollView:scrollView playerManager:playerManager containerViewTag:self.containerTag];
    player.controlView = controlView;
    player.playerDisapperaPercent = 0;
    player.playerApperaPercent = 1;
    player.WWANAutoPlay = YES;
    player.resumePlayRecord = YES;
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan;
    player.orientationObserver.fullScreenMode = ZFFullScreenModePortrait;
    player.orientationObserver.fullScreenStatusBarHidden = YES;
    player.orientationObserver.fullScreenStatusBarAnimation = UIStatusBarAnimationNone;

    /// 全屏的填充模式（全屏填充、按视频大小填充）
    player.orientationObserver.portraitFullScreenMode = ZFPortraitFullScreenModeScaleAspectFit;
    /// 禁用竖屏全屏的手势（点击、拖动手势）
    player.orientationObserver.disablePortraitGestureTypes = ZFDisablePortraitGestureTypesNone;

    @weakify(player)
    player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(player)
        [player.currentPlayerManager replay];
    };
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        @strongify(player)
        if (loadState == ZFPlayerLoadStatePrepare) {
            ZFPlayerControlView *controlView = (ZFPlayerControlView *)player.controlView;
            controlView.effectView.hidden = YES;
        }
    };
    return player;
}

+ (ZFPlayerControlView *)controlView {
    ZFPlayerControlView *controlView = [ZFPlayerControlView new];
    controlView.prepareShowLoading = YES;
    controlView.effectViewShow = YES;
    controlView.bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    controlView.bgImgView.clipsToBounds = YES;
    return controlView;
}

+ (NSInteger)containerTag {
    return 99999;
}

@end


@implementation TimelineHelper (PreviewMedia)

+ (void)previewVideo:(BlogInfo *)blog {
    
    MessageInfo *message = [[MessageInfo alloc] init];
    message.messageType = MessageType_Video;
    message.content = [[MessageContent alloc] init];
    message.content.video = blog.content.video;
    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
    v.previewList = @[message];
    v.curIndex = 0;
    v.fromTimeline = YES;
    [UIViewController.xhq_currentController.navigationController pushViewController:v animated:YES];
}

+ (void)previewPhotos:(BlogInfo *)blog currentIndex:(NSInteger)index {
    NSMutableArray *messages = NSMutableArray.array;
    for (PhotoInfo *photo in blog.content.photos) {
        MessageInfo *message = [[MessageInfo alloc] init];
        message.messageType = MessageType_Photo;
        message.content = [[MessageContent alloc] init];
        message.content.photo = photo;
        [messages addObject:message];
    }
    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
    v.previewList = messages;
    v.curIndex = (int)index;
    v.fromTimeline = YES;
    [UIViewController.xhq_currentController.navigationController pushViewController:v animated:YES];
}

@end
