//
//  TF_TimeVideoBrowseVC.m
//  GoChat
//
//  Created by apple on 2022/2/8.
//

#import "TF_TimeVideoBrowseVC.h"
#import "TF_TimeVideoCell.h"
#import "VideoResourceLoadManager.h"
#import "UIImageView+VideoThumbnail.h"
#import "VideoThumbnailManager.h"
#import "PhotoAVideoPreviewPagesViewController+Timeline.h"
#import "ZFAVPlayerManager.h"
#import "ZFDouYinControlView.h"
#import "ZFPlayerControlView.h"
#import "ZFPlayerConst.h"
#import "IQKeyboardManager.h"

#import "TF_TimeVideoCell.h"
#import "VideoResourceLoadManager.h"
#import "UIImageView+VideoThumbnail.h"
#import "VideoThumbnailManager.h"

#import "ZFAVPlayerManager.h"
#import "ZFDouYinControlView.h"
#import "ZFPlayerControlView.h"
#import "ZFPlayerConst.h"
#import "TF_ZFCustControlV.h"
#import "TimelineCommentView.h"

#import "TF_SlidePopupView.h"
#import "TF_TimeBrowseCommentV.h"
#import "UserinfoHelper.h"
#import "UserTimelineVC.h"
@interface TF_TimeVideoBrowseVC ()<UITableViewDelegate, UITableViewDataSource, BusinessListenerProtocol, ChatChooseViewControllerDelegate>
/// <#code#>
@property (nonatomic,strong) NSMutableArray<BlogInfo *> *dataSource;
/// <#code#>
@property (nonatomic,strong) UITableView *tableView;
/// <#code#>
@property (nonatomic,assign) NSInteger currentPage;

@property (nonatomic, strong) ZFPlayerController *player;
/// 默认控制页面，有动态加载样式
@property (nonatomic, strong) ZFDouYinControlView *controlView;
/// 播放时的控制页面
@property (nonatomic, strong) TF_ZFCustControlV *fullControlView;
/// <#code#>
@property (nonatomic,strong) UILabel *titleL;
/// 停止之前是否正在播放
@property (nonatomic,assign) BOOL playing;

@property (nonatomic, strong) TimelineCommentView *commentView;
/// <#code#>
@property (nonatomic,strong) NSMutableArray *origialIds;
/// <#code#>
@property (nonatomic,strong) TF_TimeBrowseCommentV *commentListV;

/// <#code#>
@property (nonatomic,assign) BOOL firstLoad;
/// <#code#>
@property (nonatomic,strong) UIButton *backButton;
/// 用户头像
@property (nonatomic,strong) UIImageView *iconView;
/// 用户名
@property (nonatomic, strong) UILabel *nameLabel;
/// 关注按钮
@property (nonatomic,strong) UIButton *fuocusBtn;
/// <#code#>
@property (nonatomic,strong) TF_SlidePopupView *popupView;
@end

@implementation TF_TimeVideoBrowseVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    self.firstLoad = YES;
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.origialIds removeAllObjects];
    for (BlogInfo *blog in self.blogs) {
        [self.origialIds addObject:@(blog.ids)];
    }
    [self dealDataSource:self.blogs];
    BlogInfo *blog = self.dataSource.firstObject;
    [self updateUserInfo:blog];
    if (self.blogs.count < 2) {
        [self.tableView.mj_footer beginRefreshing];
    }
    
    [self setPlayer];
    [self setupUI];
    
    @weakify(self)
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath];
    }];
    
}

- (void)setupUI{
    
    [self.view addSubview:self.tableView];
    
    
    [self.view addSubview:self.backButton];
    
    [self.view addSubview:self.iconView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.fuocusBtn];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15.0f);
        make.top.equalTo(self.view).offset(kTopBarDifHeight + 20.0f);
        make.width.height.mas_equalTo(44.0f);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backButton.mas_right).offset(kAdapt(7));
        make.centerY.mas_equalTo(self.backButton);
        make.width.height.mas_equalTo(kAdapt(36));
    }];
//
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView.mas_right).offset(kAdapt(10));
        make.centerY.mas_equalTo(self.iconView);
    }];
    
    [self.fuocusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(kAdapt(15));
        make.centerY.mas_equalTo(self.iconView);
        make.width.mas_equalTo(kAdapt(61));
        make.height.mas_equalTo(kAdapt(30));
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    IQKeyboardManager.sharedManager.enable = NO;
    IQKeyboardManager.sharedManager.enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    IQKeyboardManager.sharedManager.enable = YES;
    IQKeyboardManager.sharedManager.enableAutoToolbar = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self stopOrRePlay];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.firstLoad) {
        [self stopOrRePlay];
    }
    self.firstLoad = NO;
    
}

- (void)closeClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}


- (void)stopOrRePlay{
    if (self.player.currentPlayerManager.isPlaying) {
        self.playing = YES;
        [self.player.currentPlayerManager pause];
        
    } else if (self.playing ){
        [self.player.currentPlayerManager play];
    }
}

-(void)dealDataSource:(NSArray<BlogInfo *> *)blogs{
    if (blogs.count < 1) {
        return;
    }
    
    BlogInfo *blog = [blogs lastObject];
    self.currentPage = blog.ids;
    
    [self.dataSource addObjectsFromArray:blogs];
//    [blogs enumerateObjectsUsingBlock:^(BlogInfo *blog, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (blog.content.isVideoContent) {
//            [self.dataSource addObject:blog];
//        }
//    }];
    [self.tableView reloadData];
    /// 找到可以播放的视频并播放
    @weakify(self)
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath];
    }];
}

- (void)loadMore{
    MJWeakSelf
    [TimelineHelper queryTimelineList:self.type offset:(int)self.currentPage topic:self.topic completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf dealDataSource:blogs];
    }];
}


- (void)scrollViewDidEndScroll {
    
    NSIndexPath *index = [self currentIndexPath];
    
    BlogInfo *blog = self.dataSource[index.section];
    
    [self updateUserInfo:blog];
    
}

- (void)updateUserInfo:(BlogInfo *)blog{
    self.fuocusBtn.hidden = [UserInfo shareInstance]._id == blog.user_id;
    BOOL isFollow = [TimelineHelper.helper.followIds containsObject:@(blog.user_id)];
    [self setFollowStatus:isFollow];
    [UserinfoHelper setUsername:blog.user_id inLabel:self.nameLabel];
    [UserinfoHelper setUserAvatar:blog.user_id inImageView:self.iconView];
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
        NSString *imgN = [NSString stringWithFormat:@"videoB_follow_%ld", MNThemeMgr().themeStyle];
        [self.fuocusBtn setImage:[UIImage imageNamed:imgN] forState:UIControlStateNormal];
        self.fuocusBtn .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.fuocusBtn .layer.cornerRadius = 8;
        self.fuocusBtn.backgroundColor = [UIColor whiteColor];
    }
}

- (void)iconDidClick:(id)sender {
    
    NSIndexPath *index = [self currentIndexPath];
    BlogInfo *blog = self.dataSource[index.section];
    
    UserTimelineVC *user = [[UserTimelineVC alloc] initWithUserid:blog.user_id];
    [self.navigationController pushViewController:user animated:YES];
}
- (void)followAction:(UIButton *)sender {
    if (sender.isSelected) {
        [self xhq_actionSheetTitle:nil message:nil cancelTitle:@"取消".lv_localized dataSource:@[@"取消关注".lv_localized] selectedHandler:^(NSString *selectedValue) {
            [self follow:sender];
        }];
    } else {
        [self follow:sender];
    }
}

- (void)follow:(UIButton *)sender {
    sender.userInteractionEnabled = NO;
    
    sender.selected = !sender.isSelected;
    
    NSIndexPath *index = [self currentIndexPath];
    BlogInfo *blog = self.dataSource[index.section];
    
    [TimelineHelper followBlogUser:blog.user_id isFollow:sender.isSelected completions:^(BOOL success) {
        if (!success) {
            sender.selected = !sender.isSelected;
        }
        sender.userInteractionEnabled = YES;
        [self setFollowStatus:sender.selected];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    BlogInfo *blog = self.dataSource[section];
    if (blog.content.isVideoContent) {
        return 1;
    } else {
        if (section == 0 && blog.content.isPhotoContent && self.firstIndex > 0) {
            return blog.content.photos.count - self.firstIndex;
        }
        return blog.content.photos.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TF_TimeVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TF_TimeVideoCell" forIndexPath:indexPath];
    BlogInfo *blog = self.dataSource[indexPath.section];
    if (blog.content.isPhotoContent) {
        if (indexPath.section == 0 && self.firstIndex > 0) {
            cell.imageIndex = indexPath.row + self.firstIndex;
        } else {
            cell.imageIndex = indexPath.row;
        }
    } else {
        cell.imageIndex = -1;
    }
    cell.blog = blog;
    @weakify(self)
    cell.rotationCall = ^{
        @strongify(self)
        UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
        if (self.player.isFullScreen) {
            orientation = UIInterfaceOrientationPortrait;
        } else {
            orientation = UIInterfaceOrientationLandscapeRight;
        }
        [self.player rotateToOrientation:orientation animated:YES completion:nil];
    };
    cell.moreCall = ^(TF_TimeVideoCell * _Nonnull cell) {
        
    };
    cell.commentCall = ^(BlogInfo * _Nonnull blog) {
        
        @strongify(self)
        self.commentListV.blog = blog;
        TF_SlidePopupView *popupView = [TF_SlidePopupView popupViewWithFrame:UIScreen.mainScreen.bounds contentView:self.commentListV];
        [popupView showFrom:self.view completion:^{
            TimelineCommentView *commentView = [[TimelineCommentView alloc] init];
            self.commentView = commentView;
            [self.view addSubview:self.commentView];
            [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(@0);
                make.height.equalTo(@60);
                make.top.equalTo(self.tableView.mas_bottom);
            }];
        }];
        self.popupView = popupView;
        
    };
    return cell;
}

- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Timeline_Follows_Change):
            
            break;
        case MakeID(EUserManager, EUser_Timeline_Info_Liked_Change):
            /// 点赞
            [self infoLikedChange:(NSArray *)inParam];
//            [self prepareToPlay];
            break;
        case MakeID(EUserManager, EUser_Timeline_Info_Comment_Change):
            /// 评论
            [self infoCommentChange:(NSArray *)inParam];
            [self prepareToPlay];
            break;
        case MakeID(EUserManager, EUser_Td_Message_Video_Ok):
            /// 视频下载
            [self videoDownloadChanged:inParam];
            
            break;
        case MakeID(EUserManager, EUser_Timeline_Reply_Comment_Change):
            [self replyCommentChanged:(NSArray *)inParam];
            break;
        case MakeID(EUserManager, EUser_Timeline_Delete_Change):
        case MakeID(EUserManager, EUser_Timeline_Blocked_Change):
            [self deleteTimeline:inParam];
            break;
        default:
            break;
    }
}

- (void)replyCommentChanged:(NSArray *)param{
    [self.commentListV replyCommentChanged:param];
}
/// 点赞变动
- (void)infoLikedChange:(NSArray *)param {
    
   
}

/// 收到新的评论
- (void)infoCommentChange:(NSArray *)param {
    NSInteger blogId = [param.firstObject integerValue];
    if (![self.origialIds containsObject:@(blogId)]){
        for (BlogInfo *blog in self.dataSource) {
            if (blog.ids == blogId) {
                blog.reply_count ++;
                break;
            }
        }
    }
    if (self.commentListV.blog.ids == blogId) {
        for (BlogInfo *blog in self.dataSource) {
            if (blog.ids == blogId) {
                self.commentListV.blog = blog;
                break;
            }
        }
    }
    
    TF_TimeVideoCell *cell = (TF_TimeVideoCell *)[self.tableView.visibleCells firstObject];
    NSIndexPath *indexPath = [self currentIndexPath];
    cell.blog = self.dataSource[indexPath.section];
//    [self.tableView reloadRowsAtIndexPaths:@[[self currentIndexPath]] withRowAnimation:UITableViewRowAnimationNone];
//    [self prepareToPlay];
//    [self.tableView reloadData];
}

/// 视频下载
- (void)videoDownloadChanged:(id)param {
    if (![param isKindOfClass:FileInfo.class]) {
        return;
    }
    NSIndexPath *indexPath = [self currentIndexPath];
    BlogInfo *blog = self.dataSource[indexPath.section];
    if (!blog) {
        return;
    }
    FileInfo *fileInfo = (FileInfo *)param;
    if (fileInfo._id != blog.content.video.video._id) {
        return;
    }
    blog.content.video.video = fileInfo;
}

/// 删除动态
- (void)deleteTimeline:(id)param {
    NSInteger blogId = [param integerValue];
    for (BlogInfo *blog in self.dataSource) {
        if (blog.ids == blogId) {
            [self.dataSource removeObject:blog];
            break;
        }
    }
    [self.tableView reloadData];
}



#pragma mark - lazy load

- (TF_TimeBrowseCommentV *)commentListV{
    if (!_commentListV) {
        _commentListV = [TF_TimeBrowseCommentV new];
        _commentListV.backgroundColor = UIColor.whiteColor;
        _commentListV.frame = CGRectMake(0, 0, SCREEN_WIDTH, kAdapt(530));
        
        //绘制圆角 要设置的圆角 使用“|”来组合
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_commentListV.frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //设置大小
        maskLayer.frame = _commentListV.frame;
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        _commentListV.layer.mask = maskLayer;
        
        
        @weakify(self)
        _commentListV.replay = ^(NSInteger replyId, NSString * _Nonnull name) {
            @strongify(self)
            [self.view bringSubviewToFront:self.commentView];
            [self.commentView commentReply:replyId name:name];
        };
        
        _commentListV.comment = ^(NSInteger blogId) {
            @strongify(self)
            [self.view bringSubviewToFront:self.commentView];
            [self.commentView commentBlog:blogId];
        };
        _commentListV.closeCall = ^{
            @strongify(self);
            [self.popupView dismiss];
        };
    }
    return _commentListV;
}


- (NSMutableArray *)origialIds{
    if (!_origialIds) {
        _origialIds = [NSMutableArray array];
    }
    return _origialIds;
}

//- (TimelineCommentView *)commentView {
////    if (!_commentView) {
//        _commentView = [[TimelineCommentView alloc] init];
////    }
//    return _commentView;
//}

- (NSMutableArray<BlogInfo *> *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.pagingEnabled = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.rowHeight = SCREEN_HEIGHT;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            self.tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];

        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(closeClick)];
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)self.tableView.mj_header;
        header.lastUpdatedTimeLabel.hidden = YES;
        [header setTitle:@"继续下拉退出".lv_localized forState:MJRefreshStatePulling];
        
        [_tableView registerClass:[TF_TimeVideoCell class] forCellReuseIdentifier:@"TF_TimeVideoCell"];
    }
    return _tableView;
}
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton new];
        [_backButton addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"NavBackWhite"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UILabel *)titleL{
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.font = XHQBoldFont(20);
        _titleL.textColor = [UIColor whiteColor];
    }
    return _titleL;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.layer.cornerRadius = kAdapt(18);
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconView.layer.borderWidth = 1.0f;
        _iconView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconDidClick:)];
        [_iconView addGestureRecognizer:iconTap];
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _nameLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconDidClick:)];
        [_nameLabel addGestureRecognizer:nameTap];
    }
    return _nameLabel;
}

- (UIButton *)fuocusBtn{
    if (!_fuocusBtn) {
        _fuocusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fuocusBtn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
        [self setFollowStatus:NO];
        [_fuocusBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:self.fuocusBtn];
    }
    return _fuocusBtn;
}


- (NSIndexPath *)currentIndexPath{
    UITableViewCell *cell = [self.tableView.visibleCells firstObject];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return indexPath;
}

#pragma mark - player
- (void)setPlayer{
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    

    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:playerManager containerViewTag:222];
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    self.player.controlView = self.controlView;

    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    /// 1.0是完全消失时候
    self.player.playerDisapperaPercent = 1.0;
    
    
    @weakify (self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        [self.player.currentPlayerManager replay];
    };
    
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
//        kAPPDelegate.allowOrentitaionRotation = isFullScreen;
        ((AppDelegate *)[UIApplication.sharedApplication delegate]).allowOrentitaionRotation = isFullScreen;
        @strongify(self)
        self.player.controlView.hidden = YES;
    };
    
    self.player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        self.player.controlView.hidden = NO;
        if (isFullScreen) {
            self.player.controlView = self.fullControlView;
        } else {
            self.player.controlView = self.controlView;
        }
    };
    
    /// 更新另一个控制层的时间
    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)
        if ([self.player.controlView isEqual:self.fullControlView]) {
            [self.controlView videoPlayer:self.player currentTime:currentTime totalTime:duration];
        } else if ([self.player.controlView isEqual:self.controlView]) {
            [self.fullControlView videoPlayer:self.player currentTime:currentTime totalTime:duration];
        }
//        [self.controlView videoPlayer:self.player currentTime:currentTime totalTime:duration];
    };
    
    /// 更新另一个控制层的缓冲时间
    self.player.playerBufferTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval bufferTime) {
        @strongify(self)
        if ([self.player.controlView isEqual:self.fullControlView]) {
            if ([self.contentView respondsToSelector:@selector(videoPlayer:bufferTime:)]) {
                [self.controlView videoPlayer:self.player bufferTime:bufferTime];
            }
        } else if ([self.player.controlView isEqual:self.controlView]) {
            [self.fullControlView videoPlayer:self.player bufferTime:bufferTime];
        }
//        [self.controlView videoPlayer:self.player bufferTime:bufferTime];
    };
    
    /// 停止的时候找出最合适的播放
    self.player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.player.playingIndexPath) return;
        if (indexPath.section == self.dataSource.count-1) {
            /// 加载下一页数据
//            [self.tableView.mj_footer beginRefreshing];
            [self loadMore];
        }
        [self playTheVideoAtIndexPath:indexPath];
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
//        asset.muted = YES;
        [self saveVideoThumbnailInPlayerReadyToPlay:[self currentIndexPath]];
    };
}



- (void)prepareToPlay {
    if (self.player.playingIndexPath) {
        return;
    }
    @weakify(self);
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self);
        [self playTheVideoAtIndexPath:indexPath];
    }];
}


- (void)saveVideoThumbnailInPlayerReadyToPlay:(NSIndexPath *)indexPath {
    ZFAVPlayerManager *manager = (ZFAVPlayerManager *)self.player.currentPlayerManager;
    if (!manager.isPreparedToPlay) {
        return;
    }
      
    NSString *name = self.fullControlView.titleLabel.text;
    @weakify(self);
    [VideoThumbnailManager.manager saveThumbnailAsset:manager.asset forVideoName:name completion:^{
        @strongify(self);
        BlogInfo *blog = self.dataSource[indexPath.section];
        if (!blog.content.isVideoContent) {
            return;
        }
        TF_TimeVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell resetVideoThumbnail];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
    
    
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}


- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath];
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [self.tableView.visibleCells firstObject];
    indexPath = [self currentIndexPath];
    BlogInfo *blog = self.dataSource[indexPath.section];
    
    if (!blog.content.isVideoContent) {
        [self.player stopCurrentPlayingCell];
        return;
    }
    VideoInfo *video = blog.content.video;
    NSURL *url;
    if (video.isVideoDownloaded && video.localVideoPath) {
        url = [NSURL fileURLWithPath:video.localVideoPath];
    } else {
        NSString *appUrl = [NSString stringWithFormat:@"app://video/%ld/%ld/%@", video.video._id, video.video.expected_size, video.mime_type];
        url = [NSURL URLWithString:appUrl];
        VideoResourceLoadManager *manager = [[VideoResourceLoadManager alloc] init];
        self.player.resourceLoaderDelegate = manager;
    }
    [self.player playTheIndexPath:indexPath assetURL:url];
    
    [self.controlView resetControlView];
    [self.controlView showCoverViewWithUrl:video];
//    self.fullControlView.titleLabel.text = video.file_name;
    self.fullControlView.titleLabel.text = @"";
//    [self.fullControlView showTitle:@"custom landscape controlView" coverURLString:@"" fullScreenMode:ZFFullScreenModeLandscape];
}


- (ZFDouYinControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFDouYinControlView new];
    }
    return _controlView;
}

- (TF_ZFCustControlV *)fullControlView {
    if (!_fullControlView) {
        _fullControlView = [[TF_ZFCustControlV alloc] init];
    }
    return _fullControlView;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end
