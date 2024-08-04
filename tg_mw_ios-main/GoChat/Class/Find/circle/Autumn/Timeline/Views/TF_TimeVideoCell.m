//
//  TF_TimeVideoCell.m
//  GoChat
//
//  Created by apple on 2022/2/9.
//

#import "TF_TimeVideoCell.h"
#import "UIButton+ImageTitleStyle.h"
#import "ZFSliderView.h"
#import "TimelineHelper.h"
#import "UserinfoHelper.h"
#import "UIImageView+VideoThumbnail.h"
#import "UserTimelineVC.h"

#import "MMPopupItem.h"
#import "MMPopupWindow.h"
#import "MMSheetView.h"
#import "ChatChooseViewController.h"
@interface TF_TimeVideoCell()<BusinessListenerProtocol, ChatChooseViewControllerDelegate>

/// 封面图片
@property (nonatomic, strong) UIImageView *coverImgView;

/// <#code#>
@property (nonatomic,strong) UIView *contentPV;
/// 内容
@property (nonatomic, strong) UILabel *contentL;


/// 点赞
@property (nonatomic, strong) UIButton *likeBtn;
/// 评论
@property (nonatomic, strong) UIButton *commentBtn;
/// 暂赏按钮
@property (nonatomic,strong) UIButton *rewardBtn;
/// 更多按钮
@property (nonatomic,strong) UIButton *moreBtn;
/// 展开按钮
@property (nonatomic,strong) UIButton *expandBtn;
/// 旋转按钮
@property (nonatomic, strong) UIButton *rotation;
@end

@implementation TF_TimeVideoCell

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.coverImgView];
             
        [BusinessFramework.defaultBusinessFramework registerBusinessListener:self];
        
        [self.contentView addSubview:self.likeBtn];
        [self.contentView addSubview:self.commentBtn];
//        [self.contentView addSubview:self.rewardBtn];
        [self.contentView addSubview:self.moreBtn];
        [self.contentView addSubview:self.expandBtn];
        
        [self.contentView addSubview:self.contentPV];
        [self.contentPV addSubview:self.contentL];
        
        [self.contentView addSubview:self.rotation];
        
        CGFloat bottomM = kBottomSafeHeight + 40;
        
        
        [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.contentPV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(-65);
            make.bottom.mas_equalTo(-bottomM-20);
//            make.height.mas_greaterThanOrEqualTo(40);
        }];
        
        [self.contentL mas_makeConstraints:^(MASConstraintMaker *make) {\
            make.left.mas_equalTo(15);
            make.top.right.bottom.mas_equalTo(self.contentPV);
        }];
        
        [self.expandBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-bottomM - 13);
            make.right.mas_equalTo(-15);
            make.width.height.mas_equalTo(kAdapt(39));
        }];
        
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(self.expandBtn.mas_top).mas_offset(-kAdapt(90));
            make.width.height.mas_equalTo(kAdapt(39));
        }];
        
        [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.mas_equalTo(self.moreBtn);
            make.bottom.mas_equalTo(self.moreBtn.mas_top).mas_offset(-20);
            make.height.mas_equalTo(kAdapt(70));
        }];
        
//        [self.rewardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.width.centerX.height.mas_equalTo(self.commentBtn);
//            make.bottom.mas_equalTo(self.commentBtn.mas_top).mas_offset(-20);
//        }];
        
        [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.height.mas_equalTo(self.commentBtn);
            make.bottom.mas_equalTo(self.commentBtn.mas_top).mas_offset(-20);
        }];
        
        [self.rotation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.width.height.mas_equalTo(50);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        
       
    }
    return self;
}

- (void)rotationClick {
    if (self.rotationCall) {
        self.rotationCall();
    }
}

- (void)setBlog:(BlogInfo *)blog{
    _blog = blog;
    if (IsStrEmpty(blog.text)) {
        self.contentPV.hidden = YES;
        self.expandBtn.hidden = YES;
    } else {
        [self changeContentHeight:3];
        self.contentL.text = blog.text;
        self.contentPV.hidden = NO;
    }
    
    
    [self.commentBtn setTitle:[NSString stringWithFormat:@"%ld", blog.reply_count] forState:UIControlStateNormal];
    [self.commentBtn setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", blog.like_count] forState:UIControlStateNormal];
    [self.likeBtn setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
//    [self.rewardBtn setTitle:[NSString stringWithFormat:@"%.2f", blog.rewarded] forState:UIControlStateNormal];
//    [self.rewardBtn setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    
    
    self.likeBtn.selected = blog.liked;
    if (blog.content.isVideoContent) { // 视频
        [self.coverImgView setThumbnailImage:blog.content.video];
        if (blog.content.video.width > blog.content.video.height) {
            self.rotation.hidden = NO;
        } else {
            self.rotation.hidden = YES;
        }
    } else { // 图片
        self.rotation.hidden = YES;
        PhotoInfo *photo = blog.content.photos[self.imageIndex];
        if (!photo.messagePhoto) {
            self.coverImgView.image = [UIImage imageNamed:@"image_default_2"];
            return;
        }
        if (!photo.messagePhoto.isPhotoDownloaded) {
            [self downloadImage:photo.messagePhoto.photo._id];
            return;
        }
        self.coverImgView.image = [UIImage imageWithContentsOfFile:photo.messagePhoto.photo.local.path];
    }
}

- (void)downloadImage:(long)ids {
    if([[TelegramManager shareInstance] isFileDownloading:ids type:FileType_Message_Photo]) {
        return;
    }
    NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", ids];
    [[FileDownloader instance] downloadImage:key fileId:ids type:FileType_Message_Photo];
}

- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Td_Message_Photo_Ok): {
            NSDictionary *obj = inParam;
            if (!obj || ![obj isKindOfClass:NSDictionary.class]) {
                return;
            }
            FileTaskInfo *task = [obj objectForKey:@"task"];
            FileInfo *fileInfo = [obj objectForKey:@"file"];
            if (!task || !fileInfo) {
                return;
            }
            PhotoInfo *photo = self.blog.content.photos[self.imageIndex];
            
            NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", photo.messagePhoto.photo._id];
            if ([key isEqualToString:task._id]) {
                photo.messagePhoto.photo = fileInfo;
                if (!photo.messagePhoto.isPhotoDownloaded) {
                    [self downloadImage:photo.messagePhoto.photo._id];
                    return;
                }
                self.coverImgView.image = [UIImage imageWithContentsOfFile:photo.messagePhoto.photo.local.path];
            }
        }
            break;
        default:
            break;
    }
}


- (void)resetVideoThumbnail{
    [self.coverImgView setThumbnailImage:self.blog.content.video];
}


//保存到相册
- (void)saveToAlbum
{
    
    if(self.blog.content.isPhotoContent)
    {
        NSString *localPath = [self imagePath];
        if(!IsStrEmpty(localPath))
        {
            UIImage *image = [UIImage imageWithContentsOfFile:localPath];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        else
        {
            [UserInfo showTips:nil des:@"图片未准备好，无法保存到相册".lv_localized];
        }
    } else if (self.blog.content.isVideoContent) {
        NSString *localPath = [self videoPath];
        if(!IsStrEmpty(localPath))
        {
            UISaveVideoAtPathToSavedPhotosAlbum(localPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
        else
        {
            [UserInfo showTips:nil des:@"视频未准备好，无法保存到相册".lv_localized];
        }
    }
    
    
    
    
}
//文件分享
- (void)share {
    
    if(self.blog.content.isPhotoContent)
    {
        NSString *localPath = [self imagePath];
        if(!IsStrEmpty(localPath))
        {
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Image", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
            [self.xhq_currentController presentViewController:activityViewController animated:YES completion:nil];
        }
        else
        {
            [UserInfo showTips:nil des:@"图片未准备好，无法分享".lv_localized];
        }
    } else if (self.blog.content.isVideoContent) {
        NSString *localPath = [self videoPath];
        if(!IsStrEmpty(localPath))
        {
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Video", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
            [self.xhq_currentController presentViewController:activityViewController animated:YES completion:nil];
        }
        else
        {
            [UserInfo showTips:nil des:@"视频未准备好，无法分享".lv_localized];
        }
    }
    
    
}
// 转发
- (void)forward {
    
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
    chooseView.delegate = self;
    [self.xhq_currentController.navigationController pushViewController:chooseView animated:YES];
    
}

// 收藏
- (void)collect {
    
    [UserInfo show];
    NSDictionary *parameters = [self msgParametersWithId:@(UserInfo.shareInstance._id)];
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if ([TelegramManager isResultError:response]) {
            [UserInfo showTips:nil des:[TelegramManager errorMsg:response]];
            return;
        }
        [UserInfo showTips:nil des:@"收藏成功".lv_localized];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"收藏失败".lv_localized];
    }];
}






- (NSString *)videoPath
{
    
    VideoInfo *videoInfo = self.blog.content.video;
    if(videoInfo.isVideoDownloaded)
    {
        return videoInfo.localVideoPath;
    }
    return nil;
}

- (NSString *)imagePath
{
    PhotoInfo *photo = self.blog.content.photos[self.imageIndex];
    PhotoSizeInfo *b_photoInfo = photo.previewPhoto;
    if(b_photoInfo != nil && b_photoInfo.isPhotoDownloaded)
    {//首先加载大图
        return b_photoInfo.photo.local.path;
    }
    else
    {//大图没有下载，则加载小图
        PhotoSizeInfo *s_photoInfo = photo.messagePhoto;
        if(s_photoInfo != nil && s_photoInfo.isPhotoDownloaded)
        {
            return s_photoInfo.photo.local.path;
        }
    }
    return nil;
}



- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error)
    {
        [UserInfo showTips:nil des:@"已保存".lv_localized];
    }
    else
    {
        [UserInfo showTips:nil des:@"保存失败".lv_localized];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(!error)
    {
        [UserInfo showTips:nil des:@"已保存".lv_localized];
    }
    else
    {
        [UserInfo showTips:nil des:@"保存失败".lv_localized];
    }
}


#pragma mark ChatChooseViewControllerDelegate
// 群发
- (void)ChatChooseViewController_Chats_ChooseArr:(NSArray *)chatArr msg:(NSArray *)msgs{
    for (int i=0; i<chatArr.count; i++) {
        id chat = chatArr[i];
        [self ChatChooseViewController_Chat_Choose:chat msg:msgs];
    }
}

- (void)ChatChooseViewController_Chat_Choose:(id)chat msg:(NSArray *)msgs {
    [UserInfo show];
    @weakify(self);
    [self chatIdFromChooseChat:chat result:^(long chatId) {
        @strongify(self);
        if (chatId == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取聊天信息失败".lv_localized];
            return;
        }
        NSDictionary *parameters = [self msgParametersWithId:@(chatId)];
        [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if ([TelegramManager isResultError:response]) {
                [UserInfo showTips:nil des:[TelegramManager errorMsg:response]];
                return;
            }
            [UserInfo showTips:nil des:@"转发成功".lv_localized];
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"转发失败".lv_localized];
        }];
    }];
}

- (void)chatIdFromChooseChat:(id)chat result:(void(^)(long))result {
    if ([chat isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chatinfo = chat;
        !result ? :result(chatinfo._id);
        return;
    }
    UserInfo *user = chat;
    [[TelegramManager shareInstance] createPrivateChat:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
            ChatInfo *chatinfo = obj;
            !result ? :result(chatinfo._id);
            return;
        }
        !result ? :result(0);
    } timeout:^(NSDictionary *request) {
        !result ? :result(0);
    }];
}

- (NSDictionary *)msgParametersWithId:(NSNumber *)chatId {
    NSDictionary *content = nil;
    if (self.blog.content.isPhotoContent) {
        content = [self photoRemoteContent:self.blog.content.photos[self.imageIndex]];
    } else {
        content = [self videoRemoteContent:self.blog.content.video];
    }
    
    return @{
        @"@type" : @"sendMessage",
        @"chat_id" : chatId,
        @"input_message_content": content
    };
}



- (NSDictionary *)photoRemoteContent:(PhotoInfo *)photo{
    NSDictionary *photoDic = @{
        @"@type" : @"inputFileRemote",
        @"id" : photo.previewPhoto.photo.remote._id ? : @""
    };
    return @{
        @"@type" : @"inputMessagePhoto",
        @"width" : [NSNumber numberWithInt:fabs(photo.previewPhoto.width)],
        @"height" : [NSNumber numberWithInt:fabs(photo.previewPhoto.height)],
        @"photo" : photoDic
    };
}

- (NSDictionary *)videoRemoteContent:(VideoInfo *)videoInfo {
    NSDictionary *thumbnailFile = @{
        @"@type" : @"inputFileRemote",
        @"id" : videoInfo.thumbnail.file.remote._id ? : @""
    };
    NSDictionary *thumbnail = @{
        @"@type": @"inputThumbnail",
        @"thumbnail": thumbnailFile,
        @"width": @(videoInfo.width),
        @"height": @(videoInfo.height),
    };
    NSDictionary *video = @{
        @"@type" : @"inputFileRemote",
        @"id" : videoInfo.video.remote._id ? : @""
    };
    return @{
        @"@type" : @"inputMessageVideo",
        @"thumbnail" : thumbnail,
        @"video" : video,
        @"width" : @(videoInfo.width),
        @"height" : @(videoInfo.height),
        @"duration" : @(videoInfo.duration)
    };
}

#pragma mark - Action



//
- (void)commentClick:(id)sender {

    if (self.commentCall) {
        self.commentCall(self.blog);
    }
}
//
- (void)likeClick:(UIButton *)sender {

    __block NSInteger count = self.blog.like_count;
    sender.selected = !sender.isSelected;
    self.blog.liked = sender.isSelected;
    sender.isSelected ? count ++ : count --;
    count = MAX(count, 0);
    
    [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", count] forState:UIControlStateNormal];
    [self.likeBtn setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
    @weakify(self)
    [TimelineHelper likeBlog:self.blog.ids isLike:sender.isSelected completion:^(BOOL success) {
        if (!success) {
            @strongify(self)
            sender.selected = !sender.isSelected;
            self.blog.liked = sender.isSelected;
            sender.isSelected ? count ++ : count --;
            [self.likeBtn setTitle:[NSString stringWithFormat:@"%ld", count] forState:UIControlStateNormal];
            [self.likeBtn setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:10];
        }
    }];
}

- (void)rewardClick:(UIButton *)btn{
    
}

- (void)moreClick:(UIButton *)btn{
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index == 0) {
            [self saveToAlbum];
        } else if (index == 1) {
            [self share];
        }
    };
    MMPopupItem *forward = MMItemMake(@"转发".lv_localized, MMItemTypeNormal, ^(NSInteger index) {
        [self forward];
    });
    MMPopupItem *collect = MMItemMake(@"收藏".lv_localized, MMItemTypeNormal, ^(NSInteger index) {
        [self collect];
    });
    NSMutableArray *items = @[MMItemMake(@"保存到相册".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"分享".lv_localized, MMItemTypeNormal, block),
                              forward,
                              collect
    ].mutableCopy;
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
    return;
    if (self.moreCall) {
        self.moreCall(self);
    }
}

- (void)expandClick:(UIButton *)btn{
    btn.selected = !btn.isSelected;
    
    if (btn.selected) {
        [self changeContentHeight:8];
    } else {
        [self changeContentHeight:3];
    }
    
}

- (void)changeContentHeight:(NSInteger)maxNum{
    
    CGFloat lineSpace = 5;
    UIFont *font = XHQFont(16);
    //获取文字内容的高度
    CGFloat textHeight = [self boundingRectWithWidth:SCREEN_WIDTH - 90 withTextFont:font withLineSpacing:lineSpace text:self.blog.text].height;

    //文字高度超过三行，截取三行的高度，否则有多少显示多少
    if (textHeight > (font.lineHeight + lineSpace ) * maxNum - lineSpace) {
        textHeight = (font.lineHeight + lineSpace ) * maxNum - lineSpace;
        self.expandBtn.hidden = NO;
    } else {
        if (maxNum == 3) {
            self.expandBtn.hidden = YES;
        } else {
            self.expandBtn.hidden = NO;
        }
    }
    NSInteger rowNum = textHeight/font.lineHeight;
    if (rowNum == 1) {
        textHeight -= lineSpace;
    }
    textHeight += 5;
    
    //设置label的富文本
    self.contentL.attributedText = [self attributedStringFromStingWithFont:font withLineSpacing:lineSpace text:self.blog.text];
    
    [self.contentPV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(-65);
        make.bottom.mas_equalTo(-(kBottomSafeHeight + 55));
        make.height.mas_equalTo(textHeight);
    }];
}

/**
 *  根据文字内容动态计算UILabel宽高
 *  @param maxWidth label宽度
 *  @param font  字体
 *  @param lineSpacing  行间距
 *  @param text  内容
 */
-(CGSize)boundingRectWithWidth:(CGFloat)maxWidth
                   withTextFont:(UIFont *)font
                withLineSpacing:(CGFloat)lineSpacing
                           text:(NSString *)text{
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    //段落样式
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //设置行间距
    [paragraphStyle setLineSpacing:lineSpacing];
//#warning 此处设置NSLineBreakByTruncatingTail会导致计算文字高度方法失效
//    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    //计算文字尺寸
    CGSize size = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    return size;
}

/**
 *  NSString转换成NSMutableAttributedString
 *  @param font  字体
 *  @param lineSpacing  行间距
 *  @param text  内容
 */
-(NSMutableAttributedString *)attributedStringFromStingWithFont:(UIFont *)font
                                                withLineSpacing:(CGFloat)lineSpacing
                                                           text:(NSString *)text{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail]; //截断方式，"abcd..."
    [attributedStr addAttribute:NSParagraphStyleAttributeName
                          value:paragraphStyle
                          range:NSMakeRange(0, [text length])];
    return attributedStr;
}

#pragma mark - 懒加载
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.clipsToBounds = YES;
        _coverImgView.backgroundColor = [UIColor blackColor];
        _coverImgView.tag = 222;
    }
    return _coverImgView;
}


- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn =  [[UIButton alloc] init];
        [_likeBtn setImage:[UIImage imageNamed:@"videoB_like"] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"videoB_like_sel"] forState:UIControlStateSelected];
        _likeBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _likeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [_likeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_likeBtn addTarget:self action:@selector(likeClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

- (UIButton *)rewardBtn{
    if (!_rewardBtn) {
        _rewardBtn = [[UIButton alloc] init];
        [_rewardBtn setImage:[UIImage imageNamed:@"videoB_reward"] forState:UIControlStateNormal];
        _rewardBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
//        _rewardBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [_rewardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rewardBtn addTarget:self action:@selector(rewardClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _rewardBtn;
}

- (UIButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        
        [_commentBtn setImage:[UIImage imageNamed:@"videoB_comment"] forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
//        _commentBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commentBtn addTarget:self action:@selector(commentClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

- (UIButton *)moreBtn{
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        
        [_moreBtn setImage:[UIImage imageNamed:@"videoB_more"] forState:UIControlStateNormal];
        
//        _commentBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [_moreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)expandBtn{
    if (!_expandBtn) {
        _expandBtn =  [[UIButton alloc] init];
        [_expandBtn setImage:[UIImage imageNamed:@"videoB_pick_up"] forState:UIControlStateNormal];
        [_expandBtn setImage:[UIImage imageNamed:@"videoB_pick_down"] forState:UIControlStateSelected];
        [_expandBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_expandBtn addTarget:self action:@selector(expandClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _expandBtn;
}

- (UIView *)contentPV{
    if (!_contentPV) {
        _contentPV = [[UIView alloc] init];
//        _contentPV.backgroundColor = XHQRGBA(0, 0, 0, 0.6);
    }
    return _contentPV;
}

- (UILabel *)contentL{
    if (!_contentL) {
        _contentL = [[UILabel alloc] init];
        _contentL.numberOfLines = 0;
        _contentL.textColor = [UIColor whiteColor];
        _contentL.font = XHQFont(16);
        _contentL.backgroundColor = [UIColor clearColor];
    }
    return _contentL;
}

- (UIButton *)rotation {
    if (!_rotation) {
        _rotation = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rotation setImage:[UIImage imageNamed:@"zfplayer_rotaiton"] forState:UIControlStateNormal];
        [_rotation addTarget:self action:@selector(rotationClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rotation;
}

@end
