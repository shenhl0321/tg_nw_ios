//
//  MNTabMessageVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "MNTabMessageVC.h"
#import "SerchTf.h"
#import "MNMsgCell.h"
#import "MNMessageSearchVC.h"
#import <UserNotifications/UserNotifications.h>
#import "MNScanVC.h"
#import "MNAddContactVC.h"
#import "MNAddGroupVC.h"
#import "MNContactSearchVC.h"
#import "MNLongPressChatPopView.h"
#import "MNContactDetailVC.h"
#import "GC_MyInfoVC.h"
#import "ComputerLoginViewController.h"
#import "MNCloseNotificationSetTipCell.h"
#import "GroupMemberNicknameUpdate.h"
#import "MNAddContactGroupEmptyCell.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"

@interface MNTabMessageVC ()
<UISearchBarDelegate,TimerCounterDelegate, BusinessListenerProtocol, YBPopupMenuDelegate,MNScanVCDelegate,MNCloseNotificationSetTipCellDelegate>

@property (nonatomic, strong) SerchTf *searchBar;
@property (nonatomic, strong) UITextField *searchTf;
@property (nonatomic, assign) BOOL closeNotificationSet;
@property (nonatomic) NSInteger lastUnreadCellIndex;

@property (nonatomic, strong) TimerCounter *reloadListTimer;
@property (nonatomic, strong) TimerCounter *refreshTimer;
@property (nonatomic, strong) TimerCounter *queryCallTimer;
@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) NSString *logoString;
@property (nonatomic, strong) NSMutableArray *chatList;
@end

#define kMNAddContactGroupEmptyCell @"MNAddContactGroupEmptyCell"
@implementation MNTabMessageVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //refresh timer
    [self.reloadListTimer stopCountProcess];
    self.reloadListTimer = nil;
    [self.refreshTimer stopCountProcess];
    self.refreshTimer = nil;
    [self.queryCallTimer stopCountProcess];
    self.queryCallTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.logoString = localAppName.lv_localized;
        self.logoString = @"消息".lv_localized;
    self.logoLabel = [self.customNavBar style_GoChatMessage];
    [self refreshCustonNavBarFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_STATUS_BAR_HEIGHT+64)];
    [self.customNavBar setTitle:LocalString(localMessage)];
    [self.customNavBar setRightBtnWithImageName:@"icon_add_new" title:nil highlightedImageName:@""];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedLanguage) name:@"DidChangedLanguage" object:nil];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(42, 0,APP_TAB_BAR_HEIGHT2(), 0));
    }];
   
    [self.contentView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(42);
    }];
    [self refreshUI];
    //数据处理
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self loadChatListIds];
    //refresh timer
    self.reloadListTimer = [TimerCounter new];
    self.reloadListTimer.delegate = self;
    self.refreshTimer = [TimerCounter new];
    self.refreshTimer.delegate = self;
    self.queryCallTimer = [TimerCounter new];
    self.queryCallTimer.delegate = self;
    //检测通知开关
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if(settings.authorizationStatus == UNAuthorizationStatusNotDetermined)
        {
            self.closeNotificationSet = NO;
        }
        else if(settings.authorizationStatus == UNAuthorizationStatusDenied)
        {
            self.closeNotificationSet = YES;
        }
        else if(settings.authorizationStatus == UNAuthorizationStatusAuthorized)
        {
            self.closeNotificationSet = NO;
        }
        else
        {
            self.closeNotificationSet = NO;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    //消息双击事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleClickTabItemNotification) name:@"kDoubleClickTabItemNotification" object:nil];
    
    //页面显示前，可能已经连接上
    if([TelegramManager shareInstance].getUserConnectionState == GoUserConnectionState_StateReady)
    {
        //离线通话
        [self.queryCallTimer stopCountProcess];
        [self.queryCallTimer startCountProcess:0.5 repeat:NO];
        NSLog(@"添加好友 - 4444444444");
    }
    UILongPressGestureRecognizer *longPressRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [self.tableView addGestureRecognizer:longPressRec];
    
    //同步tab扩展菜单
    [self syncTabExMenu];
    //同步app全局配置
    [self syncAppConfig];

    
    [self.tableView registerNib:[UINib nibWithNibName:kMNAddContactGroupEmptyCell bundle:nil] forCellReuseIdentifier:kMNAddContactGroupEmptyCell];
}

- (void)changedLanguage{
    [self.reloadListTimer stopCountProcess];
    self.reloadListTimer = nil;
    [self.refreshTimer stopCountProcess];
    self.refreshTimer = nil;
    [self.queryCallTimer stopCountProcess];
    self.queryCallTimer = nil;
    [self.chatList removeAllObjects];
}

- (void)longPressed:(UILongPressGestureRecognizer *)longPressGesture{
    BaseTableCell *cell;
    NSIndexPath *currentIndexPath;
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {//手势开始
        CGPoint point = [longPressGesture locationInView:self.tableView];
        currentIndexPath = [self.tableView indexPathForRowAtPoint:point]; // 可以获取我们在哪个cell上长按
    cell = [self.tableView cellForRowAtIndexPath:currentIndexPath];
        NSLog(@"%ld",currentIndexPath.section);
        if (cell && [cell isKindOfClass:[MNMsgCell class]]) {
            ChatInfo *chat = [self.chatList objectAtIndex:currentIndexPath.row];
            [MNLongPressChatPopView showWithChat:chat touchBtnBlock:^(MNLongPressChatPopView *popView, UIButton *btn) {
                
            }];
        }
        }
        if (longPressGesture.state == UIGestureRecognizerStateEnded)//手势结束
        {
           
            
        }
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [MNTablePopView showTablePopViewWithType:MNTablePopViewTypeMsgAdd chooseIndexBlock:^(MNTablePopView *popView, NSInteger index, MNTablePopModel *model) {
        if ([model.aId isEqualToString:@"AddContact"]) {
            MNAddContactVC *vc = [[MNAddContactVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.aId isEqualToString:@"NewGroup"]) {
            MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
            vc.isPresent = YES;
            [self presentViewController:vc animated:YES completion:nil];
//            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.aId isEqualToString:@"NewPrivateChat"]) {
            MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
            vc.isPresent = YES;
            vc.chooseType = MNContactChooseType_Private_Chat;
            [self presentViewController:vc animated:YES completion:nil];
//            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([model.aId isEqualToString:@"Scan"]) {
            [self toScan];
//            MNScanVC *vc = [[MNScanVC alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
        }
        [popView hide];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //导航栏样式
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshConnectionState];
    [self.tableView reloadData];
}

- (NSMutableArray *)chatList
{
    if(_chatList == nil)
    {
        _chatList = [NSMutableArray array];
    }
    return _chatList;
}

- (void)refreshConnectionState
{
    GoUserConnectionState state = [TelegramManager shareInstance].getUserConnectionState;
    switch (state) {
        case GoUserConnectionState_StateReady:
        {
            self.logoLabel.text = self.logoString;
            //连接成功之后抛通知，如果再会话页面且消息列表为空就再拉取一次
            AuthUserInfo *curUser = [[AuthUserManager shareInstance] currentAuthUser];
            GoUserConnectionState state = [TelegramManager shareInstance].getUserConnectionState;
            if(curUser != nil && state != GoUserConnectionState_Connecting ){
                [[TelegramManager shareInstance] setTdlibParameters:curUser.data_directoryPath result:^(NSDictionary *request, NSDictionary *response) {
                    [self loadChatListIds];
                } timeout:^(NSDictionary *request) {
                    
                    
                }];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetWork_ConnectSuccess" object:nil];
        }
            break;
        case GoUserConnectionState_Updating:
            self.logoLabel.text = @"更新中...".lv_localized;
//            [self performSelector:@selector(checkState) withObject:nil afterDelay:10.0];
            break;
        case GoUserConnectionState_Connecting:
            self.logoLabel.text = @"连接中...".lv_localized;
//            [self performSelector:@selector(checkState) withObject:nil afterDelay:10.0];
            break;
        default:
            break;
    }
}
//检查状态 如果5秒之后还连不上就重新走配置
#if 0
-(void)checkState{
    if ([self.logoLabel.text isEqualToString:LocalString(@"更新中...".lv_localized)] || [self.logoLabel.text isEqualToString:@"连接中...".lv_localized]) {
        
//        [[TelegramManager shareInstance] resetClicent];

        
//        NSString *data_directory = nil;
//        AuthUserInfo *curUser = [[AuthUserManager shareInstance] currentAuthUser];
//        if(curUser != nil)
//        {
//            data_directory = curUser.data_directoryPath;
//        }
//        else
//        {
//            data_directory = [[AuthUserManager shareInstance] create_data_directory];
//        }
//        //重新初始化client对象
//        [[TelegramManager shareInstance] resetClicent];
//        [[TelegramManager shareInstance] setTdlibParameters:data_directory result:^(NSDictionary *request, NSDictionary *response) {
//            if(![TelegramManager isResultOk:response])
//            {
//                //配置失败，系统级错误
//                //todo wangyutao
//                NSLog(@"Config td lib fail......");
//            }
//        } timeout:^(NSDictionary *request) {
//            //超时，系统级错误
//            //todo wangyutao
//            NSLog(@"Config td lib timeout......");
//        }];
    }
}
#endif
- (void)queryOfflineCall
{
    [[TelegramManager shareInstance] queryOfflineCall:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = obj;
            if(list.count>0)
            {
                for(RemoteCallInfo *remoteCall in list)
                {
                    if(!remoteCall.isTimeOut)
                    {
                        [[CallManager shareInstance] newIncomingCall:remoteCall];
                    }
                    else
                    {
                        //消息显示未接来电
                        [[TelegramManager shareInstance] sendLocalCustomMessage:[remoteCall getRealChatId] text:[remoteCall done_jsonForMessage] sender:remoteCall.from resultBlock:^(NSDictionary *request, NSDictionary *response) {
                        } timeout:^(NSDictionary *request) {
                        }];
                    }
                }
            }
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)syncTabExMenu
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@/api/get_custom_page_list", KHostApiAddress] parameters:@{} headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        //
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //
        NSArray *array = responseObject[@"data"];
        if (array.count > 0){
            TabExMenuInfo *info = [TabExMenuInfo mj_objectWithKeyValues:array.firstObject];
//            info.status = NO;
            [TabExMenuInfo saveTabExMenuInfo:info];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //
//        [SVProgressHUD showErrorWithStatus:@"数据请求失败"];
    }];
    
    
//    // http://101.42.10.89
//    [[TelegramManager shareInstance] queryTabExMenu:^(NSDictionary *request, NSDictionary *response, id obj) {
//        if(obj && [obj isKindOfClass:[TabExMenuInfo class]])
//        {
//            TabExMenuInfo *info = obj;
//            [TabExMenuInfo saveTabExMenuInfo:info];
//        }
//    } timeout:^(NSDictionary *request) {
//    }];
}

- (void)syncAppConfig
{
    [[TelegramManager shareInstance] queryAppConfig:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj && [obj isKindOfClass:[AppConfigInfo class]])
        {
            AppConfigInfo *info = obj;
            [AppConfigInfo saveAppConfigInfo:info];
            //发送通知
            [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_App_Config_Changed) withInParam:nil];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

// 通知方法的实现 - 定位到未读消息行
- (void)doubleClickTabItemNotification
{
    if(self.chatList.count<5) return;
    if(self.lastUnreadCellIndex>0)
    {
        if(![self toScrollUnreadCell:self.lastUnreadCellIndex])
        {
            if(![self toScrollUnreadCell:0])
            {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
    else
    {
        if(![self toScrollUnreadCell:0])
        {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (BOOL)toScrollUnreadCell:(NSInteger)start
{
    if (start < self.chatList.count-1)
    {
        for (NSInteger i = start; i < self.chatList.count; i++)
        {
            ChatInfo *lastModel = self.chatList[i];
            if (lastModel.unread_count > 0)
            {
                self.lastUnreadCellIndex = i+1;
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - data
- (void)loadChatListIds
{
    [[TelegramManager shareInstance] getChatListIds:^(NSDictionary *request, NSDictionary *response) {
    } timeout:^(NSDictionary *request) {
    }];
}

-(SerchTf *)searchBar{
    if (!_searchBar) {
        _searchBar = [[SerchTf alloc] init];
        _searchBar.delegate = self;
        _searchBar.noSearch = YES;
        self.searchTf = _searchBar.searchTf;
        self.searchTf.font = [UIFont systemFontOfSize:14];
        _searchBar.cornerRadius = 21;
        _searchBar.isLeft = YES;
    }
    return _searchBar;
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

#pragma  mark - UITableView
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0)
    {
        if(self.closeNotificationSet)
        {
            return 1;
        }
    }
    
    if(section == 1)
    {
        return self.chatList.count==0?1:self.chatList.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        return self.chatList.count==0?SCREEN_HEIGHT-kNavAndTabHeight-100:72.0f;
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (self.closeNotificationSet) {
            return 0.01;
        }
        return 10;
    }
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        static NSString *cellId = @"MNCloseNotificationSetTipCell";
        MNCloseNotificationSetTipCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNCloseNotificationSetTipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.delegate = self;
        return cell;
    }

    if (indexPath.section == 1){
        if (self.chatList.count==0){
            MNAddContactGroupEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:kMNAddContactGroupEmptyCell forIndexPath:indexPath];
            cell.logoImageV.image = [UIImage imageNamed:@"icon_place_logo02"];
            cell.contentLab.text = @"暂无聊天消息";
            cell.contentLabTop.constant = -100;
            return cell;
        }else{
            NSString static *cellId = @"MNMsgCell";
            MNMsgCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell) {
                cell = [[MNMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            ChatInfo *chat = [self.chatList objectAtIndex:indexPath.row];
            [cell resetChatInfo:chat];
    //        [cell setRightUtilityButtons:[self rightButtons:chat] WithButtonWidth:75];
    //        cell.delegate = self;
            return cell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ChatInfo *cellinfo = [self.chatList objectAtIndex:indexPath.row];
//    [[TelegramManager shareInstance] testUser_id:cellinfo.userId followed:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
//
//    } timeout:^(NSDictionary *request) {
//
//    }];
//    return;
    if(indexPath.section == 1){
        if (self.chatList.count == 0){
            return;
        }
        //跳转聊天页面
        ChatInfo *cellinfo = [self.chatList objectAtIndex:indexPath.row];
        [AppDelegate gotoChatView:cellinfo];
    }
    if(indexPath.section == 0)
    {//跳转app设置页面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
        }];
    }
    
}
#pragma mark - CloseNotificationSetTipCellDelegate
- (void)CloseNotificationSetTipCell_Remove:(MNCloseNotificationSetTipCell *)view
{
    self.closeNotificationSet = NO;
    [self.tableView reloadData];
}

- (void)toggleChatNotification:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatDisableNotification:chat._id isDisableNotification:!chat.default_disable_notification  resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatPinned:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatIsPinned:chat._id isPinned:!chat.is_pinned resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatDeleteConfirm:(ChatInfo *)chat
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定删除吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//删除
            [self toggleChatDelete:chat];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)toggleChatDelete:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteChatHistory:chat._id isDeleteChat:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized];
    }];
}

//第三方打开联系人详情
- (void)showContactDetailFromOtherApp
{
    long userId = [UserInfo shareInstance].willShowContactId;
    if(userId>0)
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
                }
                else
                {
                    if (user.is_contact){
                        QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
                        vc.user = user;
                        [self presentViewController:vc animated:YES completion:nil];
                    }else{
                        QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
                        vc.user = user;
                        [self presentViewController:vc animated:YES completion:nil];
                    }
//                  
//                    MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                    v.user = user;
//                    v.isAddFriend = YES;
//                    [[self getCurrentVC].navigationController pushViewController:v animated:YES];
//                    QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
//                    vc.user = user;
//                    [self presentViewController:vc animated:YES completion:nil];
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
    [UserInfo shareInstance].willShowContactId = 0;
}

#pragma mark - 获取当前视图
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    if ([rootVC presentedViewController])
    {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]])
    {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    }
    else if ([rootVC isKindOfClass:[UINavigationController class]])
    {
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    }
    else
    {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

#pragma mark - TimerCounterDelegate
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    // tip:加后面的判断，是为了处理切换语言时获取不到会话列表的问题，不确定会不要有其它影响
    if(tm == self.queryCallTimer && self.chatList.count > 0)
    {
        //同步离线通话
        [self queryOfflineCall];
        //同步用户隐私设置
        [[TelegramManager shareInstance] updateUserPrivacySettingsByAllowFindingByPhoneNumber];
        //同步tab扩展菜单
        [self syncTabExMenu];
        //同步app全局配置
        [self syncAppConfig];
        //打开第三方跳转来的详情
        [self showContactDetailFromOtherApp];
        //链接进群
        [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
    }else{
        [self.chatList removeAllObjects];
        NSArray *list = [[TelegramManager shareInstance] getChatList];
        if(list != nil)
        {
            ChatInfo *systemNoticeChat = nil;
            NSMutableArray *pinnedList = [NSMutableArray array];
            NSMutableArray *unPinnedList = [NSMutableArray array];
            NSMutableArray *nullMsgSecreatList = [NSMutableArray array];
            NSMutableArray *secreatUserIds = [NSMutableArray array];
            NSSortDescriptor *sortChat = [NSSortDescriptor sortDescriptorWithKey:@"modifyDate" ascending:NO];
            NSArray *stList = [list sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortChat]];
            for(ChatInfo *chat in stList)
            {
                if(!chat.isGroup && chat._id == [UserInfo shareInstance]._id)
                {//我的收藏
                    continue;
                }
                if(chat._id == TG_USERID_SYSTEM_NOTICE)
                {
                    systemNoticeChat = chat;
                }
                else if (chat.isSecretChat && [chat.secretChatInfo.state isEqualToString:@"secretChatStateClosed"]) {
                    continue;
                }
                else
                {
                    if(chat.lastMessage)
                    {
                        /// 自己已退群，则不显示该会话
                        /// 问题 - 退出公开群后，重新进入App，后台还是会返回会话消息。
                        if (chat.lastMessage.content &&
                            [chat.lastMessage.content.type isEqualToString:@"messageChatDeleteMember"] &&
                            chat.lastMessage.content.user_id == UserInfo.shareInstance._id) {
                            continue;
                        }
                        
                        // 私密聊天，且之前没有在列表中时才加入聊天列表
                        if (chat.isSecretChat && ![secreatUserIds containsObject:@(chat.secretChatInfo.user_id) ]) {
                            [pinnedList addObject:chat];
                            [secreatUserIds addObject:@(chat.secretChatInfo.user_id)];
                        } else if(chat.is_pinned)
                        {
                            [pinnedList addObject:chat];
                        }
                        else
                        {
                            [unPinnedList addObject:chat];
                        }
                        
                    } else if (chat.isSecretChat){
                        // 私密聊天，且之前没有在列表中时才加入聊天列表
                        if (![secreatUserIds containsObject:@(chat.secretChatInfo.user_id) ]) {
                            [nullMsgSecreatList addObject:chat];
                            [secreatUserIds addObject:@(chat.secretChatInfo.user_id)];
                        }
                        
                    }
                }
            }
            if(systemNoticeChat != nil)
            {
                [self.chatList addObject:systemNoticeChat];
            }
            if(nullMsgSecreatList.count>0)
            {
                [self.chatList addObjectsFromArray:nullMsgSecreatList];
            }
            if(pinnedList.count>0)
            {
                [self.chatList addObjectsFromArray:pinnedList];
            }
            if(unPinnedList.count>0)
            {
                [self.chatList addObjectsFromArray:unPinnedList];
            }
        }
        [self.tableView reloadData];
        [self refreshTotalUnreadCount];
    }
}

- (void)refreshTotalUnreadCount
{
    int totalUnreadCount = 0;
    for(ChatInfo *chat in self.chatList)
    {
        if(chat.unread_count>0)
            totalUnreadCount += chat.unread_count;
    }
    [UserInfo shareInstance].msgUnreadTotalCount = totalUnreadCount;
    [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Message_Total_Unread_Changed) withInParam:[NSNumber numberWithInt:totalUnreadCount]];
    //更新桌面图标
    if(totalUnreadCount > 0)
        [UIApplication sharedApplication].applicationIconBadgeNumber = totalUnreadCount;
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Connection_State_Changed):
        {
            [self refreshConnectionState];
            if([TelegramManager shareInstance].getUserConnectionState == GoUserConnectionState_StateReady)
            {
                //离线通话
                [self.queryCallTimer stopCountProcess];
                [self.queryCallTimer startCountProcess:0.5 repeat:NO];
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_UpdateChatUpdateSecretChatStatus):
        {
            NSMutableArray<ChatInfo *> *chats = self.chatList;
            SecretChat *secret = (SecretChat *)inParam;
            ChatInfo *target = nil;
            for (ChatInfo *chat in chats) {
                if (chat.isSecretChat && chat.secretChatInfo._id == secret._id) {
                    target = chat;
                    break;
                }
            }
            if (secret.chatState == secretChatStateClosed) {
                [self.chatList removeObject:target];
            } else {
                target.secretChatInfo = secret;
            }
            
            
            [self.tableView reloadData];
        }
            break;
            
//            chatList
        case MakeID(EUserManager, EUser_Td_Chat_List_Changed):
        {
            [self.reloadListTimer stopCountProcess];
            [self.reloadListTimer startCountProcess:0.5 repeat:NO];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Last_Message_Changed):
        {
            [self.refreshTimer stopCountProcess];
            [self.refreshTimer startCountProcess:0.5 repeat:NO];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Changed):
        {
            MessageInfo *msg = inParam;
            if(msg == nil || ![msg isKindOfClass:[MessageInfo class]])
            {
                [self.tableView reloadData];
                [self refreshTotalUnreadCount];
                break;
            }
            if(!msg.is_outgoing && msg.chat_id != [TelegramManager shareInstance].getCurChatId){
                [self.tableView reloadData];
                [self refreshTotalUnreadCount];
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Title_Changed):
        case MakeID(EUserManager, EUser_Td_Chat_Photo_Changed):
        case MakeID(EUserManager, EUser_Td_Chat_Permissions_Changed):
            [self.tableView reloadData];
            [self refreshTotalUnreadCount];
            break;
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        case MakeID(EUserManager, EUser_Td_Group_Photo_Ok):
        case MakeID(EUserManager, EUser_Td_AddNewContactInfo):
        case MakeID(EUserManager, EUser_Td_Chat_OutMessage_Readed):
            [self.tableView reloadData];
            break;
        case MakeID(EUserManager, EUser_Will_Show_Contact):
            if([TelegramManager shareInstance].getUserConnectionState == GoUserConnectionState_StateReady)
            {
                [self showContactDetailFromOtherApp];
            }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_New_Message):
        {//新消息
            MessageInfo *msg = inParam;
            if(msg != nil && [msg isKindOfClass:[MessageInfo class]])
            {
                if([msg isLocalMessage])
                {
                    //不提醒，并设置为已读
                    [[TelegramManager shareInstance] setMessagesReaded:msg.chat_id msgIds:@[[NSNumber numberWithLong:msg._id]]];
                }
                else
                {
                    if(!msg.is_outgoing && msg.chat_id != [TelegramManager shareInstance].getCurChatId)
                    {
                        ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:msg.chat_id];
                        if(chat != nil && chat.default_disable_notification)
                        {//不提醒
                        }
                        else
                        {
                            //声音
                            [self PlayNewMessageSound];
                            //震动
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Group_Member_Nickname_Change):
        { /// 群内用户修改昵称
            [self groupMemberUpdateNickname:inParam];
            break;
        }
        default:
            
//            [self.reloadListTimer stopCountProcess];
//            [self.reloadListTimer startCountProcess:0.2 repeat:NO];
//
//            [self.refreshTimer stopCountProcess];
//            [self.refreshTimer startCountProcess:0.5 repeat:NO];
            break;
    }
}

/// 群组内成员修改昵称
- (void)groupMemberUpdateNickname:(id)parameters {
    if (self.chatList.count == 0) {
        return;
    }
    NSDictionary *data = parameters;
    GroupMemberNicknameUpdate *update = [GroupMemberNicknameUpdate mj_objectWithKeyValues:data];
    if (update.userId == UserInfo.shareInstance._id) {
        return;
    }
    ChatInfo *chat;
    for (ChatInfo *c in self.chatList) {
        if (c.isGroup && c.superGroupId == update.chatId) {
            chat = c;
            break;
        }
    }
    if (!chat) { return; }
    if (chat.groupMembers.count == 0) {
        return;
    }
    for (GroupMemberInfo *m in chat.groupMembers) {
        if (m.user_id == update.userId) {
            m.nickname = update.nickname;
            break;
        }
    }
    [self.tableView reloadData];
}

static SystemSoundID soundID = 0;
- (void)PlayNewMessageSound
{
    if(soundID<=0)
    {
        NSString *soundPath =  [[NSBundle mainBundle] pathForResource:@"message" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:soundPath]), &soundID);
    }
    AudioServicesPlaySystemSound(soundID);
}

//next segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
        //        @"tg://login?token=JbYpY0AnydYFt-D1b1Zlyp-y8no_co4t"
        if ([result containsString:@"login?token"]) {//扫码登录
            ComputerLoginViewController *computerVC = [[ComputerLoginViewController alloc] init];
            computerVC.hidesBottomBarWhenPushed = YES;
            computerVC.link = result;
            [self.navigationController pushViewController:computerVC animated:YES];
        } else {
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
                        }
                        else
                        {
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


@end
