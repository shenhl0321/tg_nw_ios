//
//  MNContactSearchVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/2.
//

#import "MNContactSearchVC.h"
#import "SerchTf.h"
#import "MNContactSearchContentVC.h"
#import "ContactSearchBar.h"

@interface MNContactSearchVC ()
<MNContactSearchBarDelegate,TimerCounterDelegate,BusinessListenerProtocol>
@property (nonatomic, strong) ContactSearchBar *searchBar;
//@property (nonatomic, strong) UITextField *searchTf;
@property (nonatomic, assign, readonly) CGFloat topMargin;
@property (nonatomic, strong) NSMutableArray *vcs;
@property (nonatomic, copy) NSArray *aTitles;
@property (nonatomic, strong) UILabel *tipLabel;

//好友
@property (nonatomic, strong) NSMutableArray *myContactsList;
//聊天记录
@property (nonatomic, strong) NSMutableArray *historyMsgList;

//我的群组
@property (nonatomic, strong) NSMutableArray *myGroupList;
//公开群组
@property (nonatomic, strong) NSMutableArray *publicGroupList;

@property (nonatomic) int searchHistoryMsgTaskId;

//性能考虑
@property (nonatomic, strong) TimerCounter *searchMsgTimer;

@property (nonatomic) int searchPublicContactsTaskId;


@end

@implementation MNContactSearchVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
    
    [self.searchMsgTimer stopCountProcess];
    self.searchMsgTimer = nil;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    self.view.backgroundColor = HexRGB(0xffffff);
    [self.view addSubview:self.searchBar];
    self.menuItemWidth = (kScreenWidth()-15*4)/3.0;
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(APP_STATUS_BAR_HEIGHT+1);
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(0);
    }];
    [self.view addSubview:self.tipLabel];
    [self.view bringSubviewToFront:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topMargin+20);
        make.left.mas_equalTo(left_margin());
        make.centerX.mas_equalTo(0);
    }];
    [self initData];
    [self reloadData];
    self.scrollView.hidden = YES;
    self.searchMsgTimer = [TimerCounter new];
    self.searchMsgTimer.delegate = self;
}

- (void)initData{
    _aTitles = @[@"好友".lv_localized,@"群组".lv_localized,@"聊天".lv_localized];
    for (int i = 0; i<3; i++) {
        MNContactSearchContentVC *vc = [[MNContactSearchContentVC alloc] initWithType:i];
        [self.vcs addObject:vc];
    }
}

-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

-(UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = fontRegular(13);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor colorFor878D9A];
        _tipLabel.text = @"支持搜索好友、群名、用户名和聊天记录".lv_localized;
    }
    return _tipLabel;
}
- (CGFloat)topMargin{
    return 118-20+APP_STATUS_BAR_HEIGHT;
}

-(NSMutableArray *)vcs{
    if (!_vcs) {
        _vcs = [[NSMutableArray alloc] init];
    }
    return _vcs;
}

- (NSMutableArray *)historyMsgList
{
    if(_historyMsgList == nil)
    {
        _historyMsgList = [NSMutableArray array];
    }
    return _historyMsgList;
}

- (NSMutableArray *)myGroupList
{
    if(_myGroupList == nil)
    {
        _myGroupList = [NSMutableArray array];
    }
    return _myGroupList;
}

- (NSMutableArray *)publicGroupList
{
    if(_publicGroupList == nil)
    {
        _publicGroupList = [NSMutableArray array];
    }
    return _publicGroupList;
}
- (NSMutableArray *)myContactsList
{
    if(_myContactsList == nil)
    {
        _myContactsList = [NSMutableArray array];
    }
    return _myContactsList;
}

#pragma mark - 搜索
- (void)doSearch:(NSString *)keyword
{
    if(self.searchPublicContactsTaskId > 0)
    {//结束之前的请求任务
        [[TelegramManager shareInstance] cancelTask:self.searchPublicContactsTaskId];
    }
    if(self.searchHistoryMsgTaskId > 0)
    {//结束之前的请求任务
        [[TelegramManager shareInstance] cancelTask:self.searchHistoryMsgTaskId];
    }
    [self.myContactsList removeAllObjects];
    [self.myGroupList removeAllObjects];
    [self.publicGroupList removeAllObjects];
    [self.historyMsgList removeAllObjects];
    
    if(keyword == nil || keyword.length <= 0)
    {
        //刷新列表
        self.searchMsgTimer.data = nil;
        [self.searchMsgTimer stopCountProcess];
       
        for (MNContactSearchContentVC *vc in self.vcs) {
            [vc refreshViewWithData:nil];
        }
      
        return;
    }
    
    //搜索好友
    NSArray *fds = [[TelegramManager shareInstance] getContacts:keyword];
//    if(fds.count)
    {
        [self.myContactsList addObjectsFromArray:fds];
        MNContactSearchContentVC *friendVC = self.vcs[0];
        [friendVC refreshViewWithData:self.myContactsList];
        [friendVC.tableView reloadData];
    }
    
    NSArray *grouns = [[TelegramManager shareInstance] getGroups:keyword];
//    if (grouns.count)
    {
        [self.myGroupList addObjectsFromArray:grouns];
        MNContactSearchContentVC *groupVC = self.vcs[1];
        [groupVC refreshViewWithData:self.myGroupList];
      
    }
    
    //搜索历史记录
    if(keyword.length>0)
    {
        self.searchMsgTimer.data = keyword;
        [self.searchMsgTimer stopCountProcess];
        [self.searchMsgTimer startCountProcess:0.5f repeat:NO];
        NSLog(@"添加好友 - eeeeeeeeee");
    }
    
    //刷新列表
//    [self.tableView reloadData];
}


#pragma mark - TimerCounterDelegate
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    if(!IsStrEmpty(tm.data))
    {
        [[TelegramManager shareInstance] searchMessagesList:tm.data task:^(int taskId) {
            self.searchHistoryMsgTaskId = taskId;
        } resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[NSArray class]])
            {
                NSArray *list = obj;
                if(list.count>0)
                {
                    [self.historyMsgList removeAllObjects];
                    for(NSDictionary *msgDic in list)
                    {
                        MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                        [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                        [self.historyMsgList addObject:msg];
                    }
                }
            }
            //刷新列表
           //
            MNContactSearchContentVC *historyVC = self.vcs[2];
            [historyVC refreshViewWithData:self.historyMsgList];
            [historyVC.tableView reloadData];
        } timeout:^(NSDictionary *request) {//不做处理
        }];
    }
}



#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
            //先不处理了
         
            break;
        case MakeID(EUserManager, EUser_Td_UpdateUserInfo):
          //先不处理了
            break;
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
-(void)searchBar:(ContactSearchBar *)bar textFieldDidBeginEditing:(UITextField *)textField{
    self.scrollView.hidden = NO;
    [self.searchBar styleHasCancel];
}
-(void)searchBar:(ContactSearchBar *)bar textFieldShouldReturn:(UITextField *)textField{
    self.scrollView.hidden = NO;

}
-(void)searchBar:(ContactSearchBar *)bar touchUpInsideCancelBtn:(UIButton *)cancel{
//    self.scrollView.hidden = YES;
//    [bar.searchTf resignFirstResponder];
//    [self.searchBar styleNoCancel];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)searchBar:(ContactSearchBar *)bar textFieldValueChanged:(UITextField *)textField{
    [self doSearch:textField.text];
}
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    self.tipLabel.hidden = YES;
//}


- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, APP_TOP_BAR_HEIGHT+2, APP_SCREEN_WIDTH, 50);
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

}

-(void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof MNContactSearchContentVC *)viewController withInfo:(NSDictionary *)info{
    MNContactSearchContentVC *vc = viewController;
    [vc.customNavBar removeFromSuperview];
    vc.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-self.topMargin-kBottom34());
//    vc.contentView.frame = CGRectMake(0, 0, kScreenWidth, self.vcHeight-a);
    if (vc.type == MNContactSearchTypeFriend) {
        [vc refreshViewWithData:self.myContactsList];
    }else if (vc.type == MNContactSearchTypeGroup){
        [vc refreshViewWithData:self.myGroupList];
    }else if (vc.type == MNContactSearchTypeChat){
        [vc refreshViewWithData:self.historyMsgList];
    }
}

@end
