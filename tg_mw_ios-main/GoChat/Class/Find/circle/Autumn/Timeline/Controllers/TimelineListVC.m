//
//  TimelineListVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "TimelineListVC.h"
#import "TimelineInfoVC.h"
#import "WFPopViewController.h"
#import "IQKeyboardManager.h"
#import "TimelineListCell.h"
#import "TimelineCommentView.h"
#import "VideoResourceLoadManager.h"
#import "UIImageView+VideoThumbnail.h"
#import "VideoThumbnailManager.h"
#import "TF_TimeVideoBrowseVC.h"
#import "VideoThumbnailDownload.h"
#import "VideoThumbnailStore.h"
@interface TimelineListVC ()<BusinessListenerProtocol>

@property (nonatomic, strong) TimelineCommentView *commentView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, assign, getter=isFirstInController) BOOL firstInController;


@end

@implementation TimelineListVC

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    IQKeyboardManager.sharedManager.enable = NO;
    IQKeyboardManager.sharedManager.enableAutoToolbar = NO;
    self.player.viewControllerDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    IQKeyboardManager.sharedManager.enable = YES;
    IQKeyboardManager.sharedManager.enableAutoToolbar = YES;
    self.player.viewControllerDisappear = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.firstInController) {
        [self.player stopCurrentPlayingCell];
        [self prepareToPlay];
    } else {
        self.firstInController = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    [_commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.height.equalTo(@60);
        make.top.equalTo(self.tableView.mas_bottom);
    }];
}

- (void)dy_initData {
    [super dy_initData];
    self.firstInController = YES;
    self.emptyTitle = @"暂无动态列表".lv_localized;
    self.addLoadFooter = YES;
    [self.dataArray addObject:self.sectionArray0];
}

- (void)dy_initUI {
    [super dy_initUI];
    [self.view addSubview:self.commentView];
    [self setupPlayer];
    [self.tableView xhq_registerCell:TimelineListCell.class];
}

- (void)dy_request {
    [TimelineHelper queryTimelineList:self.type offset:self.currentPage.intValue topic:self.topic completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        if (self.isDropdownRefresh) {
            [self.sectionArray0 removeAllObjects];
        }
        self.totalPage = blogs.count > 0 ? [NSString stringWithFormat:@"%ld", self.currentPage.integerValue + 1] : self.currentPage;
        for (BlogInfo *info in blogs) {
            [self dy_configureDataWithModel:info];
        }
        [self dy_tableViewReloadData];
        [self.player stopCurrentPlayingCell];
        [self prepareToPlay];
        
        NSInteger offset = blogs.lastObject.ids;
        [TimelineHelper queryTimelineList:self.type offset:(int)offset topic:self.topic completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
            for (BlogInfo *info in blogs) {
//                [self dy_configureDataWithModel:info];
                [self autoDownloadMedia:info];
            }
        }];
        
        
    }];
}

- (void)dy_load {
    TimelineListCellItem *item = self.sectionArray0.lastObject;
    BlogInfo *blog = (BlogInfo *)item.cellModel;
    self.currentPage = [NSString stringWithFormat:@"%ld", blog.ids];
    [self dy_request];
}

- (void)setupPlayer {
    self.controlView = [TimelineHelper controlView];
    self.player = [TimelineHelper playerWithScrollView:self.tableView controlView:self.controlView];
    
    /// 滚动中播放
    @weakify(self)
    self.player.zf_playerShouldPlayInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if ([indexPath compare:self.player.playingIndexPath] != NSOrderedSame) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
        }
    };
    /// 滚动结束播放
//    self.player.zf_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
//        @zf_strongify(self)
//        if (!self.player.playingIndexPath) {
//            [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
//        }
//    };
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        // 打开后播放时有声音
//        asset.muted = YES;
        [self saveVideoThumbnailInPlayerReadyToPlay:self.player.playingIndexPath];
    };
}

- (void)prepareToPlay {
    if (self.player.playingIndexPath) {
        return;
    }
    @weakify(self);
    [self.player zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self);
        [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
    }];
}


#pragma mark - ConfigureData
- (void)dy_configureDataWithModel:(BlogInfo *)model {
    TimelineListCellItem *item = TimelineListCellItem.item;
    item.cacheKey = [NSString stringWithFormat:@"%ld", model.ids];
    item.cellModel = model;
    [self.sectionArray0 addObject:item];
    [self autoDownloadMedia:model];
    
}

// 自动下载图片或者视频
-(void)autoDownloadMedia:(BlogInfo *)model{
    if (model.content.isVideoContent) { // 视频
        VideoInfo *video = model.content.video;
//        if (!video.isVideoDownloaded) {
//            long videoId = video.video._id;
//            if ([[TelegramManager shareInstance] isFileDownloading:videoId type:FileType_Message_Video]) {
//                return;
//            }
//            long fileId = video.video._id;
//            long count = video.video.expected_size;
//            NSString *mimeType = video.mime_type;
//
//        }
        
//        self.image = placeholder;
//        self.videoId = video.video._id;
        
        [VideoThumbnailManager.manager thumbnailForVideo:video result:nil];
//        [VideoThumbnailDownload.shared downloadThumbnailWithVideo:video result:^(UIImage * _Nullable image) {
//            if (image) {
//                [VideoThumbnailStore storeImage:image withVideoName:video.file_name];
//            }
//        }];
    } else { // 图片
        NSArray<PhotoInfo *> *photos = model.content.photos;
        for (PhotoInfo *photo in photos) {
            if (!photo.messagePhoto.isPhotoDownloaded) {
                long photoId = photo.messagePhoto.photo._id;
                if([[TelegramManager shareInstance] isFileDownloading:photoId type:FileType_Message_Photo]) {
                    return;
                }
                NSString *key = [NSString stringWithFormat:@"timeline_photo_%ld", photoId];
                [[FileDownloader instance] downloadImage:key fileId:photoId type:FileType_Message_Photo];
            }
        }
        
    }
    
    
    
}

#pragma mark - UITableViewDataSource
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.sectionArray0.count > 0 ? 2 : 0;
//}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineListCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    TimelineInfoVC *info = [[TimelineInfoVC alloc] init];
//    BlogInfo *blog = (BlogInfo *)item.cellModel;
//    if (blog.content.isVideoContent) {
//        TF_TimeVideoBrowseVC *vc = [[TF_TimeVideoBrowseVC alloc] init];
//        vc.type = self.type;
//        NSMutableArray *mut = [NSMutableArray array];
//        NSArray *sec = self.dataArray[indexPath.section];
//        for (int i = indexPath.row; i < sec.count; i++) {
//            TimelineListCellItem *item = sec[i];
//            [mut addObject:item.cellModel];
//        }
//        vc.blogs = mut;
//        
//        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//        nav.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:nav animated:YES completion:nil];
//        return;
//    }
    info.blog = (BlogInfo *)item.cellModel;
    [self.navigationController pushViewController:info animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimelineListCell *cell = (TimelineListCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    @weakify(self)
    __block NSIndexPath *indexP = indexPath;
    cell.photoCall = ^(TimelineListCell * _Nonnull cell, NSInteger index) {
        @strongify(self)
        
        TF_TimeVideoBrowseVC *vc = [[TF_TimeVideoBrowseVC alloc] init];
        vc.type = self.type;
        vc.topic = self.topic;
        NSMutableArray *mut = [NSMutableArray array];
        NSArray *sec = self.dataArray[indexP.section];
        for (NSInteger i = indexP.row; i < sec.count; i++) {
            TimelineListCellItem *item = sec[i];
            [mut addObject:item.cellModel];
        }
        vc.blogs = mut;
        vc.firstIndex = index;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    };
    return cell;
}

- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:TimelineListCellItem.class]) {
        TimelineListCellItem *m = (TimelineListCellItem *)item;
        if (m.response == TimelineResponse_Comment) {
            BlogInfo *blog = (BlogInfo *)item.cellModel;
            [self.commentView commentBlog:blog.ids];
        } else if (m.response == TimelineResponse_Play) {
            [self playTheVideoAtIndexPath:indexPath scrollAnimated:YES];
        } else if (m.response == TimelineResponse_BrowseVideo) {
            TF_TimeVideoBrowseVC *vc = [[TF_TimeVideoBrowseVC alloc] init];
            vc.type = self.type;
            vc.topic = self.topic;
            NSMutableArray *mut = [NSMutableArray array];
            NSArray *sec = self.dataArray[indexPath.section];
            for (NSInteger i = indexPath.row; i < sec.count; i++) {
                TimelineListCellItem *item = sec[i];
                [mut addObject:item.cellModel];
            }
            vc.blogs = mut;
//            vc.firstIndex = 1;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Timeline_Follows_Change):
            /// 关注
            [self.tableView reloadData];
            [self prepareToPlay];
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
        case MakeID(EUserManager, EUser_Timeline_Publish_Success):
            break;
        case MakeID(EUserManager, EUser_Timeline_Update_Fail):
            break;
        case MakeID(EUserManager, EUser_Timeline_Update_Success):
            [self publishTimelineSuccess:inParam];
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
    NSInteger blogId = [param.firstObject integerValue];
    BOOL isLike = [param.lastObject boolValue];
    for (TimelineListCellItem *item in self.sectionArray0) {
        BlogInfo *blog = (BlogInfo *)item.cellModel;
        if (blog.ids == blogId) {
            blog.liked = isLike;
            isLike ? blog.like_count ++ : blog.like_count --;
            blog.like_count = MAX(0, blog.like_count);
            break;
        }
    }
    [self.tableView reloadData];
    [self prepareToPlay];
}

/// 收到新的评论
- (void)infoCommentChange:(NSArray *)param {
    NSInteger blogId = [param.firstObject integerValue];
    for (TimelineListCellItem *item in self.sectionArray0) {
        BlogInfo *blog = (BlogInfo *)item.cellModel;
        if (blog.ids == blogId) {
            blog.reply_count ++;
            break;
        }
    }
    [self.tableView reloadData];
    [self prepareToPlay];
}

/// 视频下载
- (void)videoDownloadChanged:(id)param {
    if (![param isKindOfClass:FileInfo.class]) {
        return;
    }
    if (self.sectionArray0.count == 0) {
        return;
    }
    TimelineListCellItem *item = self.dataArray[self.player.playingIndexPath.section][self.player.playingIndexPath.row];
    if (!item) {
        return;
    }
    FileInfo *fileInfo = (FileInfo *)param;
    BlogInfo *blog = (BlogInfo *)item.cellModel;
    if (fileInfo._id != blog.content.video.video._id) {
        return;
    }
    blog.content.video.video = fileInfo;
}

/// 发布动态成功
- (void)publishTimelineSuccess:(id)param {
    [self dy_refresh];
}

/// 删除动态
- (void)deleteTimeline:(id)param {
    NSInteger blogId = [param integerValue];
    for (TimelineListCellItem *item in self.sectionArray0) {
        BlogInfo *blog = (BlogInfo *)item.cellModel;
        if (blog.ids == blogId) {
            [self.sectionArray0 removeObject:item];
            break;
        }
    }
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UIScrollViewDelegate 列表播放必须实现

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

/// 播放视频
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollAnimated:(BOOL)animated {
    TimelineListCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    BlogInfo *blog = (BlogInfo *)item.cellModel;
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
    if (animated) {
         [self.player playTheIndexPath:indexPath assetURL:url scrollPosition:ZFPlayerScrollViewScrollPositionCenteredVertically animated:YES];
     } else {
         [self.player playTheIndexPath:indexPath assetURL:url];
     }
    self.controlView.portraitControlView.titleLabel.text = video.file_name;
    [self.controlView.bgImgView setThumbnailImage:video];
}

- (void)saveVideoThumbnailInPlayerReadyToPlay:(NSIndexPath *)indexPath {
    ZFAVPlayerManager *manager = (ZFAVPlayerManager *)self.player.currentPlayerManager;
    if (!manager.isPreparedToPlay) {
        return;
    }
    ZFPlayerControlView *controlView = (ZFPlayerControlView *)self.player.controlView;
    NSString *name = controlView.portraitControlView.titleLabel.text;
    @weakify(self);
    [VideoThumbnailManager.manager saveThumbnailAsset:manager.asset forVideoName:name completion:^{
        @strongify(self);
        TimelineListCellItem *item = self.dataArray[indexPath.section][indexPath.row];
        BlogInfo *blog = (BlogInfo *)item.cellModel;
        if (!blog.content.isVideoContent) {
            return;
        }
        TimelineListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell resetVideoThumbnail];
    }];
}

#pragma mark - getter
- (TimelineCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[TimelineCommentView alloc] init];
    }
    return _commentView;
}

@end
