//
//  RedPacketMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageBubbleCell.h"
@protocol RedPacketMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  点击了红包的代理
 *
 *  @param cell 红包所在cell
 */
- (void)messageCellShouldOpenRedPacket:(MessageViewBaseCell *)cell;

@end

@interface RedPacketMessageCell : MessageBubbleCell

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <RedPacketMessageCellDelegate> delegate;

@end
