//
//  MNGroupHelpCell.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/14.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@class GroupSentMessage;
@interface MNGroupHelpCell : BaseTableCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *displayLabel;
@property (nonatomic, strong) UIButton *reSendBtn;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *GifLabel;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIImageView *voiceImageView;
@property (nonatomic, strong) UIView *voiceContainer;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) GroupSentMessage *msg;

@property (nonatomic, copy) dispatch_block_t resendBlock;

@property (nonatomic, copy) dispatch_block_t voiceBlock;

@property (nonatomic, copy) dispatch_block_t videoBlock;

@property (nonatomic, copy) dispatch_block_t photoBlock;

- (void)voiceStop;

@end

NS_ASSUME_NONNULL_END
