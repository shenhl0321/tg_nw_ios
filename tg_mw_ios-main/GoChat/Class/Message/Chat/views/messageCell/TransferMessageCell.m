//
//  TransferMessageCell.m
//  GoChat
//
//  Created by Autumn on 2022/1/24.
//

#import "TransferMessageCell.h"

#define Transfer_Content_Height 97
#define Transfer_Content_Width SCREEN_WIDTH-110

@interface TransferMessageCell ()

@property (nonatomic, strong) UIView *transferBgView;

@property (nonatomic, strong) UIImageView *flagImageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) IBOutlet UIImageView  *readFlag;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UILabel *bottomLeftLabel;

@end

@implementation TransferMessageCell

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName)
    {
        //昵称高度
        height += MessageCellNicknameHeight;
    }
    //气泡高度
    height += MAX(Transfer_Content_Height, MessageCellContentMinHeight);
    //下边距
    height += MessageCellVertMargins;

    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
}

- (void)reset {
    [super reset];
    [self.flagImageView removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    if ([self.subtitleLabel superview]) {
        [self.subtitleLabel removeFromSuperview];
    }
    [self.transferBgView removeFromSuperview];
}

- (void)initialize {
    [super initialize];
    self.readFlag.hidden = YES;
}

- (void)config {
    [super config];
    
    //bg
    self.transferBgView = [UIView new];
    self.transferBgView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:self.transferBgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRedPacket)];
    tap.numberOfTapsRequired = 1;
    [self.transferBgView addGestureRecognizer:tap];
    
    //icon
    self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    self.flagImageView.image = self.chatRecordDTO.transferInfo.icon;
    [self.bubbleImageView addSubview:self.flagImageView];
    
    [self.bubbleImageView addSubview:self.bottomLineView];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(-24);
    }];
    [self.bubbleImageView addSubview:self.bottomLeftLabel];
    [self refreshUIWithNormal:NO];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = fontRegular(16);
    self.titleLabel.text = self.chatRecordDTO.transferInfo.money;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.bubbleImageView addSubview:self.titleLabel];
    
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
    self.subtitleLabel.textColor = [UIColor whiteColor];
    self.subtitleLabel.text = self.chatRecordDTO.transferInfo.tipMessage;
    self.subtitleLabel.font = fontRegular(13);
    self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.bubbleImageView addSubview:self.subtitleLabel];
    
    if (self.chatRecordDTO.is_outgoing && self.chatRecordDTO.sendState == MessageSendState_Success) {
        self.readFlag.hidden = NO;
        BOOL isReaded = NO;
        if ([self.delegate respondsToSelector:@selector(messageCell_Outing_Message_IsRead:)]) {
            isReaded = [self.delegate messageCell_Outing_Message_IsRead:self];
        }
        NSString *imageName = isReaded ? @"icon_msg_read_cb" : @"icon_msg_sended_cb";
        self.readFlag.image = [UIImage imageNamed:imageName];
    }
    
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)refreshUIWithNormal:(BOOL)normal{
    if (normal) {
        self.bottomLineView.backgroundColor = HexRGB(0xFFC689);
        self.bottomLeftLabel.textColor = HexRGB(0xFFCE99);
        self.timeLabel.textColor = HexRGB(0xFFCE99);
    }else{
        self.bottomLineView.backgroundColor = HexRGB(0xffffff);
        self.bottomLeftLabel.textColor = HexRGB(0xffffff);
        self.timeLabel.textColor = HexRGB(0xffffff);
    }
}
- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    frame.size.width = Transfer_Content_Width;
    frame.size.height = Transfer_Content_Height;
    self.bubbleImageView.frame = frame;
    self.transferBgView.frame = self.bubbleImageView.bounds;
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        //提示图标
        frame = self.flagImageView.frame;
        frame.origin.x = 15;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-17)/2;
        self.flagImageView.frame = frame;
        
        frame = self.titleLabel.frame;
        frame.origin.x = self.flagImageView.frame.origin.x+self.flagImageView.frame.size.width+10;
        frame.origin.y = CGRectGetMinY(self.flagImageView.frame);
        frame.size.width = Transfer_Content_Width - frame.origin.x - 15;
        self.titleLabel.frame = frame;
        
        //副标题 subtitleLabel
        frame = self.subtitleLabel.frame;
        frame.origin.x = self.titleLabel.frame.origin.x;
        frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
        frame.size.width = self.titleLabel.frame.size.width;
        self.subtitleLabel.frame = frame;
        
        //已读已发标志
        frame = self.readFlag.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-8;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.readFlag.frame = frame;
        
        //时间
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 45;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width - 10 - (self.readFlag.hidden?0:self.readFlag.frame.size.width);
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
    }
    else
    {
        //提示图标
        frame = self.flagImageView.frame;
        frame.origin.x = 15;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-17)/2;
        self.flagImageView.frame = frame;
        
        frame = self.titleLabel.frame;
        frame.origin.x = self.flagImageView.frame.origin.x+self.flagImageView.frame.size.width+10;
        frame.origin.y = CGRectGetMinY(self.flagImageView.frame);
        frame.size.width = Transfer_Content_Width - frame.origin.x - 15;
        self.titleLabel.frame = frame;
        
        //副标题 subtitleLabel
        frame = self.subtitleLabel.frame;
        frame.origin.x = self.titleLabel.frame.origin.x;
        frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
        frame.size.width = self.titleLabel.frame.size.width;
        self.subtitleLabel.frame = frame;
       
        //时间
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 45;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-5;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height-3.5;
        self.timeLabel.frame = frame;
    }
    
    [super adjustFrame];
}

- (void)tapedRedPacket {
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellShouldShowTransferInfo:)]) {
        [self.delegate messageCellShouldShowTransferInfo:self];
    }
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
    }
    return _bottomLineView;
}

- (UILabel *)bottomLeftLabel {
    if (!_bottomLeftLabel) {
        _bottomLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 76.5, 60, 17.5)];
        _bottomLeftLabel.text = @"转账".lv_localized;
        _bottomLeftLabel.font = fontRegular(12);
    }
    return _bottomLeftLabel;
}

@end
