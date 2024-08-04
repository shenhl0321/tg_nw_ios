//
//  CallMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2021/03/19.
//

#import "CallMessageCell.h"

@interface CallMessageCell()
@property (nonatomic, strong) UIImageView *callIcon;
@property (nonatomic, strong) UILabel *callStateDesLabel;
@end

@implementation CallMessageCell
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
    height += MessageCellContentMinHeight;
    //时间高度
    //height += MessageCellTimestampRegionHeight;
    //下边距
    height += MessageCellVertMargins;
    
    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
}

- (void)reset
{
    [super reset];
    [self.callIcon removeFromSuperview];
    [self.callStateDesLabel removeFromSuperview];
}

- (void)initialize
{
    [super initialize];
}

- (void)config
{
    [super config];
    
    //icon
    self.callIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    if(self.chatRecordDTO.callInfo.isVideo)
    {
        self.callIcon.image = [UIImage imageNamed:@"call_message_video"];
    }
    else
    {
        self.callIcon.image = [UIImage imageNamed:@"call_message_voice"];
    }
    [self.bubbleImageView addSubview:self.callIcon];
    
    //state des
    self.callStateDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.callStateDesLabel.textColor = [UIColor blackColor];
    self.callStateDesLabel.font = [UIFont systemFontOfSize:15];
    self.callStateDesLabel.text = [self.chatRecordDTO.callInfo displayDetailDesc];
    self.callStateDesLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
    [self.bubbleImageView addSubview:self.callStateDesLabel];
    
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    //计算des实际宽度
    NSString *callStateDes = [self.chatRecordDTO.callInfo displayDetailDesc];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:self.callStateDesLabel.font, NSFontAttributeName, nil];
    CGRect rc = [callStateDes boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat desWidth = rc.size.width+5;
    frame.size.width = desWidth+20+25;
    frame.size.height = MessageCellContentMinHeight;
    self.bubbleImageView.frame = frame;
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        self.callIcon.frame = CGRectMake(10, (self.bubbleImageView.frame.size.height - 20)/2-4, 20, 20);
        self.callStateDesLabel.frame = CGRectMake(35, (self.bubbleImageView.frame.size.height - 20)/2-4, desWidth, 20);
        
        //时间
        self.timeLabel.textColor = HEX_COLOR(@"#999999");
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width - 10;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
    }
    else
    {
        self.callIcon.frame = CGRectMake(15, (self.bubbleImageView.frame.size.height - 20)/2-4, 20, 20);
        self.callStateDesLabel.frame = CGRectMake(40, (self.bubbleImageView.frame.size.height - 20)/2-4, desWidth, 20);
        
        //时间
        self.timeLabel.textColor = HEX_COLOR(@"#999999");
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        frame = self.timeLabel.frame;
        frame.size.width = 35;
        frame.size.height = 15;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-5;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height;
        self.timeLabel.frame = frame;
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
            if ([self.delegate respondsToSelector:@selector(messageCellShouldCall:)])
            {
                [self.delegate messageCellShouldCall:self];
            }
        }
    }
    [super singleTap:singleTapGesture];
}

@end
