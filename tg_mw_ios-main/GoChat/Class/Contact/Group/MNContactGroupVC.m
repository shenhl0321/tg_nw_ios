//
//  MNContactGroupVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/1.
//

#import "MNContactGroupVC.h"
#import "MNContactGroupContentVC.h"

@interface MNContactGroupVC ()

@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSArray *aTitles;
@property (nonatomic, strong) MNContactGroupContentVC *manageVC;
@property (nonatomic, strong) MNContactGroupContentVC *enterVC;

@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UILabel *titleLab;

@end

@implementation MNContactGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyCalculatesItemWidths = NO;
    self.scrollEnable = NO;
//    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
    self.itemMargin = 10;
    self.menuItemWidth = (APP_SCREEN_WIDTH-15*2)*0.5;
    _aTitles = @[@"我管理的群聊".lv_localized,@"我加入的群聊".lv_localized];
    
   
    _vcs = [[NSMutableArray alloc] init];
    [_vcs addObject:self.manageVC];
    [_vcs addObject:self.enterVC];
    [self reloadData];
    

    [self.view addSubview:self.leftBtn];
    [self.view addSubview:self.titleLab];
    
    [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.top.equalTo(self.view).offset(kStatusBarHeight);
        make.left.equalTo(self.view);
        make.width.height.mas_offset(44);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(self.leftBtn);
        make.centerX.equalTo(self.view);
    }];
}
- (void)backButton{
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIButton *)leftBtn{
    if (!_leftBtn){
        _leftBtn = [[UIButton alloc] init];
        [_leftBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateNormal];
        [_leftBtn addTarget:self action:@selector(backButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}
- (UILabel *)titleLab{
    if (!_titleLab){
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"群聊";
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.font = [UIFont boldSystemFontOfSize:20];
    }
    return _titleLab;
}
-(MNContactGroupContentVC *)manageVC{
    if (!_manageVC) {
        _manageVC = [[MNContactGroupContentVC alloc] initWithManaged:YES];
    }
    return _manageVC;
}

-(MNContactGroupContentVC *)enterVC{
    if (!_enterVC) {
        _enterVC = [[MNContactGroupContentVC alloc] initWithManaged:NO];
    }
    return _enterVC;
}

-(CGFloat)topMargin{
    return APP_STATUS_BAR_HEIGHT+64+42+5+50;
}
- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    
    return CGRectMake(0,kTabBarHeight, APP_SCREEN_WIDTH, 50);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
   
    CGRect rect = CGRectMake(0, 50, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-(self.topMargin+kBottom34()));
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
    vc.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-self.topMargin-kBottom34()- APP_TAB_BAR_HEIGHT2());
//    vc.contentView.frame = CGRectMake(0, 0, kScreenWidth, self.vcHeight-a);
}
@end
