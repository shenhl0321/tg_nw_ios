//
//  MNContactAddressBookVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/1.
//

#import "MNContactAddressBookVC.h"
#import <Contacts/Contacts.h>
#import "AddressBookTool.h"
#import "MNUnauthorizedAddressView.h"
#import "MNAuthorizedAddressView.h"
#import "AddressItemCell.h"
#import "AddressItemModel.h"
#import "MNContactFriendHeader.h"
#import "MNContactDetailVC.h"
#import "QTGroupPersonInfoVC.h"

@interface MNContactAddressBookVC ()
<UITableViewDelegate, UITableViewDataSource,AddressItemCellDelegate>
//检测是否授权
@property (nonatomic, strong) MNUnauthorizedAddressView *unauthAddressView;
//前往授权
@property (nonatomic, strong) MNAuthorizedAddressView *authAddressView;

@property (nonatomic, strong) NSMutableArray *phoneArray;
//通讯录授权状态
@property (nonatomic, assign) CNAuthorizationStatus addressPermiss;
//字典接口使用
@property (nonatomic, strong) NSMutableArray *contacts;

@property (nonatomic, strong) AddressItemModel *addressModel;
@end

@implementation MNContactAddressBookVC

- (NSMutableArray *)phoneArray{
    if (!_phoneArray) {
        _phoneArray = [NSMutableArray array];
    }
    return _phoneArray;
}

- (void)dealloc
{
    NSLog(@"dealloc MNContactAddressBookVC");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    self.addressPermiss = [AddressBookTool requestAddressBookPermissionsStatus];
    
    if (self.addressPermiss == CNAuthorizationStatusAuthorized) {//已经授权
        [self hasPermiss];
    } else if (self.addressPermiss == CNAuthorizationStatusRestricted || self.addressPermiss == CNAuthorizationStatusDenied) {//拒绝
        self.unauthAddressView.hidden = YES;
        self.authAddressView.hidden = NO;
        self.tableView.hidden = YES;
        //    拒绝过授权重新去授权
        self.authAddressView.goToAuthorizationBlock = ^(UIButton * _Nonnull sender) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES}  completionHandler:^(BOOL success) {
                }];
            }
        };
    }
    else {
        self.unauthAddressView.hidden = NO;
        self.authAddressView.hidden = YES;
        self.tableView.hidden = YES;
        //    未提示过授权
        self.unauthAddressView.authorizedAddressBlock = ^(UIButton * _Nonnull sender) {
            [weakSelf requestContactAuthorAfterSystemVersion9];
        };
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"通讯录".lv_localized];
    [self.contentView addSubview:self.unauthAddressView];
    [self.contentView addSubview:self.authAddressView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.unauthAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.authAddressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

//已经授权
- (void)hasPermiss{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.unauthAddressView.hidden = YES;
        self.authAddressView.hidden = YES;
        self.tableView.hidden = NO;
        [self openContact];
    });
}

//请求通讯录权限
#pragma mark 请求通讯录权限
- (void)requestContactAuthorAfterSystemVersion9{
    [AddressBookTool requestAddressBookPermissionsAuthorized:^(BOOL granted) {
        if (granted) {
            [self hasPermiss];
        } else {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goToAuthorization];
                });
            } else {
                [self goToAuthorization];
            }
        }
            
    }];
}

- (void)goToAuthorization{
    self.unauthAddressView.hidden = YES;
    self.authAddressView.hidden = NO;
    self.tableView.hidden = YES;
    //    拒绝过授权重新去授权
    self.authAddressView.goToAuthorizationBlock = ^(UIButton * _Nonnull sender) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES}  completionHandler:^(BOOL success) {
            }];
        }
    };
}

//有通讯录权限-- 进行下一步操作
- (void)openContact{
    self.tableView.hidden = NO;
    self.unauthAddressView.hidden = YES;
    self.contacts = [AddressBookTool requestAddressBookList];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *mark_isSecond = @"mark_isSecond";
    bool isSed = [defs boolForKey:mark_isSecond];
    if (isSed) {//非首次  增量API
        [[TelegramManager shareInstance] changeImportedContactsWithArray:self.contacts resultBlock:^(NSDictionary *request, NSDictionary *response) {
            NSArray *user_ids = [response objectForKey:@"user_ids"];
            [self handlerContactsWithArray:user_ids];
        } timeout:^(NSDictionary *request) {
            
        }];
    }else{//首次
        [[TelegramManager shareInstance] importContactsWithArray:self.contacts resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [defs setBool:YES forKey:mark_isSecond];
            NSArray *user_ids = [response objectForKey:@"user_ids"];
            [self handlerContactsWithArray:user_ids];
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}

//
- (void)handlerContactsWithArray:(NSArray *)user_ids{
    NSMutableArray *userarr = [NSMutableArray array];
    for (int i=0; i<user_ids.count; i++) {
        long id_str = [[user_ids objectAtIndex:i] longValue];
        NSMutableDictionary *dict = [self.contacts[i] mutableCopy];

        if (id_str > 1) {//不为  0
            UserInfo *user = [[TelegramManager shareInstance] contactInfo:id_str];
            if (user._id != [UserInfo shareInstance]._id) {
                dict[@"is_contact"] = @(user.is_contact);
                [[TelegramManager shareInstance] requestOrgContactInfo:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                    NSString * name  = @"";
                    if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]]){
                        OrgUserInfo * orgUserInfo = obj;
                        name = orgUserInfo.displayName;
                    }
                    [self loadMyNewUserInfo:user myList:userarr myName:name withUseIds:[user_ids objectAtIndex:i] withMyDict:dict];
                } timeout:^(NSDictionary *request) {
                    [self loadMyNewUserInfo:user myList:userarr myName:@"" withUseIds:[user_ids objectAtIndex:i] withMyDict:dict];
                }];
            }
        }
    }

}
-(void)loadMyNewUserInfo:(UserInfo *)user myList:(NSMutableArray *)userarr myName:(NSString *)name withUseIds:(NSString  *)user_id withMyDict:(NSMutableDictionary *)dict{
    NSString *nickname = [name isEqualToString:@""] ? user.displayName : name;
    for (NSDictionary *list in userarr) {
        if ([list[@"user_id"] isEqual:user_id] &&
            [list[@"nickname"] isEqualToString:nickname]) {
            return;
        }
    }
    dict[@"nickname"] = nickname;
    dict[@"user_id"] = user_id;
    if (user.profile_photo != nil) {
        [dict setObject:[user.profile_photo mj_keyValues] forKey:@"profile_photo"];
    }
    
    if (![user.displayName isEqualToString:name]) {
        [self doRemake:dict withUser:user];
    }
    if (!user.is_contact) {
        [self doAddContactRequest:user];
    }
    [userarr addObject:[dict copy]];
    
    if (userarr.count != 0) {
        NSArray *modelArray = [AddressItemModel mj_objectArrayWithKeyValuesArray:userarr];
        self.phoneArray = [AddressBookTool sortObjectsAccordingToInitialWith:modelArray];
    } else {
        self.phoneArray = [NSMutableArray array];
    }
    [self.tableView reloadData];
}

#pragma mark AddressItemCellDelegate
- (void)addContact_click:(AddressItemCell *)cell {
    self.addressModel = cell.model;
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:[self.addressModel.user_id longLongValue]];
    [self addContact_alter_click:user];
}

- (void)addContact_alter_click:(UserInfo *)user
{
//    MMPopupItemHandler block = ^(NSInteger index) {
//        if(index == 1)
//        {
//            [self performSelector:@selector(doAddContactRequest:) withObject:user afterDelay:0.4];
//        }
//    };
//    NSArray *items = @[MMItemMake(@"取消", MMItemTypeNormal, block),
//                       MMItemMake(@"确定", MMItemTypeHighlight, block)];
//    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示" detail:[NSString stringWithFormat:@"确定添加[%@]为好友吗？",user.displayName] items:items];
//    [view show];
}
-(void)doRemake:(NSDictionary *)dict withUser:(UserInfo *)user{

    [[TelegramManager shareInstance]  setContactNickName:user nickName:dict[@"last_name"] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            if (!self.noPop) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized];
    }];
}
- (void)doAddContactRequest:(UserInfo *)user
{
//    [UserInfo show];
#pragma mark - 2、手机通讯录联系人列表，每点一下，好友都会收到“对方加你好友”消息，点10下出现10条（bug）如果是好友了就不用再添加了

#pragma mark - end
    [[TelegramManager shareInstance] addContact:user resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
//            [UserInfo showTips:nil des:@"添加好友失败，请稍后重试" errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
//            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已被添加到您的好友列表中", user.displayName]];
            
#pragma mark - 2、手机通讯录联系人列表，每点一下，好友都会收到“对方加你好友”消息，点10下出现10条（bug）
//            [[TelegramManager shareInstance] sendBeFriendMessage:user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
//            } timeout:^(NSDictionary *request) {
//            }];
#pragma mark - end
            
            self.addressModel.is_contact = YES;
            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
//        [UserInfo dismiss];
//        [UserInfo showTips:nil des:@"添加好友失败，请稍后重试"];
    }];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.phoneArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section < self.phoneArray.count)
    {
        NSArray *sectionArr = self.phoneArray[section];
        return sectionArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"AddressItemCellID";
    AddressItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[AddressItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.delegate = self;
    NSArray *sectionArr = self.phoneArray[indexPath.section];
    cell.model = [sectionArr objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSArray *sectionArr = self.phoneArray[indexPath.section];
    AddressItemModel *address = [sectionArr objectAtIndex:indexPath.row];
    
//    MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//    v.user = [[TelegramManager shareInstance] contactInfo:[address.user_id longLongValue]];
//    [self.navigationController pushViewController:v animated:YES];
    
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:[address.user_id longLongValue]];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section < self.phoneArray.count)
    {
        NSArray *sectionArr = self.phoneArray[section];
        if (sectionArr.count == 0)
        {
            return nil;
        }
        MNContactFriendHeader *headerView = [[MNContactFriendHeader alloc] init];
//        UIView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AzSectionHeaderView" owner:nil options:nil] objectAtIndex:0];
//        headerView.backgroundColor = [UIColor clearColor];
//        UILabel *titleLabel = (UILabel *)[headerView viewWithTag:101];
        NSArray *sectionTitlesArr = [[UILocalizedIndexedCollation currentCollation] sectionTitles];
        if (section < sectionTitlesArr.count)
        {
//            titleLabel.text = sectionTitlesArr[section];
            headerView.aLabel.text = sectionTitlesArr[section];
        }
        else
        {
//            titleLabel.text = nil;
            headerView.aLabel.text = nil;
        }
        return headerView;
    }
    return nil;
}

//约束section header高度 当section下没有联系人时置为0
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < self.phoneArray.count)
    {
        NSArray *sectionArr = self.phoneArray[section];
        if (sectionArr.count == 0)
        {
            return 0.01;
        }
    }
    return 50;
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


- (MNUnauthorizedAddressView *)unauthAddressView {
    if (!_unauthAddressView) {
        int padding = 0;
        if (self.noPop) {
            padding = kNavBarAndStatusBarHeight;
        }
        _unauthAddressView = [[MNUnauthorizedAddressView alloc] initWithFrame:CGRectMake(0, 0+padding, SCREEN_WIDTH, SCREEN_HEIGHT-padding)];
        _unauthAddressView.backgroundColor = UIColor.whiteColor;
        _unauthAddressView.hidden = YES;
    }
    return _unauthAddressView;
}
- (MNAuthorizedAddressView *)authAddressView {
    if (!_authAddressView) {
        int padding = 0;
        if (self.noPop) {
            padding = kNavBarAndStatusBarHeight;
        }
        _authAddressView = [[MNAuthorizedAddressView alloc] initWithFrame:CGRectMake(0, 0+padding, SCREEN_WIDTH, SCREEN_HEIGHT-padding)];
        _authAddressView.backgroundColor = UIColor.whiteColor;
        _authAddressView.hidden = YES;
    }
    return _authAddressView;
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
