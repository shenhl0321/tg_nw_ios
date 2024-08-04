//
//  TextMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageBubbleCell.h"
#import "CoreTextView.h"
@protocol TextMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  选择了某个特殊的文本
 */
- (void)messageCell:(MessageViewBaseCell *)cell didSelectedTextUnit:(TextUnit *)textUnit;

/**
 *  全屏显示文本代理
 */
- (void)messageCellShouldFullScreen:(MessageViewBaseCell *)cell;

@end

@interface TextMessageCell : MessageBubbleCell

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, strong) CoreTextView *coreTextView;

@property (nonatomic, weak) id <TextMessageCellDelegate> delegate;

- (void)startActivityAnimating:(BOOL)start;

@end
