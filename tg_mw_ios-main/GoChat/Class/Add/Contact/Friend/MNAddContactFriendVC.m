//
//  MNAddContactFriendVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNAddContactFriendVC.h"
#import "ContactSearchBar.h"
#import "SearchPersonCell.h"
#import "MNContactAddressBookVC.h"
#import "ChatQrScanViewController.h"
#import "MNContactAddNormalCell.h"
#import "MNContactDetailVC.h"
#import "MNScanVC.h"
#import "GC_MyScanVC.h"
#import "QTGroupPersonInfoVC.h"
#import "QTAddPersonVC.h"

@interface MNAddContactFriendVC ()
<MNScanVCDelegate>
@property (nonatomic, strong) ContactSearchBar *searchBar;
@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UIImageView * qrImageV;
@property (nonatomic, strong) UIButton *clickBtn;
@property (nonatomic, strong) NSMutableArray * personArr;
@property (nonatomic, strong) NSArray * normalArr;
@property (nonatomic) int searchPublicContactsTaskId;
@end

@implementation MNAddContactFriendVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self doSearch:self.searchBar.searchTf.text];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.personArr = @[].mutableCopy;
    self.normalArr = @[@{@"icon":@"icon_saoyisao",@"name":@"扫一扫加好友".lv_localized},@{@"icon":@"icon_weixin",@"name":@"添加手机联系人".lv_localized}];
    [self initUI];
    
}

- (void)gotoPersonCard{
    NSLog(@"");
    if([UserInfo shareInstance].username){
        UIPasteboard.generalPasteboard.string = [UserInfo shareInstance].username;
        [UserInfo showTips:self.view des:@"坤坤TG号复制成功"];
    }else{
        [UserInfo showTips:self.view des:@"坤坤TG号复制失败"];
    }
//    GC_MyScanVC *vc = [[GC_MyScanVC alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)initUI{
    [self.contentView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(2);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(0);
    }];
    [self.searchBar styleNoCancel];
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    
    if (config.can_see_qr_code) {
        self.nameL = [[UILabel alloc] init];
        self.nameL.textColor = HEXCOLOR(0x333333);
        self.nameL.font = fontRegular(15);
        self.nameL.text = [NSString stringWithFormat:@"我的坤坤TG号：%@".lv_localized,[UserInfo shareInstance].username];
        [self.contentView addSubview:self.nameL];
        
        
        self.qrImageV = [[UIImageView alloc] init];
        self.qrImageV.image = [UIImage imageNamed:@"ic_copy_id"];
        [self.contentView addSubview:self.qrImageV];
        
        [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
            make.centerX.equalTo(self.contentView).with.offset(-12);
            make.height.equalTo(@50);
        }];
        [self.qrImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameL.mas_centerY);
            make.left.equalTo(self.nameL.mas_right).offset(10);
            make.width.height.equalTo(@20);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.searchBar.mas_bottom);
            make.bottom.equalTo(self.nameL.mas_top);
        }];
        [self.contentView addSubview:self.clickBtn];
        [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameL.mas_left);
            make.right.equalTo(self.qrImageV.mas_right);
            make.centerY.equalTo(self.nameL.mas_centerY);
            make.height.mas_equalTo(30);
        }];
    } else {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom).offset(15);
            make.left.right.bottom.mas_equalTo(0);
//            make.edges.mas_equalTo(UIEdgeInsetsMake(135, 0, 0, 0));
        }];
    }
    
    
}
-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.searchTf.placeholder = @"请输入手机号或用户名".lv_localized;
        _searchBar.searchTf.font = [UIFont systemFontOfSize:14];
        _searchBar.cornerRadius = 21;
    }
    return _searchBar;
}
-(UIButton *)clickBtn{
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickBtn addTarget:self action:@selector(gotoPersonCard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickBtn;
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
    [self doSearch:textField.text];
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.personArr.count == 0) {
        return self.normalArr.count;
    }
    return self.personArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.personArr.count == 0) {
        
        static NSString *cellId = @"MNContactAddNormalCell";
        MNContactAddNormalCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[MNContactAddNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
       
        NSDictionary * dic = self.normalArr[indexPath.row];
        [cell fillDataWithDic:dic];
        return cell;
    }else{
        static NSString *cellId = @"SearchPersonCell";
        SearchPersonCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[SearchPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        [cell resetUserInfo:self.personArr[indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.personArr.count>0) {
        UserInfo *user = self.personArr[indexPath.row];
//        MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//        v.user = user;
//        v.isAddFriend = YES;
//        [self.navigationController pushViewController:v animated:YES];
        
        if (user.is_contact){
            QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
            vc.user = user;
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
            vc.user = user;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }else{
        if (indexPath.row==0) {
            [self toScan];
        }else{
            MNContactAddressBookVC * addressVC = [[MNContactAddressBookVC alloc] init];
            addressVC.noPop = YES;
            [self.navigationController showViewController:addressVC sender:nil];
        }
    }

}

#pragma mark - UITextFieldDelegate

- (void)doSearch:(NSString *)keyword
{
    if(self.searchPublicContactsTaskId > 0)
    {//结束之前的请求任务
        [[TelegramManager shareInstance] cancelTask:self.searchPublicContactsTaskId];
    }



    if(keyword == nil || keyword.length <= 0)
    {
        [self.personArr removeAllObjects];
        [self.tableView reloadData];
        return;
    }

//    //搜索公开联系人、公开讨论组、公开频道
//    if(keyword.length>=5)
//    {
        
//    }
    [self.personArr removeAllObjects];
    if ([NSString xhq_phoneFormatCheck:keyword]) {
        keyword = [@"86" stringByAppendingString:keyword];
    }
    [self searchChatsList:keyword];
    //刷新列表
//    [self.tableView reloadData];
}

-(void)searchChatsList:(NSString *)keywords{
    __weak typeof(self) weak_self = self;
    [[TelegramManager shareInstance] searchChatsList:keywords task:^(int taskId) {
        self.searchPublicContactsTaskId = taskId;
        } resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if (obj != nil && [obj isKindOfClass:[NSArray class]]) {
                NSArray *lt = obj;
                if (lt.count>0) {
                    for (NSNumber *chatId in lt) {
                        UserInfo *user = [[TelegramManager shareInstance] contactInfo:chatId.longValue];
                        if (user && ![weak_self.personArr containsObject:user]) {
                            [weak_self.personArr addObject:user];
                        }
                    }
                }
            }
            [weak_self.tableView reloadData];
            [self searchPublic:keywords];
        } timeout:^(NSDictionary *request) {
            [self searchPublic:keywords];
        }];
}


/// 2022年02月07日16:22:19 不用了，只用上面一个搜索接口
-(void)searchPublic:(NSString *)keywords{
    __weak typeof(self) weak_self = self;

    [[TelegramManager shareInstance] searchPublicChatsList:keywords task:^(int taskId) {
        self.searchPublicContactsTaskId = taskId;
    } resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (obj != nil && [obj isKindOfClass:[NSArray class]]) {
            NSArray *lt = obj;
            if (lt.count>0) {
                for (NSNumber *chatId in lt) {
                    UserInfo *user = [[TelegramManager shareInstance] contactInfo:chatId.longValue];
                    if (user && ![weak_self.personArr containsObject:user]) {
                        [weak_self.personArr addObject:user];
                    }
                }
                [self.tableView reloadData];
            }
        }
    } timeout:^(NSDictionary *request) {
    }];
}

//扫一扫
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
//        ChatQrScanViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatQrScanViewController"];
//        v.hidesBottomBarWhenPushed = YES;
        v.delegate = self;
        [self.navigationController pushViewController:v animated:YES];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}

- (void)showNeedCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - ChatQrScanViewControllerDelegate
- (void)scanVC:(MNScanVC *)scanvc scanResult:(NSString *)result{
    NSLog(@"查找崩溃 - 02");
    [self ChatQrScanViewController_Result:result];
}
- (void)ChatQrScanViewController_Result:(NSString *)result
{
    if(!IsStrEmpty(result))
    {
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
                        UIViewController *v = [[UIStoryboard storyboardWithName:@"Me" bundle:nil] instantiateViewControllerWithIdentifier:@"MyProfileViewController"];
                        v.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:v animated:YES];
                    }
                    else
                    {
//                        MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                        v.user = user;
//                        v.isAddFriend = YES;
//                        [self.navigationController pushViewController:v animated:YES];
                        
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
    else
    {
        [UserInfo showTips:nil des:@"无效二维码".lv_localized];
    }
}

@end
