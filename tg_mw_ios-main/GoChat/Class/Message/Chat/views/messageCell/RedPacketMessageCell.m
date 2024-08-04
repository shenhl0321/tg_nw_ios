//
//  RedPacketMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "RedPacketMessageCell.h"
#define Rp_Content_Height 97
#define Rp_Content_Width SCREEN_WIDTH-140

@interface RedPacketMessageCell()

@property (nonatomic, strong) UIView *redBgView;

@property (nonatomic, strong) UIImageView *flagImageView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) IBOutlet UIImageView *readFlag;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UILabel *bottomLeftLabel;


@end

@implementation RedPacketMessageCell
@dynamic delegate;

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName)
    {
        //昵称高度
        height += MessageCellNicknameHeight;
    }
    //气泡高度
    height += MAX(Rp_Content_Height, MessageCellContentMinHeight);
    //下边距
    height += MessageCellVertMargins;

    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
}

- (void)reset
{
    [super reset];
    [self.flagImageView removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    if ([self.subtitleLabel superview]) {
        [self.subtitleLabel removeFromSuperview];
    }
    [self.redBgView removeFromSuperview];
}

- (void)initialize
{
    [super initialize];
    //已发已读标志
    self.readFlag.hidden = YES;
}

- (void)config
{
    [super config];
    
    //bg
    self.redBgView = [UIView new];
    self.redBgView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:self.redBgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedRedPacket)];
    tap.numberOfTapsRequired = 1;
    [self.redBgView addGestureRecognizer:tap];
    
    //icon
    self.flagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 42)];
    self.flagImageView.image = [UIImage imageNamed:@"chat_rp_flag"];
    [self.bubbleImageView addSubview:self.flagImageView];
    
    [self.bubbleImageView addSubview:self.bottomLineView];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(-24);
    }];
    [self.bubbleImageView addSubview:self.bottomLeftLabel];
    [self refreshUIWithNormal:YES];
    
    NSDictionary *dic = [CZCommonTool getGreyRedPagListwithPkid:self.chatRecordDTO.rpInfo.redPacketId];
    if (dic && dic.allKeys.count > 0) {
        //title
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = fontRegular(16);
        self.titleLabel.text = self.chatRecordDTO.rpInfo.title;
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.bubbleImageView addSubview:self.titleLabel];
        //subtitleLabel
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 18)];
        self.subtitleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.font = fontRegular(13);
        self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.bubbleImageView addSubview:self.subtitleLabel];
        //置灰
        switch ([[dic objectForKey:@"RpState"] intValue]) {
            case RpState_Expire://已过期
            {
                self.flagImageView.image = [UIImage imageNamed:@"chat_rp_flag"];
                self.subtitleLabel.text = @"已过期".lv_localized;
                [self refreshUIWithNormal:YES];
               
            }
                break;
            case RpState_To_Get://未领取，待抢
            {
                self.flagImageView.image = [UIImage imageNamed:@"chat_rp_flag"];
                [self refreshUIWithNormal:YES];
            }
                break;
            case RpState_Got: //已领取
            {
                self.flagImageView.image = [UIImage imageNamed:@"chat_rped_flag"];
                if([[dic objectForKey:@"type"] intValue] == 1){//单聊红包
                    self.subtitleLabel.text = @"已领取".lv_localized;
                }else{
                    self.subtitleLabel.text = @"已领完".lv_localized;
                }
                [self refreshUIWithNormal:NO];
            }
                break;
            case RpState_GotADone://已领取并且被抢光
            {
                self.flagImageView.image = [UIImage imageNamed:@"chat_rped_flag"];
                if([[dic objectForKey:@"type"] intValue] == 1){//单聊红包
                    self.subtitleLabel.text = @"已领取".lv_localized;
                }else{
                    self.subtitleLabel.text = @"已领完".lv_localized;
                }
                [self refreshUIWithNormal:NO];
            }
                break;
            case RpState_Done://已被抢光
            {
                self.flagImageView.image = [UIImage imageNamed:@"chat_rped_flag"];
                if([[dic objectForKey:@"type"] intValue] == 1){//单聊红包
                    self.subtitleLabel.text = @"已领取".lv_localized;
                }else{
                    self.subtitleLabel.text = @"已领完".lv_localized;
                }
                [self refreshUIWithNormal:NO];
            }
                break;
                
            default:
                
                break;
        }
    }else{
        //title
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = fontRegular(16);
        self.titleLabel.text = self.chatRecordDTO.rpInfo.title;
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        [self.bubbleImageView addSubview:self.titleLabel];
    }
    
    
    if (self.chatRecordDTO.is_outgoing)
    {
        if (self.chatRecordDTO.sendState == MessageSendState_Pending)
        {
        }
        else if (self.chatRecordDTO.sendState == MessageSendState_Fail)
        {
        }
        else
        {
            //消息发送成功后，才会显示已读未读标志
            self.readFlag.hidden = NO;
            //self.timeBg.hidden = YES;
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
    frame.size.width = Rp_Content_Width;
    frame.size.height = Rp_Content_Height;
    self.bubbleImageView.frame = frame;
    self.redBgView.frame = self.bubbleImageView.bounds;
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        //提示图标
        frame = self.flagImageView.frame;
        frame.origin.x = 15;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-24)/2;
        self.flagImageView.frame = frame;
        
        NSDictionary *dic = [CZCommonTool getGreyRedPagListwithPkid:self.chatRecordDTO.rpInfo.redPacketId];
        if (dic && dic.allKeys.count > 0) {//置灰
            //标题
            frame = self.titleLabel.frame;
            frame.origin.x = self.flagImageView.frame.origin.x+self.flagImageView.frame.size.width+10;
            frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-24)/2;
            frame.size.width = Rp_Content_Width - frame.origin.x - 15;
            self.titleLabel.frame = frame;
            
            //副标题 subtitleLabel
            frame = self.subtitleLabel.frame;
            frame.origin.x = self.titleLabel.frame.origin.x;
            frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
            frame.size.width = self.titleLabel.frame.size.width;
            self.subtitleLabel.frame = frame;
        }else{
            //标题
            frame = self.titleLabel.frame;
            frame.origin.x = self.flagImageView.frame.origin.x+self.flagImageView.frame.size.width+15;
            frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-24)/2;
            frame.size.width = Rp_Content_Width - frame.origin.x - 15;
            self.titleLabel.frame = frame;
        }
        
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
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-24)/2;
        self.flagImageView.frame = frame;
        NSDictionary *dic = [CZCommonTool getGreyRedPagListwithPkid:self.chatRecordDTO.rpInfo.redPacketId];
        if (dic && dic.allKeys.count > 0) {//置灰
            //标题
            frame = self.titleLabel.frame;
            frame.origin.x = self.flagImageView.frame.origin.x+self.flagImageView.frame.size.width+10;
            frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-24)/2;
            frame.size.width = Rp_Content_Width - frame.origin.x - 15;
            self.titleLabel.frame = frame;
            
            //副标题 subtitleLabel
            frame = self.subtitleLabel.frame;
            frame.origin.x = self.titleLabel.frame.origin.x;
            frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height;
            frame.size.width = self.titleLabel.frame.size.width;
            self.subtitleLabel.frame = frame;
        }else{
            //标题
            frame = self.titleLabel.frame;
            frame.origin.x = self.flagImageView.frame.origin.x+self.flagImageView.frame.size.width+10;
            frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height-24)/2;
            frame.size.width = Rp_Content_Width - frame.origin.x - 15;
            self.titleLabel.frame = frame;
        }
       
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

- (void)tapedRedPacket
{
    if ([self.delegate respondsToSelector:@selector(messageCellShouldOpenRedPacket:)])
    {
        [self.delegate messageCellShouldOpenRedPacket:self];
    }
}

-(UIView *)bottomLineView{
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        
    }
    return _bottomLineView;
}

-(UILabel *)bottomLeftLabel{
    if (!_bottomLeftLabel) {
        _bottomLeftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 76.5, 60, 17.5)];
        _bottomLeftLabel.text = @"现金红包".lv_localized;
        _bottomLeftLabel.font = fontRegular(12);
    }
    return _bottomLeftLabel;
}

@end
