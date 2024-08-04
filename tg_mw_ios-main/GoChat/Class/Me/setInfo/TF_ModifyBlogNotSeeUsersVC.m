//
//  TF_ModifyBlogNotSeeUsersVC.m
//  GoChat
//
//  Created by apple on 2022/2/7.
//

#import "TF_ModifyBlogNotSeeUsersVC.h"
#import "MNContactFriendCell.h"
#import "MNContactFriendHeader.h"
#import "MNContactDetailVC.h"
#import "MNAddGroupCell.h"
#import "TF_RequestManager.h"

@interface TF_ModifyBlogNotSeeUsersVC ()<BusinessListenerProtocol>
//原始列表
@property (nonatomic, strong) NSMutableArray<UserInfo *> *contactList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionContactList;
/// 选择的数组
@property (nonatomic,strong) NSMutableArray<UserInfo *> *selList;
@end

@implementation TF_ModifyBlogNotSeeUsersVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isAdding) {
        [self.customNavBar setTitle:@"添加用户".lv_localized];
    } else {
        [self.customNavBar setTitle:@"移出用户".lv_localized];
    }
    UIButton *leftBtn = [self.customNavBar setLeftBtnWithImageName:nil title:@"取消".lv_localized highlightedImageName:nil];
    [leftBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"确定".lv_localized highlightedImageName:nil];
    [rightBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    //初始数据
    [self reloadContacts];
    //同步联系人
    [[TelegramManager shareInstance] syncMyContacts];
    self.tableView.sectionIndexColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor colorTextForA9B0BF];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)closeClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sureClick{
    if (self.selList.count < 1) {
        [UserInfo showTips:nil des:@"请先选择用户".lv_localized];
        return;
    }
    NSMutableArray *userIds = [NSMutableArray array];
    for (UserInfo *user in self.selList) {
        [userIds addObject:@(user._id)];
    }
    MJWeakSelf
    [UserInfo show];
    [TF_RequestManager setCustomPrivacyChangeUserAuthority:userIds isAdding:self.isAdding type:self.type resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if (obj) {
            if (weakSelf.changeCall) {
                weakSelf.changeCall();
            }
            [weakSelf closeClick];
        } else {
            [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"设置失败，请稍后重试".lv_localized];
        
        [weakSelf.tableView reloadData];
    }];
}

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)reloadContacts
{
    [self.contactList removeAllObjects];
    [self.sectionContactList removeAllObjects];
    
    NSArray<UserInfo *> *list = [[TelegramManager shareInstance] getContacts];
    if(list.count > 0)
    {
        if (!self.isAdding) {
            for (UserInfo *user in list){
                if([self.userIds containsObject:@(user._id)]){
                    [self.contactList addObject:user];
                }
            }
        } else {
            [self.contactList addObjectsFromArray:list];
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

- (NSMutableArray<UserInfo *> *)selList{
    if (!_selList) {
        _selList = [NSMutableArray array];
    }
    return _selList;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MNAddGroupCell";
    MNAddGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId ];
    if (!cell) {
        cell = [[MNAddGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    UserInfo *user = [sectionArr objectAtIndex:indexPath.row];
    BOOL sel = [self.selList containsObject:user];
    BOOL showMask = NO;
    if (self.isAdding) {
        sel = sel || [self.userIds containsObject:@(user._id)];
        showMask = [self.userIds containsObject:@(user._id)];
    }
    [cell resetUserInfo:user isChoose:sel showMask:showMask];
//    [cell resetUserInfo:user isChoose:[self.choosedDic objectForKey:[NSNumber numberWithLong:user._id]]!=nil showMask:[self.disableChooseDic objectForKey:[NSNumber numberWithLong:user._id]]!=nil];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    UserInfo *user = [sectionArr objectAtIndex:indexPath.row];
    if (self.isAdding && [self.userIds containsObject:@(user._id)]) {
        return;
    }
    if ([self.selList containsObject:user]) {
        [self.selList removeObject:user];
    } else {
        [self.selList addObject:user];
    }
//    if([self.choosedDic objectForKey:[NSNumber numberWithLong:user._id]]!=nil)
//    {
//        [self.choosedDic removeObjectForKey:[NSNumber numberWithLong:user._id]];
//    }
//    else
//    {
//        [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
//    }
    [self.tableView reloadData];
//    self.selectedUser = user;
//    if([self.disableChooseDic objectForKey:[NSNumber numberWithLong:user._id]]==nil)
//    {//不在不可更改的列表里
//        if(self.chooseType == MNContactChooseType_Group_At_Someone)
//        {//单选模式
//            if([self.delegate respondsToSelector:@selector(chooseUser:)])
//            {
//                [self.delegate chooseUser:user];
//            }
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else if (self.chooseType == MNContactChooseType_Private_Chat){
//            [self.choosedDic removeAllObjects];
//            [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
//            [self.tableView reloadData];
//        }
//        else
//        {//多选模式
//            if([self.choosedDic objectForKey:[NSNumber numberWithLong:user._id]]!=nil)
//            {
//                [self.choosedDic removeObjectForKey:[NSNumber numberWithLong:user._id]];
//            }
//            else
//            {
//                [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
//            }
//            [self.tableView reloadData];
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
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



#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
            [self.tableView reloadData];
            break;
        case MakeID(EUserManager, EUser_Td_UpdateContactInfo):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]])
            {
                UserInfo *prev = [self findUser:updateUser._id];
                if(prev)
                {
                    [self reloadContacts];
                }
                else
                {
                    if(updateUser.is_contact)
                    {
                        [self reloadContacts];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_AddNewContactInfo):
        {
            UserInfo *user = inParam;
            if(user != nil && [user isKindOfClass:[UserInfo class]] && user.is_contact)
            {
                [self reloadContacts];
            }
        }
            break;
        default:
            break;
    }
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
