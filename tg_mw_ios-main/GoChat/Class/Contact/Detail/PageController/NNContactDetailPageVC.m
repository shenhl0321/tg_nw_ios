//
//  NNContactDetailPageVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/20.
//

#import "NNContactDetailPageVC.h"
#import "MNContactDetailContentVC.h"
#import "MNSubInfoMediaVC.h"
#import "MNSubInfoDocumentVC.h"
#import "MNSubInfoVoiceVC.h"
#import "MNSubInfoLinkVC.h"
#import "MMSubInfoGroupVC.h"
#import "MNSubInfoGifVC.h"

@interface NNContactDetailPageVC ()
<MNContactDetailContentVCDelegate>

@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) MNSubInfoMediaVC *mediaVC;
@property (nonatomic, strong) MNSubInfoDocumentVC *documentVC;
@property (nonatomic, strong) MNSubInfoVoiceVC *voiceVC;
@property (nonatomic, strong) MNSubInfoLinkVC *linkVC;
@property (nonatomic, strong) MMSubInfoGroupVC *groupVC;
@property (nonatomic, strong) MNSubInfoGifVC *gifVC;
@property (nonatomic, strong) NSMutableArray *aTitles;
@property (nonatomic, assign, readonly) CGFloat mnMenuHeight;
@property (nonatomic, assign, readonly) CGFloat mnContentHeight;

@end

@implementation NNContactDetailPageVC


- (instancetype)initWithUser:(UserInfo *)user
{
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}
- (void)backButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.customNavBar removeFromSuperview];
    [self.customNavBar setTitle:@"收发的图片/视频".lv_localized];
    [self.customNavBar setLeftBtnWithImageName:@"NavBack" title:@"" highlightedImageName:@"NavBack"];
//    [self.contentView removeFromSuperview];
    self.menuView.backgroundColor = [UIColor whiteColor];
//    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
    self.titleSizeSelected = 16.f;
    self.titleSizeNormal = 15.f;
    self.menuItemWidth = floor(APP_SCREEN_WIDTH/6.0);
    self.titleColorNormal = [UIColor colorTextForA9B0BF];
    self.titleColorSelected = [UIColor colorTextFor0DBFC0];
    self.titleFontName = @"PingFangSC-Regular";
    self.titleFontNameSelected = @"PingFangSC-Semibold";
    

    self.menuViewStyle = WMMenuViewStyleLine;
    self.menuView.style = WMMenuViewStyleLine;
//    self.menuView.lineColor = [UIColor colorForTextOrange];
    self.itemMargin = 0;
    self.progressHeight = 2;
    self.progressColor = [UIColor colorMain];
    self.pageAnimatable = YES;
//    self.automaticallyCalculatesItemWidths = YES;
//    self.scrollEnable = FALSE;
    [self reloadData];
}

-(NSMutableArray *)aTitles{
    if (!_aTitles) {
        _aTitles = [[NSMutableArray alloc] init];
        [_aTitles addObject:@"媒体".lv_localized];
        [_aTitles addObject:@"文件".lv_localized];
        [_aTitles addObject:@"语音".lv_localized];
        [_aTitles addObject:@"链接".lv_localized];
        [_aTitles addObject:@"GIF".lv_localized];
        [_aTitles addObject:@"群组".lv_localized];
    }
    return _aTitles;
}

-(NSMutableArray *)vcs{
    if (!_vcs) {
        _vcs = [[NSMutableArray alloc] init];
        [_vcs addObject:self.mediaVC];
        [_vcs addObject:self.documentVC];
        [_vcs addObject:self.voiceVC];
        [_vcs addObject:self.linkVC];
        [_vcs addObject:self.gifVC];
        [_vcs addObject:self.groupVC];
    }
    return _vcs;
}

-(MNSubInfoMediaVC *)mediaVC{
    if (!_mediaVC) {
        _mediaVC = [[MNSubInfoMediaVC alloc] initWithUser:self.user type:1];
        [_mediaVC refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight-kBottom34()];
        _mediaVC.delegate = self;
    }
    return _mediaVC;
}

-(MNSubInfoDocumentVC *)documentVC{
    if (!_documentVC) {
        _documentVC = [[MNSubInfoDocumentVC alloc] initWithUser:self.user type:2];
        [_documentVC refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight-kBottom34()];
        _documentVC.delegate = self;
    }
    return _documentVC;
}

-(MNSubInfoVoiceVC *)voiceVC{
    if (!_voiceVC) {
        _voiceVC = [[MNSubInfoVoiceVC alloc] initWithUser:self.user type:3];
        [_voiceVC refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight-kBottom34()];
        _voiceVC.delegate = self;
    }
    return _voiceVC;
}

-(MNSubInfoLinkVC *)linkVC{
    if (!_linkVC) {
        _linkVC = [[MNSubInfoLinkVC alloc] initWithUser:self.user type:4];
        [_linkVC refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight-kBottom34()];
        _linkVC.delegate = self;
    }
    return _linkVC;
}

-(MNSubInfoGifVC *)gifVC{
    if (!_gifVC) {
        _gifVC = [[MNSubInfoGifVC alloc] initWithUser:self.user type:5];
        [_gifVC refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight-kBottom34()];
        _gifVC.delegate = self;
    }
    return _gifVC;
}

-(MMSubInfoGroupVC *)groupVC{
    if (!_groupVC) {
        _groupVC = [[MMSubInfoGroupVC alloc] initWithUser:self.user type:6];
        [_groupVC refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight-kBottom34()];
        _groupVC.delegate = self;
    }
    return _groupVC;
}

-(CGFloat)mnMenuHeight{
    return 53;
}

-(CGFloat)mnContentHeight{
    
    return APP_SCREEN_HEIGHT-self.mnTop-kBottom34();
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    
    return CGRectMake(0,kNavBarAndStatusBarHeight, APP_SCREEN_WIDTH, self.mnMenuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGRect rect = CGRectMake(0, kNavBarAndStatusBarHeight + self.mnMenuHeight, APP_SCREEN_WIDTH, self.mnContentHeight-self.mnMenuHeight-kNavBarAndStatusBarHeight);
    return rect;
}

-(NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController{
    return self.vcs.count;
}

-(NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index{
    
    NSString *str = self.aTitles[index];
    return str;
}


-(UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    return self.vcs[index];
}

-(void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info{
//    viewController.view.backgroundColor = [UIColor colorWithRed:random()%255/255.0 green:random()%255/255.0 blue:random()%255/255.0 alpha:1];
}

-(void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof MNContactDetailContentVC *)viewController withInfo:(NSDictionary *)info{
//    viewController.contentView.frame = CGRectMake(0, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    [viewController refreshConetentViewWithHeight:self.mnContentHeight-self.mnMenuHeight];
    
//    vc.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-self.topMargin-kBottom34()- APP_TAB_BAR_HEIGHT2());
//    vc.contentView.frame = CGRectMake(0, 0, kScreenWidth, self.vcHeight-a);
}



@end
