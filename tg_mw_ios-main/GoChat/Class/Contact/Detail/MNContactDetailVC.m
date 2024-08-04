//
//  MNContactDetailVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNContactDetailVC.h"
#import "MNDetailHeaderView.h"
#import "MNContactDetailBtnCell.h"
#import "MNContactDetailPhoneCell.h"
#import "MNContactDetailDynamicCell.h"
#import "MNContactDetailEditVC.h"
#import "NNContactDetailPageVC.h"
#import "MNContactDetailSearchVC.h"
#import "ChatChooseViewController.h"
#import "MNAddGroupVC.h"
#import "GC_CirclePhotoVC.h"
#import "UserTimelineVC.h"
#import "ChatBgTableViewController.h"
#import "TF_RequestManager.h"
#import "UIView+Toast.h"
#import "MNChatBgTableViewController.h"
#import "MNContactDetailContentVC.h"
#import "MNScrollView.h"
#import "UserTimelineHelper.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"
#import "QTSetInfoBottomView.h"

@interface MNContactDetailVC ()
<BusinessListenerProtocol,UIScrollViewDelegate,YBPopupMenuDelegate>

@property (nonatomic, strong) MNScrollView *bgScrollView;
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, assign) BOOL isFriend;

@property (nonatomic, strong) OrgUserInfo *orgUserInfo;
@property (nonatomic, strong) ChatInfo *send_chatInfo;
@property (nonatomic, strong) NSString *invidePath;
@property (nonatomic, strong) MNDetailHeaderView *headerView;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;

@property (nonatomic, strong) NNContactDetailPageVC *pageVC;
@property (nonatomic, assign) CGFloat mnTableHeight;
@property (nonatomic, assign) CGFloat mnContentHeight;
@property (nonatomic, assign) CGPoint lastOffset;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, assign) CGPoint contentLastOffset;

@property (nonatomic, assign)BOOL canScroll;
@property (nonatomic, assign)BOOL isTop;//是否滑动到顶部了

@property (nonatomic, strong)UIView* pageView;

@property (nonatomic, strong) NSMutableArray *blogsArray;


@end

@implementation MNContactDetailVC

- (void)dealloc{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

-(CGFloat)mnContentHeight{
//    if(ShowLocal_VoiceRecord){
//        return APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34();
//    }else{
        return 0;
//    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self.customNavBar setTitle:@""];
    if (self.user.is_contact) {
//       self.editBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"编辑".lv_localized highlightedImageName:nil];
    }
    self.send_chatInfo = [[TelegramManager shareInstance] getChatInfo:self.user._id];
    if (!self.send_chatInfo) {
        [[TelegramManager shareInstance] createPrivateChat:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
                self.send_chatInfo = (ChatInfo *)obj;
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    [self initData];
    [self initUI];
    [self requestLoginUserOrgInfo];
    [self requestOrgUserInfo];
    [self resetBaseInfo];
    [self requestBlogs];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:NotifyLeaveTopNotification object:nil];
    
    _isTop = FALSE;
    _canScroll = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMsg:) name:NotifyLeaveTopNotification object:nil];
    
    MJWeakSelf
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //
        if (weakSelf.user.is_contact){
            
        }else{
            if (weakSelf.isAddFriend == YES){
                [weakSelf addFriends];
            }
        }
    });
}

- (void)requestBlogs {
    [UserTimelineHelper fetchUserBlogs:self.user._id offset:0 limit:3 completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        self.blogsArray = [[NSMutableArray alloc] initWithArray:blogs];
        [self.tableView reloadData];

    }];
}

#pragma mark - 编辑按钮点按
-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    //编辑按钮
    MNContactDetailEditVC *vc = [[MNContactDetailEditVC alloc] init];
    vc.toBeModifyUser = self.user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 初始化数据

- (void)initData{
    _rows = [[NSMutableArray alloc] init];
//    [self initTableData];
}

//刷新页面的
- (void)refreshView{
    //最大高度就是
}

#pragma mark - UI样式布局
-(MNScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView = [[MNScrollView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, self.mnContentHeight)];
        _bgScrollView.userInteractionEnabled = YES;
        _bgScrollView.delegate = self;
        _bgScrollView.scrollEnabled = YES;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.hidden = YES;
    }
    return _bgScrollView;
}

- (void)initUI{
    [self.contentView addSubview:self.bgScrollView];
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self addTableView];
    [self initTableView];
    
    if (self.user.type.isDeleted) {
        return;
    }
    if(ShowLocal_VoiceRecord){
//        [self addChildViewController:self.pageVC];
//
//        [self.bgScrollView addSubview:self.pageVC.view];
//        self.pageVC.view.frame = CGRectMake(0, self.mnTableHeight, APP_SCREEN_WIDTH, self.mnContentHeight);
    }
    
//    [self refreshCurPageScrollEnabled:NO];
}

-(NNContactDetailPageVC *)pageVC{
    if (!_pageVC) {
        _pageVC = [[NNContactDetailPageVC alloc] initWithUser:self.user];
        _pageVC.delegate = self;
    }
    return _pageVC;
}

#pragma mark - 关于tableviw的
//要这么写才可以覆盖父类方法
- (void)addTableView{
//    [self.bgScrollView addSubview:self.tableView];
    [self.view addSubview:self.tableView];
   
}
//头部图像
-(MNDetailHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[MNDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 855-180)];
    }
    return _headerView;
}


//tablevie的数据的
- (void)initTableData{
    [self.rows removeAllObjects];
    CGFloat tempHeight = 0;
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if (self.user) {
        if (self.user.is_contact) {//已经是朋友了
            if (self.user.phone_number.length) {
                [self.rows addObject:@"手机号码".lv_localized];
                tempHeight += 80;
            }
            if (self.user.username) {
//                [self.rows addObject:@"用户名".lv_localized];
//                tempHeight += 80;
            }
            
            
        }else{
            if ([self canAddFriend] || [self canSendMsg]) {
//                [self.rows addObject:@"btns"];
//                tempHeight += 165;
            }
            
            
        }
        if (config.can_see_blog) {
//            [self.rows addObject:@"dongtai"];
//            tempHeight += 100;
        }
    }
    //头像部分281 动态100
    self.mnTableHeight = tempHeight + CGRectGetHeight(self.headerView.frame) + 100;
    [self.tableView reloadData];
}



-(void)setMnTableHeight:(CGFloat)mnTableHeight{
    _mnTableHeight = mnTableHeight;
    self.bgScrollView.contentSize = CGSizeMake(APP_SCREEN_WIDTH, mnTableHeight+self.mnContentHeight);
}

#pragma mark - 头部按钮点按动作入口
- (void)initTableView{
//    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.frame = CGRectMake(0, APP_NAV_BAR_HEIGHT+APP_STATUS_BAR_HEIGHT, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - APP_NAV_BAR_HEIGHT-APP_STATUS_BAR_HEIGHT - kBottom34());
    @weakify(self)
    [self.headerView setClickBtnBlock:^(UIButton *btn) {
        @strongify(self)
        if (btn == self.headerView.sendMsgBtn) {
            if ([self canSendMsg]) {
                [AppDelegate gotoChatView:self.send_chatInfo];
            } else {
                [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
            }
            
//            [AppDelegate gotoChatView:self.send_chatInfo];
            
        }else if (btn == self.headerView.videoBtn){
            
            if ([self canSendMsg]) {
                [self toOnlineVideoOrVoice:YES];
            } else {
                [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
            }
            
        }else if(btn == self.headerView.voiceBtn){
            
            if ([self canSendMsg]) {
                [self toOnlineVideoOrVoice:NO];
            } else {
                [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
            }
            
            
        }else if (btn == self.headerView.muteBtn){
            NSLog(@"");
        }else if (btn == self.headerView.moreBtn){
            //不知道做什么
            [self showMorePop:btn];
            
        }else if (btn == self.headerView.qunliaoBtn){ // 发起群聊
            if ([self canSendMsg]) {
//                MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
//                chooseView.chooseType = MNContactChooseType_CreateBasicGroup_From_Contact;
//                chooseView.fromContactId = self.user._id;
//                [self.navigationController pushViewController:chooseView animated:YES];
                MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
                vc.chooseType = MNContactChooseType_CreateBasicGroup_From_Contact;
                vc.fromContactId = self.user._id;
                vc.isPresent = YES;
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                [UserInfo showTips:nil des:@"当前设置不允许开启新群聊".lv_localized];
            }
        }else if (btn == self.headerView.ltnrBtn){ // 查找聊天记录
            MNContactDetailSearchVC *vc = [[MNContactDetailSearchVC alloc] init];
            vc.chatId = self.send_chatInfo._id;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (btn == self.headerView.ltbjBtn){ // 设置当前聊天背景
            MNChatBgTableViewController *vc = [[MNChatBgTableViewController alloc] init];
            vc.currentChatId = self.user._id;
            [self.navigationController pushViewController:vc animated:YES];
        }else if (btn == self.headerView.tjghyBtn){ // 推荐给好友
            ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
            //    chooseView.toSendMsgsList = [self selectedMsgs];
            chooseView.type = 2;
            chooseView.hidesBottomBarWhenPushed = YES;
            chooseView.delegate = self;
            ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.user._id];
            chooseView.sendChatInfo = chat;
            [self.navigationController pushViewController:chooseView animated:YES];
        }else if (btn == self.headerView.kqsmltBtn){ // 开启私密来哦天
            if ([self canSendMsg]) {
                NSLog(@"开启私密聊天");
    //            [self sendMsg_click:nil];
                [TF_RequestManager createNewSecretChatWithUserId:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                    {
                        [AppDelegate gotoChatView:obj];
                    }
                } timeout:^(NSDictionary *request) {
                    
                }];
            } else {
                [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
            }
        }else if (btn == self.headerView.tousuBtn){
            NSString *url = [NSString stringWithFormat:@"%@?uid=%ld&chatid=%ld", KHostEReport, [UserInfo shareInstance]._id, self.user._id];
            BaseWebViewController *v = [BaseWebViewController new];
            v.hidesBottomBarWhenPushed = YES;
            v.titleString = @"投诉".lv_localized;
            v.urlStr = url;
            v.type = WEB_LOAD_TYPE_URL;
            [self.navigationController pushViewController:v animated:YES];
        }else if (btn == self.headerView.shoufatupianBtn){
            [self.navigationController pushViewController:self.pageVC animated:YES];
        }else if (btn == self.headerView.avatarBtn || btn == self.headerView.nicknameBtn){
            if (self.user.is_contact){
                QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
                vc.user = self.user;
                [self presentViewController:vc animated:YES completion:nil];
            }else{
                [self addFriends];
            }
        }
    }];
}
- (void)addFriends{
    MJWeakSelf
    QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.user = self.user;
    vc.refreshBlock = ^{
        //
        weakSelf.user.is_contact = YES;
        [weakSelf requestOrgUserInfo];
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)showMorePop:(UIButton *)btn{
    NSArray *titles = @[@"推荐给好友".lv_localized,
                        @"查找聊天记录".lv_localized,
                        @"发起群聊".lv_localized,
                        @"开启私密聊天".lv_localized,
                        @"设置当前聊天背景".lv_localized,
                        @"投诉".lv_localized];
    NSArray *icons = @[@"",@"",@"",@"",@"",@""];
    [YBPopupMenu showRelyOnView:btn titles:titles icons:icons menuWidth:160 otherSettings:^(YBPopupMenu *popupMenu) {
//          popupMenu.dismissOnSelected = YES;
//          popupMenu.isShowShadow = YES;
//          popupMenu.delegate = self;
//          popupMenu.offset = 10;
//          popupMenu.type = YBPopupMenuTypeDefault;
//          popupMenu.rectCorner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
        popupMenu.dismissOnSelected = YES;
        popupMenu.isShowShadow = NO;
        popupMenu.delegate = self;
        popupMenu.offset = 2;
        popupMenu.type = YBPopupMenuTypeDefault;
        popupMenu.maxVisibleCount = 8;
        popupMenu.rectCorner = UIRectCornerAllCorners;
        popupMenu.tableView.separatorColor = [UIColor clearColor];
        popupMenu.arrowHeight = 0;
        popupMenu.font = fontRegular(15);
        popupMenu.textColor = [UIColor colorTextFor23272A];
//        popupMenu.titleAlignment = NSTextAlignmentCenter;
    
      }];
   
}

- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index{
    NSLog(@"index : %ld",(long)index);
    switch (index) {
        case 0:
        {
            ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
            //    chooseView.toSendMsgsList = [self selectedMsgs];
            chooseView.type = 2;
            chooseView.hidesBottomBarWhenPushed = YES;
            chooseView.delegate = self;
            ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.user._id];
            chooseView.sendChatInfo = chat;
            [self.navigationController pushViewController:chooseView animated:YES];
            
        }
            break;
        case 1:
        {
            MNContactDetailSearchVC *vc = [[MNContactDetailSearchVC alloc] init];
            vc.chatId = self.send_chatInfo._id;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            if ([self canSendMsg]) {
//                MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
//                chooseView.chooseType = MNContactChooseType_CreateBasicGroup_From_Contact;
//                chooseView.fromContactId = self.user._id;
//                [self.navigationController pushViewController:chooseView animated:YES];
                
                MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
                vc.chooseType = MNContactChooseType_CreateBasicGroup_From_Contact;
                vc.fromContactId = self.user._id;
                vc.isPresent = YES;
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                [UserInfo showTips:nil des:@"当前设置不允许开启新群聊".lv_localized];
            }
            
        }
            break;
            
        case 3:{
            
            if ([self canSendMsg]) {
                NSLog(@"开启私密聊天");
    //            [self sendMsg_click:nil];
                [TF_RequestManager createNewSecretChatWithUserId:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                    {
                        [AppDelegate gotoChatView:obj];
                    }
                } timeout:^(NSDictionary *request) {
                    
                }];
            } else {
                [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
            }
            
            

            
        }
            break;
            
        case 4:{
//
            MNChatBgTableViewController *vc = [[MNChatBgTableViewController alloc] init];
            vc.currentChatId = self.user._id;
            [self.navigationController pushViewController:vc animated:YES];
//            ChatBgTableViewController *chatBg = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatBgTableViewController"];
////            chatBg.hidesBottomBarWhenPushed = YES;
//            chatBg.currentChatId = self.user._id;
//
//            [self.navigationController pushViewController:chatBg animated:YES];
            
        }
            break;
            
        case 5:{
            NSString *url = [NSString stringWithFormat:@"%@?uid=%ld&chatid=%ld", KHostEReport, [UserInfo shareInstance]._id, self.user._id];
            BaseWebViewController *v = [BaseWebViewController new];
            v.hidesBottomBarWhenPushed = YES;
            v.titleString = @"投诉".lv_localized;
            v.urlStr = url;
            v.type = WEB_LOAD_TYPE_URL;
            [self.navigationController pushViewController:v animated:YES];
        }
        default:
            break;
    }
}

- (void)requestInvideUserInfo:(long)invideUserId
{
    [[TelegramManager shareInstance] requestContactInfo:invideUserId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:UserInfo.class])
        {
            UserInfo *invideUser = obj;
            [self resetInvidePath:invideUser];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)resetInvidePath:(UserInfo *)user
{
//    if(user._id == [UserInfo shareInstance]._id)
//    {//自己
//        self.invidePath = @"您邀请进群";
//    }
//    else
//    {
//        self.invidePath = [NSString stringWithFormat:@"%@邀请进群", user.displayName];
//    }
//    self.invidePathLabel.text = self.invidePath;
//    [self.tableView reloadData];
}

- (void)requestOrgUserInfo
{
    [[TelegramManager shareInstance] requestOrgContactInfo:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
        {
            self.orgUserInfo = obj;
            [self resetBaseInfo];
            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)requestLoginUserOrgInfo{
    __block UserInfo *userInfo = [UserInfo shareInstance];
    if (!userInfo.orgUserInfo) {
        [[TelegramManager shareInstance] requestOrgContactInfo:userInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
            {
                userInfo.orgUserInfo = obj;
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    
}

- (void)resetBaseInfo
{
    self.name = @"";
    self.phone = @"";
    self.nickName = @"";
    [self.headerView refreshUIWithUserInfo:self.user orgUserInfo:self.orgUserInfo];
    if (self.user.type.isDeleted) {
        return;
    }
    if(self.user.is_contact)
    {
        if(self.orgUserInfo != nil)
        {
            self.name = [self.orgUserInfo displayName];
            if(![[self.orgUserInfo displayName] isEqualToString:self.user.displayName])
            {
                self.nickName = self.user.displayName;
                self.phone = self.user.phone_number;
            }
            else
            {
//                self.makerLabel.text = nil;
            }
        }
        else
        {
//            self.title1Label.text = self.user.displayName;
//            self.makerLabel.text = nil;
            self.name = self.user.displayName;
            self.phone = self.user.phone_number;
        }
    }
    else
    {

        self.name = [self.user displayName];;
        self.phone = self.user.phone_number;
    }

    if(self.blockContact)
    {
        self.name = @"@******";;
    }
    else
    {
        if(self.user.username != nil && self.user.username.length>0)
        {
            self.name = [NSString stringWithFormat:@"@%@", self.user.username];
            self.phone = self.user.phone_number;

        }
        
    }
    [self initTableData];
    self.pageVC.view.frame = CGRectMake(0, self.mnTableHeight, APP_SCREEN_WIDTH, self.mnContentHeight);
    self.editBtn.hidden = !self.user.is_contact;
    
}

#pragma mark - click
//发送消息的页面
- (void)sendMsg_click:(id)sender
{
    [[TelegramManager shareInstance] createPrivateChat:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:ChatInfo.class])
        {
            [AppDelegate gotoChatView:obj];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

//添加好友的
- (void)addContact_click:(id)sender
{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 1)
        {
            [self performSelector:@selector(doAddContactRequest) withObject:nil afterDelay:0.4];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:[NSString stringWithFormat:@"确定添加[%@]为好友吗？".lv_localized, self.user.displayName] items:items];
    [view show];
}

- (void)doAddContactRequest
{
    if (![self canAddFriend]) {
        [UserInfo showTips:nil des:@"当前设置不允许添加好友".lv_localized];
        return;
    }
    [UserInfo show];
    [[TelegramManager shareInstance] addContact:self.user resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"添加好友失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已被添加到您的好友列表中".lv_localized, self.user.displayName]];
            [[TelegramManager shareInstance] sendBeFriendMessage:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            } timeout:^(NSDictionary *request) {
            }];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"添加好友失败，请稍后重试".lv_localized];
    }];
}
//删除好友的
- (void)deleteContact_click:(id)sender
{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 1)
        {
            [self performSelector:@selector(doDeleteContactRequest) withObject:nil afterDelay:0.4];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:[NSString stringWithFormat:@"确定删除好友[%@]吗？".lv_localized, self.user.displayName] items:items];
    [view show];
}

- (void)doDeleteContactRequest
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteContact:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除好友失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已您的好友列表中删除".lv_localized, self.user.displayName]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除好友失败，请稍后重试".lv_localized];
    }];
}

- (void)onlineAv_click:(id)sender
{
    if([CallManager shareInstance].canNewCall && ![CallManager shareInstance].isInCalling)
    {
        __block NSInteger tag = -1;
        MMPopupItemHandler block = ^(NSInteger index) {
            tag = index;
        };
        NSArray *items = @[MMItemMake(@"视频通话".lv_localized, MMItemTypeNormal, block),
                           MMItemMake(@"语音通话".lv_localized, MMItemTypeNormal, block)];
        MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                              items:items];
        sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
            if(tag == 0)
            {//视频通话
                [self toOnlineVideoOrVoice:YES];
            }
            if(tag == 1)
            {//语音通话
                [self toOnlineVideoOrVoice:NO];
            }
        };
        [MMPopupWindow sharedWindow].touchWildToHide = YES;
        [sheetView show];
    }
    else
    {
        [UserInfo showTips:nil des:@"无法发起视频通话".lv_localized];
    }
}
//toOnlineVideoOrVoice
- (void)toOnlineVideoOrVoice:(BOOL)isVideo
{
    LocalCallInfo *call = [LocalCallInfo new];
    call.channelName = [Common generateGuid];
    call.from = [UserInfo shareInstance]._id;
    call.to = @[[NSNumber numberWithLong:self.user._id]];
    call.chatId = self.user._id;
    call.isVideo = isVideo;
    call.isMeetingAV = NO;
    call.callState = CallingState_Init;
    call.callTime = [NSDate new].timeIntervalSince1970;
    [[CallManager shareInstance] newCall:call fromView:self];
}

#pragma mark - 发送名片
- (void)ChatChooseViewController_PersonalCard_Choose:(id)chat {
    
    if ([chat isKindOfClass:[ChatInfo class]]) {
        self.send_chatInfo = (ChatInfo *)chat;
    }
    if (self.send_chatInfo != nil) {
        if (self.send_chatInfo.isGroup) {
            [self checkUserChatState];
        } else {
            
            if(!self.send_chatInfo.permissions.can_send_messages){//全体禁言
                [UserInfo showTips:nil des:@"全体禁言".lv_localized];
                return;
            }
            if (self.send_chatInfo.userId == self.user._id) {
                [UserInfo showTips:nil des:@"不能推荐给自己".lv_localized];
                return;
            }
            [self sendPersonCard];
        }
    }
}

- (void)checkUserChatState
{
    if (!self.send_chatInfo.isGroup) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    if(self.send_chatInfo.isSuperGroup) {//超级群组
        [[TelegramManager shareInstance] getSuperGroupInfo:self.send_chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupInfo class]])
            {
                SuperGroupInfo *super_groupInfo = obj;
                [weakSelf resetUIFromMemberState:super_groupInfo.status];
            }
        } timeout:^(NSDictionary *request) {
        }];
        return;
    }
    //普通群组
    [[TelegramManager shareInstance] getBasicGroupInfo:self.send_chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[BasicGroupInfo class]]) {
            [weakSelf resetUIFromBasicGroupInfo:obj];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (BOOL)canSendMsg:(UserInfo *)user
{
    
    if(user.is_contact)
    {//已经是好友的，不受任何影响
        return YES;
    }
    
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        
        if(info.onlyFriendChat)
        {//加好友才能聊天
            return user.is_contact;
        }
        
        if(info.onlyWhiteAddFriend)
        {
            return NO;
        }
    }
    return YES;
}

- (void)sendPersonCard{
    
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        if(!info.onlyFriendChat && !info.onlyWhiteAddFriend)
        {
            return [self sendCard];
        }
        
    }
    
    
    UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:self.send_chatInfo.userId];
    if (!userInfo) {
        [TelegramManager.shareInstance getUserSimpleInfo_inline:self.send_chatInfo.userId resultBlock:^(NSDictionary *request, NSDictionary *response) {
            UserInfo *user = [UserInfo mj_objectWithKeyValues:response];
            if ([self canSendMsg:user]) {
                return [self sendCard];
            } else {
                [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
            }
        } timeout:nil];
    } else {
        if ([self canSendMsg:userInfo]) {
            return [self sendCard];
        } else {
            [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
        }
    }
    
    
}

- (void)sendCard{
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.user._id];
    [[TelegramManager shareInstance] requestOrgContactInfo:self.user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
        {
            [self sendContactWithRaw:obj withChat:chat];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)sendContactWithRaw:(OrgUserInfo *)obj withChat:(id)chat{
    [[TelegramManager shareInstance] sendContentMessage:self.send_chatInfo._id withRwa:obj withChatInfo:chat resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if([TelegramManager isResultError:response])
        {//表示发送失败
            NSLog(@"TelegramManager isResultError");
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)resetUIFromBasicGroupInfo:(BasicGroupInfo *)groupInfo
{
    if(groupInfo.is_active)
    {//是否激活
        [self resetUIFromMemberState:groupInfo.status];
    }
    else
    {//未激活
        [UserInfo showTips:nil des:@"群组未激活".lv_localized];
    }
}

- (void)resetUIFromMemberState:(Group_ChatMemberStatus *)status
{
    switch ([status getMemberState])
    {
        case GroupMemberState_Administrator:
            //管理员
            [self sendPersonCard];
            break;
        case GroupMemberState_Creator:
            //创建者
            if(!status.is_member)
            {//创建者已不在群组
                [UserInfo showTips:nil des:@"您已不在群组里".lv_localized];
            }
            else
            {
                [self sendPersonCard];
            }
            break;
        case GroupMemberState_Left:
            //不在群组
            [UserInfo showTips:nil des:@"您已不在群组里".lv_localized];
            break;
        case GroupMemberState_Member:
            //普通成员
            if(self.send_chatInfo.permissions.can_send_messages)//can_send_messages
            {
                [self sendPersonCard];
            }
            else
            {
                [UserInfo showTips:nil des:@"管理员已开启全体禁言".lv_localized];
            }
            break;
        case GroupMemberState_Banned:
            //被禁用
            [UserInfo showTips:nil des:@"您已不在群组里".lv_localized];
            break;
        case GroupMemberState_Restricted:
            //被禁言
            [UserInfo showTips:nil des:@"您被禁言".lv_localized];
            break;
        default:
            break;
    }
}

- (void)clickBLockBtn{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:self.send_chatInfo.is_blocked?@"确定从黑名单中移除吗？".lv_localized:@"确定加入黑名单吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {
            [self blockUser];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}
//从黑名单移除来
- (void)blockUser
{
    [UserInfo show];
    MJWeakSelf
    BOOL isBlock = !self.send_chatInfo.is_blocked;
    [[TelegramManager shareInstance] blockUser:self.user._id isBlock:isBlock resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            weakSelf.send_chatInfo.is_blocked = isBlock;
            [weakSelf.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
        
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized];
    }];
}


- (BOOL)canAddFriend
{
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        if(info.onlyWhiteAddFriend)
        {
            UserInfo *userInfo = [UserInfo shareInstance];
            return self.orgUserInfo.isInternal || userInfo.orgUserInfo.isInternal;
        }
    }
    return YES;
}

- (BOOL)canSendMsg
{
    
    if(self.user.is_contact)
    {//已经是好友的，不受任何影响
        return YES;
    }
    
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        
        if(info.onlyFriendChat)
        {//加好友才能聊天
            return self.user.is_contact;
        }
        
        if(info.onlyWhiteAddFriend)
        {
            return NO;
        }
    }
    return YES;
}



#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowName = self.rows[indexPath.row];
    if ([rowName isEqualToString:@"dongtai"]) {
        return 60;
    }else if ([rowName isEqualToString:@"btns"]){
        return 165;
    }else if ([rowName isEqualToString: @"手机号码".lv_localized]||[rowName isEqualToString: @"用户名".lv_localized]){
        return 80;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *rowName = self.rows[indexPath.row];
    if ([rowName isEqualToString:@"dongtai"]) {
        static NSString *cellId = @"MNContactDetailDynamicCell";
        MNContactDetailDynamicCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNContactDetailDynamicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        [cell fillDataWithBlogs:self.blogsArray];
        return cell;
    }else if ([rowName isEqualToString:@"btns"]){
        static NSString *cellId = @"MNContactDetailBtnCell";
        MNContactDetailBtnCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNContactDetailBtnCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        [cell fillDataWithUser:self.user chat:self.send_chatInfo];
        WS(weakSelf)
        [cell setClickBtnBlock:^(UIButton *btn) {
            if (btn == cell.topBtn) {
                [weakSelf addContact_click:btn];
            }else{
                [weakSelf clickBLockBtn];
            }
            
        }];
        return cell;
    }else if ([rowName isEqualToString: @"手机号码".lv_localized]||
              [rowName isEqualToString: @"用户名".lv_localized]){
        static NSString *cellId = @"MNContactDetailPhoneCell";
        MNContactDetailPhoneCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNContactDetailPhoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.topLabel.text = rowName;
        if ([rowName isEqualToString: @"手机号码".lv_localized]) {
            cell.bottomLabel.text = self.phone;
        }else{
            cell.bottomLabel.text = self.name;
        }
        
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowName = self.rows[indexPath.row];
    if ([rowName isEqualToString:@"dongtai"]) {
        UserTimelineVC *vc = [[UserTimelineVC alloc] initWithUserid:self.user._id];
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([rowName isEqualToString:@"btns"]){
       
    }else if ([rowName isEqualToString: @"手机号码".lv_localized]||
              [rowName isEqualToString: @"用户名".lv_localized]){
       
    }
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateContactInfo):
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]])
            {
                if(self.user._id == updateUser._id)
                {
                    self.user = updateUser;
                    [self requestOrgUserInfo];
                    [self resetBaseInfo];
                    [self.tableView reloadData];
                }
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - notification -
-(void)acceptMsg: (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    NSString *canScroll = userInfo[@"canScroll"];
    if ([canScroll isEqualToString:@"1"]) {
        _canScroll = YES;
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat maxOffsetY = self.mnTableHeight;
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY>=maxOffsetY) {
        scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        [[NSNotificationCenter defaultCenter] postNotificationName:NotifyGoToTopNotification object:nil userInfo:@{@"canScroll":@"1"}];
        _canScroll = NO;
       
    } else {
      
        if (!_canScroll) {
            scrollView.contentOffset = CGPointMake(0, maxOffsetY);
        }
    }
}

@end
