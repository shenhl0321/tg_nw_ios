//
//  VideoMessageCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageBubbleCell.h"
@protocol VideoMessageCellDelegate <MessageBubbleCellDelegate>

@optional

/**
 *  点击了视频的代理
 *
 *  @param cell 图片所在cell
 */
- (void)messageCellShouldShowVideo:(MessageViewBaseCell *)cell;

@end

@interface VideoMessageCell : MessageBubbleCell

/**
*  某条消息内容在tableView中展示时所需的cell高度
*
*  @param chatRecordDTO 待展示的消息
*
*  @return 实际需要的高度，默认返回0，
*/
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName;

@property (nonatomic, weak) id <VideoMessageCellDelegate> delegate;

- (void)reloadVideoInfo:(VideoInfo *)video;

- (void)resetVideoThumbnail;

@end


@interface VideoContainer : UIView

@property (nonatomic, strong) VideoInfo *video;

- (void)reloadVideoInfo:(VideoInfo *)video;

- (void)resetVideoThumbnail;

@end

/// 发送进度条
@interface MessageSendProgress : UIView

@property (nonatomic, assign) NSInteger rate;
/// <#code#>
@property (nonatomic, assign) CGFloat fontSize;

- (void)startAnimation;

@end
