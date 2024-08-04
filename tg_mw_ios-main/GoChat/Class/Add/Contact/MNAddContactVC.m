//
//  MNAddContactVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNAddContactVC.h"
#import "MNAddContactFriendVC.h"
#import "MNAddContactGroupVC.h"

@interface MNAddContactVC ()
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSArray *aTitles;
@property (nonatomic, strong) MNAddContactGroupVC *addGroupVC;
@property (nonatomic, strong) MNAddContactFriendVC *addFriendVC;
@end

@implementation MNAddContactVC


-(void)viewDidLoad{
    [super viewDidLoad];
    _aTitles = @[@"好友".lv_localized,@"群组".lv_localized];
    _vcs = [[NSMutableArray alloc] initWithObjects:self.addFriendVC,self.addGroupVC, nil];
    self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
    self.titleSizeSelected = 22.f;
    self.titleSizeNormal = 18.f;
    self.progressHeight = 7;
    self.progressWidth = 7;
    self.progressColor = HEXCOLOR(0x6fe6b2);
    
    [self reloadData];
    
    
}

-(MNAddContactGroupVC *)addGroupVC{
    if (!_addGroupVC) {
        _addGroupVC = [[MNAddContactGroupVC alloc] init];
    }
    return _addGroupVC;
}

-(MNAddContactFriendVC *)addFriendVC{
    if (!_addFriendVC) {
        _addFriendVC = [[MNAddContactFriendVC alloc] init];
    }
    return _addFriendVC;
}

-(CGFloat)topMargin{
    return 78-20+APP_STATUS_BAR_HEIGHT;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(67, APP_STATUS_BAR_HEIGHT -3, APP_SCREEN_WIDTH-2*67, 50);
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
    [vc.customNavBar removeFromSuperview];
    vc.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-self.topMargin-kBottom34());
//    vc.contentView.frame = CGRectMake(0, 0, kScreenWidth, self.vcHeight-a);
}

@end
