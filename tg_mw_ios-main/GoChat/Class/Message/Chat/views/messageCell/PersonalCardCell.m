//
//  PersonalCardCell.m
//  GoChat
//
//  Created by mac on 2021/9/6.
//

#import "PersonalCardCell.h"

@interface PersonalCardCell ()
@property (weak, nonatomic) IBOutlet UIImageView *failedImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *readFlag;
@property (weak, nonatomic) IBOutlet UIView *timeBg;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;


@property (nonatomic, strong) UIView *matterView;
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nicknameLab;
@property (nonatomic, strong) UILabel *accountLab;
@property (nonatomic, strong) UIView *lineV;
@property (nonatomic, strong) UILabel *tipLab;
@property (nonatomic, strong) UserInfo *user;

@property (nonatomic, strong) UIButton * fireTimeBtn; //阅后即焚倒计时


@end

@implementation PersonalCardCell
@dynamic delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnTimeLabelChaged:) name:@"BurnTimeLabelChaged" object:nil];
    }
    return self;
}

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName{
    return 128+6;
}

- (void)initialize
{
    [super initialize];
    //失败
    self.failedImageView.hidden = YES;
    //状态
    self.statusLabel.hidden = YES;
    //已发已读标志
    self.readFlag.hidden = YES;
    self.timeBg.hidden = YES;
    

    
    self.user = [[TelegramManager shareInstance] contactInfo:self.chatRecordDTO.content.contact.user_id];
    
    if ([self.user.displayName isEqualToString:@""] && self.user.willShowContactId == 0 && self.user.pushToken.length == 0) {
        self.user = nil;
    }
    
    if (self.user == nil) {
        [[TelegramManager shareInstance] requestContactInfo:self.chatRecordDTO.content.contact.user_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:UserInfo.class]){
                self.user = obj;
                [self loadMyUI:self.user];
            }
        } timeout:^(NSDictionary *request) {
            [self loadMyUI:self.user];
        }];
    }else{
        [self loadMyUI:self.user];
    }
    


    
}
-(void)loadMyUI:(UserInfo *)user{
    if(user != nil)
    {
        if(user.profile_photo != nil)
        {
            if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
            {
                [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
                //本地头像
                self.iconImgV.image = nil;
                unichar text = [@" " characterAtIndex:0];
                if(user.displayName.length>0)
                {
                    text = [[user.displayName uppercaseString] characterAtIndex:0];
                }
                [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
            }
            else
            {
                [UserInfo cleanColorBackgroundWithView:self.iconImgV];
                self.iconImgV.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
            }
        }
        else
        {
            //本地头像
            self.iconImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
        }
        self.nicknameLab.text = user.displayName;
    }
    else
    {
        self.nicknameLab.text = self.chatRecordDTO.content.contact.first_name;
        //本地头像
        self.iconImgV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.nicknameLab.text.length>0)
        {
            text = [[self.nicknameLab.text uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(42, 42) withChar:text];
    }
}
- (void)reset
{
    [super reset];
    [self.matterView removeFromSuperview];
    self.matterView = nil;
}

- (void)config
{
    [super config];
    
    if (![self.accountLab.text isEqualToString:self.chatRecordDTO.textTypeContent])
    {
        [self.contentView addSubview:self.matterView];
        [self.matterView addSubview:self.iconImgV];
        [self.matterView addSubview:self.nicknameLab];
        [self.matterView addSubview:self.accountLab];
        [self.matterView addSubview:self.lineV];
        [self.matterView addSubview:self.tipLab];
        
        [self.matterView addSubview:self.readFlag];
        [self.matterView addSubview:self.timeLabel];
        
    }
    if (self.chatRecordDTO.is_outgoing)
    {
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
            //self.timeBg.hidden = NO;
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
    else{
        //阅后即焚
        if (self.chatRecordDTO.fireTime.intValue>0) {
            self.fireTimeBtn.hidden = NO;
        }
        else{
            self.fireTimeBtn.hidden = YES;
        }
    }
    
    self.accountLab.text = self.chatRecordDTO.textTypeContent;
    [self.bubbleImageView addSubview:self.matterView];
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    self.bubbleImageView.frame = CGRectMake(frame.origin.x, frame.origin.y, 230, 94);
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    self.iconImgV.frame = CGRectMake(0, 0, 42, 42);
    self.nicknameLab.frame = CGRectMake(52, 0, 130, 24);
    self.accountLab.frame = CGRectMake(52, 26, 130, 14);
    self.lineV.frame = CGRectMake(0, 52, 206, 0.5);
    self.tipLab.frame = CGRectMake(0, 60, 202, 14);
    
    if (self.chatRecordDTO.is_outgoing)
    {
        //文本
#if 0
        frame = self.matterView.frame;
        frame.origin.x = 10;//箭头在右边，所以内容区稍微偏左调
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height)/2 - 4;
        self.matterView.frame = frame;

        //√√
        //进度
        if (self.indicatorView.hidden == NO)
        {
            frame = self.indicatorView.frame;
            frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame)- frame.size.width - 10;
            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
            self.indicatorView.frame = frame;
        }
        
        //失败图标
        if (self.failedImageView.hidden == NO)
        {
            frame = self.failedImageView.frame;
            frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame)- frame.size.width - 10;
            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
            self.failedImageView.frame = frame;
        }
        
        //已读已发标志
        frame = self.readFlag.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-8;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.readFlag.frame = frame;
        
        //时间
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.font = fontRegular(12);
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width - 10 - (self.readFlag.hidden?0:self.readFlag.frame.size.width);
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
#endif
        if (self.indicatorView.hidden == NO)
        {
            [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bubbleImageView.mas_right).with.offset(-10);
                make.centerY.equalTo(self.bubbleImageView);
            }];
        }
        
        if (self.failedImageView.hidden == NO)
        {
            [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bubbleImageView.mas_right).with.offset(-10);
                make.centerY.equalTo(self.bubbleImageView);
            }];
        }
        
        [self.readFlag mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        
        
        //时间
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.font = fontRegular(12);
        self.timeLabel.textAlignment = NSTextAlignmentRight;
       
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.readFlag.mas_left).with.offset(0);
            make.bottom.mas_equalTo(0);
        }];
        
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(self.bubbleImageView.frame.origin.x - 40, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
    }
    else
    {
#if 0
        //文本
        frame = self.matterView.frame;
        frame.origin.x = 15;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height)/2 - 4;
        self.matterView.frame = frame;
        
        //时间
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-5;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
#endif
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+15, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
    }
    
    [super adjustFrame];
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    if (singleTapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [singleTapGesture locationInView:self.contentBaseView];
        
        BOOL effectiveGesture = CGRectContainsPoint(self.bubbleImageView.frame, point);
        
        if (effectiveGesture)
        {
            NSLog(@"点击");
            if ([self.delegate respondsToSelector:@selector(personalCard:)]) {
                [self.delegate personalCard:self.chatRecordDTO];
            }
        }
    }
    [super singleTap:singleTapGesture];
}

- (UIView *)matterView {
    if (!_matterView) {
        _matterView = [[UIView alloc] initWithFrame:CGRectMake(12, 10, 230-24, 94-17)];
//        _matterView.backgroundColor = UIColor.whiteColor;
    }
    return _matterView;
}

- (UIImageView *)iconImgV {
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_default_header"]];
        _iconImgV.layer.cornerRadius = 21;
        _iconImgV.layer.masksToBounds = YES;
    }
    return _iconImgV;
}

- (UILabel *)nicknameLab {
    if (!_nicknameLab) {
        _nicknameLab = [[UILabel alloc] init];
        _nicknameLab.font = fontRegular(17);
        _nicknameLab.textColor = [UIColor colorTextFor010009];
        _nicknameLab.text = @"昵称";
    }
    return _nicknameLab;
}

- (UILabel *)accountLab {
    if (!_accountLab) {
        _accountLab = [[UILabel alloc] init];
        _accountLab.font = [UIFont fontWithName:@"PingFang SC" size: 12];
        _accountLab.textColor = HEX_COLOR(@"#999999");
        _accountLab.text = @"aqmkfui";
    }
    return _accountLab;
}

- (UIView *)lineV{
    if (!_lineV) {
        _lineV = [[UIView alloc] init];
        _lineV.backgroundColor = HEX_COLOR(@"#E5E5E5");
    }
    return _lineV;
}

- (UILabel *)tipLab {
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.font = [UIFont fontWithName:@"PingFang SC" size: 12];
        _tipLab.textColor = HEX_COLOR(@"#999999");
        _tipLab.text = @"个人名片";
    }
    return _tipLab;
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

- (void)BurnTimeLabelChaged:(NSNotification *)not{
    NSArray *dataArr = not.object;
    MessageInfo *message = self.chatRecordDTO;
    NSString * msgID = [NSString stringWithFormat:@"%ld",message._id];
    
    if ([dataArr containsObject:msgID]) {
        NSString * timeStr = [[NSUserDefaults standardUserDefaults] valueForKey:msgID];
        NSLog(@"current Time - %@",timeStr);
        [self.fireTimeBtn setTitle:[NSString stringWithFormat:@"%@s",timeStr] forState:UIControlStateNormal];
        self.fireTimeBtn.hidden = NO;
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
    }
    else{
        if (self.chatRecordDTO.fireTime.intValue>0) {
            self.fireTimeBtn.hidden = NO;
        }else{
            self.fireTimeBtn.hidden = YES;
        }
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
