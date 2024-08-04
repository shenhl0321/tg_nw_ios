//
//  AudioMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/12/25.
//

#import "AudioMessageCell.h"
#import "PlayAudioManager.h"

@interface AudioMessageCell()

@property (nonatomic, strong) IBOutlet UILabel *durationLabel;

@property (nonatomic, strong) IBOutlet UIImageView *failedImageView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) IBOutlet UILabel *progressLabel;

@property (nonatomic, strong) IBOutlet UIImageView *AudioImageView;

@property (nonatomic, strong) UIImageView *playAnimationImageView;

@property (nonatomic, strong) IBOutlet UIImageView *readFlag;
@property (nonatomic, strong) UIButton * fireTimeBtn; //阅后即焚倒计时
/// 语音转文字的显示内容
@property (nonatomic,strong) UILabel *transferTL;
/// <#code#>
@property (nonatomic,strong) UIView *transferPV;
/// 转译菊花圈
@property (nonatomic,strong) UIActivityIndicatorView *activityV;
@end

@implementation AudioMessageCell
@dynamic delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnTimeLabelChaged:) name:@"BurnTimeLabelChaged" object:nil];
        [self.contentView addSubview:self.transferPV];
        [self.transferPV addSubview:self.transferTL];
        [self.contentView addSubview:self.activityV];
    }
    return self;
}
+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName)
    {
        //昵称高度
        height += MessageCellNicknameHeight;
    }
    //气泡高度
    height += MessageCellContentMinHeight;
    //时间高度
    //height += MessageCellTimestampRegionHeight;
    //下边距
    height += MessageCellVertMargins;
    
    // 语音转文字显示控件
    if (chatRecordDTO.content.audio.isShowTransfer) {
        CGFloat maxW = SCREEN_WIDTH - 150;
        CGFloat transferHeight = [chatRecordDTO.content.audio.transferText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(maxW, CGFLOAT_MAX)].height;
        transferHeight += 20;
        
        height += transferHeight;
    }
    
    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
}

- (void)reset
{
    [super reset];
    
    [self.indicatorView stopAnimating];
    
    [self.AudioImageView removeFromSuperview];
    
    [self stopPlay];
}

- (void)initialize
{
    [super initialize];
    //失败
    self.failedImageView.hidden = YES;
    //状态
    self.statusLabel.hidden = YES;
    //时长
    self.durationLabel.hidden = NO;
    //播放动画
    self.playAnimationImageView.hidden = NO;
    //图标
    self.AudioImageView.hidden = NO;
    //下载进度-暂时隐藏
    self.progressLabel.hidden = YES;
    //已发已读标志
    self.readFlag.hidden = YES;
}

- (void)config
{
    [super config];
    
    if (self.chatRecordDTO._id == [PlayAudioManager sharedPlayAudioManager].getPlayingMsgId)
    {
        [self startPlay];
    }
    if([self.chatRecordDTO.content.type isEqualToString:@"messageVoiceNote"]){
        self.durationLabel.text = [NSString stringWithFormat:@"%ld\"",lround(self.chatRecordDTO.content.voice_note.duration)];
    }else{
        self.durationLabel.text = [NSString stringWithFormat:@"%ld\"",lround(self.chatRecordDTO.content.audio.duration)];
    }
    
    
    [self.bubbleImageView addSubview:self.AudioImageView];
    
    
    if (self.chatRecordDTO.is_outgoing)
    {
        self.durationLabel.textAlignment = NSTextAlignmentRight;
        self.progressLabel.textAlignment = NSTextAlignmentRight;
        if (self.chatRecordDTO.sendState == MessageSendState_Pending)
        {
            self.failedImageView.hidden = YES;
            [self.indicatorView startAnimating];
        }
        else if (self.chatRecordDTO.sendState == MessageSendState_Fail)
        {
            self.failedImageView.hidden = NO;
            [self.indicatorView stopAnimating];
        }
        else
        {
            self.failedImageView.hidden = YES;
            [self.indicatorView stopAnimating];
            //消息发送成功后，才会显示已读未读标志
            self.readFlag.hidden = NO;
            BOOL isReaded = NO;
            if ([self.delegate respondsToSelector:@selector(messageCell_Outing_Message_IsRead:)])
            {
                isReaded = [self.delegate messageCell_Outing_Message_IsRead:self];
            }
            if(isReaded)
            {
                self.readFlag.image = [UIImage imageNamed:@"icon_msg_read_cb"];
            }
            else
            {
                self.readFlag.image = [UIImage imageNamed:@"icon_msg_sended_cb"];
            }
        }
        //阅后即焚
        if (self.chatRecordDTO.fireTime.intValue>0) {
            [self.fireTimeBtn setTitle:[NSString stringWithFormat:@"%@s",self.chatRecordDTO.fireTime] forState:UIControlStateNormal];
            self.fireTimeBtn.hidden = NO;
            [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
        }
        else{
            self.fireTimeBtn.hidden = YES;
        }
    }
    else
    {
        //阅后即焚
        if (self.chatRecordDTO.fireTime.intValue>0) {
            self.fireTimeBtn.hidden = NO;
        }
        else{
            self.fireTimeBtn.hidden = YES;
        }
        self.durationLabel.textAlignment = NSTextAlignmentLeft;
        self.progressLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if (self.chatRecordDTO.content.audio.isShowTransfer) {
        self.transferPV.hidden = NO;
        self.transferTL.text = self.chatRecordDTO.content.audio.transferText;
    } else {
        self.transferPV.hidden = YES;
    }
    
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    frame.size.width = self.AudioImageView.frame.size.width + 30;
    //泡泡长度随语音长度改变而改变
    if(self.chatRecordDTO.content.audio.duration > 60)
    {
        frame.size.width = frame.size.width + 2 * 60;
    }
    else
    {
        frame.size.width = frame.size.width + 2*self.chatRecordDTO.content.audio.duration;
    }
    frame.size.width = MAX(frame.size.width, 120);
    frame.size.height = MessageCellContentMinHeight;
    self.bubbleImageView.frame = frame;

    //调整气泡坐标
    [self adjustBubblePosition];

    if (self.chatRecordDTO.is_outgoing)
    {
        //语音图标
        CGPoint center = self.AudioImageView.center;
        center.x = self.bubbleImageView.frame.size.width/2 - 5;
        center.y = self.bubbleImageView.frame.size.height/2;
        self.AudioImageView.center = center;

        //进度
        if (self.indicatorView.hidden == NO)
        {
            frame = self.indicatorView.frame;
            frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame) - frame.size.width - 25;
            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
            self.indicatorView.frame = frame;
        }
        
        //失败图标
        if (self.failedImageView.hidden == NO)
        {
            frame = self.failedImageView.frame;
            frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame) - frame.size.width - 25;
            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
            self.failedImageView.frame = frame;
        }
        
        //时长
        frame = self.durationLabel.frame;
        frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame) - frame.size.width - 5;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.durationLabel.frame = frame;
        
        // 菊花圈
        CGRect durationF = self.durationLabel.frame;
        CGFloat activiW = 30;
        CGFloat activiH = activiW;
        CGFloat activiX = CGRectGetMinX(durationF) - 15;
        CGFloat activiY = CGRectGetMaxY(durationF) - activiH;
        self.activityV.frame = CGRectMake(activiX, activiY, activiW, activiH);
        
        //已读已发标志
        frame = self.readFlag.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-8;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.readFlag.frame = frame;
        
        //时间
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width - 12 - (self.readFlag.hidden?0:self.readFlag.frame.size.width);
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
        
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(self.bubbleImageView.frame.origin.x - 40, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
        if (self.chatRecordDTO.content.audio.isShowTransfer) {
            CGRect bubbleFrame = self.bubbleImageView.frame;
            
            CGFloat maxW = SCREEN_WIDTH - 150;
            CGFloat width = maxW;
            CGFloat height = [self.chatRecordDTO.content.audio.transferText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(width, CGFLOAT_MAX)].height;
            if (height < 17) {
                width = [self.chatRecordDTO.content.audio.transferText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(CGFLOAT_MAX, height)].width;
            }
            
            self.transferTL.frame = CGRectMake(10, 10, width, height);
            
            height += 20;
            width += 20;
            CGFloat x = CGRectGetMaxX(bubbleFrame) - width;
            CGFloat y = CGRectGetMaxY(bubbleFrame) + 5;
            
            self.transferPV.frame = CGRectMake(x, y, width, height);
            
        } else {
            self.transferTL.frame = CGRectZero;
            self.transferPV.frame = CGRectZero;
        }
        
    }
    else
    {
        //语音图标
        CGPoint center = self.AudioImageView.center;
        center.y = self.bubbleImageView.frame.size.height/2;
        center.x = self.bubbleImageView.frame.size.width/2 + 5;
        self.AudioImageView.center = center;

        //时长
        frame = self.durationLabel.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) + 5;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.durationLabel.frame = frame;
        
        //时间
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-12;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
        
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+15, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
        
        
        // 菊花圈
        CGRect durationF = self.durationLabel.frame;
        CGFloat activiW = 30;
        CGFloat activiH = activiW;
        CGFloat activiX = CGRectGetMaxX(durationF) + 15;
        CGFloat activiY = CGRectGetMaxY(durationF) - activiH;
        self.activityV.frame = CGRectMake(activiX, activiY, activiW, activiH);
        
        
        if (self.chatRecordDTO.content.audio.isShowTransfer) {
            CGRect bubbleFrame = self.bubbleImageView.frame;
            
            CGFloat maxW = SCREEN_WIDTH - 150;
            CGFloat width = maxW;
            CGFloat height = [self.chatRecordDTO.content.audio.transferText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(width, CGFLOAT_MAX)].height;
            if (height < 17) {
                width = [self.chatRecordDTO.content.audio.transferText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(CGFLOAT_MAX, height)].width;
            }
            
            self.transferTL.frame = CGRectMake(10, 10, width, height);
            
            height += 20;
            width += 20;
            CGFloat x = CGRectGetMinX(bubbleFrame);
            CGFloat y = CGRectGetMaxY(bubbleFrame) + 5;
            
            self.transferPV.frame = CGRectMake(x, y, width, height);
            
        } else {
            self.transferTL.frame = CGRectZero;
            self.transferPV.frame = CGRectZero;
        }
    }

    self.AudioImageView.clipsToBounds = YES;
    self.AudioImageView.layer.cornerRadius = 10;
    
    [super adjustFrame];
}

- (void)configProgressWithPercent:(float)percent
{
    self.progressLabel.text = [NSString stringWithFormat:@"%ld%@", lroundf(percent*100), @"%"];
}

- (void)startPlay
{
    if (!self.playAnimationImageView.isAnimating)
    {
        [self.playAnimationImageView startAnimating];
    }
    if (self.playAnimationImageView.superview != self.AudioImageView)
    {
        [self.playAnimationImageView removeFromSuperview];
        [self.AudioImageView addSubview:self.playAnimationImageView];
        self.AudioImageView.image = nil;
    }
}

- (void)stopPlay
{
    if (_playAnimationImageView.isAnimating)
    {
        [self.playAnimationImageView stopAnimating];
    }
    if (_playAnimationImageView.superview == self.AudioImageView)
    {
        self.AudioImageView.image = [UIImage imageNamed:@"g_ic_voice_05"];
        [_playAnimationImageView removeFromSuperview];
    }
}

- (void)startActivityAnimating:(BOOL)start{
    if (start) {
        self.activityV.hidden = NO;
        [self.activityV startAnimating];
    } else {
        self.activityV.hidden = YES;
        [self.activityV stopAnimating];
    }
}

- (UIImageView *)playAnimationImageView
{
    if (_playAnimationImageView)
    {
        return _playAnimationImageView;
    }
    
    _playAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:5];
    for (int i = 1; i <= 5; ++i)
    {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"g_ic_voice_0%d", i]];
        [images addObject:image];
    }
    _playAnimationImageView.animationImages = images;
    _playAnimationImageView.animationDuration = 1;
    return _playAnimationImageView;
}

- (NSArray *)menuItems;
{
    NSMutableArray *menuItems = [NSMutableArray array];
    //引用
    [menuItems addObject:[ChatMenu menuWithTitle:@"引用".lv_localized icon:@"menu_quote" action:@selector(quoteMessage:)]];
    //加上父类的菜单
    [menuItems addObjectsFromArray:[super menuItems]];
    return menuItems;
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    if (singleTapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [singleTapGesture locationInView:self.contentBaseView];
        
        BOOL effectiveGesture = CGRectContainsPoint(self.bubbleImageView.frame, point);
        
        if (effectiveGesture)
        {
            if (self.chatRecordDTO._id == [PlayAudioManager sharedPlayAudioManager].getPlayingMsgId)
            {
                //正在播放的，再次点击需要结束
                if ([self.delegate respondsToSelector:@selector(messageCellShouldStopPlayAudio:)])
                {
                    [self.delegate messageCellShouldStopPlayAudio:self];
                }
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(messageCellShouldStartPlayAudio:)])
                {
                    [self.delegate messageCellShouldStartPlayAudio:self];
                }
            }
        }
        else if (self.failedImageView.hidden == NO)
        {
            effectiveGesture = CGRectContainsPoint(self.failedImageView.frame, point);
            if (effectiveGesture)
            {
                if (self.chatRecordDTO.is_outgoing && self.chatRecordDTO.sendState == MessageSendState_Fail)
                {//重发
                    if ([self.delegate respondsToSelector:@selector(messageCellWillResend:)])
                    {
                        [self.delegate messageCellWillResend:self];
                    }
                }
                else
                {
                    if ([self.delegate respondsToSelector:@selector(messageCellWillReDownloadFile:)])
                    {
                        [self.delegate messageCellWillReDownloadFile:self];
                    }
                }
            }
        }
    }
    [super singleTap:singleTapGesture];
}
- (void)BurnTimeLabelChaged:(NSNotification *)not{
    NSArray *dataArr = not.object;
    MessageInfo *message = self.chatRecordDTO;
    NSString * msgID = [NSString stringWithFormat:@"%ld",message._id];
    
    if ([dataArr containsObject:msgID]) {
        NSString * timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:msgID];
        NSLog(@"current Time - %@",timeStr);
        [self.fireTimeBtn setTitle:[NSString stringWithFormat:@"%@s",timeStr] forState:UIControlStateNormal];
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
        self.fireTimeBtn.hidden = NO;
    }
    else{
        if (self.chatRecordDTO.fireTime.intValue>0) {
            self.fireTimeBtn.hidden = NO;
        }else{
            self.fireTimeBtn.hidden = YES;
        }
    }
}

- (UIButton *)fireTimeBtn{
    if (!_fireTimeBtn) {
        _fireTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fireTimeBtn setTitleColor:[UIColor colorforFD4E57] forState:UIControlStateNormal];
        _fireTimeBtn.titleLabel.font = fontRegular(12);
        [_fireTimeBtn setImage:[UIImage imageNamed:@"fire_time"] forState:UIControlStateNormal];
//        [_fireTimeBtn setTitle:@"100s" forState:UIControlStateNormal];
        [self.timeLabel.superview addSubview:_fireTimeBtn];
        _fireTimeBtn.hidden = YES;
    }
    return _fireTimeBtn;
}

- (UIView *)transferPV{
    if (!_transferPV) {
        _transferPV = [[UIView alloc] init];
        _transferPV.backgroundColor = [UIColor colorBubbleOther];
        _transferPV.layer.cornerRadius = 5;
        _transferPV.clipsToBounds = YES;
    }
    return _transferPV;;
}

- (UILabel *)transferTL{
    if (!_transferTL) {
        _transferTL = [[UILabel alloc] init];
        _transferTL.numberOfLines = 0;
        
        _transferTL.textColor = XHQHexColor(0x333333);
        _transferTL.font = XHQFont(13);
    }
    return _transferTL;
}

- (UIActivityIndicatorView *)activityV{
    if (!_activityV) {
        _activityV = [[UIActivityIndicatorView alloc] init];
        [_activityV setBackgroundColor:[UIColor whiteColor]];
        _activityV.hidden = YES;
    }
    return _activityV;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
