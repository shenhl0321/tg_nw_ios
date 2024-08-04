//
//  GC_RedRecordVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/13.
//

#import "GC_RedRecordVC.h"
#import "GC_ReceiveRecordVC.h"
#import "GC_GiveRecordVC.h"

@interface GC_RedRecordVC ()
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSArray *aTitles;
@property (nonatomic, assign) CGFloat topMargin;//内容距离顶端的距离

@end

@implementation GC_RedRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)initUI{
//    self.view.backgroundColor = [UIColor blueColor];
    _aTitles = @[@"收到的红包".lv_localized,@"发出的红包".lv_localized];
    
    GC_ReceiveRecordVC *friendVC = [[GC_ReceiveRecordVC alloc] init];
    GC_GiveRecordVC *groupVC = [[GC_GiveRecordVC alloc] init];
    _vcs = [[NSMutableArray alloc] init];
    [_vcs addObject:friendVC];
    [_vcs addObject:groupVC];
    [self confi];
    
}
- (void)confi{
    self.menuView.backgroundColor = [UIColor colorTextForFFFFFF];
    self.scrollView.backgroundColor = [UIColor colorTextForFFFFFF];
    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.titleSizeSelected = 19.f;
    self.titleSizeNormal = 17.f;
    self.titleColorNormal = [UIColor colorTextFor23272A];
    self.titleColorSelected = [UIColor colorTextForD94545];
    self.titleFontName = @"PingFangSC-Regular";
    self.titleFontNameSelected = @"PingFangSC-Semibold";
    self.automaticallyCalculatesItemWidths = YES;
    self.scrollEnable = NO;
    self.progressHeight = 3.5;
    self.progressWidth = 30;
    self.itemMargin = 30;
    [self reloadData];
}


-(CGFloat)topMargin{
    return 78-20+APP_STATUS_BAR_HEIGHT;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(67, APP_STATUS_BAR_HEIGHT -3, APP_SCREEN_WIDTH-67 - 67, 50);
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
