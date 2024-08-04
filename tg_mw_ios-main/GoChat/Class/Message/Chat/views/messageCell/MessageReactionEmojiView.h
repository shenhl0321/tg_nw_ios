//
//  MessageReactionEmojiView.h
//  GoChat
//
//  Created by Autumn on 2022/3/25.
//

#import "DYView.h"
#import "MessageInfo+ReactionEmoji.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageReactionEmojiView : DYView

- (instancetype)initWithMessage:(MessageInfo *)message;

@property (nonatomic, copy) dispatch_block_t selectedBlock;

@end



@interface MessageReactionEmojiCell : DYCollectionViewCell

@property (nonatomic, strong) UILabel *emojiLabel;

@end

NS_ASSUME_NONNULL_END
