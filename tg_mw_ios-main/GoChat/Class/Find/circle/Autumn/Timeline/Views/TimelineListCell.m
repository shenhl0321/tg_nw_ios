//
//  TimelineListCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "TimelineListCell.h"
#import "WFPopViewController.h"
#import "CycleMainViewController.h"
#import "TimelineTopicVC.h"
#import "UserTimelineVC.h"
#import "SDCycleScrollView.h"
#import "PhotoImageView.h"
#import "TimelineVideoView.h"

#import "BlogInfo.h"
#import "UserinfoHelper.h"
#import "TimelineHelper.h"
#import "TimeFormatting.h"
#import "TF_TimeVideoBrowseVC.h"
#import "YYText.h"

/// 赏金
@interface RewardView : DYView

@property (nonatomic, assign) CGFloat number;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation RewardView

- (void)dy_initUI {
    [super dy_initUI];
    _imageView = ({
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_cycle_reward"]];
        iv;
    });
    _numberLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextForFD4E57;
        label.font = [UIFont regularCustomFontOfSize:14];
        label.text = @"￥0.00";
        label;
    });
    self.backgroundColor = XHQHexColor(0xFFE5E6);
    [self addSubview:_imageView];
    [self addSubview:_numberLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_imageView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)setNumber:(CGFloat)number {
    _number = number;
    _numberLabel.text = [NSString stringWithFormat:@"￥%.2f", number];
    [_numberLabel xhq_AttributeTextAttributes:@{NSFontAttributeName: [UIFont regularCustomFontOfSize:10]}
                                        range:NSMakeRange(0, 1)];
}

@end

@interface TimelineListCellItem ()

@property (nonatomic, assign) TimelineResponse response;

@end

@implementation TimelineListCellItem


@end

@interface TimelineListCell ()<UIScrollViewDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) UIImageView *headImageV;
@property (nonatomic, strong) UILabel *nameL;
@property (nonatomic, strong) UIButton *fuocusBtn;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TimelineVideoView *videoView;

@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *loveBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *delButton;
@property (nonatomic, strong) UIPageControl *pageControll;

@property (nonatomic, strong) UILabel *positionL;
@property (nonatomic, strong) UILabel *loveL;
@property (nonatomic, strong) YYLabel *contentL;

@property (nonatomic, strong) UILabel *commentL;
@property (nonatomic, strong) UILabel *timeL;

@property (nonatomic, strong) UILabel *pinnedLabel;

@property (nonatomic, strong) RewardView *rewardView;

@end

@implementation TimelineListCell

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item {    
    [super setItem:item];
    TimelineListCellItem *m = (TimelineListCellItem *)item;
    BlogInfo *blog = (BlogInfo *)item.cellModel;
    [self setContentRichText:blog];
    self.commentL.text = [NSString stringWithFormat:@"%ld条评论".lv_localized, blog.reply_count];
    self.loveL.text = [NSString stringWithFormat:@"%ld次点赞".lv_localized, blog.like_count];
    self.timeL.text = [TimeFormatting formatTimeWithTimeInterval:blog.date];
    self.rewardView.number = blog.rewarded;
    if (m.isDisplayInDetail) {
        self.delButton.hidden = [UserInfo shareInstance]._id != blog.user_id;
        self.timeL.hidden = [UserInfo shareInstance]._id == blog.user_id;
//        self.contentL.userInteractionEnabled = YES;
        self.pinnedLabel.hidden = YES;
    } else {
//        self.contentL.userInteractionEnabled = NO;
        self.delButton.hidden = YES;
        self.timeL.hidden = NO;
        self.pinnedLabel.hidden = !blog.pinned;
    }
    self.loveBtn.selected = blog.liked;
    self.positionL.text = blog.location.address;
    self.fuocusBtn.hidden = self.moreBtn.hidden = [UserInfo shareInstance]._id == blog.user_id;
    BOOL isFollow = [TimelineHelper.helper.followIds containsObject:@(blog.user_id)];
    [self setFollowStatus:isFollow];
    [UserinfoHelper setUsername:blog.user_id inLabel:self.nameL];
    [UserinfoHelper setUserAvatar:blog.user_id inImageView:self.headImageV];
    [self setupImageViews];
    [self setupVideoViews];
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)setContentRichText:(BlogInfo *)blog {
    if (blog.entities.entities.count == 0 || ![NSString xhq_notEmpty:blog.text]) {
        self.contentL.text = blog.text;
        return;
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:blog.text];
    text.yy_font = [UIFont helveticaFontOfSize:15];
    text.yy_color = [UIColor colorFor878D9A];
    for (BlogEntity *entity in blog.entities.entities) {
        if (entity.length + entity.offset <= text.length) {
            NSRange range = NSMakeRange(entity.offset, entity.length);
            entity.type.text = [blog.text substringWithRange:range];
            [text yy_setColor:UIColor.colorMain range:range];
            YYTextHighlight *high = YYTextHighlight.new;
            high.userInfo = @{@"key": entity.type};
            [text yy_setTextHighlight:high range:range];
        }
    }
    self.contentL.attributedText = text;
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.headImageV = [[UIImageView alloc] init];
    self.headImageV.layer.masksToBounds = YES;
    self.headImageV.layer.cornerRadius = 20;
    [self.contentView addSubview:self.headImageV];
    @weakify(self);
    [self.headImageV xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        BlogInfo *blog = (BlogInfo *)self.item.cellModel;
        [self showUserDetail:blog.user_id];
    }];
    
    
    self.nameL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameL.font = [UIFont helveticaFontOfSize:17];
    self.nameL.textColor = [UIColor colorTextFor000000];
    [self.contentView addSubview:self.nameL];
    
    self.fuocusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fuocusBtn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
    [self setFollowStatus:NO];
    [self.fuocusBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.fuocusBtn];

    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"icon_circle_more"] forState:UIControlStateNormal];
    [self.moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.moreBtn];


    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.layer.masksToBounds = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.contentView addSubview:self.scrollView];

    self.videoView = [[TimelineVideoView alloc] init];
    self.videoView.layer.masksToBounds = YES;
    [self.videoView.clearMaskView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self playAction];
    }];
    [self.contentView addSubview:self.videoView];
    
    self.pinnedLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont regularCustomFontOfSize:13];
        label.text = @"置顶";
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = XHQHexColor(0xFD4E57);
        [label xhq_cornerRadius:3];
        label;
    });
    [self.contentView addSubview:self.pinnedLabel];

    self.loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loveBtn setImage:[UIImage imageNamed:@"icon_circle_praise"] forState:UIControlStateNormal];
    [self.loveBtn setImage:[UIImage imageNamed:@"icon_circle_praise_select"] forState:UIControlStateSelected];
    [self.loveBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.loveBtn];

    self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentBtn setImage:[UIImage imageNamed:@"icon_circle_comment"] forState:UIControlStateNormal];
    [self.commentBtn addTarget:self action:@selector(commemtAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.commentBtn];
    
    self.rewardView = [[RewardView alloc] init];
    self.rewardView.hidden = YES;
    [self.contentView addSubview:self.rewardView];
    [self.rewardView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self reward];
    }];
    
    self.delButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"删除" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorforFD4E57] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:16];
        [btn xhq_addTarget:self action:@selector(deleteAction)];
        btn;
    });
    [self.contentView addSubview:self.delButton];

    self.pageControll = [[UIPageControl alloc] init];
    self.pageControll.currentPageIndicatorTintColor = UIColor.xhq_base;
    [self.contentView addSubview:self.pageControll];


    self.positionL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.positionL.font = [UIFont regularCustomFontOfSize:14];
    self.positionL.textColor = [UIColor colorFor878D9A];
    self.positionL.textAlignment = 2;
    [self.contentView addSubview:self.positionL];

    self.loveL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.loveL.font = [UIFont helveticaFontOfSize:16];
    self.loveL.textColor = [UIColor colorTextFor23272A];
    
    [self.contentView addSubview:self.loveL];

    self.contentL = [[YYLabel alloc] initWithFrame:CGRectZero];
    self.contentL.font = [UIFont helveticaFontOfSize:15];
    self.contentL.textColor = [UIColor colorFor878D9A];
    self.contentL.numberOfLines = 0;
    [self.contentView addSubview:self.contentL];
    
    /// 高亮的 @ # 点击
    self.contentL.highlightTapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        @strongify(self);
        YYTextHighlight *high = [text yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
        BlogEntityType *type = high.userInfo[@"key"];
        if (!type) {
            return;
        }
        [self contentHighSelected:type];
    };


    self.commentL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.commentL.textColor = [UIColor colorTextForA9B0BF];
    self.commentL.font = [UIFont helveticaFontOfSize:14];
    [self.contentView addSubview:self.commentL];

    self.timeL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeL.textColor = [UIColor colorTextForA9B0BF];
    self.timeL.font = [UIFont helveticaFontOfSize:14];
    [self.contentView addSubview:self.timeL];
    self.hyb_lastViewInCell = self.commentL;
    self.hyb_bottomOffsetToCell = 10;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self.contentL addGestureRecognizer:longPress];
}

- (void)layoutSubviews {
    [super layoutSubviews];
 
    [self.headImageV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(15);
        make.width.height.equalTo(@40);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(50);
        make.centerY.equalTo(self.headImageV.mas_centerY);
    }];
    
    [self.fuocusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-53);
        make.width.mas_equalTo(61);
        make.height.mas_equalTo(30);
        make.centerY.equalTo(self.headImageV.mas_centerY);
    }];
    

    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(67);
        make.right.mas_equalTo(-140);
        make.centerY.equalTo(self.headImageV.mas_centerY);
    }];
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(kAdapt(0));
        make.top.equalTo(self.headImageV.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(kAdapt(-0));
        make.height.equalTo(@(kScreenWidth() - kAdapt(30)));
    }];

    [self.videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
    }];
    
    [self.pinnedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.equalTo(self.scrollView).offset(7);
        make.size.mas_equalTo(CGSizeMake(40, 22));
    }];

    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    [self.loveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        if (blog.content.isVideoContent || blog.content.isPhotoContent) {
            make.top.equalTo(self.scrollView.mas_bottom).offset(12);
        } else {
            make.top.equalTo(self.headImageV.mas_bottom).offset(12);
        }
        make.height.width.equalTo(@22);
    }];

    [self.commentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loveBtn.mas_right).offset(15);
        make.centerY.equalTo(self.loveBtn);
        make.height.width.equalTo(@22);
    }];
    
    [self.rewardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.commentBtn.mas_trailing).offset(15);
        make.centerY.equalTo(self.commentBtn);
        make.height.mas_equalTo(24);
        make.trailing.equalTo(self.rewardView.numberLabel.mas_trailing).offset(10);
    }];
    [self.rewardView xhq_cornerRadius:12];
    [self.pageControll mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.bottom.equalTo(self.scrollView.mas_bottom).offset(-5);
    }];

    [self.positionL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.loveBtn.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@22);
    }];

    [self.loveL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.loveBtn.mas_bottom).offset(15);
        make.height.equalTo(@20);
    }];

    [self.contentL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.loveL.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    self.contentL.preferredMaxLayoutWidth = SCREEN_WIDTH - 30;
    [self.commentL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        if ([NSString xhq_notEmpty:blog.text]) {
            make.top.equalTo(self.contentL.mas_bottom).offset(15);
        } else {
            make.top.equalTo(self.contentL);
        }
        make.height.equalTo(@15);
    }];

    [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@15);
        make.centerY.equalTo(self.commentL);
    }];
    [self.delButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-15);
        make.centerY.equalTo(self.commentL);
        make.size.equalTo(@(CGSizeMake(80, 20)));
    }];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)press {
    TimelineListCellItem *m = (TimelineListCellItem *)self.item;
    if (!m.isDisplayInDetail) {
        return;
    }
    if (press.state == UIGestureRecognizerStateEnded) {
        self.contentL.backgroundColor = UIColor.clearColor;
    } else if (press.state == UIGestureRecognizerStateBegan) {
        self.contentL.backgroundColor = UIColor.lightGrayColor;
        [self setMenuItems];
    }
}

- (void)setMenuItems {
    TimelineListCellItem *m = (TimelineListCellItem *)self.item;
    if (!m.isDisplayInDetail) {
        return;
    }
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *item1 = [[UIMenuItem alloc]initWithTitle:@"复制".lv_localized action:@selector(copyText:)];
    menu.menuItems = @[item1];
    [menu setTargetRect:self.contentL.frame inView:self];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyText:)) {
        return YES;
    }
    return NO;
}

- (void)copyText:(UIMenuController *)menu {
    if (!self.contentL.text) return;
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    paste.string = self.contentL.text;
}

- (void)setFollowStatus:(BOOL)isSelect{
    if (isSelect) {
        [self.fuocusBtn setTitle:@"已关注".lv_localized forState:UIControlStateNormal];
        [self.fuocusBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        [self.fuocusBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.fuocusBtn.backgroundColor = [UIColor colorForF5F9FA];
        self.fuocusBtn .layer.borderWidth = 0;
        self.fuocusBtn .layer.cornerRadius = 8;
    }else{
        [self.fuocusBtn setTitle:@"关注".lv_localized forState:UIControlStateNormal];
        [self.fuocusBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        [self.fuocusBtn setImage:[UIImage imageNamed:@"icon_circle_follow_add"] forState:UIControlStateNormal];
        self.fuocusBtn .layer.borderWidth = 1;
        self.fuocusBtn .layer.borderColor = [UIColor colorMain].CGColor;
        self.fuocusBtn .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.fuocusBtn .layer.cornerRadius = 8;
        self.fuocusBtn.backgroundColor = [UIColor whiteColor];
    }
}

- (void)setupImageViews {
    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    if (!blog.content.isPhotoContent) {
        _scrollView.hidden = YES;
        _pageControll.hidden = YES;
        return;
    }
    _scrollView.hidden = NO;
    _pageControll.hidden = NO;
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat width = kScreenWidth(), height = width;
    [blog.content.photos enumerateObjectsUsingBlock:^(PhotoInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PhotoImageView *imageView = [[PhotoImageView alloc] init];
        imageView.frame = CGRectMake(idx * width, 0, width, height);
        imageView.photo = obj;
        @weakify(self);
        [imageView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            [self previewPhoto:idx];
        }];
        [self.scrollView addSubview:imageView];
    }];
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.contentSize = CGSizeMake(blog.content.photos.count * width, 0);
    _pageControll.numberOfPages = blog.content.photos.count;
    _pageControll.hidden = blog.content.photos.count == 1;
}

- (void)setupVideoViews {
    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    if (!blog.content.isVideoContent) {
        _videoView.hidden = YES;
        return;
    }
    _videoView.hidden = NO;
    _videoView.video = blog.content.video;
}

- (void)resetVideoThumbnail {
    _videoView.video = _videoView.video;
}

#pragma mark - Event
- (void)showUserDetail:(long)userid {
    if (userid <= 0) {
        return;
    }
    UserTimelineVC *user = [[UserTimelineVC alloc] initWithUserid:userid];
    [self.xhq_currentController.navigationController pushViewController:user animated:YES];
}

- (void)followAction:(UIButton *)sender {
    if (sender.isSelected) {
        [self.xhq_currentController xhq_actionSheetTitle:nil message:nil cancelTitle:@"取消".lv_localized dataSource:@[@"取消关注".lv_localized] selectedHandler:^(NSString *selectedValue) {
            [self follow:sender];
        }];
    } else {
        [self follow:sender];
    }
}

- (void)follow:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    sender.selected = !sender.isSelected;
    
    [TimelineHelper followBlogUser:blog.user_id isFollow:sender.isSelected completions:^(BOOL success) {
        if (!success) {
            sender.selected = !sender.isSelected;
        }
        sender.userInteractionEnabled = YES;
        [self setFollowStatus:sender.selected];
    }];
}

- (void)likeAction:(UIButton *)sender {
    TimelineListCellItem *item = (TimelineListCellItem *)self.item;
    if (item.response == TimelineResponse_Liking) {
        return;
    }
    item.response = TimelineResponse_Liking;
    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    __block NSInteger count = blog.like_count;
    sender.selected = !sender.isSelected;
    blog.liked = sender.isSelected;
    sender.isSelected ? count ++ : count --;
    count = MAX(count, 0);
    self.loveL.text = [NSString stringWithFormat:@"%ld次点赞".lv_localized, count];
    [TimelineHelper likeBlog:blog.ids isLike:sender.isSelected completion:^(BOOL success) {
        if (!success) {
            sender.selected = !sender.isSelected;
            blog.liked = sender.isSelected;
            sender.isSelected ? count ++ : count --;
            self.loveL.text = [NSString stringWithFormat:@"%ld次点赞".lv_localized, count];
        }
        item.response = TimelineResponse_Liked;
    }];
}

- (void)playAction {
//    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
//    if (blog.content.isVideoContent) {
//        TimelineListCellItem *item = (TimelineListCellItem *)self.item;
//        item.response = TimelineResponse_BrowseVideo;
//        !self.responseBlock ? : self.responseBlock();
//        return;
//    }
//    [TimelineHelper previewVideo:blog];
    TimelineListCellItem *item = (TimelineListCellItem *)self.item;
    item.response = TimelineResponse_BrowseVideo;
    !self.responseBlock ? : self.responseBlock();
    return;
}

- (void)commemtAction {
    TimelineListCellItem *item = (TimelineListCellItem *)self.item;
    item.response = TimelineResponse_Comment;
    !self.responseBlock ? : self.responseBlock();
}

- (void)reward {
    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    [TimelineHelper rewardBlog:blog.ids userId:blog.user_id amout:1 completion:^(BOOL success) {
        
    }];
}

- (void)deleteAction {
    XHQAlertSingleAction(@"提示".lv_localized, @"确定要删除该条动态".lv_localized, @"删除".lv_localized, @"取消".lv_localized, ^{
        BlogInfo *blog = (BlogInfo *)self.item.cellModel;
        [TimelineHelper deleteBlog:blog.ids completion:^(BOOL success) {}];
    });
}

- (void)moreAction:(UIButton *)sender {
    BlogInfo *blog = (BlogInfo *)self.item.cellModel;
    WFPopViewController *viewVC = [[WFPopViewController alloc] init];
    viewVC.preferredContentSize =CGSizeMake(150,100);
    viewVC.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popVC = viewVC.popoverPresentationController;
    popVC.delegate = self;
    popVC.sourceView = sender;
    popVC.sourceRect = CGRectMake(0, sender.frame.size.height, 0, 0);
    popVC.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self.xhq_currentController presentViewController:viewVC animated:YES completion:nil];
    viewVC.reportBlock = ^{
        /// 投诉
        NSString *url = [NSString stringWithFormat:@"%@?uid=%ld&chatid=%ld", KHostEReport, [UserInfo shareInstance]._id, blog.user_id];
        BaseWebViewController *v = [BaseWebViewController new];
        v.hidesBottomBarWhenPushed = YES;
        v.titleString = @"举报";
        v.urlStr = url;
        v.type = WEB_LOAD_TYPE_URL;
        [self.xhq_currentController.navigationController pushViewController:v animated:YES];
    };
    viewVC.blockBlock = ^{
        [TimelineHelper deleteBlog:blog.ids completion:^(BOOL success) {}];
    };
}

- (void)previewPhoto:(NSInteger)index {
    if (self.photoCall) {
        self.photoCall(self, index);
    } else {
        BlogInfo *blog = (BlogInfo *)self.item.cellModel;
        [TimelineHelper previewPhotos:blog currentIndex:index];
    }
}

- (void)contentHighSelected:(BlogEntityType *)type {
    /// @ 用户
    if (type.isAt) {
        [self showUserDetail:type.user_id];
        return;
    }
    /// # 话题
    NSString *topic = type.topicText;
    if (![NSString xhq_notEmpty:topic]) {
        return;
    }
    TimelineTopicVC *topicVC = [[TimelineTopicVC alloc] initWithTopic:topic];
    [self.xhq_currentController.navigationController pushViewController:topicVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControll.currentPage = index;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end


