//
//  RecentCallsViewController.m
//  GoChat
//
//  Created by 李标 on 2021/5/22.
//

#import "RecentCallsViewController.h"
#import "CallsSingleTableViewController.h"

@interface RecentCallsViewController ()

@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) CallsSingleTableViewController *AllListView;
@property (nonatomic, strong) CallsSingleTableViewController *callOutView;
@property (nonatomic, strong) CallsSingleTableViewController *callInView;
@end

@implementation RecentCallsViewController

- (instancetype)init
{
    self = [super init];
    if(self != nil)
    {
        [self initTabToolView];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self != nil)
    {
        [self initTabToolView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self != nil)
    {
        [self initTabToolView];
    }
    return self;
}

- (void)initTabToolView
{
    self.menuItems = @[@"所有通话".lv_localized, @"呼出".lv_localized, @"呼入".lv_localized];
    NSMutableArray *menuWidthItems = [NSMutableArray array];
    for(int i=0; i< self.menuItems.count; i++)
    {
        [menuWidthItems addObject:[NSNumber numberWithFloat:SCREEN_WIDTH/3]];
        //[str boundingRectWithSize:CGSizeMake(MAXFLOAT, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:FONT_S1]} context:nil].size.width + 1]
    }
    self.itemsWidths = menuWidthItems;
    self.itemMargin = 0;
    self.titleSizeNormal = FONT_S1;
    self.titleColorNormal = COLOR_C2;
    self.titleSizeSelected = FONT_S1;
    self.titleColorSelected = COLOR_C3;
    self.menuViewStyle = WMMenuViewStyleLine;
    self.menuViewLayoutMode = WMMenuViewLayoutModeScatter;
    self.progressWidth = 20;
    self.progressHeight = 3;
    self.progressColor = COLOR_CG1;
    self.progressViewBottomSpace = 2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.customNavBar setTitle:@"最近通话".lv_localized];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self setDefaultStyle];
    //去除导航栏分割线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (IBAction)gotoBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDefaultStyle
{
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:COLOR_C1,NSFontAttributeName:[UIFont boldSystemFontOfSize:FONT_S1]}];
    self.navigationController.navigationBar.tintColor = COLOR_CG1;
    if(self.navigationController.viewControllers.count>0 && self.navigationController.viewControllers[0] != self)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"com_nav_ic_back_white":@"com_nav_ic_back_black"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"com_nav_ic_back_white":@"com_nav_ic_back_black"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
}

#pragma mark - WMPageController
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController
{
    return self.menuItems.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    if(index == 0)
    {// 所有通话
        if(self.AllListView == nil)
        {
            self.AllListView = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"CallsSingleTableViewController"];
            self.AllListView.type = 0;
        }
        return self.AllListView;
    }
    else if(index == 1)
    {// 呼出通话
        if(self.callOutView == nil)
        {
            self.callOutView = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"CallsSingleTableViewController"];
            self.callOutView.type = 1;
        }
        return self.callOutView;
    }
    else if(index == 2)
    {// 呼入通话
        if(self.callInView == nil)
        {
            self.callInView = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"CallsSingleTableViewController"];
            self.callInView.type = 2;
        }
        return self.callInView;
    }
    else
    {
        return [BaseTableViewController new];
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index
{
    return [self.menuItems objectAtIndex:index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView
{
    return CGRectMake(0, kStatusBarHeight+kNavBarHeight, SCREEN_WIDTH, 50);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView
{
    return CGRectMake(0, kStatusBarHeight+kNavBarHeight - 10, SCREEN_WIDTH, SCREEN_HEIGHT-kStatusBarHeight-kNavBarHeight-50);
}

@end
