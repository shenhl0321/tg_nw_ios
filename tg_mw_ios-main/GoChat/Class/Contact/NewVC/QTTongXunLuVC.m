//
//  QTTongXunLuVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/1.
//

#import "QTTongXunLuVC.h"
#import "MNContactFriendCell.h"
#import "MNContactFriendHeader.h"
#import "MNContactDetailVC.h"
#import "MNAddContactVC.h"
#import "MNAddGroupVC.h"
#import "MNScanVC.h"
#import "ComputerLoginViewController.h"
#import "GC_MyInfoVC.h"
#import "QTTongXunLuHeadView.h"
#import "MNContactGroupVC.h"
#import "MNGroupSentVC.h"
#import "MNContactSearchVC.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"

@interface QTTongXunLuVC ()
<BusinessListenerProtocol>
//原始列表
@property (nonatomic, strong) NSMutableArray *contactList;
//分组列表
@property (nonatomic, strong) NSMutableArray *sectionContactList;


@property (nonatomic, strong) UILabel *logoLabel;
@property (nonatomic, strong) NSString *logoString;

@property (strong, nonatomic) QTTongXunLuHeadView *headView;

@end

@implementation QTTongXunLuVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.logoString = @"通讯录".lv_localized;
    self.logoLabel = [self.customNavBar style_GoChatMessage];
    [self refreshCustonNavBarFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_STATUS_BAR_HEIGHT+64)];
    [self.customNavBar setTitle:LocalString(localAddressBook)];
    [self.customNavBar setRightBtnWithImageName:@"icon_lianxiren_add02" title:nil highlightedImageName:@""];
    
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    //初始数据
    [self reloadContacts];
    //同步联系人
    [[TelegramManager shareInstance] syncMyContacts];
    self.tableView.sectionIndexColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor colorTextForA9B0BF];
    self.tableView.tableHeaderView = self.headView;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-kBottomSafeHeight);
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
    
    [UserInfo showTips:nil des:title];
    return section;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{//右侧索引
    NSMutableArray *array = [[NSMutableArray alloc] init];

    NSArray *titles = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    for (int i=0; i<self.sectionContactList.count; i++) {
        NSArray *sectionArr = self.sectionContactList[i];
        if (sectionArr.count > 0){
            [array addObject:titles[i]];
        }
    }

    return [array copy];
//    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
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
//            UserInfo *user = sender;
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

- (void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    MNAddContactVC *vc = [[MNAddContactVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
//    [MNTablePopView showTablePopViewWithType:MNTablePopViewTypeMsgAdd chooseIndexBlock:^(MNTablePopView *popView, NSInteger index, MNTablePopModel *model) {
//        if ([model.aId isEqualToString:@"AddContact"]) {
//            MNAddContactVC *vc = [[MNAddContactVC alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//        }else if ([model.aId isEqualToString:@"NewGroup"]) {
//            MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//        }else if ([model.aId isEqualToString:@"NewPrivateChat"]) {
//            MNAddGroupVC *vc = [[MNAddGroupVC alloc] init];
//            vc.chooseType = MNContactChooseType_Private_Chat;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        else if ([model.aId isEqualToString:@"Scan"]) {
//            [self toScan];
//        }
//        [popView hide];
//    }];
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
//                            MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                            v.user = user;
//                            [self.navigationController pushViewController:v animated:YES];
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
- (QTTongXunLuHeadView *)headView{
    if(!_headView){
        _headView = [[NSBundle mainBundle] loadNibNamed:@"QTTongXunLuHeadView" owner:nil options:nil].firstObject;
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 66 * 2 + 45);
        MJWeakSelf
        _headView.chooseBlock = ^(NSInteger chooseIndex) {
            //
            if (chooseIndex == 1){ // 新的朋友
                MNAddContactVC *vc = [[MNAddContactVC alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (chooseIndex == 2){ // 邀请微信好友
                [UserInfo showTips:weakSelf.view des:@"功能暂未开放".lv_localized];
            }else if (chooseIndex == 3){ // 群发助手
                MNGroupSentVC *vc = [[MNGroupSentVC alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (chooseIndex == 4){ // 群聊
                MNContactGroupVC *vc = [[MNContactGroupVC alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (chooseIndex == 5){ // 分组
                [UserInfo showTips:weakSelf.view des:@"功能暂未开放".lv_localized];
            }else if (chooseIndex == 10){ // 搜索
                MNContactSearchVC *vc = [[MNContactSearchVC alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _headView;
}


@end
