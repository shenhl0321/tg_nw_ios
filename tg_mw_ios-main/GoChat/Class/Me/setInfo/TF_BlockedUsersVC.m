//
//  TF_BlockedUsersVC.m
//  GoChat
//
//  Created by apple on 2022/1/28.
//

#import "TF_BlockedUsersVC.h"
#import "MNContactFriendCell.h"
#import "MNContactFriendHeader.h"
#import "MNContactDetailVC.h"

@interface TF_BlockedUsersVC ()<BusinessListenerProtocol, MGSwipeTableCellDelegate>
//原始列表
@property (nonatomic, strong) NSMutableArray *contactList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionContactList;
@end

@implementation TF_BlockedUsersVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"黑名单".lv_localized];
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    //初始数据
    [self reloadContacts:nil];
    [self reloadBlockedUsers];
    
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

- (void)reloadBlockedUsers
{
    [[TelegramManager shareInstance] requestblockedUserList:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = (NSArray *)obj;
            NSMutableArray *ctList = [NSMutableArray array];
            for(NSDictionary *msgDic in list)
            {
                MessageSender *ms = [MessageSender mj_objectWithKeyValues:msgDic];
                long userId = ms.user_id;//messageSenderUser
                if([ms.type isEqualToString:@"messageSenderChat"]) {
                    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:ms.chat_id];
                    if(chat != nil)
                    {
                        if([@"chatTypePrivate" isEqualToString:chat.type.type])
                        {
                            userId = [chat userId];
                        }
                    }
                }
                if (userId != 0) {
                    UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId];
                    if(user != nil)
                    {
                        [ctList addObject:user];
                    }
                }
            }
            [self reloadContacts:ctList];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)reloadContacts:(NSArray *)list
{
    [self.contactList removeAllObjects];
    [self.sectionContactList removeAllObjects];
    
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
    cell.rightButtons = [self rightButtons];
//    cell.delegate = self;
    return cell;
}

#pragma mark - SWTableViewCellDelegate



- (NSArray *)rightButtons
{
    MGSwipeButton *btn = [MGSwipeButton buttonWithTitle:@"移除".lv_localized icon:[UIImage imageNamed:@"com_ic_list_close_normal"] backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSArray *sectionArr = self.sectionContactList[indexPath.section];
        UserInfo *user = [sectionArr objectAtIndex:indexPath.row];
        [self unblockUser:user];
        return YES;
    }];
    
    return @[btn];
}

- (void)unblockUser:(UserInfo *)user
{
    [UserInfo show];
    [[TelegramManager shareInstance] blockUser:user._id isBlock:NO resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"移除黑名单失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [self.contactList removeObject:user];
            [self reloadContacts:[NSArray arrayWithArray:self.contactList]];
            [UserInfo showTips:nil des:@"已从黑名单中移除".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"移除黑名单失败，请稍后重试".lv_localized];
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
        default:
            break;
    }
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
