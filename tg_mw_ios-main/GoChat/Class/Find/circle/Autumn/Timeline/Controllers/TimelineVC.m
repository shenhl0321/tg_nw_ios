//
//  TimelineVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "TimelineVC.h"
#import "TimelineListVC.h"
#import "PublishTimelinesVC.h"
#import "UserTimelineVC.h"
#import "TimelinePostProgressView.h"
#import "HXPhotoPicker.h"
#import "TimelineHelper.h"
#import "UserinfoHelper.h"
#import <IJSFoundation/IJSFoundation.h>


@interface TimelineVC ()<JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, BusinessListenerProtocol,HXCustomNavigationControllerDelegate, HXCustomCameraViewControllerDelegate>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *controllers;
@property (nonatomic, strong) JXCategoryTitleView *categoryView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) TimelinePostProgressView *progressView;

@property (nonatomic, weak) UILabel *unreadLabel;

@property (nonatomic, strong) HXPhotoManager *photoManager;

@end

static NSInteger const maxVideoDuration = 180;

@implementation TimelineVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [BusinessFramework.defaultBusinessFramework registerBusinessListener:self];
}

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.categoryView.frame = CGRectMake(67, APP_STATUS_BAR_HEIGHT - 10, APP_SCREEN_WIDTH-67 - 130, 60);
    self.progressView.frame = CGRectMake(0, kNavigationStatusHeight(), self.view.bounds.size.width, 50);
    CGFloat listY = self.progressView.isHidden ? kNavigationStatusHeight() : self.progressView.xhq_bottom;
    self.listContainerView.frame = CGRectMake(0, listY, self.view.bounds.size.width, self.view.bounds.size.height - listY);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadMessage];
}

- (void)dy_initData {
    [super dy_initData];
    self.titles = @[@"热门".lv_localized, @"关注".lv_localized, @"好友".lv_localized];
    TimelineListVC *hot = [[TimelineListVC alloc] init];
    hot.type = TimelineType_Hot;
    TimelineListVC *follow = [[TimelineListVC alloc] init];
    follow.type = TimelineType_Follow;
    TimelineListVC *friend = [[TimelineListVC alloc] init];
    friend.type = TimelineType_Friend;
    self.controllers = @[hot, follow, friend];
    [TimelineHelper helper];
}

- (void)dy_initUI {
    [super dy_initUI];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.progressView];
    
    JXCategoryIndicatorLineView *indicator = [[JXCategoryIndicatorLineView alloc] init];
    indicator.indicatorColor = XHQHexColor(0x222222);
    indicator.indicatorWidth = 20;
    indicator.indicatorHeight = 3.5;
    indicator.verticalMargin = -2;
    self.categoryView.indicators = @[indicator];
//    self.navigationItem.titleView = self.categoryView;
    [self.customNavBar addSubview:self.categoryView];
    [self.view addSubview:self.listContainerView];
    
    [self setupNavigationItem];
}

- (void)setupNavigationItem {
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add setImage:[UIImage imageNamed:@"icon_circle_publish"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];

    
    UIView *mineContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIView *imageContainer = [[UIView alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
    [imageContainer xhq_cornerRadius:15];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = imageContainer.bounds;
    [UserinfoHelper setUserAvatar:UserInfo.shareInstance._id inImageView:imageView];
    [imageContainer addSubview:imageView];
    UILabel *badge = [[UILabel alloc] init];
    badge.backgroundColor = XHQHexColor(0xFD4E57);
    badge.textColor = UIColor.whiteColor;
    badge.font = [UIFont systemFontOfSize:11];
    badge.textAlignment = NSTextAlignmentCenter;
    badge.frame = CGRectMake(25, 0, 16, 16);
    [badge xhq_cornerRadius:8];
    [mineContainer addSubview:imageContainer];
    [mineContainer addSubview:badge];
    badge.hidden = YES;
    self.unreadLabel = badge;
    @weakify(self);
    [mineContainer xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        UserTimelineVC *user = [[UserTimelineVC alloc] initWithUserid:UserInfo.shareInstance._id];
        [self.navigationController pushViewController:user animated:YES];
    }];
    
    [self.view addSubview:add];
    [add mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-65);
        make.width.height.mas_equalTo(24);
        make.top.mas_equalTo(APP_STATUS_BAR_HEIGHT +8);
    }];
    
    [self.view addSubview:mineContainer];
    [mineContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(30);
        make.centerY.mas_equalTo(add.mas_centerY).offset(-5);
    }];
  
}

- (void)reloadMessage {
    [TimelineHelper queryUnreadCountCompletion:^(NSInteger count) {
        self.unreadLabel.text = [NSString stringWithFormat:@"%ld", count];
        self.unreadLabel.hidden = count == 0;
    }];
}

#pragma mark rightItemClick
- (void)rightItemClick {
    if (!self.progressView.isHidden) {
        [self.view makeToast:@"上一条动态还在发送中，请稍后在操作".lv_localized];
        return;
    }
    
    HXPhotoBottomViewModel *model1 = [[HXPhotoBottomViewModel alloc] init];
    model1.title = [NSBundle hx_localizedStringForKey:@"拍摄".lv_localized];
    model1.subTitle = [NSBundle hx_localizedStringForKey:@"照片或视频".lv_localized];
    model1.subTitleDarkColor = [UIColor hx_colorWithHexStr:@"#999999"];
    model1.cellHeight = 65.f;
    
    HXPhotoBottomViewModel *model2 = [[HXPhotoBottomViewModel alloc] init];
    model2.title = [NSBundle hx_localizedStringForKey:@"从手机相册选择".lv_localized];
    [HXPhotoBottomSelectView showSelectViewWithModels:@[model1, model2] headerView:nil cancelTitle:nil selectCompletion:^(NSInteger index, HXPhotoBottomViewModel * _Nonnull model) {
        self.photoManager.selectPhotoFinishDismissAnimated = NO;
        self.photoManager.cameraFinishDismissAnimated = NO;
        if (index == 0) {
            [self hx_presentCustomCameraViewControllerWithManager:self.photoManager delegate:self];
        }else if (index == 1){
            [self hx_presentSelectPhotoControllerWithManager:self.photoManager delegate:self];
        }
    } cancelClick:nil];
}

#pragma mark - JXCategoryListContainerViewDelegate

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    return self.controllers[index];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
        case MakeID(EUserManager, EUser_Timeline_Publish_Success):
            self.progressView.sendingBlog = (BlogInfo *)inParam;
            if (self.categoryView.selectedIndex != 2) {
                [self.categoryView selectItemAtIndex:2];
            }
            break;
        case MakeID(EUserManager, EUser_Timeline_UnReadMessage):
            [self reloadMessage];
            break;
        default:
            break;
    }
}
#pragma mark - < HXCustomCameraViewControllerDelegate >
- (void)customCameraViewController:(HXCustomCameraViewController *)viewController didDone:(HXPhotoModel *)model {
    [self.photoManager afterListAddCameraTakePicturesModel:model];
}

- (void)customCameraViewControllerFinishDismissCompletion:(HXPhotoPreviewViewController *)previewController {
    [self pushPublishTimelineVC];
}

#pragma mark - < HXCustomNavigationControllerDelegate >
- (void)photoNavigationViewControllerFinishDismissCompletion:(HXCustomNavigationController *)photoNavigationViewController {
    [self pushPublishTimelineVC];
}

- (void)pushPublishTimelineVC {
    self.photoManager.selectPhotoFinishDismissAnimated = YES;
    self.photoManager.cameraFinishDismissAnimated = YES;
    PublishTimelinesVC *vc = [[PublishTimelinesVC alloc] init];
    vc.photoManager = self.photoManager;
    [self.navigationController pushViewController:vc animated:YES];
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.delegate = self;
        _categoryView.listContainer = self.listContainerView;
        _categoryView.titles = self.titles;
        _categoryView.cellSpacing = 0;
        _categoryView.cellWidth = 210/3;
        _categoryView.cellWidthZoomEnabled = YES;
        _categoryView.titleColorGradientEnabled = YES;
        _categoryView.titleLabelZoomEnabled = YES;
        _categoryView.titleLabelStrokeWidthEnabled = YES;
        _categoryView.titleFont = [UIFont regularCustomFontOfSize:16];
        _categoryView.titleSelectedFont = [UIFont semiBoldCustomFontOfSize:24];
//        _categoryView.titleLabelZoomScale = 1.5;
        _categoryView.titleColor = [UIColor colorTextFor23272A];
        _categoryView.titleSelectedColor = [UIColor colorTextFor23272A];
        _categoryView.titleLabelMaskEnabled = YES;
    }
    return _categoryView;
}

// 列表容器视图
- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _listContainerView;
}

- (TimelinePostProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[TimelinePostProgressView alloc] init];
        @weakify(self);
        _progressView.changedBlock = ^{
            @strongify(self);
            [self viewDidLayoutSubviews];
        };
    }
    return _progressView;
}

- (HXPhotoManager *)photoManager {
    if (!_photoManager) {
        _photoManager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _photoManager.configuration.type = HXConfigurationTypeWXMoment;
        _photoManager.configuration.videoCanEdit = NO;
        _photoManager.configuration.lookGifPhoto = NO;
        _photoManager.configuration.videoMaximumSelectDuration = 180;
        _photoManager.configuration.themeColor = UIColor.whiteColor;
        _photoManager.configuration.openCamera = NO;
        _photoManager.configuration.hideOriginalBtn = YES;
        _photoManager.configuration.saveSystemAblum = YES;
        _photoManager.configuration.videoMaximumDuration = 180;
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"JSPhotoSDK" ofType:@"bundle"];
        NSString *filePath = [bundlePath stringByAppendingString:@"/Expression"];
        [IJSFFilesManager ergodicFilesFromFolderPath:filePath completeHandler:^(NSInteger fileCount, NSInteger fileSzie, NSMutableArray *filePath) {
            HXPhotoEditChartletTitleModel *netModel = [HXPhotoEditChartletTitleModel modelWithImageNamed:@"hx_sticker_cover"];
            NSMutableArray *models = [NSMutableArray array];
            for (NSString *path in filePath) {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                HXPhotoEditChartletModel *subModel = [HXPhotoEditChartletModel modelWithImage:image];
                [models addObject:subModel];
            }
            netModel.models = models.copy;
            self->_photoManager.configuration.photoEditConfigur.chartletModels = @[netModel];
        }];
        
    }
    return _photoManager;
}


@end
