//
//  MessageBubbleCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "MessageViewBaseCell.h"
#import "YBPopupMenu.h"

@class MessageBubbleCell;

@protocol MessageBubbleCellDelegate <MessageViewBaseCellDelegate>

@optional

- (BOOL)isGroupChat;
- (BOOL)canManageSomeone:(MessageViewBaseCell *)cell;

- (void)messageCellWillBan:(MessageViewBaseCell *)cell;
- (void)messageCellWillDelOneHis:(MessageViewBaseCell *)cell;
- (void)messageCellWillDelAllHis:(MessageViewBaseCell *)cell;
- (void)messageCellWillTransferMessage:(MessageViewBaseCell *)cell;
- (void)messageCellWillTranslateMessage:(MessageViewBaseCell *)cell;

/**
 *  他人的头像被点击的回调
 */
- (void)messageCell:(MessageViewBaseCell *)cell someoneHeadPhotoWasTapped:(long)userId;

/**
 *  我的头像被点击
 */
- (void)messageCellMyHeadPhotoWasTapped:(MessageViewBaseCell *)cell;

/**
 *  长按了某个人的头像，表示@了某人
 */
- (void)messageCell:(MessageViewBaseCell *)cell shouldAtSomeone:(long)userId;

/**
 *  点击了重发
 */
- (void)messageCellWillResend:(MessageViewBaseCell *)cell;

/**
 *  点击了重新下载
 */
- (void)messageCellWillReDownloadFile:(MessageViewBaseCell *)cell;

//发送消息是否已被对方读过了
- (BOOL)messageCell_Outing_Message_IsRead:(MessageViewBaseCell *)cell;

//点击引用  滚动到指定的cell
- (void)quoteMsgClickWithCell:(MessageViewBaseCell *)cell;

@end

@interface ChatMenu : NSObject
+ (instancetype)menuWithTitle:(NSString *)title icon:(NSString *)icon action:(SEL)action;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *icon;
@property(nonatomic) SEL action;
@end

@interface MessageBubbleCell : MessageViewBaseCell

@property (nonatomic, weak) id <MessageBubbleCellDelegate> delegate;

//昵称
@property (nonatomic, strong) IBOutlet UILabel *nickNameLabel;

//头像
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;

//气泡
@property (nonatomic, strong) IBOutlet UIImageView *bubbleImageView;

//时间-即将废弃
@property (nonatomic, strong) IBOutlet UILabel *timeLabel;
//日期
@property (nonatomic, strong) IBOutlet UILabel *dayLabel;

//@property (nonatomic, assign) CGFloat maxCellWidth;

/**
 *  供给子类调用，设置气泡位置，调用前需要先设置其大小，由于许多其他view位置依赖于气泡，所以，由各个子类在设置完气泡大小后，调用该方法设置位置，再各自定制其他view位置。
 */
- (void)adjustBubblePosition;

/**
 *  复制，供子类super
 */
- (void)copyMessage:(id)sender;

@end
