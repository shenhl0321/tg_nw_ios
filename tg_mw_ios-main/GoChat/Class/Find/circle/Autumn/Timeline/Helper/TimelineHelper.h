//
//  TimelineHelper.h
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import <Foundation/Foundation.h>
#import "BlogInfo.h"
#import "BlogReply.h"

#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TimelineType) {
    TimelineType_Hot,
    TimelineType_Follow,
    TimelineType_Friend,
    
    TimelineType_Topic_Recommend,
    TimelineType_Topic_Recently,
    TimelineType_Topic_Hot,
};

typedef NS_ENUM(NSUInteger, RepayListDisplayMode) {
    /// 没有子回复
    RepayListDisplayMode_None = 0,
    /// 展开x条回复
    RepayListDisplayMode_All,
    /// 展开更多回复
    RepayListDisplayMode_More,
    /// 收起回复
    RepayListDisplayMode_Close,
};

typedef void(^TimelineListBlock)(NSArray <BlogInfo *>*blogs);

typedef void(^ReplyListCompletion)(NSArray<BlogReply *> *replys);

typedef void(^BOOLCompletion)(BOOL success);

typedef void(^UnreadCountCompletion)(NSInteger count);

@interface TimelineHelper : NSObject

+ (TimelineHelper *)helper;

@property (nonatomic, strong, readonly) NSArray<NSNumber *> *followIds;

@end

@interface TimelineHelper (ClassMethod)

+ (void)queryUnreadCountCompletion:(UnreadCountCompletion)completion;

/// 获取朋友圈列表
+ (void)queryTimelineList:(TimelineType)type offset:(int)offset completion:(TimelineListBlock)completion;

+ (void)queryTimelineList:(TimelineType)type offset:(int)offset topic:(NSString *)topic completion:(TimelineListBlock)completion;

/// 获取动态详情
+ (void)queryTimelineInfo:(NSInteger)blogId completion:(TimelineListBlock)completion;

/// 获取正在发布的动态
+ (void)querySendingBlog:(TimelineListBlock)completion;

/// 重新发布动态
+ (void)resendBlog:(NSInteger)blogId completion:(BOOLCompletion)completion;

/// 获取动态评论列表
+ (void)queryBlogReplys:(NSInteger)blogId offset:(NSInteger)offset completion:(ReplyListCompletion)completion;
/// 获取评论子评论列表
+ (void)querySubReplys:(NSInteger)replyId completion:(ReplyListCompletion)completion;

/// 点赞/取消点赞 动态
+ (void)likeBlog:(NSInteger)blogId isLike:(BOOL)isLike completion:(BOOLCompletion)completion;
/// 点赞/取消点赞 评论
+ (void)likeReply:(NSInteger)replyId isLike:(BOOL)isLike completion:(BOOLCompletion)completion;

+ (void)queryFollows:(dispatch_block_t)completion;

/// 评论动态
+ (void)commentBlog:(NSInteger)blogId text:(NSString *)text completion:(BOOLCompletion)completion;
/// 回复评论
+ (void)commentReply:(NSInteger)replyId text:(NSString *)text completion:(BOOLCompletion)completion;

/// 删除动态
+ (void)deleteBlog:(NSInteger)blogId completion:(BOOLCompletion)completion;

/// 关注用户
+ (void)followBlogUser:(NSInteger)userId isFollow:(BOOL)isFollow completions:(BOOLCompletion)completion;

/// 打赏动态
+ (void)rewardBlog:(NSInteger)blogId userId:(NSInteger)userId amout:(CGFloat)amout completion:(BOOLCompletion)completion;

@end


@interface TimelineHelper (ZFPlayer)

+ (ZFPlayerController *)playerWithScrollView:(UIScrollView *)scrollView controlView:(UIView<ZFPlayerMediaControl> *)controlView;

+ (ZFPlayerControlView *)controlView;

+ (NSInteger)containerTag;

@end


@interface TimelineHelper (PreviewMedia)

+ (void)previewVideo:(BlogInfo *)blog;

+ (void)previewPhotos:(BlogInfo *)blog currentIndex:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
