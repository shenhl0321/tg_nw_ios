//
//  MNMsgCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/29.
//

#import "BaseTableCell.h"

@class MNMsgCell;
@protocol MNMsgCellDelegate <NSObject>

- (void)msgCell:(MNMsgCell *)cell topBtn:(UIButton *)topBtn;
- (void)msgCell:(MNMsgCell *)cell notiBtn:(UIButton *)notiBtn;
- (void)msgCell:(MNMsgCell *)cell archiveBtn:(UIButton *)archiveBtn;
- (void)msgCell:(MNMsgCell *)cell deleteBtn:(UIButton *)deleteBtn;



@end

@interface MNMsgCell : BaseTableCell
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic,  strong) UILabel *titleLabel;
@property (nonatomic,  strong) UILabel *timeLabel;
@property (nonatomic,  strong) UILabel *contentLabel;

//@property (nonatomic,  strong) NSLayoutConstraint *badgeWidth;
@property (nonatomic,  strong) UILabel *badgeLabel;

//@property (nonatomic,  strong) NSLayoutConstraint *ayIndicatorRightMargin;
@property (nonatomic,  strong) UILabel *ayIndicatorView;//名字就先这样吧。。为了不动原来的代码
@property (nonatomic,  strong) UILabel *failImageView;//名字就先这样吧。为了不动原来的业务

//@property (nonatomic,  strong) NSLayoutConstraint *muteImageRightMargin;
@property (nonatomic,  strong) UIImageView *muteImageView;

//已读标志
//@property (nonatomic,  strong) NSLayoutConstraint *readImageRightMargin;
@property (nonatomic,  strong) UIImageView *readImageView;
/// 私密聊天的图标
@property (nonatomic,strong) UIImageView *secretIcon;

- (void)resetChatInfo:(ChatInfo *)info;
- (void)resetMessageInfo:(MessageInfo *)info;

@property (nonatomic, strong) MGSwipeButton *deleteBtn;
@property (nonatomic, strong) MGSwipeButton *archiveBtn;
@property (nonatomic, strong) MGSwipeButton *topBtn;
@property (nonatomic, strong) MGSwipeButton *notiBtn;
@property (nonatomic, weak) id<MNMsgCellDelegate>delegate;
//- (void)addRightSwipeCallback:(MGSwipeButtonCallback)callback;
@end


