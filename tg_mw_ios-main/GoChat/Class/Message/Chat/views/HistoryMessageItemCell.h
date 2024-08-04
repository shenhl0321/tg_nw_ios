//
//  HistoryMessageItemCell.h
//  GoChat
//
//  Created by wangyutao on 2020/11/3.
//

#import <UIKit/UIKit.h>

@interface HistoryMessageItemCell : SWTableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *badgeWidth;
@property (nonatomic, weak) IBOutlet UILabel *badgeLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ayIndicatorRightMargin;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *ayIndicatorView;
@property (nonatomic, weak) IBOutlet UIImageView *failImageView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *muteImageRightMargin;
@property (nonatomic, weak) IBOutlet UIImageView *muteImageView;

//已读标志
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *readImageRightMargin;
@property (nonatomic, weak) IBOutlet UIImageView *readImageView;

- (void)resetChatInfo:(ChatInfo *)info;
- (void)resetMessageInfo:(MessageInfo *)info;
@end
