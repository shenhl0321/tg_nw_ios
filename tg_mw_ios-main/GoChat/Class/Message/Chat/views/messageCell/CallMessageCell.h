//
//  CallMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2021/03/19.
//

#import <UIKit/UIKit.h>

@protocol CallMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  点击了call的代理
 */
- (void)messageCellShouldCall:(MessageViewBaseCell *)cell;

@end

@interface CallMessageCell : MessageBubbleCell
/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <CallMessageCellDelegate> delegate;
@end
