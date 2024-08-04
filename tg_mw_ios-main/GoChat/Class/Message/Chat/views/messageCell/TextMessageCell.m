//
//  TextMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "TextMessageCell.h"

@interface TextMessageCell()<CoreTextViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *failedImageView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) IBOutlet UIImageView *readFlag;

@property (nonatomic, strong) TextUnit *willSelectedTextUnit;

@property (nonatomic, strong) UIButton * fireTimeBtn; //阅后即焚倒计时

@property (nonatomic, assign) BOOL needChangeLine;//需要换行

/// 语音转文字的显示内容
@property (nonatomic,strong) UILabel *translateTL;
/// <#code#>
@property (nonatomic,strong) UIView *translatePV;
/// 转译菊花圈
@property (nonatomic,strong) UIActivityIndicatorView *activityV;
///
@property (nonatomic,strong) UIButton *tipBtn;

@end

@implementation TextMessageCell
@dynamic delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnTimeLabelChaged:) name:@"BurnTimeLabelChaged" object:nil];
        [self.contentView addSubview:self.translatePV];
        [self.translatePV addSubview:self.translateTL];
        [self.translatePV addSubview:self.tipBtn];
        [self.contentView addSubview:self.activityV];
    }
    return self;
}
- (UIButton *)fireTimeBtn{
    if (!_fireTimeBtn) {
        _fireTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fireTimeBtn setTitleColor:[UIColor colorforFD4E57] forState:UIControlStateNormal];
        _fireTimeBtn.titleLabel.font = fontRegular(12);
        [_fireTimeBtn setImage:[UIImage imageNamed:@"fire_time"] forState:UIControlStateNormal];
        [self.timeLabel.superview addSubview:_fireTimeBtn];
        _fireTimeBtn.hidden = YES;
       
    }
    return _fireTimeBtn;
}


+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    CoreTextView *coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, [TextMessageCell maxBubbleWidth], 0)];
    coreTextView.analyzeType = AnalyzeTypeURL|AnalyzeTypeEmail|AnalyzeTypePhoneNumber|AnalyzeTypeSomeone|AnalyzeTypeTransferRemind;
    coreTextView.text = chatRecordDTO.textTypeContent;
    [coreTextView startAnalyze];
    [coreTextView adjustFrame];
    
    
    
    NSString *a = @"00:00 ";
    if (chatRecordDTO.is_outgoing) {
        a = @"00:00 00 ";
    }
    CoreTextView *tempTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, [self maxBubbleWidth], 0)];
    tempTextView.analyzeType = AnalyzeTypeURL|AnalyzeTypeEmail|AnalyzeTypePhoneNumber|AnalyzeTypeSomeone;
    tempTextView.text = [NSString stringWithFormat:@"%@%@",chatRecordDTO.textTypeContent,a];
    [tempTextView startAnalyze];
    [tempTextView adjustFrame];
    
    CGFloat otherHeight = 0;
    if (tempTextView.frame.size.height > coreTextView.frame.size.height) {
    //需要换行说明 就需要加上 24的高度。
        otherHeight = 24;
    }
    
    
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName)
    {
        //昵称高度
        height += MessageCellNicknameHeight;
    }
    //气泡高度
    height += MAX(coreTextView.frame.size.height  + otherHeight + 24, MessageCellContentMinHeight);
    //时间高度
    //height += MessageCellTimestampRegionHeight;
    //下边距
    height += MessageCellVertMargins;
    
    // 语音转文字显示控件
    if (chatRecordDTO.isShowTranslate) {
        CGFloat maxW = SCREEN_WIDTH - 150;
        CGFloat transferHeight = [chatRecordDTO.translateText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(maxW, CGFLOAT_MAX)].height;
        transferHeight += 20;
        // 翻译提示
        transferHeight += 25;
        height += transferHeight;
    }
    

    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
    
   
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

+ (CGFloat)maxBubbleWidth{
    return APP_SCREEN_WIDTH-140;
}

- (CGFloat)maxBubbleWidth{
    return [TextMessageCell maxBubbleWidth];
    
}
- (void)reset
{
    [super reset];
    
    [self.indicatorView stopAnimating];
    
    [self.coreTextView removeFromSuperview];
    
    self.coreTextView.delegate = nil;
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
   
}

- (void)config
{
    [super config];
    
    if (![self.coreTextView.text isEqualToString:self.chatRecordDTO.textTypeContent])
    {
        self.coreTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, [self maxBubbleWidth], 0)];
        self.coreTextView.analyzeType = AnalyzeTypeURL|AnalyzeTypeEmail|AnalyzeTypePhoneNumber|AnalyzeTypeSomeone|AnalyzeTypeTransferRemind;
        self.coreTextView.text = self.chatRecordDTO.textTypeContent;
        self.coreTextView.msginfo = self.chatRecordDTO;
        [self.coreTextView startAnalyze];
        [self.coreTextView adjustFrame];
        
       
        
        CGRect frame = self.coreTextView.frame;
        frame.size.width = MAX(self.coreTextView.frame.size.width, 50);
        self.coreTextView.frame = frame;
    }
    
    self.coreTextView.delegate = self;
    self.coreTextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    
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
        if (self.chatRecordDTO.fireTime.intValue>0) {
            self.fireTimeBtn.hidden = NO;
        }
        else{
            self.fireTimeBtn.hidden = YES;
        }
    }
    
    if (self.chatRecordDTO.isShowTranslate) {
        self.translateTL.text = self.chatRecordDTO.translateText;
        self.translatePV.hidden = NO;
    } else {
        self.translatePV.hidden = YES;
    }
    
    [self.bubbleImageView addSubview:self.coreTextView];
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)adjustFrame
{
    
    self.needChangeLine = NO;
    NSString *a = @"00:00 ";
    if (self.chatRecordDTO.is_outgoing) {
        a = @"00:00 00 ";
    }
    
    
    CoreTextView *tempTextView = [[CoreTextView alloc] initWithFrame:CGRectMake(0, 0, [self maxBubbleWidth], 0)];
    tempTextView.analyzeType = AnalyzeTypeURL|AnalyzeTypeEmail|AnalyzeTypePhoneNumber|AnalyzeTypeSomeone|AnalyzeTypeTransferRemind;
    tempTextView.text = [NSString stringWithFormat:@"%@%@",self.chatRecordDTO.textTypeContent,a];
    tempTextView.msginfo = self.chatRecordDTO;
    [tempTextView startAnalyze];
    [tempTextView adjustFrame];
    
    if (tempTextView.frame.size.height > self.coreTextView.frame.size.height) {
        self.needChangeLine = YES;//需要换行说明 就需要加上 24的高度。
    }
    
    
    [self.bubbleImageView addSubview:self.coreTextView];
    [self.bubbleImageView addSubview:self.timeLabel];
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
   
    CGFloat height = self.coreTextView.frame.size.height;
    CGFloat width = self.coreTextView.frame.size.width;
    if (self.needChangeLine) {//需要换行的情况
        height = height +24;
    }else{//不需要换行请下
        if (width < [self maxBubbleWidth]) {
            if (self.chatRecordDTO.is_outgoing) {
                width = width+63;
            }else{
                width = width + 37;
            }
        }
        
        width = MIN(width, [self maxBubbleWidth]);
        
    }
//    CGFloat size = CGSizeMake(width, height);
   
    if (self.chatRecordDTO.is_outgoing) {
        [self.bubbleImageView addSubview:self.readFlag];
        self.bubbleImageView.frame = CGRectMake(0, 0,width+24, height + 24 );
        self.coreTextView.frame = CGRectMake(12, 12, self.coreTextView.frame.size.width, self.coreTextView.frame.size.height);
        //进度
        if (self.indicatorView.hidden == NO)
        {
            [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bubbleImageView.mas_right).with.offset(-10);
                make.centerY.equalTo(self.bubbleImageView);
            }];
        }
        
        if (self.failedImageView.hidden == NO)
        {
            [self.failedImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.bubbleImageView.mas_left).with.offset(-10);
                make.centerY.equalTo(self.bubbleImageView);
            }];
        }
        
        [self.readFlag mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.bottom.mas_equalTo(-10);
            make.size.mas_equalTo(CGSizeMake(14, 14));
        }];
        
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.readFlag.mas_left).with.offset(-12);
            make.bottom.mas_equalTo(-10);
           
        }];
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
        [self.fireTimeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.bubbleImageView.mas_left).with.offset(-15);
            make.centerY.equalTo(self.bubbleImageView);
            make.size.mas_equalTo(CGSizeMake(30, 50));
        }];
        
    }else{
        
        self.bubbleImageView.frame = CGRectMake(0, 0, width+24, height + 24);
//        [self.coreTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.center.mas_equalTo(0);
//        }];
        self.coreTextView.frame = CGRectMake(12, 12, self.coreTextView.frame.size.width, self.coreTextView.frame.size.height);
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(-10);
        }];
        
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
        [self.fireTimeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bubbleImageView.mas_right).with.offset(15);
            make.centerY.equalTo(self.bubbleImageView);
            make.size.mas_equalTo(CGSizeMake(30, 50));
        }];
    }
    [self adjustBubblePosition];
    [super adjustFrame];
    
    if (self.chatRecordDTO.is_outgoing) {
        
        CGRect bubbleFrame = self.bubbleImageView.frame;
        
        CGFloat activiW = 30;
        CGFloat activiH = activiW;
        CGFloat activiX = CGRectGetMinX(bubbleFrame) - 45;
        CGFloat activiY = CGRectGetMaxY(bubbleFrame) - activiH;
        self.activityV.frame = CGRectMake(activiX, activiY, activiW, activiH);
        
        if (self.chatRecordDTO.isShowTranslate) {
            CGFloat maxW = SCREEN_WIDTH - 150;
            CGFloat width = maxW;
            CGFloat height = [self.chatRecordDTO.translateText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(width, CGFLOAT_MAX)].height;
            if (height < 17) {
                width = [self.chatRecordDTO.translateText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(CGFLOAT_MAX, height)].width;
            }
            
            self.translateTL.frame = CGRectMake(10, 10, width, height);
            
            height += 20;
            CGFloat tipH = 25;
            CGFloat minW = 160;
            height += tipH;
            width += 20;
            width = MAX(width, minW);
            CGFloat x = CGRectGetMaxX(bubbleFrame) - width;
            CGFloat y = CGRectGetMaxY(bubbleFrame) + 5;
            self.tipBtn.frame = CGRectMake(10, height - tipH - 5, minW - 20, tipH);
            self.translatePV.frame = CGRectMake(x, y, width, height);
            
        } else {
            self.translateTL.frame = CGRectZero;
            self.translatePV.frame = CGRectZero;
            self.tipBtn.frame = CGRectZero;
        }
    } else {
        CGRect bubbleFrame = self.bubbleImageView.frame;
        
        // 菊花圈
        CGFloat activiW = 30;
        CGFloat activiH = activiW;
        CGFloat activiX = CGRectGetMaxX(bubbleFrame) + 15;
        CGFloat activiY = CGRectGetMaxY(bubbleFrame) - activiH;
        self.activityV.frame = CGRectMake(activiX, activiY, activiW, activiH);
        
        if (self.chatRecordDTO.isShowTranslate) {
            CGFloat maxW = SCREEN_WIDTH - 150;
            CGFloat width = maxW;
            CGFloat height = [self.chatRecordDTO.translateText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(width, CGFLOAT_MAX)].height;
            if (height < 17) {
                width = [self.chatRecordDTO.translateText xhq_sizeWithFont:XHQFont(13) withSize:CGSizeMake(CGFLOAT_MAX, height)].width;
            }
            
            self.translateTL.frame = CGRectMake(10, 10, width, height);
            
            height += 20;
            CGFloat tipH = 25;
            CGFloat minW = 160;
            height += tipH;
            width += 20;
            width = MAX(width, minW);
            
            CGFloat x = CGRectGetMinX(bubbleFrame);
            CGFloat y = CGRectGetMaxY(bubbleFrame) + 5;
            self.tipBtn.frame = CGRectMake(10, height - tipH - 5, minW - 20, tipH);
            self.translatePV.frame = CGRectMake(x, y, width, height);
            
        } else {
            self.translateTL.frame = CGRectZero;
            self.translatePV.frame = CGRectZero;
            self.tipBtn.frame = CGRectZero;
        }
        
    }
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
    
}

- (NSArray *)menuItems;
{
    NSMutableArray *menuItems = [NSMutableArray array];
    //引用
    [menuItems addObject:[ChatMenu menuWithTitle:@"引用".lv_localized icon:@"menu_quote" action:@selector(quoteMessage:)]];
    //拷贝
    [menuItems addObject:[ChatMenu menuWithTitle:@"拷贝".lv_localized icon:@"menu_copy" action:@selector(copyMessage:)]];
    if (self.willSelectedTextUnit && self.willSelectedTextUnit.textUnitType == TextUnitTypeURL) {
        //拷贝url
        [menuItems addObject:[ChatMenu menuWithTitle:@"拷贝链接".lv_localized icon:@"menu_copy_link" action:@selector(copyURLString:)]];
    }
    //加上父类的菜单
    [menuItems addObjectsFromArray:[super menuItems]];
    return menuItems;
}

//复制
- (void)copyMessage:(id)sender
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    NSString *transferContent = [self parseMentionedSomeone:self.chatRecordDTO.textTypeContent];
    gpBoard.string = transferContent;
}

//复制
- (void)copyURLString:(id)sender
{
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    NSString *transferContent = self.willSelectedTextUnit.originalContent;
    gpBoard.string = transferContent;
    self.willSelectedTextUnit = nil;
}

- (NSString *)parseMentionedSomeone:(NSString*)chatMessage;
{
    NSError *error = nil;
    NSString *regularStr = IM_AT_FORMAT;
    NSString * orginalContent = chatMessage;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *arrayOfAllMatches = [regex matchesInString:chatMessage options:0 range:NSMakeRange(0, [chatMessage length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString *tempOriginalContent = [chatMessage substringWithRange:match.range];
        NSUInteger left = [tempOriginalContent rangeOfString:@"|"].location;
        NSUInteger right = [tempOriginalContent rangeOfString:@"}"].location;
        
        if (right - left <= 1)
        {
            right = left;
            left = [tempOriginalContent rangeOfString:@"@"].location;
            left += [@"@" length];
        }
        else
        {
            left += [@"|" length];
        }
        NSString *tempTransferContent = [tempOriginalContent substringWithRange:NSMakeRange(left, right - left)];
        
        tempTransferContent = [@"@" stringByAppendingString:tempTransferContent];
        
        orginalContent = [orginalContent stringByReplacingOccurrencesOfString:tempOriginalContent withString:tempTransferContent];
    }
    return orginalContent;
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    if (singleTapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [singleTapGesture locationInView:self.contentBaseView];
        
        BOOL effectiveGesture = CGRectContainsPoint(self.bubbleImageView.frame, point);
        
        if (effectiveGesture)
        {
            //点击了特殊字符串
            TextUnit *unit = self.willSelectedTextUnit;
            if (unit && [self.delegate respondsToSelector:@selector(messageCell:didSelectedTextUnit:)])
            {
                [self.delegate messageCell:self didSelectedTextUnit:unit];
            }
        }
        else if (self.failedImageView.hidden == NO)
        {
            effectiveGesture = CGRectContainsPoint(self.failedImageView.frame, point);
            if (effectiveGesture)
            {
                //重发
                if ([self.delegate respondsToSelector:@selector(messageCellWillResend:)])
                {
                    [self.delegate messageCellWillResend:self];
                }
            }
        }
    }
    self.willSelectedTextUnit = nil;
    [super singleTap:singleTapGesture];
}

- (void)coreTextView:(CoreTextView *)coreTextView didSelected:(TextUnit *)textUnit
{
    self.willSelectedTextUnit = textUnit;
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTapGesture
{
    self.willSelectedTextUnit = nil;
    if (doubleTapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [doubleTapGesture locationInView:self.contentBaseView];
        
        BOOL effectiveGesture = CGRectContainsPoint(self.bubbleImageView.frame, point);
        
        if (effectiveGesture)
        {
            if ([self.delegate respondsToSelector:@selector(messageCellShouldFullScreen:)])
            {
                [self.delegate messageCellShouldFullScreen:self];
            }
        }
    }
    [super doubleTap:doubleTapGesture];
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture
{
    [super longPress:longPressGesture];
    if (self.willSelectedTextUnit.textUnitType != TextUnitTypeURL) {
        self.willSelectedTextUnit = nil;
    }
}

- (void)ybPopupMenuDidDismiss:(YBPopupMenu *)ybPopupMenu {
    self.willSelectedTextUnit = nil;
}

- (void)BurnTimeLabelChaged:(NSNotification *)not{
    NSArray *dataArr = not.object;
    MessageInfo *message = self.chatRecordDTO;
    NSString * msgID = [NSString stringWithFormat:@"%ld",message._id];
//    // 谓词搜索
//    NSPredicate *predmsgIde = [NSPredicate predicateWithFormat:@"_id CONTAINS[cd] %ld", msgID];
//    NSArray *searchArray = [dataArr filteredArrayUsingPredicate:predmsgIde];
//    if (searchArray && searchArray.count>0) {
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
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UIView *)translatePV{
    if (!_translatePV) {
        _translatePV = [[UIView alloc] init];
        _translatePV.backgroundColor = [UIColor colorBubbleOther];
        _translatePV.layer.cornerRadius = 5;
        _translatePV.clipsToBounds = YES;
    }
    return _translatePV;;
}

- (UILabel *)translateTL{
    if (!_translateTL) {
        _translateTL = [[UILabel alloc] init];
        _translateTL.numberOfLines = 0;
        
        _translateTL.textColor = XHQHexColor(0x333333);
        _translateTL.font = XHQFont(13);
    }
    return _translateTL;
}

- (UIActivityIndicatorView *)activityV{
    if (!_activityV) {
        _activityV = [[UIActivityIndicatorView alloc] init];
        [_activityV setBackgroundColor:[UIColor whiteColor]];
        _activityV.hidden = YES;
    }
    return _activityV;
}

- (UIButton *)tipBtn{
    if (!_tipBtn) {
        _tipBtn = [[UIButton alloc] init];
        [_tipBtn setImage:[UIImage imageNamed:@"icon_choose_sel"] forState:UIControlStateNormal];
        [_tipBtn setTitle:[NSString stringWithFormat:@"由 %@ 提供翻译支持".lv_localized, localAppName.lv_localized] forState:UIControlStateNormal];
        _tipBtn.userInteractionEnabled = NO;
        _tipBtn.titleLabel.font = XHQFont(12);
        [_tipBtn setTitleColor:XHQHexColor(0x777777) forState:UIControlStateNormal];
    }
    return _tipBtn;
}

@end
