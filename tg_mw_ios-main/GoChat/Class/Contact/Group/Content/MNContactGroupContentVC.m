//
//  MNContactGroupContentVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNContactGroupContentVC.h"
#import "MNContactGroupContentCell.h"

@interface MNContactGroupContentVC ()
@property (nonatomic, assign) BOOL isManaged;
//原始列表
@property (nonatomic, strong) NSMutableArray *groupList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionGroupList;
@property (nonatomic, strong) NSMutableDictionary *managerDic;
@end

@implementation MNContactGroupContentVC

- (instancetype)initWithManaged:(BOOL)isManaged
{
    self = [super init];
    if (self) {
        _isManaged = isManaged;
        _managerDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(UIEdgeInsetsZero);
        make.top.equalTo(self.view).offset(kNavBarHeight+50);
    }];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //初始数据
    [self reloadGroups];
}

- (void)reloadGroups
{
    [self.groupList removeAllObjects];
    [self.sectionGroupList removeAllObjects];
    
    NSArray *list = [[TelegramManager shareInstance] getGroups];
   
    UserInfo *curUser = [UserInfo shareInstance];
    dispatch_group_t group = dispatch_group_create();
   
    WS(weakSelf)
    __block NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    __block NSMutableArray *tempList = [[NSMutableArray alloc] init];
    if (list.count>0) {
        for (ChatInfo *chat in list) {
            if ([chat.type.type isEqualToString:@"chatTypeSupergroup"]) {
                long supergroupId = chat.type.supergroup_id;
                
                dispatch_group_enter(group);
                [[TelegramManager shareInstance] getSuperGroupInfo:supergroupId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    SuperGroupInfo *groupInfo = obj;
                    Group_ChatMemberStatus *status = groupInfo.status;
                    if ([status.type  isEqualToString:@"chatMemberStatusAdministrator"]||
                        [status.type isEqualToString:@"chatMemberStatusCreator"]||
                        [status.type  isEqualToString:@"chatMemberStatusMember"]) {
                        if ([status.type  isEqualToString:@"chatMemberStatusAdministrator"]||
                            [status.type isEqualToString:@"chatMemberStatusCreator"]){
                            [tempDic setObject:chat forKey:[@(supergroupId) stringValue]];
                        }
                        [tempList addObject:chat];
                    }
                    dispatch_group_leave(group);
                } timeout:^(NSDictionary *request) {
                    dispatch_group_leave(group);
                }];
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            weakSelf.managerDic = tempDic;
            for (ChatInfo *chat in tempList) {
                NSString *key  = @(chat.type.supergroup_id).stringValue;
                ChatInfo *myChat = self.managerDic[key];
                if (weakSelf.isManaged) {
                    if (myChat) {
                        [weakSelf.groupList addObject:chat];
                    }
                }else{
                    if (!myChat) {
                        [weakSelf.groupList addObject:chat];
                    }
                }
                
            }
            [weakSelf.tableView reloadData];
            [UserInfo dismiss];
            
        });
    }
    
    [self.tableView reloadData];
}

- (NSMutableArray *)groupList
{
    if(_groupList == nil)
    {
        _groupList = [NSMutableArray array];
    }
    return _groupList;
}

- (NSMutableArray *)sectionGroupList
{
    if(_sectionGroupList == nil)
    {
        _sectionGroupList = [NSMutableArray array];
    }
    return _sectionGroupList;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupList.count;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section < self.sectionGroupList.count)
//    {
//        NSArray *sectionArr = self.sectionGroupList[section];
//        if (sectionArr.count == 0)
//        {
//            return nil;
//        }
//        UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AzSectionHeaderView" owner:nil options:nil] objectAtIndex:0];
//        headerView.backgroundColor = [UIColor clearColor];
//        UILabel *titleLabel = (UILabel *)[headerView viewWithTag:101];
//        NSArray *sectionTitlesArr = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
//        if (section < sectionTitlesArr.count)
//        {
//            titleLabel.text = sectionTitlesArr[section];
//        }
//        else
//        {
//            titleLabel.text = nil;
//        }
//        return headerView;
//    }
//    return nil;
//}

//约束section header高度 当section下没有联系人时置为0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section < self.sectionGroupList.count)
//    {
//        NSArray *sectionArr = self.sectionGroupList[section];
//        if (sectionArr.count == 0)
//        {
//            return 0.001;
//        }
//    }
//    return 20;
    return 9;
}

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{//点击索引的响应
//    NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
//    return section;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{//右侧索引
//    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MNContactGroupContentCell";
    MNContactGroupContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNContactGroupContentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
//    NSArray *sectionArr = self.sectionGroupList[indexPath.section];
//    [cell resetGroupInfo:[sectionArr objectAtIndex:indexPath.row]];
    ChatInfo *chat = self.groupList[indexPath.row];
    [cell resetGroupInfo:chat];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSArray *sectionArr = self.sectionGroupList[indexPath.section];
//    [AppDelegate gotoChatView:[sectionArr objectAtIndex:indexPath.row]];
    ChatInfo *chat = self.groupList[indexPath.row];
    [AppDelegate gotoChatView:chat];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Group_Photo_Ok):
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}



@end
