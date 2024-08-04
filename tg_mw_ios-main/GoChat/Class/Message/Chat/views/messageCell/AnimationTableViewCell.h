//
//  VideoMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageBubbleCell.h"
@protocol AnimationMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  点击了视频的代理
 *
 *  @param cell 图片所在cell
 */
- (void)messageCellShouldShowAnimation:(MessageViewBaseCell *)cell;

/**
 *  添加表情
 *
 *  @param cell 图片所在cell
 */
- (void)messageCellAddEmoji:(MessageViewBaseCell *)cell;

@end

@interface AnimationTableViewCell : MessageBubbleCell

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <AnimationMessageCellDelegate> delegate;

@end
