//
//  PhotoMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "PhotoMessageCell.h"

@interface PhotoMessageCell()

@property (nonatomic, strong) IBOutlet UIImageView *contentImageView;

@property (nonatomic, strong) IBOutlet UIImageView *failedImageView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) IBOutlet UIImageView *readFlag;

@property (nonatomic, strong) IBOutlet UIView *timeBg;

@property (nonatomic, strong) UIButton * fireTimeBtn; //阅后即焚倒计时

@end

@implementation PhotoMessageCell
@dynamic delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnTimeLabelChaged:) name:@"BurnTimeLabelChaged" object:nil];
    }
    return self;
}
+ (CGFloat)ScaleFromCompassToSize:(CGSize)toSize fromSize:(CGSize)fromSize
{
    float scale = 1.0f;
    if (fromSize.width >= fromSize.height)
    {
        if (fromSize.width > toSize.width)
        {
            scale =  toSize.width / fromSize.width;
        }
    }
    else if (fromSize.height > fromSize.width)
    {
        if (fromSize.height > toSize.height)
        {
            scale =  toSize.height / fromSize.height;
        }
    }
    return scale;
}

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName
{
    CGFloat photoHeight = 0.0f;
    UIImage *image = nil;
    PhotoSizeInfo *photoInfo = chatRecordDTO.content.photo.messagePhoto;
    if(photoInfo != nil && photoInfo.isPhotoDownloaded)
    {
        image = [UIImage imageWithContentsOfFile:photoInfo.photo.local.path];
    }
    if (!image)
    {
        if(photoInfo.width>0 && photoInfo.height>0)
        {
            photoHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX([self ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(photoInfo.width, photoInfo.height)]*photoInfo.height, 20));
        }
        else
        {
            photoHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX(MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT, 20));
        }
    }
    else
    {
        photoHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX([self ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(image.size.width, image.size.height)]*image.size.height, 20));
    }
    
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName)
    {
        //昵称高度
        height += MessageCellNicknameHeight;
    }
    //气泡高度
    height += MAX(photoHeight + 10, MessageCellContentMinHeight);
    //时间高度
    //height += MessageCellTimestampRegionHeight;
    //下边距
    height += MessageCellVertMargins;

    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
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

- (void)reset
{
    [super reset];
    
    [self.indicatorView stopAnimating];
    
    [self.contentImageView removeFromSuperview];
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
}

- (void)config
{
    [super config];
    
    UIImage *image = nil;
    PhotoSizeInfo *photoInfo = self.chatRecordDTO.content.photo.messagePhoto;
    if(photoInfo != nil && photoInfo.isPhotoDownloaded)
    {
        image = [UIImage imageWithContentsOfFile:photoInfo.photo.local.path];
    }
    
    CGRect imageFrame;
    if (!image)
    {
        //计算frame
        if(photoInfo.width>0 && photoInfo.height>0)
        {
            CGFloat scale = [PhotoMessageCell ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(photoInfo.width, photoInfo.height)];
            imageFrame = CGRectMake(0, 0, MIN(MAX(40, scale*photoInfo.width), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, scale*photoInfo.height)));
        }
        else
        {
            imageFrame = CGRectMake(0, 0, MIN(MAX(40, MESSAGE_CELL_PHOTO_DEFAULT_WIDTH), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT)));
        }
        
        CGFloat defaultContentWidth = MIN(imageFrame.size.width, imageFrame.size.height);
        if(defaultContentWidth>120)
            defaultContentWidth = 80;
        else
            defaultContentWidth -= 40;
        CGFloat defaultContentHeight = defaultContentWidth;

        //原始图片
        UIImage *defaultImage = [Common createImageWithColor:RGBA(214, 214, 214, 1) size:imageFrame.size];
        UIImage *defaultContentImage = [UIImage imageNamed:@"image_default_2"];
        //图片叠加
        UIGraphicsBeginImageContext(defaultImage.size);
        [defaultImage drawInRect:CGRectMake(0, 0, defaultImage.size.width, defaultImage.size.height)];
        [defaultContentImage drawInRect:CGRectMake((defaultImage.size.width - defaultContentWidth)/2, (defaultImage.size.height - defaultContentHeight)/2, defaultContentWidth, defaultContentHeight)];
        UIImage *resultingDefaultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = resultingDefaultImage;
        self.contentImageView.image = image;
    }
    else
    {
        self.contentImageView.image = image;
        CGFloat scale = [PhotoMessageCell ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(image.size.width, image.size.height)];
        imageFrame = CGRectMake(0, 0, MIN(MAX(40, image.size.width*scale), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, image.size.height*scale)));
    }

    //在图片高度相当小或者相当大的情况下的调整
    self.contentImageView.frame = imageFrame;
    [self.bubbleImageView addSubview:self.contentImageView];
    
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
    frame.size.width = self.contentImageView.frame.size.width + 15;
    frame.size.height = self.contentImageView.frame.size.height + 10;
    self.bubbleImageView.frame = frame;
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        //图片
        frame = self.contentImageView.frame;
        frame.origin.x = 5;//箭头在右边，所以内容区稍微偏左调
        frame.origin.y = 5;
        self.contentImageView.frame = frame;
        
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
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-16;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height-10;
        self.readFlag.frame = frame;
        
        //时间
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.timeLabel.layer setMasksToBounds:YES];
        [self.timeLabel.layer setCornerRadius:8];
        frame = self.timeLabel.frame;
        frame.size.width = 36;
        frame.size.height = 16;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width - 18 - (self.readFlag.hidden?0:self.readFlag.frame.size.width);
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height - 10;
        self.timeLabel.frame = frame;
        
//        self.timeBg.backgroundColor = RGBA(0, 0, 0, 0.5);
//        frame = self.timeBg.frame;
//        frame.size.height = 20;
//        frame.size.width = (self.readFlag.hidden?0:self.readFlag.frame.size.width)+self.timeLabel.frame.size.width+2+8;
//        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width - 12;
//        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height - 8;
//        [self.timeBg.layer setMasksToBounds:YES];
//        [self.timeBg.layer setCornerRadius:frame.size.height/2];
//        self.timeBg.frame = frame;
        
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(self.bubbleImageView.frame.origin.x - 40, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
        [self.fireTimeBtn setImagePosition:LXMImagePositionTop spacing:0];
        
    }
    else
    {
        //图片
        frame = self.contentImageView.frame;
        frame.origin.x = 10;//箭头在左边，所以内容区稍微偏右调
        frame.origin.y = 5;
        self.contentImageView.frame = frame;
        
        //失败图标
//        if (self.failedImageView.hidden == NO)
//        {
//            frame = self.failedImageView.frame;
//            frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) + 10;
//            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
//            self.failedImageView.frame = frame;
//        }
        
        //时间
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.backgroundColor = RGBA(0, 0, 0, 0.5);
        [self.timeLabel.layer setMasksToBounds:YES];
        [self.timeLabel.layer setCornerRadius:8];
        frame = self.timeLabel.frame;
        frame.size.width = 36;
        frame.size.height = 16;
        frame.origin.x = CGRectGetMaxX(self.bubbleImageView.frame) - frame.size.width-10;
        frame.origin.y = CGRectGetMaxY(self.bubbleImageView.frame) - frame.size.height-10;
        self.timeLabel.frame = frame;
        //阅后即焚
        self.fireTimeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.fireTimeBtn.frame = CGRectMake(CGRectGetMaxX(self.bubbleImageView.frame)+15, self.bubbleImageView.frame.origin.y+self.bubbleImageView.frame.size.height*0.5-25, 30, 50);
    }
    
//    frame = self.progressBgView.frame;
//    frame.origin = CGPointZero;
//    frame.size = self.contentImageView.frame.size;
//    self.progressBgView.frame = frame;
    
    self.contentImageView.layer.masksToBounds = YES;
    self.contentImageView.layer.cornerRadius = 6;
    
    [super adjustFrame];
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
            if ([self.delegate respondsToSelector:@selector(messageCellShouldShowImage:)])
            {
                [self.delegate messageCellShouldShowImage:self];
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
