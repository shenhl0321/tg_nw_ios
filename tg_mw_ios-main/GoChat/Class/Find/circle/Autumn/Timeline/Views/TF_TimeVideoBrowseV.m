//
//  TF_TimeVideoBrowseV.m
//  GoChat
//
//  Created by apple on 2022/2/9.
//

#import "TF_TimeVideoBrowseV.h"
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
#import "MMPopupItem.h"
#import "MMPopupWindow.h"
#import "MMSheetView.h"
#import "ChatChooseViewController.h"
@interface TF_TimeVideoBrowseV()<UITableViewDelegate, UITableViewDataSource, BusinessListenerProtocol>
/// <#code#>
@property (nonatomic,strong) NSMutableArray<BlogInfo *> *dataSource;
/// <#code#>
@property (nonatomic,strong) UITableView *tableView;
/// <#code#>
@property (nonatomic,assign) NSInteger currentPage;
/// <#code#>
@property (nonatomic,strong) UIButton *backBtn;

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
@property (nonatomic,strong) UIView *topV;
@end

@implementation TF_TimeVideoBrowseV

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self addSubview:self.backBtn];
        [self addSubview:self.titleL];
        [self addSubview:self.commentView];

        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15.0f);
            make.top.equalTo(self).offset(kTopBarDifHeight + 20.0f);
            make.width.height.mas_equalTo(44.0f);
        }];
        [self.titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backBtn);
            make.centerX.mas_equalTo(self);
        }];
        
        [self setPlayer];
        
        [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.height.equalTo(@60);
            make.top.equalTo(self.tableView.mas_bottom);
        }];
    }
    return self;
}

- (void)setBlogs:(NSArray<BlogInfo *> *)blogs{
    _blogs = blogs;
    [self.origialIds removeAllObjects];
    for (BlogInfo *blog in blogs) {
        [self.origialIds addObject:@(blog.ids)];
    }
    [self dealDataSource:blogs];
    if (blogs.count < 2) {
        [self.tableView.mj_footer beginRefreshing];
    }
//    [self playTheIndex:0];
}

- (void)setType:(TimelineType)type{
    _type = type;
//    TimelineType_Hot,
//    TimelineType_Follow,
//    TimelineType_Friend,
    switch (type) {
        case TimelineType_Hot:
            self.titleL.text = @"热门".lv_localized;
            break;
        case TimelineType_Follow:
            self.titleL.text = @"关注".lv_localized;
            break;
        case TimelineType_Friend:
            self.titleL.text = @"好友".lv_localized;
            break;
            
        default:
            break;
    }
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
    
    [blogs enumerateObjectsUsingBlock:^(BlogInfo *blog, NSUInteger idx, BOOL * _Nonnull stop) {
        if (blog.content.isVideoContent) {
            [self.dataSource addObject:blog];
        }
    }];
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
    [TimelineHelper queryTimelineList:self.type offset:self.currentPage completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf dealDataSource:blogs];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TF_TimeVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TF_TimeVideoCell" forIndexPath:indexPath];
    cell.blog = self.dataSource[indexPath.row];
    @weakify(self)
    cell.commentCall = ^(BlogInfo * _Nonnull blog) {
        @strongify(self)
//
        
        TF_TimeBrowseCommentV *commentView = [TF_TimeBrowseCommentV new];
        self.commentListV = commentView;
        commentView.backgroundColor = UIColor.whiteColor;
        commentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, kAdapt(530));
        commentView.blog = blog;
        commentView.replay = ^(NSInteger replyId, NSString * _Nonnull name) {
            [self bringSubviewToFront:self.commentView];
            [self.commentView commentReply:replyId name:name];
        };
        
        commentView.comment = ^(NSInteger blogId) {
            [self bringSubviewToFront:self.commentView];
            [self.commentView commentBlog:blog.ids];
        };
        TF_SlidePopupView *popupView = [TF_SlidePopupView popupViewWithFrame:UIScreen.mainScreen.bounds contentView:commentView];
//        [popupView showFrom:UIApplication.sharedApplication.keyWindow completion:^{
//            [commentView requestData];
//        }];
        [popupView showFrom:self completion:nil];
        
    };
    return cell;
}

- (NSArray *)timelineItems {
    MMPopupItem *forward = MMItemMake(@"转发".lv_localized, MMItemTypeNormal, ^(NSInteger index) {
        [self forward];
    });
    MMPopupItem *collect = MMItemMake(@"收藏".lv_localized, MMItemTypeNormal, ^(NSInteger index) {
        [self collect];
    });
    return @[forward, collect];
}

#pragma mark 转发
- (void)forward {
    
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
//    chooseView.delegate = self;
//    [self.navigationController pushViewController:chooseView animated:YES];
    
}

#pragma mark 收藏
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

//- (NSDictionary *)remoteContent {
//    NSDictionary *thumbnailFile = @{
//        @"@type" : @"inputFileRemote",
//        @"id" : self.thumbnail.file.remote._id ? : @""
//    };
//    NSDictionary *thumbnail = @{
//        @"@type": @"inputThumbnail",
//        @"thumbnail": thumbnailFile,
//        @"width": @(self.width),
//        @"height": @(self.height),
//    };
//    NSDictionary *video = @{
//        @"@type" : @"inputFileRemote",
//        @"id" : self.video.remote._id ? : @""
//    };
//    return @{
//        @"@type" : @"inputMessageVideo",
//        @"thumbnail" : thumbnail,
//        @"video" : video,
//        @"width" : @(self.width),
//        @"height" : @(self.height),
//        @"duration" : @(self.duration)
//    };
//}

- (NSDictionary *)msgParametersWithId:(NSNumber *)chatId {
    
//    NSDictionary *content = msg.content.photo.remoteContent;
//    NSDictionary *content = self.dataSource.firstObject.content.video;
    NSDictionary *content = @{};
    return @{
        @"@type" : @"sendMessage",
        @"chat_id" : chatId,
        @"input_message_content": content
    };
}

- (IBAction)moreClick:(UIView *)view
{
    MMPopupItemHandler block = ^(NSInteger index) {
        if (index == 0) {
            [self saveToAlbum];
        } else if (index == 1) {
            [self share];
        }
//        else if(index == 2){//转发
//            [self forwardMessage:self.previewList[self.curIndex]];
//        }else if (index == 3){//收藏
//            [self favorMessage:self.previewList[self.curIndex]];
//        }
    };
    NSMutableArray *items = @[MMItemMake(@"保存到相册".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"分享".lv_localized, MMItemTypeNormal, block)
//                              ,MMItemMake(@"转发", MMItemTypeNormal, block),
//                              MMItemMake(@"收藏", MMItemTypeNormal, block)
    ].mutableCopy;
    [items addObjectsFromArray:self.timelineItems];
    
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)saveToAlbum
{//保存到相册
//    self.player.currentPlayIndex;
////    MessageInfo *msg = [self.previewList objectAtIndex:self.selectIndex];
//    NSString *localPath = [self videoPath:msg];
//    if(!IsStrEmpty(localPath))
//    {
//        UISaveVideoAtPathToSavedPhotosAlbum(localPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    }
//    else
//    {
//        [UserInfo showTips:nil des:@"视频未准备好，无法保存到相册"];
//    }
//    NSString *localPath = [self documentPath:msg];
//    if(!IsStrEmpty(localPath))
//    {
//        UISaveVideoAtPathToSavedPhotosAlbum(localPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    }
//    else
//    {
//        [UserInfo showTips:nil des:@"视频未准备好，无法保存到相册"];
//    }
    
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

- (void)share {//文件分享
    
//    NSString *localPath = [self videoPath:msg];
//    if(!IsStrEmpty(localPath))
//    {
//        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Video", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
//        [self presentViewController:activityViewController animated:YES completion:nil];
//    }
//    else
//    {
//        [UserInfo showTips:nil des:@"视频未准备好，无法分享"];
//    }
//    
//    
//    NSString *localPath = [self documentPath:msg];
//    if(!IsStrEmpty(localPath))
//    {
//        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Video", [NSURL fileURLWithPath:localPath]] applicationActivities:nil];
//        [self presentViewController:activityViewController animated:YES completion:nil];
//    }
//    else
//    {
//        [UserInfo showTips:nil des:@"视频未准备好，无法分享"];
//    }
    
}


- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Timeline_Follows_Change):
            /// 关注
            [self.tableView reloadData];
            break;
        case MakeID(EUserManager, EUser_Timeline_Info_Liked_Change):
            /// 点赞
            [self infoLikedChange:(NSArray *)inParam];
            break;
        case MakeID(EUserManager, EUser_Timeline_Info_Comment_Change):
            /// 评论
            [self infoCommentChange:(NSArray *)inParam];
            break;
        case MakeID(EUserManager, EUser_Td_Message_Video_Ok):
            /// 视频下载
            [self videoDownloadChanged:inParam];
            break;
        case MakeID(EUserManager, EUser_Timeline_Delete_Change):
        case MakeID(EUserManager, EUser_Timeline_Blocked_Change):
            [self deleteTimeline:inParam];
            break;
        default:
            break;
    }
}

/// 点赞变动
- (void)infoLikedChange:(NSArray *)param {
//    NSInteger blogId = [param.firstObject integerValue];
//    BOOL isLike = [param.lastObject boolValue];
//    for (BlogInfo *blog in self.dataSource) {
//        if (blog.ids == blogId) {
//            blog.liked = isLike;
//            isLike ? blog.like_count ++ : blog.like_count --;
//            blog.like_count = MAX(0, blog.like_count);
//            break;
//        }
//    }
//    [self.tableView reloadData];
   
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
    
    [self.tableView reloadData];
}

/// 视频下载
- (void)videoDownloadChanged:(id)param {
    if (![param isKindOfClass:FileInfo.class]) {
        return;
    }
    BlogInfo *blog = self.dataSource[self.player.playingIndexPath.row];
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



- (void)close{
    if (self.closeCall) {
        self.closeCall();
    }
}

- (NSMutableArray *)origialIds{
    if (!_origialIds) {
        _origialIds = [NSMutableArray array];
    }
    return _origialIds;
}

- (TimelineCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[TimelineCommentView alloc] init];
    }
    return _commentView;
}

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
        [_tableView registerClass:[TF_TimeVideoCell class] forCellReuseIdentifier:@"TF_TimeVideoCell"];
    }
    return _tableView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton new];
        [_backBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setImage:[UIImage imageNamed:@"NavBackWhite"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIView *)topV{
    if (!_topV) {
        _topV = [[UIView alloc] init];
        
//        self.rightbtn = [self.customNavBar setRightBtnWithImageName:@"icon_more" title:nil highlightedImageName:@"icon_more"];
    }
    return _topV;
}

- (UILabel *)titleL{
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.font = XHQBoldFont(20);
        _titleL.textColor = [UIColor whiteColor];
    }
    return _titleL;
}

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
            [self.controlView videoPlayer:self.player bufferTime:bufferTime];
        } else if ([self.player.controlView isEqual:self.controlView]) {
            [self.fullControlView videoPlayer:self.player bufferTime:bufferTime];
        }
//        [self.controlView videoPlayer:self.player bufferTime:bufferTime];
    };
    
    /// 停止的时候找出最合适的播放
    self.player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.player.playingIndexPath) return;
        if (indexPath.row == self.dataSource.count-1) {
            /// 加载下一页数据
//            [self.tableView.mj_footer beginRefreshing];
            [self loadMore];
        }
        [self playTheVideoAtIndexPath:indexPath];
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
//        asset.muted = YES;
        [self saveVideoThumbnailInPlayerReadyToPlay:self.player.playingIndexPath];
    };
}

- (void)playTheIndex:(NSInteger)index {
    @weakify(self)
    /// 指定到某一行播放
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
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
        BlogInfo *blog = self.dataSource[indexPath.row];
        if (!blog.content.isVideoContent) {
            return;
        }
        TF_TimeVideoCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell resetVideoThumbnail];
    }];
}

#pragma mark - UIScrollViewDelegate  列表播放必须实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
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

#pragma mark - ZFTableViewCellDelegate

- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath];
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    BlogInfo *blog = self.dataSource[indexPath.row];
    
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
    self.fullControlView.titleLabel.text = video.file_name;
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

@end
