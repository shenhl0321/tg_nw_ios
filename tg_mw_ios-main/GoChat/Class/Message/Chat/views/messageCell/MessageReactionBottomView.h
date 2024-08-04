//
//  MessageReactionBottomView.h
//  GoChat
//
//  Created by Autumn on 2022/3/27.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MessageReactionBottomView : DYView

+ (CGFloat)viewHeight;

@property (nonatomic, strong) NSArray<MessageReactionList *> *reactions;

@end



@interface MessageReactionBottomListCellItem : DYCollectionViewCellItem

@property (nonatomic, assign) NSInteger reactionId;
@property (nonatomic, strong) NSArray *userIds;

@end

@interface MessageReactionBottomListCell : DYCollectionViewCell

@property (nonatomic, strong) UILabel *emojiLabel;
@property (nonatomic, strong) UIView *avatarContainer;

@end


@interface MessageReactionPop : UIViewController

+ (void)showReactions:(NSArray<MessageReactionList *> *)reactions;

@end

NS_ASSUME_NONNULL_END
