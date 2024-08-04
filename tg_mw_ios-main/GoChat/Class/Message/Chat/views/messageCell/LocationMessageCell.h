//
//  LocationMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageBubbleCell.h"
@protocol LocationMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  点击了位置的代理
 *
 *  @param cell 位置所在cell
 */
- (void)messageCellShouldShowLocation:(MessageViewBaseCell *)cell;

@end

@interface LocationMessageCell : MessageBubbleCell

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <LocationMessageCellDelegate> delegate;

@end
