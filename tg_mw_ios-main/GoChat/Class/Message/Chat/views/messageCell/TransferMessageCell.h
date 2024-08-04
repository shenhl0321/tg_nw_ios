//
//  TransferMessageCell.h
//  GoChat
//
//  Created by Autumn on 2022/1/24.
//

#import "MessageBubbleCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TransferMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  点击了红包的代理
 *
 *  @param cell 红包所在cell
 */
- (void)messageCellShouldShowTransferInfo:(MessageViewBaseCell *)cell;

@end

@interface TransferMessageCell : MessageBubbleCell

@property (nonatomic, weak) id <TransferMessageCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
