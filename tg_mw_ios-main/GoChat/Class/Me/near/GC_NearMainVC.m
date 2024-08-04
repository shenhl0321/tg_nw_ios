//
//  GC_NearMainVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/16.
//

#import "GC_NearMainVC.h"
#import "GC_NearPeopleVC.h"
#import "GC_PublishGroupVC.h"

@interface GC_NearMainVC ()
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSArray *aTitles;

@end

@implementation GC_NearMainVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)initUI{
//    self.view.backgroundColor = [UIColor blueColor];
    _aTitles = @[@"附近人".lv_localized,@"公开群".lv_localized];
    
    GC_NearPeopleVC *nearVC = [[GC_NearPeopleVC alloc] init];
    GC_PublishGroupVC *publishVC = [[GC_PublishGroupVC alloc] init];
    
    _vcs = [[NSMutableArray alloc] init];
    [_vcs addObject:nearVC];
    [_vcs addObject:publishVC];

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
//    self.itemMargin = 20;
//    self.scrollEnable = NO;
//    self.progressHeight = 3.5;
//    self.progressWidth = 20;
//    UIView *view = [UIView new];
//    view.backgroundColor = [UIColor redColor];
//    view.frame = CGRectMake(0, 0, 100, 84);
//    self.menuView.leftView = view;
    [self reloadData];
    self.selectIndex = self.index;
}

-(CGFloat)topMargin{
    return 78-20+APP_STATUS_BAR_HEIGHT;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(67, APP_STATUS_BAR_HEIGHT -3, APP_SCREEN_WIDTH-67 - 120, 50);
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
