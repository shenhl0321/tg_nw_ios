//
//  MNContactFriendVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/1.
//

#import "MNContactFriendVC.h"
#import "MNContactFriendCell.h"
#import "MNContactFriendHeader.h"
#import "MNContactDetailVC.h"

@interface MNContactFriendVC ()
<BusinessListenerProtocol>
//原始列表
@property (nonatomic, strong) NSMutableArray *contactList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionContactList;
@end

@implementation MNContactFriendVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar removeFromSuperview];
    
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

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)reloadContacts
{
    [self.contactList removeAllObjects];
    [self.sectionContactList removeAllObjects];
    
    NSArray *list = [[TelegramManager shareInstance] getContacts];
    if(list.count>0)
    {
        [self.contactList addObjectsFromArray:list];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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
//        UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AzSectionHeaderView" owner:nil options:nil] objectAtIndex:0];
//        headerView.backgroundColor = [UIColor clearColor];
//        UILabel *titleLabel = (UILabel *)[headerView viewWithTag:101];
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
    static NSString *cellId = @"MNContactFriendCell";
    MNContactFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNContactFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    [cell resetUserInfo:[sectionArr objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    UserInfo *user = [sectionArr objectAtIndex:indexPath.row];
//    MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//    v.user = user;
//    [self.navigationController pushViewController:v animated:YES];
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
//
//                if(updateUser.is_contact)
//                {
//                    if([prev.displayName isEqualToString:prev.displayName])
//                    {
//                        [self.contactList replaceObjectAtIndex:[self.contactList indexOfObject:prev] withObject:updateUser];
//                        [self.tableView reloadData];
//                    }
//                    else
//                    {
//                        [self reloadContacts];
//                    }
//                }
//                else
//                {
//                    [self reloadContacts];
//                }
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

//next segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([@"ContactDetailView" isEqualToString:segue.identifier])
    {
        if([sender isKindOfClass:[UserInfo class]])
        {
            UserInfo *user = sender;
//            ContactDetailViewController *v = segue.destinationViewController;
//            v.hidesBottomBarWhenPushed = YES;
//            MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//            v.user = user;
        }
    }
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
