//
//  ChatChooseViewController.m
//  GoChat
//
//  Created by wangyutao on 2020/12/2.
//

#import "ChatChooseViewController.h"
#import "ChatItemCell.h"
#import "PersonalCardView.h"
#import "ContactSearchBar.h"
#import "QTChooseFriendCell.h"

@interface ChatChooseViewController ()
<MNContactSearchBarDelegate>

@property (nonatomic, strong) ContactSearchBar *searchBar;

//原始列表
@property (nonatomic, strong) NSMutableArray *org_chatList;
//
@property (nonatomic, strong) NSMutableArray *chatList;
//发送名片view
@property (nonatomic, strong) PersonalCardView *personalCardV;

/// 多选按钮
@property (strong, nonatomic) UIButton *chooseBtn;
/// 多选按钮
@property (strong, nonatomic) UIButton *sendBtn;

@end

@implementation ChatChooseViewController

- (UIButton *)sendBtn{
    if (!_sendBtn){
        _sendBtn = [[UIButton alloc] init];
        _sendBtn.clipsToBounds = YES;
        _sendBtn.hidden = YES;
        _sendBtn.layer.cornerRadius = 5;
        _sendBtn.titleLabel.font = fontRegular(15);
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendBtn.backgroundColor = HEXCOLOR(0x08CF98);
        [_sendBtn addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}
- (UIButton *)chooseBtn{
    if (!_chooseBtn){
        _chooseBtn = [[UIButton alloc] init];
        [_chooseBtn setTitle:@"多选" forState:UIControlStateNormal];
        [_chooseBtn setTitle:@"单选" forState:UIControlStateSelected];
        _chooseBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _chooseBtn.titleLabel.font = fontRegular(15);
        [_chooseBtn setTitleColor:HEXCOLOR(0x333333) forState:UIControlStateNormal];
        [_chooseBtn addTarget:self action:@selector(chooseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.type == 1 || self.type == 2){
            _chooseBtn.hidden = YES;
        }else{
            _chooseBtn.hidden = NO;
        }
    }
    return _chooseBtn;
}
- (void)sendButtonClick:(UIButton *)sender{
    
    if ([self.delegate respondsToSelector:@selector(ChatChooseViewController_Chats_ChooseArr:msg:)]){
        
//            id chat = [self.chatList objectAtIndex:indexPath.row];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (id chat in self.chatList) {
            if ([chat isKindOfClass:[ChatInfo class]]) {
                ChatInfo *detailModel = chat;
                if (detailModel.isChoose == YES){
                    [array addObject:chat];
                }
            }else if([chat isKindOfClass:[UserInfo class]]){
                UserInfo *detailModel = chat;
                if (detailModel.isChoose == YES){
                    [array addObject:chat];
                }
            }else{
                
            }
        }
        if (array.count == 0){
            [UserInfo showTips:self.view des:@"请选择联系人"];
            return;
        }
        [self.delegate ChatChooseViewController_Chats_ChooseArr:[array copy] msg:self.toSendMsgsList];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)chooseButtonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected == YES){
        for (id chat in self.chatList) {
            if ([chat isKindOfClass:[ChatInfo class]]) {
                ChatInfo *detailModel = chat;
                detailModel.isChoose = YES;
            }else if([chat isKindOfClass:[UserInfo class]]){
                UserInfo *detailModel = chat;
                detailModel.isChoose = YES;
            }else{
                
            }
        }
    }
    [self.customNavBar setTitle:sender.selected==YES?@"选择多个聊天":@"选择一个聊天".lv_localized];
    [self refreshChooseButton];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置标题
    [self.customNavBar setTitle:@"选择一个聊天".lv_localized];
    [self.customNavBar addSubview:self.chooseBtn];
    [self.customNavBar addSubview:self.sendBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(self.customNavBar.titleLabel);
        make.right.equalTo(self.customNavBar).offset(-10);
        make.height.mas_offset(30);
        make.width.mas_offset(60);
    }];
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.right.equalTo(self.chooseBtn);
        make.height.mas_offset(30);
        make.width.mas_offset(60);
    }];
    
    //初始数据
    [self loadData];
    
    //搜索
    [self.contentView addSubview:self.searchBar];
    [self.searchBar styleNoCancel];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(42);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(5);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
   
}

-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}


- (void)loadData
{
    [self.org_chatList removeAllObjects];
    //会话列表
    NSArray *list = [TelegramManager shareInstance].getChatList;
    //聊天列表
    NSMutableArray *contactsList = [[[TelegramManager shareInstance] getContacts] mutableCopy];
    
    NSMutableArray *pinnedList = [NSMutableArray array];
    NSMutableArray *unPinnedList = [NSMutableArray array];
    if(list != nil && list.count>0)
    {
        NSSortDescriptor *sortChat = [NSSortDescriptor sortDescriptorWithKey:@"modifyDate" ascending:NO];
        NSArray *stList = [list sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortChat]];
        for(ChatInfo *chat in stList)
        {
            if(!chat.isGroup && chat._id == [UserInfo shareInstance]._id)
            {//我的收藏
                continue;
            }
            //发送名片不展示群组
            if (self.type == 1 && chat.isGroup) {
                continue;
            }
            if(chat.is_pinned)
            {
                [pinnedList addObject:chat];
            }
            else
            {
                [unPinnedList addObject:chat];
            }
        }
        if(pinnedList.count>0)
        {
            [self.org_chatList addObjectsFromArray:pinnedList];
        }
        if(unPinnedList.count>0)
        {
            [self.org_chatList addObjectsFromArray:unPinnedList];
        }
    }
    
    if (contactsList && contactsList.count > 0) {//UserInfo
        for (ChatInfo *chatinfo in [self.org_chatList copy]) {
            for (UserInfo *userinfo in [contactsList copy]) {
                if (chatinfo.userId == userinfo._id) {
                    [contactsList removeObject:userinfo];
                }
            }
        }
        [self.org_chatList addObjectsFromArray:contactsList];
    }
    [self reloadChats:self.org_chatList];
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

//推荐好友


- (void)initTitle
{
   
}

- (void)initNavButton
{
}

- (void)reloadChats:(NSArray *)ctsList
{
    MJWeakSelf
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil && (!info.onlyFriendChat && !info.onlyWhiteAddFriend))
    {
        [self.chatList removeAllObjects];
        [self.chatList addObjectsFromArray:ctsList];
        [self.tableView reloadData];
        return;
    }
    
    
    __block NSMutableArray *del = [NSMutableArray array];
    for(ChatInfo *chat in ctsList)
    {
        if([chat isKindOfClass:[UserInfo class]]){
            
        }else{
            UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:chat.userId];
            if (!userInfo) {
                [TelegramManager.shareInstance getUserSimpleInfo_inline:chat.userId resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    UserInfo *user = [UserInfo mj_objectWithKeyValues:response];
                    if (![weakSelf canSendMsg:user]) {
                        [del addObject:chat];
                    }
                } timeout:nil];
            } else {
                if (![weakSelf canSendMsg:userInfo]) {
                    [del addObject:chat];
                }
            }
        }
    }
    NSMutableArray *chatList = [NSMutableArray arrayWithArray:ctsList];
    [chatList removeObjectsInArray:del];
    [self.chatList removeAllObjects];
    [self.chatList addObjectsFromArray:chatList];
    
    for (id chat in self.chatList) {
        if ([chat isKindOfClass:[ChatInfo class]]) {
            ChatInfo *detailModel = chat;
            detailModel.isChoose = NO;
        }else if([chat isKindOfClass:[UserInfo class]]){
            UserInfo *detailModel = chat;
            detailModel.isChoose = NO;
        }else{
            
        }
    }
    
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

- (NSMutableArray *)org_chatList
{
    if(_org_chatList == nil)
    {
        _org_chatList = [NSMutableArray array];
    }
    return _org_chatList;
}

#pragma mark - UITextFieldDelegate
-(void)searchBar:(ContactSearchBar *)bar touchUpInsideCancelBtn:(UIButton *)cancel{
    [bar styleNoCancel];
}

-(void)searchBar:(ContactSearchBar *)bar textFieldValueChanged:(UITextField *)textField{
    NSString *keyword = textField.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!IsStrEmpty(keyword))
    {
        NSMutableArray *list = [NSMutableArray array];
        for(id chat in self.org_chatList)
        {
            if([chat isMatch:keyword])
            {
                [list addObject:chat];
            }
        }
        [self reloadChats:list];
    }
    else
    {
        [self reloadChats:self.org_chatList];
    }
}


#pragma mark - click
- (void)click_ok
{
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"QTChooseFriendCell";
    QTChooseFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId ];
    if (!cell) {
        cell = [[QTChooseFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    id chat = [self.chatList objectAtIndex:indexPath.row];
    [cell resetChatInfo:chat];
    cell.isEdit = self.chooseBtn.selected;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id chat = [self.chatList objectAtIndex:indexPath.row];
    if (self.type == 2) {//推荐给好友
        
        [self.personalCardV resetChatInfo:self.sendChatInfo sendChatInfo:chat];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.personalCardV];
        __weak typeof(self) weakSelf = self;
        self.personalCardV.personalCardSendBlock = ^(UIButton * _Nonnull sender) {
            [weakSelf.personalCardV removeFromSuperview];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if ([weakSelf.delegate respondsToSelector:@selector(ChatChooseViewController_PersonalCard_Choose:)]) {
                [weakSelf.delegate ChatChooseViewController_PersonalCard_Choose:chat];
            }
        };
        
        self.personalCardV.personalCardCancelBlock = ^(UIButton * _Nonnull sender) {
            [weakSelf.personalCardV removeFromSuperview];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
    } else if (self.type == 1) {//分享名片
        if ([chat isKindOfClass:[ChatInfo class]]) {
            ChatInfo *chatInfo = (ChatInfo *)chat;
            if(chatInfo.isGroup)
            {
                [UserInfo showTips:nil des:@"不可以选择群组分享名片".lv_localized];
                return;
            }
        }
        [self.personalCardV resetChatInfo:chat sendChatInfo:self.sendChatInfo];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window addSubview:self.personalCardV];
        __weak typeof(self) weakSelf = self;
        self.personalCardV.personalCardSendBlock = ^(UIButton * _Nonnull sender) {
            [weakSelf.personalCardV removeFromSuperview];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            if ([weakSelf.delegate respondsToSelector:@selector(ChatChooseViewController_PersonalCard_Choose:)]) {
                [weakSelf.delegate ChatChooseViewController_PersonalCard_Choose:chat];
            }
        };
        
        self.personalCardV.personalCardCancelBlock = ^(UIButton * _Nonnull sender) {
            [weakSelf.personalCardV removeFromSuperview];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        
    } else {
        
        if (self.chooseBtn.selected == YES){
            
            if ([chat isKindOfClass:[ChatInfo class]]) {
                ChatInfo *detailModel = chat;
                detailModel.isChoose = !detailModel.isChoose;
            }else if([chat isKindOfClass:[UserInfo class]]){
                UserInfo *detailModel = chat;
                detailModel.isChoose = !detailModel.isChoose;
            }else{
                
            }
            
            [self.tableView reloadData];
            
            [self refreshChooseButton];
        }else{
            if([self.delegate respondsToSelector:@selector(ChatChooseViewController_Chat_Choose:msg:)])
            {
                [self.delegate ChatChooseViewController_Chat_Choose:chat msg:self.toSendMsgsList];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)refreshChooseButton{
    if (self.chooseBtn.selected == YES){ // 多选
        NSInteger index = 0;
        for (id chat in self.chatList) {
            if ([chat isKindOfClass:[ChatInfo class]]) {
                ChatInfo *detailModel = chat;
                if (detailModel.isChoose == YES){
                    index++;
                }
            }else if([chat isKindOfClass:[UserInfo class]]){
                UserInfo *detailModel = chat;
                if (detailModel.isChoose == YES){
                    index++;
                }
            }else{
                
            }
        }
        
        if (index == 0){
            self.chooseBtn.hidden = NO;
            self.chooseBtn.selected = YES;
            self.sendBtn.hidden = YES;
        }else{
            self.chooseBtn.hidden = YES;
            self.sendBtn.hidden = NO;
            [self.sendBtn setTitle:[NSString stringWithFormat:@"发送(%ld)", index] forState:UIControlStateNormal];
        }
    }
}

- (PersonalCardView *)personalCardV {
    if (!_personalCardV) {
        _personalCardV = [[PersonalCardView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _personalCardV;
}

@end
