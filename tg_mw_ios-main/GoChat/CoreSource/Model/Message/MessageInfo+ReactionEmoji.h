//
//  MessageInfo+ReactionEmoji.h
//  GoChat
//
//  Created by Autumn on 2022/3/26.
//

#import "MessageInfo.h"


NS_ASSUME_NONNULL_BEGIN

@interface MessageReactionList : DYModel

@property (nonatomic, assign) NSInteger reactionId;
@property (nonatomic, assign) NSInteger userId;

@end

@interface MessageReaction : DYModel

@property (nonatomic, assign) NSInteger chatId;
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, strong) NSArray *reactionList;
@property (nonatomic, assign) NSInteger type;

@end


/// 消息表情回复
@interface MessageInfo (ReactionEmoji)

/// 消息长按是否显示表情回复功能
- (BOOL)canShowLongPressReactionEmojiView;

@property (nonatomic, strong) NSMutableArray *reactions;
/// 群组消息显示表情回复底部view
- (BOOL)isShowGroupReactionView;

/// 本地更新表情回应
/// 一个用户只能有一个表情回应，先检测数据源里是否有相同的userid，
/// 有的话先删除，然后再添加
/// 根据 reactionId 为 0 做删除处理
- (void)updateRecation:(MessageReactionList *)list;

/// 表情回复数据请求
- (void)reactionWithEmoji:(NSString *)emoji;
/// 获取消息的表情回复数据
- (void)getReactions;

@end


#pragma mark - 表情回复参数
static inline NSArray *ReactionEmojis() {
    return @[@"👍", @"👎", @"❤️", @"👏"];
}

static inline NSArray *ReactionEmojiIds() {
    return @[@1, @2, @3, @4];
}

static inline NSString *ReactionEmojiForId(NSNumber *ids) {
    NSInteger index = [ReactionEmojiIds() indexOfObject:ids];
    return ReactionEmojis()[index];
}

static inline NSNumber *ReactionIdForEmoji(NSString *emoji) {
    NSInteger index = [ReactionEmojis() indexOfObject:emoji];
    return ReactionEmojiIds()[index];
}

NS_ASSUME_NONNULL_END
