//
//  GC_CircleMainVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_CircleMainVC.h"

#import "GC_CircleHotVC.h"
#import "GC_CircleFollowVC.h"
#import "GC_CircleGoodFriendVC.h"
#import "GC_PublishDynamicVC.h"
#import "TimelineListVC.h"

@interface GC_CircleMainVC ()
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSArray *aTitles;

@property (nonatomic, strong) UIButton *publishBtn;

@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) UIButton *dynamicBtn;
@end

@implementation GC_CircleMainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    // Do any additional setup after loading the view.
}

- (UIButton *)publishBtn{
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishBtn setImage:[UIImage imageNamed:@"icon_circle_publish"] forState:UIControlStateNormal];
        [_publishBtn addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}

- (UIButton *)photoBtn{
    if (!_photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoBtn setImage:[UIImage imageNamed:@"ic_default_header"] forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}


- (void)initUI{
    [self.view addSubview:self.publishBtn];
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-65);
        make.width.height.mas_equalTo(24);
        make.top.mas_equalTo(APP_STATUS_BAR_HEIGHT +8);
    }];
    
    [self.view addSubview:self.photoBtn];
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(30);
        make.centerY.mas_equalTo(self.publishBtn.mas_centerY);
    }];
    
//    self.view.backgroundColor = [UIColor blueColor];
    _aTitles = @[@"热门".lv_localized,@"关注".lv_localized,@"好友".lv_localized];
    
//    GC_CircleHotVC *hotVC = [[GC_CircleHotVC alloc] init];
//    GC_CircleFollowVC *followVC = [[GC_CircleFollowVC alloc] init];
//    GC_CircleGoodFriendVC *friendVC = [[GC_CircleGoodFriendVC alloc] init];
    
    TimelineListVC *hotVC = [[TimelineListVC alloc] init];
    hotVC.type = TimelineType_Hot;
    TimelineListVC *followVC = [[TimelineListVC alloc] init];
    followVC.type = TimelineType_Follow;
    TimelineListVC *friendVC = [[TimelineListVC alloc] init];
    friendVC.type = TimelineType_Friend;
    
    _vcs = [[NSMutableArray alloc] init];
    [_vcs addObject:hotVC];
    [_vcs addObject:followVC];
    [_vcs addObject:friendVC];
    [self confi];
    
}
- (void)confi{
//    self.menuView.backgroundColor = [UIColor colorTextForFFFFFF];
//    self.scrollView.backgroundColor = [UIColor colorTextForFFFFFF];
//    self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
//    self.menuViewStyle = WMMenuViewStyleLine;
//    self.titleSizeSelected = 24.f;
//    self.titleSizeNormal = 16.f;
//    self.titleColorNormal = [UIColor colorTextFor23272A];
//    self.titleColorSelected = [UIColor colorTextFor23272A];
//    self.titleFontName = @"PingFangSC-Regular";
//    self.titleFontNameSelected = @"PingFangSC-Semibold";
//    self.automaticallyCalculatesItemWidths = YES;
    self.itemMargin = 10;
    self.scrollEnable = YES;
//    self.progressHeight = 3.5;
//    self.progressWidth = 20;
//    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor redColor];
//    view.frame = CGRectMake(0, 0, 100, 84);
//    self.menuView.leftView = view;
    [self reloadData];
}

-(CGFloat)topMargin{
    return 78-20+APP_STATUS_BAR_HEIGHT;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(67, APP_STATUS_BAR_HEIGHT -3, APP_SCREEN_WIDTH-67 - 130, 50);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
   
    CGRect rect = CGRectMake(0, self.topMargin, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-(self.topMargin+kBottom34()));
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

-(void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof BaseVC *)viewController withInfo:(NSDictionary *)info{
    BaseVC *vc = viewController;
    vc.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-kNavBarHeight);
//    vc.contentView.frame = CGRectMake(0, 0, kScreenWidth, self.vcHeight-a);
}

- (void)publishAction{
//    GC_PublishDynamicVC *vc = [[GC_PublishDynamicVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (void)photoAction{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
