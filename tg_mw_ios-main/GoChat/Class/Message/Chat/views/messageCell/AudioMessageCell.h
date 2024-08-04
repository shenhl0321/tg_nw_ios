//
//  AudioMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2020/12/25.
//

#import "MessageBubbleCell.h"

@class AudioMessageCell;

@protocol AudioMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  需要播放语音的代理
 *
 *  @param cell 语音所在cell
 */
- (void)messageCellShouldStartPlayAudio:(MessageViewBaseCell *)cell;

/**
 *  需要停止播放语音的代理
 *
 *  @param cell 语音所在cell
 */
- (void)messageCellShouldStopPlayAudio:(MessageViewBaseCell *)cell;

@end


@interface AudioMessageCell : MessageBubbleCell
/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <AudioMessageCellDelegate> delegate;

- (void)startActivityAnimating:(BOOL)start;
@end
