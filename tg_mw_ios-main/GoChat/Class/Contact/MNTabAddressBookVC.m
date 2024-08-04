//
//  MNTabAddressBookVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "MNTabAddressBookVC.h"
#import "MNContactAddressBookVC.h"
#import "MNContactGroupVC.h"
#import "MNContactFriendVC.h"
#import "SerchTf.h"
#import "MNContactSearchVC.h"
#import "MNAddContactVC.h"
#import "MNAddGroupVC.h"
#import "MNScanVC.h"
#import "MNContactDetailVC.h"
#import "GC_MyInfoVC.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"

@interface MNTabAddressBookVC ()
<MNScanVCDelegate>
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, strong) NSArray *aTitles;
@property (nonatomic, strong) SerchTf *searchBar;
@property (nonatomic, strong) UITextField *searchTf;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, assign) CGFloat topMargin;//内容距离顶端的距离
@end

@implementation MNTabAddressBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title1 = @"好友".lv_localized;
    NSString *title2 = @"群聊".lv_localized;
    NSString *title3 = @"通讯录".lv_localized;
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (config.can_see_address_book) {
        _aTitles = @[title1, title2, title3];
    } else {
        _aTitles = @[title1, title2];
    }
//    _aTitles = @[@"好友".lv_localized,@"群聊".lv_localized,@"通讯录".lv_localized];
    
    
    MNContactFriendVC *friendVC = [[MNContactFriendVC alloc] init];
    MNContactGroupVC *groupVC = [[MNContactGroupVC alloc] init];
    MNContactAddressBookVC *addressBookVC = [[MNContactAddressBookVC alloc] init];
    _vcs = [[NSMutableArray alloc] init];
    [_vcs addObject:friendVC];
    [_vcs addObject:groupVC];
    [_vcs addObject:addressBookVC];
    [self reloadData];
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64+APP_STATUS_BAR_HEIGHT);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(42);
    }];
    [self.view addSubview:self.addBtn];

}
-(UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addBtn setImage:[UIImage imageNamed:@"NavAdd"] forState:UIControlStateNormal];
        _addBtn.frame = CGRectMake(APP_SCREEN_WIDTH-50-4, APP_STATUS_BAR_HEIGHT +8,50 , 50);
        [_addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}
- (void)addAction:(UIButton *)btn{
    
    [MNTablePopView showTablePopViewWithType:MNTablePopViewTypeMsgAdd chooseIndexBlock:^(MNTablePopView *popView, NSInteger index, MNTablePopModel *model) {
        if ([model.aId isEqualToString:@"AddContact"]) {
            MNAddContactVC *vc = [[MNAddContactVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.aId isEqualToString:@"NewGroup"]) {
            MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.aId isEqualToString:@"NewPrivateChat"]) {
            MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
            vc.chooseType = MNContactChooseType_Private_Chat;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([model.aId isEqualToString:@"Scan"]) {
            [self toScan];
//            MNScanVC *vc = [[MNScanVC alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
        }
        [popView hide];
        
    }];
}

-(SerchTf *)searchBar{
    if (!_searchBar) {
        _searchBar = [[SerchTf alloc] init];
        _searchBar.delegate = self;
        _searchBar.noSearch = YES;
        self.searchTf = _searchBar.searchTf;
    }
    return _searchBar;
}

-(CGFloat)topMargin{
    return APP_STATUS_BAR_HEIGHT+64+42+5;
}
//刷新一下UI
- (void)refreshUIWithAnimation:(BOOL)animation{
    if (self.searchBar.isSearching) {
        self.customNavBar.hidden = YES;
       
    }else{
        self.customNavBar.hidden = NO;
      
    }
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self refreshUI];
        }];
    }else{
        [self refreshUI];
    }
    
    
}
- (void)refreshUI{
    if (self.searchBar.isSearching) {
        self.customNavBar.hidden = YES;
        self.contentView.frame = CGRectMake(0, APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_STATUS_BAR_HEIGHT-kBottom34());
    }else{
        self.customNavBar.hidden = NO;
        self.contentView.frame = CGRectMake(0, APP_STATUS_BAR_HEIGHT+64, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-(APP_STATUS_BAR_HEIGHT+64)-kBottom34());
    }
}
#pragma mark - UITextFieldDelegate
- (void)searchTf:(SerchTf *)tfView didEndSearchWithText:(NSString *)text{
    
}//结束搜索
- (void)searchTf_didCancelSearch:(SerchTf *)tfView{
    
}//取消搜索
- (void)searchTf_valueChanged:(SerchTf *)tfView{
//    [self doSearch:tfView.searchTf.text];
}
- (void)searchTf_textFieldDidBeginEditing:(SerchTf *)tfView{
    MNContactSearchVC *vc = [[MNContactSearchVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)searchTf_searchStateChanged:(BOOL)isSearching{
    [self refreshUIWithAnimation:YES];
}


- (void)toScan
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        MNScanVC *v = [[MNScanVC alloc] init];
//        v.hidesBottomBarWhenPushed = YES;
        v.delegate = self;
        [self.navigationController pushViewController:v animated:YES];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}
-(void)scanVC:(MNScanVC *)scanvc scanResult:(NSString *)result{
    [self ChatQrScanViewController_Result:result];
}

- (void)ChatQrScanViewController_Result:(NSString *)result
{
    if(!IsStrEmpty(result))
    {
        long userId = [[UserInfo shareInstance] userIdFromQrString:result];
        NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:[NSURL URLWithString:result]];
        if(userId <= 0)
        {
            if(invitelink && invitelink.length > 5){
                //链接进群
                [UserInfo shareInstance].inviteLink = invitelink;
                [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
            }else{
                [UserInfo showTips:nil des:@"无效二维码".lv_localized];
            }
        }
        else
        {
            [UserInfo show];
            [[TelegramManager shareInstance] requestContactInfo:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                [UserInfo dismiss];
                if(obj != nil && [obj isKindOfClass:UserInfo.class])
                {
                    UserInfo *user = obj;
                    if(userId == [UserInfo shareInstance]._id)
                    {
                            GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
                            [self.navigationController pushViewController:vc animated:YES];
//                        UIViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
//                        v.hidesBottomBarWhenPushed = YES;
//                        [self.navigationController pushViewController:v animated:YES];
                    }
                    else
                    {
//                        MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                        v.user = user;
//                        [self.navigationController pushViewController:v animated:YES];
                        if (user.is_contact){
                            QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
                            vc.user = user;
                            [self presentViewController:vc animated:YES completion:nil];
                        }else{
                            QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
                            vc.user = user;
                            [self presentViewController:vc animated:YES completion:nil];
                        }
                    }
                }
                else
                {
                    [UserInfo showTips:nil des:@"获取联系人失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
                }
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [UserInfo showTips:nil des:@"获取联系人失败，请稍后重试".lv_localized];
            }];
        }
    }
    else
    {
        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
    }
}

- (void)showNeedCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, APP_STATUS_BAR_HEIGHT +8, APP_SCREEN_WIDTH - 100, 50);
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
    vc.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-self.topMargin-kBottom34()- APP_TAB_BAR_HEIGHT2());
//    vc.contentView.frame = CGRectMake(0, 0, kScreenWidth, self.vcHeight-a);
}

@end
