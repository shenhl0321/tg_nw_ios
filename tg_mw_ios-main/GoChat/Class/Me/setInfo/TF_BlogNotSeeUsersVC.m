//
//  TF_BlogNotSeeUsersVC.m
//  GoChat
//
//  Created by apple on 2022/2/7.
//

#import "TF_BlogNotSeeUsersVC.h"
#import "MNContactFriendCell.h"
#import "MNContactFriendHeader.h"
#import "MNContactDetailVC.h"
#import "TF_ModifyBlogNotSeeUsersVC.h"
#import "TF_RequestManager.h"
#import "CustomUserPrivacyRules.h"

@interface TF_BlogNotSeeUsersVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
//原始列表
@property (nonatomic, strong) NSMutableArray<UserInfo *> *contactList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionContactList;
@end

@implementation TF_BlogNotSeeUsersVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.type == 1) {
        [self.customNavBar setTitle:@"不让谁看".lv_localized];
    } else {
        [self.customNavBar setTitle:@"不看谁".lv_localized];
    }
    
    //初始数据
    [self reloadContacts];
    
    [self.contentView addSubview:self.tableView];
    self.tableView.sectionIndexColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor colorTextForA9B0BF];
    
    
    UIView *toolBar = [[UIView alloc] init];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:toolBar];
    
    UIButton *addBtn = [[UIButton alloc] init];
    [addBtn setTitle:@"添加".lv_localized forState:UIControlStateNormal];
    addBtn.titleLabel.font = XHQFont(15);
    [addBtn addTarget:self action:@selector(addUser) forControlEvents:UIControlEventTouchUpInside];
    [addBtn setTitleColor:XHQHexColor(0x333333) forState:UIControlStateNormal];
    [toolBar addSubview:addBtn];
    
    UIButton *removeBtn = [[UIButton alloc] init];
    [removeBtn setTitle:@"移出".lv_localized forState:UIControlStateNormal];
    removeBtn.titleLabel.font = XHQFont(15);
    [removeBtn addTarget:self action:@selector(removeUser) forControlEvents:UIControlEventTouchUpInside];
    [removeBtn setTitleColor:XHQHexColor(0x333333) forState:UIControlStateNormal];
    [toolBar addSubview:removeBtn];
    
    [toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
//        make.bottom.mas_equalTo(-kBottomSafeHeight);
        make.height.mas_equalTo(60);
    }];
    
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(toolBar);
        make.left.mas_equalTo(5);
        make.height.mas_equalTo(toolBar);
        make.width.mas_equalTo(50);
    }];
    
    [removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.mas_equalTo(toolBar);
        make.width.mas_equalTo(50);
        make.right.mas_equalTo(-5);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.bottom.mas_equalTo(toolBar.mas_top);
    }];
    
    
//    [self.contentView addSubview:self.tableView];
//
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.right.bottom.mas_equalTo(0);
//    }];
//    [self.tableView reloadData];
}

- (void)addUser{
    
    TF_ModifyBlogNotSeeUsersVC *vc = [[TF_ModifyBlogNotSeeUsersVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.userIds = self.userIds;
    vc.isAdding = YES;
    vc.type = self.type;
    MJWeakSelf
    vc.changeCall = ^{
        [weakSelf requestPrivacySetting];
        if (weakSelf.changeCall) {
            weakSelf.changeCall();
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)removeUser{
    if (self.userIds.count < 1) {
        [UserInfo showTips:nil des:@"没有用户，无法移出，请先添加".lv_localized];
        return;
    }
    TF_ModifyBlogNotSeeUsersVC *vc = [[TF_ModifyBlogNotSeeUsersVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.userIds = self.userIds;
    vc.isAdding = NO;
    vc.type = self.type;
    MJWeakSelf
    vc.changeCall = ^{
        [weakSelf requestPrivacySetting];
        if (weakSelf.changeCall) {
            weakSelf.changeCall();
        }
    };
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)requestPrivacySetting{
    MJWeakSelf
    [TF_RequestManager getAllCustomPrivacySettingResultBlock:^(NSDictionary *request, NSDictionary *response, NSArray *list) {
        NSArray *arr = [CustomUserPrivacy mj_objectArrayWithKeyValuesArray:list];
        if (arr != nil && arr.count > 0) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"key = %ld", weakSelf.type]];
            NSArray *filterArray = [arr filteredArrayUsingPredicate:predicate];
            CustomUserPrivacy *model = filterArray.firstObject;
            weakSelf.userIds = model.rules.firstObject.users;
            
            [weakSelf reloadContacts];
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}


- (void)reloadContacts
{
    [self.contactList removeAllObjects];
    [self.sectionContactList removeAllObjects];
    
    NSArray<UserInfo *> *list = [[TelegramManager shareInstance] getContacts];
    if(list.count > 0 && self.userIds.count > 0)
    {
        for (UserInfo *user in list) {
            if ([self.userIds containsObject:@(user._id)]) {
                [self.contactList addObject:user];
            }
        }
    }
    NSInteger sectionCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int i = 0; i < sectionCount; i++)
    {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArrays addObject:sectionArray];
    }
    
    //将user添加到对应section的array下
    for (UserInfo *user in self.contactList)
    {
        [(NSMutableArray *)[sectionArrays objectAtIndex:user.sectionNum] addObject:user];
    }
    
    //排序
    for (int i = 0; i < [sectionArrays count]; ++i)
    {
        NSArray *sectionArray = [[sectionArrays objectAtIndex:i] copy];
        sectionArray = [sectionArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            UserInfo *user1 = (UserInfo *)obj1;
            UserInfo *user2 = (UserInfo *)obj2;
            return [user1.displayName_full_py compare:user2.displayName_full_py];
        }];
        
        [self.sectionContactList addObject:sectionArray];
    }
    [self.tableView reloadData];
}

- (UserInfo *)findUser:(long)userId
{
    for(UserInfo *user in self.contactList)
    {
        if(user._id == userId)
        {
            return user;
        }
    }
    return nil;
}

- (NSMutableArray *)contactList
{
    if(_contactList == nil)
    {
        _contactList = [NSMutableArray array];
    }
    return _contactList;
}

- (NSMutableArray *)sectionContactList
{
    if(_sectionContactList == nil)
    {
        _sectionContactList = [NSMutableArray array];
    }
    return _sectionContactList;
}

-(UITableView *)tableView{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[MNContactFriendCell class] forCellReuseIdentifier:@"MNContactFriendCell"];
        
        _tableView.rowHeight = 60;
        _tableView.backgroundColor = [UIColor colorForF5F9FA];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        
        
    }
    return _tableView;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionContactList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.sectionContactList.count)
    {
        NSArray *sectionArr = self.sectionContactList[section];
        return sectionArr.count;
    }
    return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < self.sectionContactList.count)
    {
        NSArray *sectionArr = self.sectionContactList[section];
        if (sectionArr.count == 0)
        {
            return nil;
        }
        MNContactFriendHeader *header = [[MNContactFriendHeader alloc] init];

        NSArray *sectionTitlesArr = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
        if (section < sectionTitlesArr.count)
        {
            header.aLabel.text = sectionTitlesArr[section];
        }
        else
        {
            header.aLabel.text = nil;
        }
        return header;
    }
    return nil;
}

//约束section header高度 当section下没有联系人时置为0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < self.sectionContactList.count)
    {
        NSArray *sectionArr = self.sectionContactList[section];
        if (sectionArr.count == 0)
        {
            return 0.001;
        }
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{//点击索引的响应
    NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    return section;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{//右侧索引
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellId = @"MNContactFriendCell";
//    MNContactFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
//    if (!cell) {
//        cell = [[MNContactFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
//    }
    MNContactFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MNContactFriendCell" forIndexPath:indexPath];
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    [cell resetUserInfo:[sectionArr objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    UserInfo *user = [sectionArr objectAtIndex:indexPath.row];

    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:user._id];
    if (chat) {
        [AppDelegate gotoChatView:chat];
        return;
    }
    [[TelegramManager shareInstance] createPrivateChat:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:ChatInfo.class]) {
            [AppDelegate gotoChatView:obj];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
