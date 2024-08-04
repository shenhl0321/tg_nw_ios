//
//  PersonalCardCell.h
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import "MessageBubbleCell.h"

@protocol PersonalCardCellDelegate <MessageBubbleCellDelegate>

@optional

- (void)personalCard:(MessageInfo *)chatRecordDTO;

@end

@interface PersonalCardCell : MessageBubbleCell

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <PersonalCardCellDelegate> delegate;

@end
