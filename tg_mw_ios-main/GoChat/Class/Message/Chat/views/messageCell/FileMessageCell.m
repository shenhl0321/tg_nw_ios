//
//  FileMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "FileMessageCell.h"
#define File_Type_Icon_Width 50
#define File_Content_Height 75
#define File_Max_Content_Width SCREEN_WIDTH-140

@interface FileMessageCell()

@property (nonatomic, strong) IBOutlet UIImageView *failedImageView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *typeImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *readFlag;
@property (nonatomic, strong) UIButton * fireTimeBtn; //阅后即焚倒计时

@end

@implementation FileMessageCell
@dynamic delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnTimeLabelChaged:) name:@"BurnTimeLabelChaged" object:nil];
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
    height += MAX(File_Content_Height, MessageCellContentMinHeight);
    //下边距
    height += MessageCellVertMargins;

    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
}

- (void)reset
{
    [super reset];
    [self.indicatorView stopAnimating];
    [self.typeImageView removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.sizeLabel removeFromSuperview];
    [self.bgView removeFromSuperview];
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
    
    //bg
    self.bgView = [UIView new];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:self.bgView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedFile)];
    tap.numberOfTapsRequired = 1;
    [self.bgView addGestureRecognizer:tap];
    
    //icon
    self.typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, File_Type_Icon_Width, File_Type_Icon_Width)];
    self.typeImageView.image = [UIImage imageNamed:[DocumentInfo fileTypeIcon:self.chatRecordDTO.content.document.file_name]];
    [self.bubbleImageView addSubview:self.typeImageView];
    
    //title
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textColor = COLOR_C1;
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.text = self.chatRecordDTO.content.title;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.bubbleImageView addSubview:self.titleLabel];
    
    self.sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 15)];
    self.sizeLabel.textColor = COLOR_C2;
    self.sizeLabel.font = [UIFont systemFontOfSize:13];
    self.sizeLabel.text = self.chatRecordDTO.content.document.totalSize;
    self.sizeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.bubbleImageView addSubview:self.sizeLabel];
    
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
        
        //阅后即焚
        if (self.chatRecordDTO.fireTime.intValue>0) {
            [self.fireTimeBtn setTitle:[NSString stringWithFormat:@"%@s",self.chatRecordDTO.fireTime] forState:UIControlStateNormal];
            [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
            self.fireTimeBtn.hidden = NO;
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
    
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    //计算气泡宽度
    float maxDesContentWidth = 0;
    float typeLeftMargin = 0;
    float typeRightMargin = 8;
    float contentRightMargin = 15;
    if (self.chatRecordDTO.is_outgoing)
    {
        typeLeftMargin = 15;
    }
    else
    {
        typeLeftMargin = 20;
    }
    maxDesContentWidth = File_Max_Content_Width - typeLeftMargin - File_Type_Icon_Width - typeRightMargin - contentRightMargin;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font, NSFontAttributeName, nil];
    CGRect rc = [self.chatRecordDTO.content.title boundingRectWithSize:CGSizeMake(maxDesContentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    if(rc.size.height<20)
    {//单行
        float contentWidth = MAX(80, rc.size.width+1);
        frame.size.width = contentWidth + typeLeftMargin + File_Type_Icon_Width + typeRightMargin + contentRightMargin;
    }
    else
    {//多行
        frame.size.width = File_Max_Content_Width;
    }
    frame.size.height = File_Content_Height;
    self.bubbleImageView.frame = frame;
    self.bgView.frame = self.bubbleImageView.bounds;
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
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
        
        //提示图标
        frame = self.typeImageView.frame;
        frame.origin.x = typeLeftMargin;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height)/2;
        self.typeImageView.frame = frame;
        
        //标题
        frame = self.titleLabel.frame;
        frame.size.height = rc.size.height+1;
        frame.origin.x = self.typeImageView.frame.origin.x+self.typeImageView.frame.size.width+typeRightMargin;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height - 20)/2;
        frame.size.width = File_Max_Content_Width - frame.origin.x - contentRightMargin;
        self.titleLabel.frame = frame;
        
        //大小
        frame = self.sizeLabel.frame;
        frame.origin.x = self.titleLabel.frame.origin.x;
        frame.origin.y = self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5;
        frame.size.width = self.titleLabel.frame.size.width;
        self.sizeLabel.frame = frame;
        
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
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height-5;
        self.timeLabel.frame = frame;
        
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(self.bubbleImageView.frame.origin.x - 40, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
    }
    else
    {
        //提示图标
        frame = self.typeImageView.frame;
        frame.origin.x = typeLeftMargin;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height)/2;
        self.typeImageView.frame = frame;
        
        //标题
        frame = self.titleLabel.frame;
        frame.size.height = rc.size.height+1;
        frame.origin.x = self.typeImageView.frame.origin.x+self.typeImageView.frame.size.width+typeRightMargin;
        frame.origin.y = (self.bubbleImageView.frame.size.height - frame.size.height - 20)/2;
        frame.size.width = File_Max_Content_Width - frame.origin.x - contentRightMargin;
        self.titleLabel.frame = frame;
        
        //大小
        frame = self.sizeLabel.frame;
        frame.origin.x = self.titleLabel.frame.origin.x;
        frame.origin.y = self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5;
        frame.size.width = self.titleLabel.frame.size.width;
        self.sizeLabel.frame = frame;
                
        //时间
        self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-12;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height-5;
        self.timeLabel.frame = frame;
        
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+15, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
    }
    [super adjustFrame];
}

- (void)tapedFile
{
    if ([self.delegate respondsToSelector:@selector(messageCellShouldOpenFile:)])
    {
        [self.delegate messageCellShouldOpenFile:self];
    }
}

- (void)singleTap:(UITapGestureRecognizer *)singleTapGesture
{
    if (singleTapGesture.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [singleTapGesture locationInView:self.contentBaseView];
        
        BOOL effectiveGesture = CGRectContainsPoint(self.bubbleImageView.frame, point);
        
        if (self.failedImageView.hidden == NO)
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
            }
        }
    }
    [super singleTap:singleTapGesture];
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

@end
