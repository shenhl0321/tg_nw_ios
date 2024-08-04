//
//  VideoMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "AnimationTableViewCell.h"
#import "ZyPlayerView.h"
#import "FLAnimatedImage.h"
@interface AnimationTableViewCell()

@property (nonatomic, strong) ZyPlayerView *contentVideoView;

@property (nonatomic, strong) IBOutlet UIImageView *failedImageView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) IBOutlet UIImageView *readFlag;

@property (nonatomic, strong) IBOutlet UIView *timeBg;
/// <#code#>
@property (nonatomic, strong) FLAnimatedImageView *gifPlayV;

@end

@implementation AnimationTableViewCell
@dynamic delegate;

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
    CGFloat videoContentHeight = 0.0f;
    CGFloat videoWidth = fabs(chatRecordDTO.content.animation.width);
    CGFloat videoHeight = fabs(chatRecordDTO.content.animation.height);
    if(videoWidth>0 && videoHeight>0)
    {
        videoContentHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX([self ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(videoWidth, videoHeight)]*videoHeight, 20));
    }
    else
    {
        videoContentHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX(MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT, 20));
    }
    
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName)
    {
        //昵称高度
        height += MessageCellNicknameHeight;
    }
    //气泡高度
    height += MAX(videoContentHeight + 10, MessageCellContentMinHeight);
    //时间高度
    //height += MessageCellTimestampRegionHeight;
    //下边距
    height += MessageCellVertMargins;
    return [super contentHeightForTableViewWith:chatRecordDTO showNickName:showNickName]+height;
}

- (void)reset
{
    [super reset];
    [self.indicatorView stopAnimating];
    [self.contentVideoView removeFromSuperview];
    self.contentVideoView = nil;
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
    
    UIImage *coverImage = nil;
    if(self.chatRecordDTO.content.animation.thumbnail != nil)
    {
        ThumbnailInfo *thumbnailInfo = self.chatRecordDTO.content.animation.thumbnail;
        if(thumbnailInfo.isThumbnailDownloaded)
        {
            coverImage = [UIImage imageWithContentsOfFile:thumbnailInfo.file.local.path];
        }
    }
    if (!coverImage) {
//        coverImage = [UIImage imageNamed:@"NavLogo"];
    }

    CGRect contentFrame;
    CGFloat videoWidth = fabs(self.chatRecordDTO.content.animation.width);
    CGFloat videoHeight = fabs(self.chatRecordDTO.content.animation.height);
    if(videoWidth>0 && videoHeight>0)
    {
        CGFloat scale = [AnimationTableViewCell ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(videoWidth, videoHeight)];
        contentFrame = CGRectMake(0, 0, MIN(MAX(40, scale*videoWidth), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, scale*videoHeight)));
    }
    else
    {
        contentFrame = CGRectMake(0, 0, MIN(MAX(40, MESSAGE_CELL_PHOTO_DEFAULT_WIDTH), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT)));
    }

    
    AnimationInfo *videoInfo = self.chatRecordDTO.content.animation;
    NSString *path = videoInfo.localVideoPath;
    

    
    self.contentVideoView = [[ZyPlayerView alloc] initWithFrame:contentFrame duration:videoInfo.duration totalLength:videoInfo.totalSize downloadLength:videoInfo.donwloadSize localPath:path isSound:NO coverImage:coverImage placeHodlerImage:@"gif_holder" completed:videoInfo.animation.local.is_downloading_completed];
    [self.bubbleImageView addSubview:self.contentVideoView];
    
    
    if ([path hasSuffix:@".gif"]) {
        NSData *imageData = [NSData dataWithContentsOfFile:path];

        FLAnimatedImage *fadImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
        self.gifPlayV.animatedImage = fadImage;
        self.gifPlayV.hidden = NO;
        self.contentVideoView.hidden = YES;
    } else {
        self.gifPlayV.hidden = YES;
        self.contentVideoView.hidden = NO;
    }
    

    [self.bubbleImageView addSubview:self.gifPlayV];
    
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
    }
    
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    frame.size.width = self.contentVideoView.frame.size.width + 15;
    frame.size.height = self.contentVideoView.frame.size.height + 10;
    self.bubbleImageView.frame = frame;
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        //图片
        frame = self.contentVideoView.frame;
        frame.origin.x = 5;//箭头在右边，所以内容区稍微偏左调
        frame.origin.y = 5;
        self.contentVideoView.frame = frame;
        self.gifPlayV.frame = frame;
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
    }
    else
    {
        //图片
        frame = self.contentVideoView.frame;
        frame.origin.x = 10;//箭头在左边，所以内容区稍微偏右调
        frame.origin.y = 5;
        self.contentVideoView.frame = frame;
        self.gifPlayV.frame = frame;
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
    }
    
//    frame = self.progressBgView.frame;
//    frame.origin = CGPointZero;
//    frame.size = self.contentImageView.frame.size;
//    self.progressBgView.frame = frame;
    
    self.contentVideoView.layer.masksToBounds = YES;
    self.contentVideoView.layer.cornerRadius = 6;
    
    [super adjustFrame];
}

- (NSArray *)menuItems;
{
    NSMutableArray *menuItems = [NSMutableArray array];
    [menuItems addObject:[ChatMenu menuWithTitle:@"添加表情".lv_localized icon:@"menu_emoji" action:@selector(addEmoji:)]];
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
            if ([self.delegate respondsToSelector:@selector(messageCellShouldShowAnimation:)])
            {
                [self.delegate messageCellShouldShowAnimation:self];
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

//addEmoji
- (void)addEmoji:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(messageCellAddEmoji:)]) {
        [self.delegate messageCellAddEmoji:self];
    }
}

- (UIImageView *)gifPlayV{
    if (!_gifPlayV) {
        _gifPlayV = [[FLAnimatedImageView alloc] init];
    }
    return _gifPlayV;
}

@end
