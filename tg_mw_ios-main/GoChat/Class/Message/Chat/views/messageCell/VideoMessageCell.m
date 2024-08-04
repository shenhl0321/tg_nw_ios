//
//  VideoMessageCell.m
//  GoChat
//
//  Created by wangyutao on 2020/11/12.
//

#import "VideoMessageCell.h"
#import "ZyPlayerView.h"
#import "UIImageView+VideoThumbnail.h"
#import "PhotoImageView.h"

@interface VideoMessageCell()

@property (nonatomic, strong) ZyPlayerView *contentVideoView;

@property (nonatomic, strong) IBOutlet UIImageView *failedImageView;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) IBOutlet UIImageView *readFlag;

@property (nonatomic, strong) IBOutlet UIView *timeBg;
@property (weak, nonatomic) IBOutlet VideoContainer *videoContainer;

@property (nonatomic, strong) UIView *clearMaskView;

@property (nonatomic, strong) UIButton * fireTimeBtn; //阅后即焚倒计时

@property (nonatomic, strong) MessageSendProgress *sendProgress;

@end

@implementation VideoMessageCell
@dynamic delegate;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BurnTimeLabelChaged:) name:@"BurnTimeLabelChaged" object:nil];
        _clearMaskView = UIView.new;
        _sendProgress = [[MessageSendProgress alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _sendProgress.fontSize = 12;
        [self.contentView addSubview:_sendProgress];
        @weakify(self);
        [_clearMaskView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(messageCellShouldShowVideo:)]) {
                [self.delegate messageCellShouldShowVideo:self];
            }
        }];
    }
    return self;
}

+ (CGFloat)ScaleFromCompassToSize:(CGSize)toSize fromSize:(CGSize)fromSize {
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

+ (CGFloat)contentHeightForTableViewWith:(MessageInfo *)chatRecordDTO showNickName:(BOOL)showNickName {
    CGFloat videoContentHeight = 0.0f;
    CGFloat videoWidth = fabs(chatRecordDTO.content.video.width);
    CGFloat videoHeight = fabs(chatRecordDTO.content.video.height);
    if (videoWidth>0 && videoHeight>0) {
        videoContentHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX([self ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(videoWidth, videoHeight)]*videoHeight, 20));
    } else {
        videoContentHeight = MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT , MAX(MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT, 20));
    }
    
    CGFloat height = MessageCellVertMargins;
    if(!chatRecordDTO.is_outgoing && showNickName) {
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

- (void)reset {
    [super reset];
    [self.indicatorView stopAnimating];
    self.sendProgress.hidden = YES;
}

- (void)initialize {
    [super initialize];
    //失败
    self.failedImageView.hidden = YES;
    //状态
    self.statusLabel.hidden = YES;
    self.sendProgress.hidden = YES;
    //已发已读标志
    self.readFlag.hidden = YES;
    self.timeBg.hidden = YES;
    self.videoContainer.hidden = NO;
    if (![self.bubbleImageView.subviews containsObject:self.videoContainer]) {
        [self.bubbleImageView addSubview:self.videoContainer];
        [self.bubbleImageView addSubview:_clearMaskView];
    }
    
    /// 隐藏 indicatorView，替换 sendProgress
    self.indicatorView.alpha = 0;
    
    
#pragma mark - ************************************
    self.bubbleImageView.image = [UIImage imageNamed:@""];
    self.bubbleImageView.backgroundColor = [UIColor whiteColor];
}

- (void)config
{
    [super config];
    
    UIImage *coverImage = nil;
    if(self.chatRecordDTO.content.video.thumbnail != nil)
    {
        ThumbnailInfo *thumbnailInfo = self.chatRecordDTO.content.video.thumbnail;
        if(thumbnailInfo.isThumbnailDownloaded)
        {
            coverImage = [UIImage imageWithContentsOfFile:thumbnailInfo.file.local.path];
        }
    }

    CGRect contentFrame;
    CGFloat videoWidth = fabs(self.chatRecordDTO.content.video.width);
    CGFloat videoHeight = fabs(self.chatRecordDTO.content.video.height);
    if(videoWidth>0 && videoHeight>0)
    {
        CGFloat scale = [VideoMessageCell ScaleFromCompassToSize:CGSizeMake(MESSAGE_CELL_PHOTO_MAX_WIDTH, MESSAGE_CELL_PHOTO_MAX_HEIGHT) fromSize:CGSizeMake(videoWidth, videoHeight)];
        contentFrame = CGRectMake(0, 0, MIN(MAX(40, scale*videoWidth), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, scale*videoHeight)));
    }
    else
    {
        contentFrame = CGRectMake(0, 0, MIN(MAX(40, MESSAGE_CELL_PHOTO_DEFAULT_WIDTH), MESSAGE_CELL_PHOTO_MAX_WIDTH) , MIN(MESSAGE_CELL_PHOTO_MAX_HEIGHT, MAX(20, MESSAGE_CELL_PHOTO_DEFAULT_HEIGHT)));
    }

    self.videoContainer.frame = contentFrame;
    self.videoContainer.video = self.chatRecordDTO.content.video;
    
//    VideoInfo *videoInfo = self.chatRecordDTO.content.video;
//    self.contentVideoView = [[ZyPlayerView alloc] initWithFrame:contentFrame duration:videoInfo.duration totalLength:videoInfo.totalSize downloadLength:videoInfo.donwloadSize localPath:videoInfo.localVideoPath isSound:NO coverImage:coverImage placeHodlerImage:@"icon_player" completed:videoInfo.video.local.is_downloading_completed];
//    [self.bubbleImageView addSubview:self.contentVideoView];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        if (self.chatRecordDTO.sendState == MessageSendState_Pending)
        {
            self.failedImageView.hidden = YES;
            [self.indicatorView startAnimating];
            self.sendProgress.hidden = NO;
        }
        else if (self.chatRecordDTO.sendState == MessageSendState_Fail)
        {
            self.failedImageView.hidden = NO;
            self.sendProgress.hidden = YES;
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
}

- (void)adjustFrame
{
    CGRect frame = self.bubbleImageView.frame;
    frame.size.width = self.videoContainer.frame.size.width + 15;
    frame.size.height = self.videoContainer.frame.size.height + 10;
    self.bubbleImageView.frame = frame;
    
    //调整气泡坐标
    [self adjustBubblePosition];
    
    if (self.chatRecordDTO.is_outgoing)
    {
        //图片
        frame = self.videoContainer.frame;
        frame.origin.x = 5;//箭头在右边，所以内容区稍微偏左调
        frame.origin.y = 5;
        self.videoContainer.frame = frame;
        
        //进度
        if (self.indicatorView.hidden == NO)
        {
            frame = self.indicatorView.frame;
            frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame)- frame.size.width - 30;
            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
            self.indicatorView.frame = frame;
            self.sendProgress.frame = CGRectMake(frame.origin.x, frame.origin.y, 40, 40);
            
            CGAffineTransform transform = CGAffineTransformMakeScale(2, 2);
            self.indicatorView.transform = transform;
//            self.sendProgress.transform = transform;
        }
        
        //失败图标
        if (self.failedImageView.hidden == NO)
        {
            frame = self.failedImageView.frame;
            frame.origin.x = CGRectGetMinX(self.bubbleImageView.frame)- frame.size.width - 30;
            frame.origin.y = CGRectGetMidY(self.bubbleImageView.frame) - frame.size.height/2;
            self.failedImageView.frame = frame;
//            self.sendProgress.frame = frame;
            self.sendProgress.frame = CGRectMake(frame.origin.x, frame.origin.y, 40, 40);
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
        frame = self.videoContainer.frame;
        frame.origin.x = 10;//箭头在左边，所以内容区稍微偏右调
        frame.origin.y = 5;
        self.videoContainer.frame = frame;
        
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
    
    self.videoContainer.layer.masksToBounds = YES;
    self.videoContainer.layer.cornerRadius = 6;
    self.clearMaskView.frame = self.videoContainer.frame;
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
            if ([self.delegate respondsToSelector:@selector(messageCellShouldShowVideo:)])
            {
                [self.delegate messageCellShouldShowVideo:self];
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



//-(void)reloadVideoState:(NSNotification *)noti{
//    MessageInfo * msg = (MessageInfo *)noti.object;
//    if (msg._id == self.chatRecordDTO._id) {
////        self.chatRecordDTO = msg;
//        if (msg.content.video.video.local.is_downloading_completed) {
//            
//            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReloadVideoCell" object:nil];
//            [self reset];
//            [self config];
//            [self adjustFrame];
//        }else{
//            [self.contentVideoView reloadDownLoadState:msg.content.video];
//
//        }
//    }
//}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadVideoInfo:(VideoInfo *)video {
    /// 正在发送视频
    if (self.chatRecordDTO.is_outgoing && self.chatRecordDTO.sendState == MessageSendState_Pending) {
        CGFloat progress = video.video.remote.uploaded_size * 1.0 / video.video.expected_size;
        self.sendProgress.rate = progress * 100;
    }
    self.chatRecordDTO.content.video = video;
    [self.videoContainer reloadVideoInfo:video];
}

- (void)resetVideoThumbnail {
    [self.videoContainer resetVideoThumbnail];
}

@end

#pragma mark - VideoContainer

@interface VideoContainer ()

@property (nonatomic, strong) PhotoImageView *imageView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIView *sizeContainer;

@end

@implementation VideoContainer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupViews];
}

- (void)setupViews {
    _imageView = ({
        PhotoImageView *iv = [[PhotoImageView alloc] init];
        iv.userInteractionEnabled = NO;
        iv.tag = 10000;
        iv;
    });
    _playButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_player"] forState:UIControlStateNormal];
        btn.userInteractionEnabled = NO;
        btn;
    });
    _sizeContainer = ({
        UIView *view = UIView.new;
        view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
        [view xhq_cornerRadius:5];
        view;
    });
    _durationLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:10];
        label.text = @"01:12";
        label;
    });
    _sizeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:10];
        label.text = @"0B / 10MB";
        label;
    });
    [self addSubview:_imageView];
    [_imageView addSubview:_playButton];
    [self addSubview:_sizeContainer];
    [_sizeContainer addSubview:_durationLabel];
    [_sizeContainer addSubview:_sizeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(44);
    }];
    [_sizeContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(5);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(_sizeLabel.mas_bottom).offset(5);
        make.trailing.mas_equalTo(_sizeLabel.mas_trailing).offset(5);
    }];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.leading.mas_equalTo(5);
    }];
    [_sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_durationLabel);
        make.top.equalTo(_durationLabel.mas_bottom).offset(5);
    }];
}

- (void)setVideo:(VideoInfo *)video {
    _video = video;
    [_imageView setLocalThumbnailImage:video];
    if (video.isVideoDownloaded) {
        _sizeContainer.hidden = YES;
    } else {
        _sizeContainer.hidden = NO;
        _durationLabel.text = [NSString stringWithFormat:@"%@", [CZCommonTool getFormatTimeStrWith:video.duration]];
        _sizeLabel.text = [NSString stringWithFormat:@"%@ / %@", video.donwloadSize, video.totalSize];
    }
}

- (void)reloadVideoInfo:(VideoInfo *)video {
    _video = video;
    if (video.video.local.is_downloading_completed) {
        _sizeContainer.hidden = YES;
    } else {
        _sizeContainer.hidden = NO;
        _durationLabel.text = [NSString stringWithFormat:@"%@", [CZCommonTool getFormatTimeStrWith:video.duration]];
        _sizeLabel.text = [NSString stringWithFormat:@"%@ / %@", video.donwloadSize, video.totalSize];
    }
}

- (void)resetVideoThumbnail {
    [_imageView setThumbnailImage:_video];
}

@end

@interface MessageSendProgress ()

{
    CGFloat _startAngle; // 开始的角度
    NSInteger _startRate;
    
}
//   半径r
@property(nonatomic,assign) CGFloat rWidth;
//    显示圆的边缘图层
@property(nonatomic,strong) CAShapeLayer *shapeLayer;
//    定时器
@property(nonatomic,strong) CADisplayLink *displayLink;
//     显示圆的路径
@property(nonatomic,strong) UIBezierPath *bPath;
//      显示Lab
@property (nonatomic, strong) UILabel *rateLbl;

@end

static NSInteger const LineWidth = 2;

@implementation MessageSendProgress

- (instancetype)initWithFrame:(CGRect)frame {
    self =  [super initWithFrame:frame];
    if (self) {
        _startAngle = -90; // 从圆的最顶部开始
        _rWidth = frame.size.width;
        _bPath = [UIBezierPath bezierPath];
        // 先画一个底部的圆
        [self configBgCircle];
        // 配置CAShapeLayer
        [self configShapeLayer];
        // 配置CADisplayLink
        [self configDisplayLink];
        // label
        [self configLab];
    }
    return self;
    
}

#pragma mark - 底下灰色的圆(辅助圆)
- (void)configBgCircle {
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:(CGPoint){self.bounds.size.width *0.5,self.bounds.size.height *0.5} radius:_rWidth * 0.5 startAngle:0 endAngle:360 clockwise:YES];
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.lineWidth = LineWidth;
    shaperLayer.strokeColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.5].CGColor;
    shaperLayer.fillColor = nil;
    shaperLayer.path = bPath.CGPath;
    [self.layer addSublayer:shaperLayer];
}

#pragma mark 配置CAShaperLayer(用于显示圆)
- (void)configShapeLayer {
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.lineWidth = LineWidth;
    _shapeLayer.strokeColor = [UIColor xhq_base].CGColor;
    _shapeLayer.fillColor = nil;
    [self.layer addSublayer:_shapeLayer];
}

#pragma mark 配置CADisplayLink
- (void)configDisplayLink {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawCircle)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES; //  默认暂停
}

#pragma mark - 中间显示数字的Label
- (void)configLab {
    UILabel *lab = [[UILabel alloc] initWithFrame:self.bounds];
    _rateLbl = lab;
    lab.font = [UIFont systemFontOfSize:6];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor xhq_base];
    lab.text = @"0%";
    [self addSubview:lab];
}

#pragma mark - event response
- (void)drawCircle {
    CGFloat angle = _rate * 3.6 - 90;
    _rateLbl.text = [NSString stringWithFormat:@"%ld%%", _rate];
    
    [_bPath addArcWithCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_rWidth * 0.5  startAngle:(M_PI /180.0) *_startAngle endAngle:(M_PI /180.0) *angle clockwise:YES];
    _shapeLayer.path = _bPath.CGPath;
    _startAngle = angle;
}

#pragma mark - public methods
- (void)startAnimation {
    if (_displayLink.paused == YES) {
        _startAngle = -90;
        _startRate = 0;
        _displayLink.paused = NO;
    }
}

#pragma mark - getter/setter
- (void)setRate:(NSInteger)rate {
    if (rate <= 0 || rate > 100) {
        rate = 100;
    } else {
        _rate = rate;
    }
    [self drawCircle];
}

- (void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    _rateLbl.font = [UIFont systemFontOfSize:fontSize];
}

@end

