//
//  CZShowAllMemberViewController.m
//  GoChat
//
//  Created by mac on 2021/7/7.
//

#import "CZShowAllMemberViewController.h"
#import "CZGroupMemberCollectionViewCell.h"
#import "CZSearchMemberTableViewCell.h"
#import "ContactSearchBar.h"
#import "MNAddGroupVC.h"
#import "MNContactDetailVC.h"
#import "GC_MyInfoVC.h"
#import "QTGroupPersonInfoVC.h"

@interface CZShowAllMemberViewController ()<BusinessListenerProtocol,TimerCounterDelegate,UISearchControllerDelegate,UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate,MNContactSearchBarDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView   *mainCollectionView;
@property (nonatomic,strong) NSArray                    *itemsArray;
@property (nonatomic, strong) TimerCounter              *reloadMembersTimer;
@property (nonatomic, strong) BasicGroupInfo            *groupInfo;
@property (nonatomic, strong) SuperGroupInfo            *super_groupInfo;
@property (nonatomic,strong) NSMutableArray                    *membersList;
@property (nonatomic,strong) NSArray                    *memberIsManagersList;
@property (nonatomic, strong) SuperGroupFullInfo        *super_groupFullInfo;
@property (nonatomic, strong) BasicGroupFullInfo        *groupFullInfo;
//群成员字典表
@property (nonatomic, strong) NSMutableDictionary       *membersDic;
@property (nonatomic, retain) UISearchController        *searchController;
// 存放搜索出结果的数组
@property (nonatomic, retain) NSMutableArray            *searchResultDataArray;
// 搜索使用的表示图控制器
@property (nonatomic, retain) UITableViewController     *searchTVC;
@property (nonatomic, strong) ContactSearchBar *searchBar;
@property (nonatomic, assign) int offset;


@end

@implementation CZShowAllMemberViewController

- (NSMutableArray *)membersList{
    if(!_membersList){
        _membersList = [NSMutableArray array];
    }
    return _membersList;
}

- (NSMutableArray *)searchResultDataArray{
    if (!_searchResultDataArray) {
        _searchResultDataArray = [NSMutableArray array];
    }
    return _searchResultDataArray;
}

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
    [self.reloadMembersTimer stopCountProcess];
    self.reloadMembersTimer = nil;
}

- (void)getSuperAdminMembers
{
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterAdministrators" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = (NSArray *)obj;
            self.memberIsManagersList = list;
            [self freshCollectionData];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)getSuperMembers
{
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterRecent" keyword:nil offset:self.offset limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            [self.membersList removeAllObjects];
            NSArray *list = (NSArray *)obj;
            if(self.offset + list.count < [response[@"total_count"] intValue]){
                [self.membersList addObjectsFromArray:list];
                self.offset = (int)list.count;
                [self getSuperMembers];
            }else{
                [self.membersList addObjectsFromArray:list];
                [self freshCollectionData];
            }
        }
    } timeout:^(NSDictionary *request) {
    }];
}

#pragma mark - TimerCounterDelegate
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    //获取超级群组成员列表
    [self getSuperMembers];
    //获取超级群组管理员列表
    [self getSuperAdminMembers];
}

- (void)syncChatInfo
{
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.chatInfo._id];
    if(chat != nil)
    {
        self.chatInfo = chat;
    }
}

- (void)checkUserChatState
{
    if(self.chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupInfo class]])
            {
                self.super_groupInfo = obj;
                [self freshCollectionData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    else
    {//普通群组
        //获得群组基本资料
        [[TelegramManager shareInstance] getBasicGroupInfo:self.chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[BasicGroupInfo class]])
            {
                self.groupInfo = obj;
                [self freshCollectionData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.offset = 0;
    self.definesPresentationContext = YES;
    [self.contentView removeFromSuperview];
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(APP_TOP_BAR_HEIGHT+65);
        make.bottom.mas_equalTo(-kBottom34());
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initCreateCollectionView];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    self.reloadMembersTimer = [TimerCounter new];
    self.reloadMembersTimer.delegate = self;
    
    //先同步会话信息
    [self syncChatInfo];
    
    //检查状态
    [self checkUserChatState];
    [self syncFullGroupInfo];
    // Do any additional setup after loading the view from its nib.
    
    
     [self.searchBar styleNoCancel];
}

- (BOOL)canInvideMember
{
    BOOL canInvide = [self canEditGroupSetting];
    if(canInvide)
    {
        return canInvide;
    }
    return self.chatInfo.permissions.can_invite_users;
}

- (BOOL)canEditGroupSetting
{
    if(self.chatInfo.isSuperGroup)
    {
        switch ([self.super_groupInfo.status getMemberState])
        {
            case GroupMemberState_Administrator:
                //管理员
                return YES;
            case GroupMemberState_Creator:
                //创建者
                if(self.super_groupInfo.status.is_member)
                {//创建者已不在群组
                    return YES;
                }
                break;
            case GroupMemberState_Left:
                //不在群组
                break;
            case GroupMemberState_Member:
                //普通成员
                break;
            case GroupMemberState_Banned:
                //被禁用
                break;
            case GroupMemberState_Restricted:
                //被禁言
                break;
            default:
                break;
        }
    }
    else
    {
        if(self.groupInfo.is_active)
        {//是否激活
            switch ([self.groupInfo.status getMemberState])
            {
                case GroupMemberState_Administrator:
                    //管理员
                    return YES;
                case GroupMemberState_Creator:
                    //创建者
                    if(self.groupInfo.status.is_member)
                    {//创建者已不在群组
                        return YES;
                    }
                    break;
                case GroupMemberState_Left:
                    //不在群组
                    break;
                case GroupMemberState_Member:
                    //普通成员
                    break;
                case GroupMemberState_Banned:
                    //被禁用
                    break;
                case GroupMemberState_Restricted:
                    //被禁言
                    break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (BOOL)canEditGroupManagerSetting
{
    if(self.chatInfo.isSuperGroup)
    {
        switch ([self.super_groupInfo.status getMemberState])
        {
            case GroupMemberState_Creator:
                //创建者
                if(self.super_groupInfo.status.is_member)
                {//创建者还在群组
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    else
    {
        if(self.groupInfo.is_active)
        {//是否激活
            switch ([self.groupInfo.status getMemberState])
            {
                case GroupMemberState_Creator:
                    //创建者
                    if(self.groupInfo.status.is_member)
                    {//创建者还在群组
                        return YES;
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (BOOL)isOwnerGroup
{
    if(self.chatInfo.isSuperGroup)
    {
        switch ([self.super_groupInfo.status getMemberState])
        {
            case GroupMemberState_Creator:
                //创建者
                if(self.super_groupInfo.status.is_member)
                {
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    else
    {
        if(self.groupInfo.is_active)
        {//是否激活
            switch ([self.groupInfo.status getMemberState])
            {
                case GroupMemberState_Creator:
                    //创建者
                    if(self.groupInfo.status.is_member)
                    {
                        return YES;
                    }
                    break;
                default:
                    break;
            }
        }
    }
    return NO;
}

- (void)freshCollectionData{
    [self.customNavBar setTitle: [NSString stringWithFormat:@"群成员(%lu人)".lv_localized, (unsigned long)self.membersList.count]];
    [self resetMembersList:self.membersList canAdd:[self canInvideMember] canDelete:[self canEditGroupSetting]];
    [self.mainCollectionView reloadData];
}

- (void)resetMembersList:(NSArray *)list canAdd:(BOOL)canAdd canDelete:(BOOL)canDelete
{
    NSMutableArray *lt = [NSMutableArray array];
    if(list.count>0)
    {
        for(int i=0; i<list.count; i++)
        {
            [lt addObject:[list objectAtIndex:i]];
        }
    }
    if(canAdd)
    {
        [lt addObject:@"add"];
    }
    if(canDelete)
    {
        [lt addObject:@"delete"];
    }
    self.itemsArray = lt;
}


-(void)initCreateCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 15, 10, 15);
    flowLayout.minimumLineSpacing = 15;
    flowLayout.minimumInteritemSpacing = 15;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//垂直
    self.mainCollectionView.collectionViewLayout = flowLayout;
    self.mainCollectionView.showsVerticalScrollIndicator = NO;
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"CZGroupMemberCollectionViewCell"bundle:nil]forCellWithReuseIdentifier:@"CZGroupMemberCollectionViewCell"];
    
    // 添加 searchbar 到 headerview
//    self.mainCollectionView.contentInset = UIEdgeInsetsMake(65, 0, 0, 0);
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, SCREEN_WIDTH, 50)];
    [headerView addSubview:self.searchBar];
    headerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headerView];
//    [self.mainCollectionView addSubview: headerView];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(0);
    }];
}

-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.cornerRadius = 21;
    }
    return _searchBar;
}

#pragma mark - UITextFieldDelegate
-(void)searchBar:(ContactSearchBar *)bar textFieldDidBeginEditing:(UITextField *)textField{
   
    [self.searchBar styleNoCancel];
}

-(void)searchBar:(ContactSearchBar *)bar textFieldShouldReturn:(UITextField *)textField{
    //
    [self searchMembersFromAllList:textField.text];
    self.tableView.hidden = NO;
    self.mainCollectionView.hidden = YES;
    [self.tableView reloadData];
}
-(void)searchBar:(ContactSearchBar *)bar touchUpInsideCancelBtn:(UIButton *)cancel{
    self.tableView.hidden = YES;
    self.mainCollectionView.hidden = NO;
    [bar.searchTf resignFirstResponder];
    [self.searchBar styleNoCancel];
}

-(void)searchBar:(ContactSearchBar *)bar textFieldValueChanged:(UITextField *)textField{
//    [self doSearch:textField.text];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.itemsArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *const cellidf = @"CZGroupMemberCollectionViewCell";
    CZGroupMemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellidf forIndexPath:indexPath];
    NSObject *obj = [self.itemsArray objectAtIndex:indexPath.row];
    cell.cellModel = obj;
    return cell;
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellWidth = (SCREEN_WIDTH - 30 - 20*4)/5;
    return CGSizeMake(cellWidth, cellWidth+35);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSObject *obj = [self.itemsArray objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[GroupMemberInfo class]]){
        [self MemberListCell_Click_Membermember:(GroupMemberInfo *)obj];
    }
    if([obj isKindOfClass:[NSString class]]){
        if([@"add" isEqualToString:(NSString *)obj]){
            [self MemberListCell_AddMember];
        }
        if([@"delete" isEqualToString:(NSString *)obj]){
            [self MemberListCell_DeleteMember];
        }
    }
}


- (void)MemberListCell_Click_Membermember:(GroupMemberInfo *)member
{//点击了成员，进入联系人详情
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
    if (!user) {
        return;
    }
    if (user._id == [UserInfo shareInstance]._id) {
        GC_MyInfoVC *vc = [[GC_MyInfoVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    /// 群组禁止单聊时，普通成员无法点击用户头像 22-01-07
    BOOL isGroupChat = (self.chatInfo.isSuperGroup && self.super_groupInfo);
    BOOL isGroupAdmin = [@[@(GroupMemberState_Administrator), @(GroupMemberState_Creator)] containsObject:@(self.super_groupInfo.status.getMemberState)];
    /// 是群组 不是管理员 群组禁止私聊
    if (isGroupChat && !isGroupAdmin && self.cusPermissionsModel.banWhisper) {
        return;
    }
    
//    MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//    v.user = user;
//    [self.navigationController pushViewController:v animated:YES];
    
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

- (void)MemberListCell_AddMember
{//增加成员
    MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
    chooseView.hidesBottomBarWhenPushed = YES;
    chooseView.chooseType = MNContactChooseType_Group_Add_Member;
    chooseView.group_membersList = self.membersList;
    chooseView.chatId = self.chatInfo._id;
    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
    [self.navigationController pushViewController:chooseView animated:YES];
//    ContactChooseViewController *chooseView = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactChooseViewController"];
//    chooseView.hidesBottomBarWhenPushed = YES;
//    chooseView.chooseType = ContactChooseType_Group_Add_Member;
//    chooseView.group_membersList = self.membersList;
//    chooseView.chatId = self.chatInfo._id;
//    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
//    [self.navigationController pushViewController:chooseView animated:YES];
}

- (void)MemberListCell_DeleteMember
{//删除成员
    
    MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
    chooseView.chooseType = MNContactChooseType_Group_Delete_Member;
    chooseView.group_membersList = self.membersList;
    chooseView.group_managersList = self.memberIsManagersList;
    chooseView.chatId = self.chatInfo._id;
    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
    [self.navigationController pushViewController:chooseView animated:YES];
//    ContactChooseViewController *chooseView = [[UIStoryboard storyboardWithName:@"Chat" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactChooseViewController"];
//    chooseView.hidesBottomBarWhenPushed = YES;
//    chooseView.chooseType = ContactChooseType_Group_Delete_Member;
//    chooseView.group_membersList = self.membersList;
//    chooseView.group_managersList = self.memberIsManagersList;
//    chooseView.chatId = self.chatInfo._id;
//    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
//    [self.navigationController pushViewController:chooseView animated:YES];
}

- (void)reloadSuperGroupFullInfo:(SuperGroupFullInfo *)info
{
    self.super_groupFullInfo = info;
    //性能考虑
    [self.reloadMembersTimer stopCountProcess];
    [self.reloadMembersTimer startCountProcess:1 repeat:NO];
    NSLog(@"添加好友 - aaaaaaaaaa");
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Group_Basic_Info_Changed):
        {
            if(self.chatInfo.isGroup && !self.chatInfo.isSuperGroup)
            {
                BasicGroupInfo *info = inParam;
                if(info != nil && [info isKindOfClass:[BasicGroupInfo class]])
                {
                    if(self.chatInfo.type.basic_group_id == info._id)
                    {
                        self.groupInfo = info;
                        [self freshCollectionData];
                        //同步详情
                        [self syncFullGroupInfo];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Basic_Full_Info_Changed):
        {//@{@"info":info, @"basic_group_id":[dic objectForKey:@"basic_group_id"]}
            if(self.chatInfo.isGroup && !self.chatInfo.isSuperGroup)
            {
                NSDictionary *obj = inParam;
                if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
                {
                    BasicGroupFullInfo *info = [obj objectForKey:@"info"];
                    NSNumber *basic_group_id = [obj objectForKey:@"basic_group_id"];
                    if(info != nil && basic_group_id != nil)
                    {
                        if([info isKindOfClass:[BasicGroupFullInfo class]] && [basic_group_id isKindOfClass:[NSNumber class]])
                        {
                            if(self.chatInfo.type.basic_group_id == basic_group_id.longValue)
                            {
                                //延时加载
                                [self performSelector:@selector(reloadBasicGroupFullInfo:) withObject:info afterDelay:0.1];
                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Super_Info_Changed)://成员删除
        {
            if(self.chatInfo.isGroup && self.chatInfo.isSuperGroup)
            {
                SuperGroupInfo *info = inParam;
                if(info != nil && [info isKindOfClass:[SuperGroupInfo class]])
                {
                    if(self.chatInfo.type.supergroup_id == info._id)
                    {
                        self.super_groupInfo = info;
                        [self freshCollectionData];
                        
                        //同步详情
                        //[self syncFullGroupInfo];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Super_Full_Info_Changed)://成员删除
        {//@{@"info":info, @"supergroup_id":[dic objectForKey:@"supergroup_id"]}
            if(self.chatInfo.isGroup && self.chatInfo.isSuperGroup)
            {
                NSDictionary *obj = inParam;
                if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
                {
                    SuperGroupFullInfo *info = [obj objectForKey:@"info"];
                    NSNumber *super_group_id = [obj objectForKey:@"supergroup_id"];
                    if(info != nil && super_group_id != nil)
                    {
                        if([info isKindOfClass:[SuperGroupFullInfo class]] && [super_group_id isKindOfClass:[NSNumber class]])
                        {
                            if(self.chatInfo.type.supergroup_id == super_group_id.longValue)
                            {
                                //延时加载
                                [self performSelector:@selector(reloadSuperGroupFullInfo:) withObject:info afterDelay:0.1];
                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Chatcustom_Permissions_Change)://权限变更
        {
            if (inParam) {
                CZPermissionsModel *info = inParam;
                self.cusPermissionsModel = info;
            }
        }
            break;
        default:
            break;
    }
}

- (void)reloadBasicGroupFullInfo:(BasicGroupFullInfo *)info
{
    self.groupFullInfo = info;
    [self resetMembers:self.groupFullInfo.members];
}

- (void)resetMembers:(NSArray *)list
{
    [self.membersList removeAllObjects];
    [self.membersList addObjectsFromArray:self.groupFullInfo.members];
    
    NSMutableArray *managersList = [NSMutableArray array];
    [self.membersDic removeAllObjects];
    for(GroupMemberInfo *member in self.membersList)
    {
        if([member isManagerRole])
        {
            [managersList addObject:member];
        }
        [self.membersDic setObject:member forKey:[NSNumber numberWithLong:member.user_id]];
    }
    self.memberIsManagersList = managersList;
    [self freshCollectionData];
}

- (void)syncFullGroupInfo
{
    if(self.chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupFullInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupFullInfo class]])
            {
                self.super_groupFullInfo = obj;
                //获取超级群组成员列表
                [self getSuperMembers];
                //获取超级群组管理员列表
                [self getSuperAdminMembers];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }else{//普通群组
        [[TelegramManager shareInstance] getBasicGroupFullInfo:self.chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[BasicGroupFullInfo class]])
            {
                self.groupFullInfo = obj;
                [self resetMembers:self.groupFullInfo.members];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  /*
  self.searchController.active active 属性用于判断 searchBar 是否处于活动状态
  */
    return [self.searchResultDataArray count];
}
 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CZSearchMemberTableViewCellId = @"CZSearchMemberTableViewCell";
    CZSearchMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CZSearchMemberTableViewCellId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CZSearchMemberTableViewCell" owner:nil options:nil] firstObject];
    }
    NSObject *obj = [self.searchResultDataArray objectAtIndex:indexPath.row];
    cell.cellModel = obj;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.searchResultDataArray objectAtIndex:indexPath.row];
    if([obj isKindOfClass:[GroupMemberInfo class]]){
        [self MemberListCell_Click_Membermember:(GroupMemberInfo *)obj];
    }
    if([obj isKindOfClass:[NSString class]]){
        if([@"add" isEqualToString:(NSString *)obj]){
            [self MemberListCell_AddMember];
        }
        if([@"delete" isEqualToString:(NSString *)obj]){
            [self MemberListCell_DeleteMember];
        }
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
   NSString *inputText = searchController.searchBar.text;
    [self searchMembersFromAllList:inputText];
   [self.searchTVC.tableView reloadData];
}


//从成员中搜索满足条件的成员
- (void)searchMembersFromAllList:(NSString *)searchStr{
    [self.searchResultDataArray removeAllObjects];
    for (NSObject *item in self.membersList) {
        if ([item isKindOfClass:[GroupMemberInfo class]]) {
            GroupMemberInfo *info = (GroupMemberInfo *)item;
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.user_id];
            if ([user.displayName containsString:searchStr]) {
                [self.searchResultDataArray addObject:item];
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
