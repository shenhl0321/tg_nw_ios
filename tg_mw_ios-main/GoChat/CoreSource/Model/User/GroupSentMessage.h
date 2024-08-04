//
//  GroupSentMessage.h
//  GoChat
//
//  Created by Autumn on 2022/2/22.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GroupSentChatIdsCompletion)(NSArray<NSNumber *> *chatIds);

typedef void(^GroupSentForwardingChatIdsCompletion)(NSNumber *firstChatId, NSArray<NSNumber *> *fChatIds);

typedef NS_ENUM(NSUInteger, GroupSentMsgType) {
    GroupSentMsgType_Text = 0,
    GroupSentMsgType_Voice,
    GroupSentMsgType_Photo,
    GroupSentMsgType_Gif,
    GroupSentMsgType_Video,
};

@interface GroupSentMessage : JWModel

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSArray<NSNumber *> *users;
@property (nonatomic, copy) NSString *usernames;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) GroupSentMsgType type;

/// 时长（语音、视频）
@property (nonatomic, assign) int duration;

/// 媒体本地路径
- (NSString *)mediaPath;

/// 获取全部会话id数组
- (void)fetchChatIds:(GroupSentChatIdsCompletion)completion;

/// 获取第一个会话id，和后续的转发id数组
- (void)fetchForwadingChatIds:(GroupSentForwardingChatIdsCompletion)completion;

@end

NS_ASSUME_NONNULL_END
