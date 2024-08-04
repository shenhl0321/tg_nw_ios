//
//  MNAddGroupVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNAddGroupVC.h"
#import "ContactSearchBar.h"
#import "MNAddGroupHeaderView.h"
#import "MNAddGroupCell.h"
#import "TF_RequestManager.h"

@interface MNAddGroupVC ()
<MNContactSearchBarDelegate>

@property (nonatomic, strong) ContactSearchBar *searchBar;
//原始列表
@property (nonatomic, strong) NSMutableArray *contactList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionContactList;
//选中的联系人
@property (nonatomic, strong) NSMutableDictionary *choosedDic;
//不可更改的联系人
@property (nonatomic, strong) NSMutableDictionary *disableChooseDic;

@property (nonatomic, strong) UserInfo *selectedUser;//创建私密聊天的时候用

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *groupNicknames;
@property (nonatomic, strong) UIButton *allSelecter;
@property (strong, nonatomic) UIImageView *avatarImage;
@property (strong, nonatomic) UILabel *allLab;
@property (strong, nonatomic) UIButton *okBtn;
@property (strong, nonatomic) UIButton *rightBtn;

@property (strong, nonatomic) UIView *lineV;

@end

@implementation MNAddGroupVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}
- (void)cliclBack{
    if (self.isPresent == YES){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chooseClose)]) {
            [self.delegate chooseClose];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    [self initTitle];
    
    //设置导航栏菜单
    [self initNavButton];
    [self initUI];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    if (self.chooseType == MNContactChooseType_Private_Chat) {
        self.fromContactId = [UserInfo shareInstance]._id;
    }
    //初始数据
    [self loadData];
    
    if (self.isPresent == YES){
        [self.customNavBar setLeftBtnWithImageName:nil title:@"取消" highlightedImageName:nil];
    }else{
        
    }
}

- (void)navigationBar:(MNNavigationBar *)navationBar didClickLeftBtn:(UIButton *)btn{
    [self cliclBack];
}
-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self click_ok];
}

- (void)initUI{
    [self.contentView addSubview:self.searchBar];
    if (self.isPresent == YES){
        self.customNavBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        self.customNavBar.contentView.frame = CGRectMake(0, 16, SCREEN_WIDTH, 44);
        
        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(2 - kStatusBarHeight + 16);
            make.left.mas_equalTo(0);
            make.height.mas_equalTo(42);
            make.right.mas_equalTo(0);
        }];
    }else{
        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(2);
            make.left.mas_equalTo(0);
            make.height.mas_equalTo(42);
            make.right.mas_equalTo(0);
        }];
    }
    
    [self.searchBar styleNoCancel];
    
    [self.contentView addSubview:self.lineV];
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.searchBar.mas_bottom);
        make.height.mas_offset(1);
    }];
    
    if(self.chooseType == MNContactChooseType_Group_Sent){
        [self.contentView addSubview:self.avatarImage];
        [self.contentView addSubview:self.allLab];
        [self.contentView addSubview:self.allSelecter];
        [self.allSelecter mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).with.offset(20);
            make.width.mas_equalTo(99);
            make.height.mas_equalTo(25);
            make.left.mas_equalTo(15);
        }];
        
        [self.avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.centerY.equalTo(self.allSelecter);
            make.left.equalTo(self.contentView).offset(50);
            make.width.height.mas_offset(50);
        }];
        [self.allLab mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.left.equalTo(self.avatarImage.mas_right).offset(10);
            make.centerY.equalTo(self.avatarImage);
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImage.mas_bottom).with.offset(10);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).with.offset(15);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
}
- (UIView *)lineV{
    if (!_lineV){
        _lineV = [[UIView alloc] init];
        _lineV.backgroundColor = HEXCOLOR(0xF0F0F0);
    }
    return _lineV;
}
-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.searchTf.placeholder = @"搜索".lv_localized;
        _searchBar.cornerRadius = 21;
        _searchBar.backColor = [UIColor clearColor];
    }
    return _searchBar;
}
- (UIButton *)rightBtn{
    if (!_rightBtn){
        _rightBtn = [[UIButton alloc] init];
        _rightBtn.backgroundColor = HEXCOLOR(0x00C69B);
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rightBtn.clipsToBounds = YES;
        _rightBtn.layer.cornerRadius = 15;
    }
    return _rightBtn;
}
- (UILabel *)allLab{
    if (!_allLab){
        _allLab = [[UILabel alloc] init];
        _allLab.text = @"所有人";
        _allLab.textColor = HEXCOLOR(0x333333);
        _allLab.font = [UIFont systemFontOfSize:15];
    }
    return _allLab;
}
- (UIImageView *)avatarImage{
    if (!_avatarImage){
        _avatarImage = [[UIImageView alloc] init];
        _avatarImage.clipsToBounds = YES;
        _avatarImage.layer.cornerRadius = 25;
        _avatarImage.image = [UIImage imageNamed:@"icon_contact_logo04"];
    }
    return _avatarImage;
}
-(UIButton *)allSelecter{
    if(!_allSelecter){
        _allSelecter = [UIButton new];
        _allSelecter.imageEdgeInsets = UIEdgeInsetsMake(3, 0, 3, 99-19);
//        _allSelecter.titleEdgeInsets = UIEdgeInsetsMake(0, 30, 0, 10);
        _allSelecter.titleLabel.font = [UIFont systemFontOfSize:18];
        [_allSelecter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_allSelecter setImage:[UIImage imageNamed:@"UnSelect"] forState:UIControlStateNormal];
        [_allSelecter setImage:[UIImage imageNamed:@"Select"] forState:UIControlStateSelected];
        [_allSelecter setTitle:@"" forState:UIControlStateNormal];
        [_allSelecter addTarget:self action:@selector(allSelecterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allSelecter;
}

- (void)allSelecterBtnClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if(sender.selected){
        if(self.sectionContactList && self.sectionContactList.count > 0){
            for (int i=0; i<self.sectionContactList.count; i++) {
                NSArray *sectionArr = self.sectionContactList[i];
                if(sectionArr && sectionArr.count > 0){
                    for (int j=0; j<sectionArr.count; j++) {
                        UserInfo *user = [sectionArr objectAtIndex:j];
                        [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                    }
                }
            }
        }
    }else{
        [self.choosedDic removeAllObjects];
    }
    [self.tableView reloadData];
}

//是否全选
- (void)setAllSelStyle{
    bool isSel = YES;
    if(self.sectionContactList && self.sectionContactList.count > 0){
        for (int i=0; i<self.sectionContactList.count; i++) {
            NSArray *sectionArr = self.sectionContactList[i];
            if(sectionArr && sectionArr.count > 0){
                for (int j=0; j<sectionArr.count; j++) {
                    UserInfo *user = [sectionArr objectAtIndex:j];
                    if(![self.choosedDic objectForKey:[NSNumber numberWithLong:user._id]]){
                        isSel = NO;
                    }
                }
            }
        }
    }
    self.allSelecter.selected = isSel;
}


#pragma mark - UITextFieldDelegate
-(void)searchBar:(ContactSearchBar *)bar textFieldDidBeginEditing:(UITextField *)textField{
  
    [self.searchBar styleHasCancel];
}
-(void)searchBar:(ContactSearchBar *)bar textFieldShouldReturn:(UITextField *)textField{

}
-(void)searchBar:(ContactSearchBar *)bar touchUpInsideCancelBtn:(UIButton *)cancel{
 
    [bar.searchTf resignFirstResponder];
    [self.searchBar styleNoCancel];
}

-(void)searchBar:(ContactSearchBar *)bar textFieldValueChanged:(UITextField *)textField{
//    [self doSearch:textField.text];
    NSString *keyword = textField.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!IsStrEmpty(keyword))
    {
        NSMutableArray *list = [NSMutableArray array];
        for(UserInfo *user in self.contactList)
        {
            if([user isMatch:keyword])
            {
                [list addObject:user];
            }
        }
        [self reloadContacts:list];
    }
    else
    {
        [self reloadContacts:self.contactList];
    }
}

- (void)doSearch:(NSString *)keyWord{
    
}

- (void)loadData
{
    [self.contactList removeAllObjects];
    self.groupNicknames = NSMutableDictionary.dictionary;
    
    if(self.chooseType == MNContactChooseType_CreateBasicGroup || self.chooseType == MNContactChooseType_CreateBasicGroup_From_Contact||self.chooseType == MNContactChooseType_Private_Chat || self.chooseType == MNContactChooseType_Group_Sent || self.chooseType == MNContactChooseType_Timeline_At_Someone)
    {//联系人相关
        //不可更改部分
        if(self.chooseType == MNContactChooseType_CreateBasicGroup_From_Contact)
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.fromContactId];
            if(user)
            {
                [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            }
        }
        //联系人列表
        NSArray *list = [[TelegramManager shareInstance] getContacts];
        if(list.count>0)
        {
            [self.contactList addObjectsFromArray:list];
        }
        [self reloadContacts:self.contactList];
    }
    if(self.chooseType == MNContactChooseType_Group_Add_Member)
    {//群组增加成员-从联系人列表增加
        //不可更改部分
        for(GroupMemberInfo *member in self.group_membersList)
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
            if (user) {
                [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            }
        }
        //联系人列表
        NSArray *list = [[TelegramManager shareInstance] getContacts];
        if(list.count>0)
        {
            [self.contactList addObjectsFromArray:list];
        }
        [self reloadContacts:self.contactList];
    }
    if(self.chooseType == MNContactChooseType_Group_Add_Manager)
    {//群组增加管理员-从现有群组成员提升
        //不可更改部分
        for(GroupMemberInfo *member in self.group_managersList)
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
            if(user)
            {
                [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            }
        }
        //联系人列表
        if(self.group_membersList.count>0)
        {
            for(GroupMemberInfo *member in self.group_membersList) {
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
                if (user) {
                    [self.contactList addObject:user];
                    [self.groupNicknames setObject:member.nickname ? : @"" forKey:@(user._id)];
                }
            }
        }
        [self reloadContacts:self.contactList];
    }
    if(self.chooseType == MNContactChooseType_Group_Delete_Member)
    {//群组移除成员-从现有群组成员移除(不包括自己和管理员)
        //不可更改部分-去除自己
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:[UserInfo shareInstance]._id];
        if(user)
        {
            [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
        }
        //不可更改部分-去除管理员
        for(GroupMemberInfo *member in self.group_managersList)
        {
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
            if(user)
            {
                [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            }
        }
        //联系人列表
        if(self.group_membersList.count>0)
        {
            for(GroupMemberInfo *member in self.group_membersList)
            {
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
                if (user) {
                    [self.contactList addObject:user];
                    [self.groupNicknames setObject:member.nickname ? : @"" forKey:@(user._id)];
                }
            }
        }
        [self reloadContacts:self.contactList];
    }
    if(self.chooseType == MNContactChooseType_Group_Delete_Manager)
    {//群组删除管理员-从现有群管理员降级
        //不可更改部分-去除自己
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:[UserInfo shareInstance]._id];
        if(user)
        {
            [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
        }
        //联系人列表
        if(self.group_managersList.count>0)
        {
            for(GroupMemberInfo *member in self.group_managersList)
            {
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
                if (user) {
                    [self.contactList addObject:user];
                    [self.groupNicknames setObject:member.nickname ? : @"" forKey:@(user._id)];
                }
            }
        }
        [self reloadContacts:self.contactList];
    }
    //
    if(self.chooseType == MNContactChooseType_Group_At_Someone)
    {
        [[TelegramManager shareInstance] getSuperGroupMembers:self.supergroup_id type:@"supergroupMembersFilterRecent" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[NSArray class]])
            {
                self.group_membersList = (NSArray *)obj;
                //不可更改部分-去除自己
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:[UserInfo shareInstance]._id];
                if(user) {
                    [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                    [self.disableChooseDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
                }
                //联系人列表
                if(self.group_membersList.count>0)
                {
                    for(GroupMemberInfo *member in self.group_membersList)
                    {
                        UserInfo *user = [[TelegramManager shareInstance] contactInfo:member.user_id];
                        if (user) {
                            [self.contactList addObject:user];
                            [self.groupNicknames setObject:member.nickname ? : @"" forKey:@(user._id)];
                        }
                    }
                }
                [self reloadContacts:self.contactList];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (void)initTitle
{
    if(!IsStrEmpty(self.chooseTitle))
    {
        [self.customNavBar setTitle:self.chooseTitle];
    }
    else
    {
        switch (self.chooseType)
        {
            case MNContactChooseType_CreateBasicGroup:
                [self.customNavBar setTitle:@"新建群组".lv_localized];
                break;
            case MNContactChooseType_CreateBasicGroup_From_Contact:
                [self.customNavBar setTitle:@"选择好友".lv_localized];
                break;
            case MNContactChooseType_Group_Add_Member:
                [self.customNavBar setTitle:@"添加群组成员".lv_localized];
                break;
            case MNContactChooseType_Group_Add_Manager:
                [self.customNavBar setTitle:@"添加群主管理员".lv_localized];
                break;
            case MNContactChooseType_Group_Delete_Member:
                [self.customNavBar setTitle:@"移除群组成员".lv_localized];
                break;
            case MNContactChooseType_Group_Delete_Manager:
                [self.customNavBar setTitle:@"移除群组管理员".lv_localized];
                break;
            case MNContactChooseType_Group_At_Someone:
            case MNContactChooseType_Timeline_At_Someone:
                [self.customNavBar setTitle:@"选择提醒的人".lv_localized];
                break;
            case MNContactChooseType_Private_Chat:
                [self.customNavBar setTitle:@"创建私密聊天".lv_localized];
                break;
            case MNContactChooseType_Group_Sent:
                [self.customNavBar setTitle:@"新建群发".lv_localized];
                break;
            default:
                [self.customNavBar setTitle:@"".lv_localized];
                break;
        }
    }
}

- (void)initNavButton
{
    switch (self.chooseType)
    {
        case MNContactChooseType_CreateBasicGroup:
        {
           
            self.okBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"创建".lv_localized highlightedImageName:nil];
            [self.rightBtn setTitle:@"创建" forState:UIControlStateNormal];
            [self.view addSubview:self.rightBtn];
            [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.center.equalTo(self.okBtn);
                make.height.mas_offset(30);
                make.width.mas_offset(60);
            }];
            [self.rightBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
            self.okBtn.hidden = YES;
            
        }
            break;
        case MNContactChooseType_CreateBasicGroup_From_Contact:
        case MNContactChooseType_Group_Add_Member:
        case MNContactChooseType_Group_Add_Manager:
        case MNContactChooseType_Group_Delete_Member:
        case MNContactChooseType_Group_Delete_Manager:
        case MNContactChooseType_Group_Sent:
        {
            self.okBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"完成".lv_localized highlightedImageName:nil];
            [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
            [self.view addSubview:self.rightBtn];
            [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.center.equalTo(self.okBtn);
                make.height.mas_offset(30);
                make.width.mas_offset(60);
            }];
            [self.rightBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
            self.okBtn.hidden = YES;
        }
            break;
        case MNContactChooseType_Group_At_Someone:
        case MNContactChooseType_Timeline_At_Someone:
            break;
        case MNContactChooseType_Private_Chat:
        {
            self.okBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"完成".lv_localized highlightedImageName:nil];
            [self.rightBtn setTitle:@"完成" forState:UIControlStateNormal];
            [self.view addSubview:self.rightBtn];
            [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.center.equalTo(self.okBtn);
                make.height.mas_offset(30);
                make.width.mas_offset(60);
            }];
            [self.rightBtn addTarget:self action:@selector(click_ok) forControlEvents:UIControlEventTouchUpInside];
            self.okBtn.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (void)reloadContacts:(NSArray *)ctsList
{
    [self.sectionContactList removeAllObjects];
    NSInteger sectionCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:sectionCount];
    for (int i = 0; i < sectionCount; i++)
    {
        NSMutableArray *sectionArray = [NSMutableArray array];
        [sectionArrays addObject:sectionArray];
    }
    
    //将user添加到对应section的array下
    for (UserInfo *user in ctsList)
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

- (NSMutableDictionary *)choosedDic
{
    if(_choosedDic == nil)
    {
        _choosedDic = [NSMutableDictionary dictionary];
    }
    return _choosedDic;
}

- (NSMutableDictionary *)disableChooseDic
{
    if(_disableChooseDic == nil)
    {
        _disableChooseDic = [NSMutableDictionary dictionary];
    }
    return _disableChooseDic;
}

#pragma mark - UITextFieldDelegate
-(void)textContentChanged:(UITextField*)textFiled
{
    NSString *keyword = textFiled.text;
    keyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if(!IsStrEmpty(keyword))
    {
        NSMutableArray *list = [NSMutableArray array];
        for(UserInfo *user in self.contactList)
        {
            if([user isMatch:keyword])
            {
                [list addObject:user];
            }
        }
        [self reloadContacts:list];
    }
    else
    {
        [self reloadContacts:self.contactList];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - click
- (void)click_ok
{
    switch (self.chooseType)
    {
        case MNContactChooseType_CreateBasicGroup:
            [self createGroup:NO];
            break;
        case MNContactChooseType_CreateBasicGroup_From_Contact:
            [self createGroup:NO];
            break;
        case MNContactChooseType_Group_Add_Member:
            [self addGroupMember];
            break;
        case MNContactChooseType_Group_Add_Manager:
            [self addGroupManager];
            break;
        case MNContactChooseType_Group_Delete_Member:
            [self deleteGroupMember];
            break;
        case MNContactChooseType_Group_Delete_Manager:
            [self deleteGroupManager];
            break;
        case MNContactChooseType_Private_Chat:
            [self creaetPrivateChat];
            break;
        case MNContactChooseType_Group_Sent:
            [self createGroupSent];
            break;
        default:
            break;
    }
}

- (void)createGroup:(BOOL)isBasicGroup
{
    NSArray *list = self.choosedDic.allValues;
    if(list.count<2)
    {
        [UserInfo showTips:nil des:@"请至少选择两个好友来创建群组".lv_localized];
        return;
    }
    
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        UserInfo *user1 = (UserInfo *)obj1;
        UserInfo *user2 = (UserInfo *)obj2;
        return [user1.displayName_full_py compare:user2.displayName_full_py];
    }];
    NSString *groupName = @"";
    if(list.count>2)
    {
        groupName = [NSString stringWithFormat:@"%@、%@、%@", ((UserInfo *)([list objectAtIndex:0])).displayName, ((UserInfo *)([list objectAtIndex:1])).displayName, ((UserInfo *)([list objectAtIndex:2])).displayName];
    }
    else
    {
        groupName = [NSString stringWithFormat:@"%@、%@、%@", ((UserInfo *)([list objectAtIndex:0])).displayName, ((UserInfo *)([list objectAtIndex:1])).displayName, [UserInfo shareInstance].displayName];
    }
    
    if(isBasicGroup)
    {//普通群组
        [self createBasicGroup:groupName userIds:[self.choosedDic allKeys]];
    }
    else
    {//超级群组
        [self createSuperGroup:groupName userIds:[self.choosedDic allKeys]];
    }
}

- (void)createBasicGroup:(NSString *)groupName userIds:(NSArray *)userIds
{
    [UserInfo show];
    [[TelegramManager shareInstance] createBasicGroupChat:groupName userIds:userIds resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if(obj != nil && [obj isKindOfClass:ChatInfo.class])
        {
            [self toChat:obj];
        }
        else
        {
            [UserInfo showTips:nil des:@"创建群组失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"创建群组失败，请稍后重试".lv_localized];
    }];
}

- (void)createSuperGroup:(NSString *)groupName userIds:(NSArray *)userIds
{
    [UserInfo show];
    [[TelegramManager shareInstance] createSuperGroupChat:groupName resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:ChatInfo.class])
        {
            ChatInfo *chat = (ChatInfo *)obj;
            [[TelegramManager shareInstance] addMembers2SuperGroup:chat._id members:userIds resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                [self toChat:obj];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
                [self toChat:obj];
            }];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"创建群组失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"创建群组失败，请稍后重试".lv_localized];
    }];
}

- (NSArray *)filterChooseList
{
    NSArray *list = self.choosedDic.allValues;
    if(list.count<=0)
    {
        return nil;
    }
    NSMutableArray *filterList = [NSMutableArray array];
    for(UserInfo *user in list)
    {
        if([self.disableChooseDic objectForKey:[NSNumber numberWithLong:user._id]] == nil)
        {
            [filterList addObject:[NSNumber numberWithLong:user._id]];
        }
    }
    return filterList;
}

- (NSArray *)filterChooseUsers
{
    NSArray *list = self.choosedDic.allValues;
    if(list.count<=0)
    {
        return nil;
    }
    NSMutableArray *filterList = [NSMutableArray array];
    for(UserInfo *user in list)
    {
        if([self.disableChooseDic objectForKey:[NSNumber numberWithLong:user._id]] == nil)
        {
            [filterList addObject:user];
        }
    }
    return filterList;
}

- (void)addGroupMember
{
    NSArray *list = [self filterChooseList];
    if(list.count<=0)
    {
        [UserInfo showTips:nil des:@"请选择好友".lv_localized];
        return;
    }
    
    //添加群组成员请求
    if(self.isSuperGroup)
    {
        [self addSuperGroupMembers:list];
    }
    else
    {
        [UserInfo show];
        [self addGroupMember:list index:0];
    }
}

- (void)addSuperGroupMembers:(NSArray *)list
{
    MJWeakSelf
    [UserInfo show];
    [[TelegramManager shareInstance] addMembers2SuperGroup:self.chatId members:list resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组成员已增加".lv_localized];
            if (weakSelf.isPresent == YES){
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }else{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组成员增加失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组成员增加失败，请稍后重试".lv_localized];
    }];
}

- (void)addGroupMember:(NSArray *)list index:(int)index
{//普通群组成员只有一个一个添加
    if(list.count<=0 || list.count <= index)
    {//已执行完
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组成员已增加".lv_localized];
        [self cliclBack];
        return;
    }
    NSNumber *userId = [list objectAtIndex:index++];
    [[TelegramManager shareInstance] addMember2Group:self.chatId member:[userId longValue] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //下一个
            [self addGroupMember:list index:index];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组成员增加失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组成员增加失败，请稍后重试".lv_localized];
    }];
}

- (void)addGroupManager
{
    NSArray *list = [self filterChooseList];
    if(list.count<=0)
    {
        [UserInfo showTips:nil des:@"请选择群组成员".lv_localized];
        return;
    }
    
    //添加群组管理员请求
    [UserInfo show];
    [self addGroupManager:list index:0];
}

- (void)addGroupManager:(NSArray *)list index:(int)index
{//群组管理员只有一个一个添加
    if(list.count<=0 || list.count <= index)
    {//已执行完
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员已增加".lv_localized];
        [self cliclBack];
        return;
    }
    NSNumber *userId = [list objectAtIndex:index++];
    [[TelegramManager shareInstance] addManager2Group:self.chatId member:[userId longValue] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //下一个
            [self addGroupManager:list index:index];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组管理员增加失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员增加失败，请稍后重试".lv_localized];
    }];
}

- (void)deleteGroupMember
{
    NSArray *list = [self filterChooseList];
    if(list.count<=0)
    {
        [UserInfo showTips:nil des:@"请选择群组成员".lv_localized];
        return;
    }
    
    //移除
    [UserInfo show];
    [self deleteGroupMember:list index:0];
}

- (void)deleteGroupMember:(NSArray *)list index:(int)index
{//群组成员只有一个一个移除
    if(list.count<=0 || list.count <= index)
    {//已执行完
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组成员已移除".lv_localized];
        [self cliclBack];
        return;
    }
    NSNumber *userId = [list objectAtIndex:index++];
    [[TelegramManager shareInstance] removeMemberFromGroup:self.chatId member:[userId longValue] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //下一个
            [self deleteGroupMember:list index:index];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组成员移除失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组成员移除失败，请稍后重试".lv_localized];
    }];
}

- (void)deleteGroupManager
{
    NSArray *list = [self filterChooseList];
    if(list.count<=0)
    {
        [UserInfo showTips:nil des:@"请选择群组管理员".lv_localized];
        return;
    }
    
    //移除
    [UserInfo show];
    if(self.isSuperGroup)
    {
        [self deleteSuperGroupManager:list index:0];
    }
    else
    {
        [self deleteGroupManager:list index:0];
    }
}

- (void)deleteGroupManager:(NSArray *)list index:(int)index
{//群组管理员只有一个一个移除
    if(list.count<=0 || list.count <= index)
    {//已执行完
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员已移除".lv_localized];
        [self cliclBack];
        return;
    }
    NSNumber *userId = [list objectAtIndex:index++];
    [[TelegramManager shareInstance] removeManagerFromGroup:self.chatId member:[userId longValue] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //下一个
            [self deleteGroupManager:list index:index];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组管理员移除失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员移除失败，请稍后重试".lv_localized];
    }];
}

- (void)deleteSuperGroupManager:(NSArray *)list index:(int)index
{//超级群组管理员只有一个一个移除-先禁言再设置为普通成员
    if(list.count<=0 || list.count <= index)
    {//已执行完
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员已移除".lv_localized];
        [self cliclBack];
        return;
    }
    NSNumber *userId = [list objectAtIndex:index++];
    [[TelegramManager shareInstance] banMemberFromSuperGroup:self.chatId member:[userId longValue] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //下一个
            [self toSuperGroupMember:list index:index memberId:[userId longValue]];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组管理员移除失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员移除失败，请稍后重试".lv_localized];
    }];
}

- (void)toSuperGroupMember:(NSArray *)list index:(int)index memberId:(long)memberId
{//超级群组管理员只有一个一个移除-先禁言再设置为普通成员
    [[TelegramManager shareInstance] removeManagerFromGroup:self.chatId member:memberId resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //下一个
            [self deleteSuperGroupManager:list index:index];
        }
        else
        {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群组管理员移除失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"群组管理员移除失败，请稍后重试".lv_localized];
    }];
}

- (void)toChat:(ChatInfo *)chat
{
    [AppDelegate gotoChatView:chat];
}

- (void)creaetPrivateChat{
    if (self.selectedUser == nil) {
        [UserInfo showTips:nil des:@"请选择聊天对象".lv_localized];
        return;
    }
    [UserInfo dismiss];
    [TF_RequestManager createNewSecretChatWithUserId:self.selectedUser._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if(obj != nil && [obj isKindOfClass:ChatInfo.class])
        {
            [AppDelegate gotoChatView:obj];
        }else{
            [UserInfo showTips:nil des:@"创建私密聊天失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"创建私密聊天失败，请稍后重试".lv_localized];
    }];
}

/// 新建群发
- (void)createGroupSent {
    NSArray *list = [self filterChooseUsers];
    if (list.count<=0) {
        [UserInfo showTips:nil des:@"请选择成员".lv_localized];
        return;
    }
    if (list.count == 1) {
        [UserInfo showTips:nil des:@"请最少选择两名成员".lv_localized];
        return;
    }
    [self cliclBack];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chooseUsers:)]) {
        [self.delegate chooseUsers:list];
    }
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
        MNAddGroupHeaderView *headerView = [[MNAddGroupHeaderView alloc] init];;
        UILabel *titleLabel = headerView.aLabel;
        NSArray *sectionTitlesArr = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
        if (section < sectionTitlesArr.count)
        {
            titleLabel.text = sectionTitlesArr[section];
        }
        else
        {
            titleLabel.text = nil;
        }
        return headerView;
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
            return 0.01;
        }
    }
    return 47;
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
    static NSString *cellId = @"MNAddGroupCell";
    MNAddGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId ];
    if (!cell) {
        
        cell = [[MNAddGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    UserInfo *user = [sectionArr objectAtIndex:indexPath.row];
    [cell resetUserInfo:user isChoose:self.choosedDic[@(user._id)]!=nil showMask:self.disableChooseDic[@(user._id)]!=nil];
    /// 设置群组内成员昵称
    NSString *nickname = self.groupNicknames[@(user._id)];
    if ([NSString xhq_notEmpty:nickname]) {
        cell.titleLabel.text = nickname;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionArr = self.sectionContactList[indexPath.section];
    UserInfo *user = [sectionArr objectAtIndex:indexPath.row];
    self.selectedUser = user;
    if([self.disableChooseDic objectForKey:[NSNumber numberWithLong:user._id]]==nil)
    {//不在不可更改的列表里
        if(self.chooseType == MNContactChooseType_Group_At_Someone ||
           self.chooseType == MNContactChooseType_Timeline_At_Someone)
        {//单选模式
            if([self.delegate respondsToSelector:@selector(chooseUser:)])
            {
                [self.delegate chooseUser:user];
            }
            [self cliclBack];
        }
        else if (self.chooseType == MNContactChooseType_Private_Chat){
            [self.choosedDic removeAllObjects];
            [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            [self.tableView reloadData];
        }
        else
        {//多选模式
            if([self.choosedDic objectForKey:[NSNumber numberWithLong:user._id]]!=nil)
            {
                [self.choosedDic removeObjectForKey:[NSNumber numberWithLong:user._id]];
            }
            else
            {
                [self.choosedDic setObject:user forKey:[NSNumber numberWithLong:user._id]];
            }
            [self.tableView reloadData];
            [self setAllSelStyle];
        }
    }
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

@end
