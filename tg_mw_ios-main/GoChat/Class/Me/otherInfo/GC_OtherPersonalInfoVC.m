//
//  GC_OtherPersonalInfoVC.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/6.
//

#import "GC_OtherPersonalInfoVC.h"
#import "GC_OtherPhotoCell.h"
#import "GC_OtherSignCell.h"
#import "GC_NearCell.h"
#import "UserTimelineVC.h"
#import "UserTimelineHelper.h"
#import "GC_OtherMenuCell.H"
#import "GC_SayHelloVC.h"

@interface GC_OtherPersonalInfoVC ()
@property (nonatomic, strong)NSArray<BlogInfo *> *dataArr;

@end

@implementation GC_OtherPersonalInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}
- (void)initUI{
    [self.customNavBar setTitle:@"个人信息".lv_localized];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_NearCell" bundle:nil] forCellReuseIdentifier:@"GC_NearCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_OtherPhotoCell" bundle:nil] forCellReuseIdentifier:@"GC_OtherPhotoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_OtherMenuCell" bundle:nil] forCellReuseIdentifier:@"GC_OtherMenuCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_OtherSignCell" bundle:nil] forCellReuseIdentifier:@"GC_OtherSignCell"];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
    }];
    [self reloadBlogs];
}
- (void)reloadBlogs {
    MJWeakSelf
    [UserTimelineHelper fetchUserBlogs:[self.userInfo.chat_id integerValue] offset:0 completion:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        self.dataArr = blogs;
        [weakSelf.tableView reloadData];
    }];
}

- (void)footView{
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        GC_NearCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_NearCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInfo = self.userInfo;
        return cell;
    }
    if (indexPath.row == 2) {
        GC_OtherSignCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_OtherSignCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (indexPath.row == 3) {
        GC_OtherMenuCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_OtherMenuCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.hiBtn addTarget:self action:@selector(hiAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.complaintBtn addTarget:self action:@selector(complaint) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    GC_OtherPhotoCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GC_OtherPhotoCell"];
    [cell setData:self.dataArr];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 72;
    }
    if (indexPath.row == 1) {
        return 110;
    }
    if (indexPath.row == 3) {
        return 175;
    }
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        UserTimelineVC *vc = [[UserTimelineVC alloc] initWithUserid:[self.userInfo.chat_id integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)hiAction{
    if (![self canSendMsg]) {
        [UserInfo showTips:nil des:@"加好友后才能聊天".lv_localized];
        return;
    }
    GC_SayHelloVC *vc = [[GC_SayHelloVC alloc] init];
    vc.userInfo = self.userInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)canSendMsg
{
    if(self.userInfo.user.is_contact)
    {//已经是好友的，不受任何影响
        return YES;
    }
    AppConfigInfo *info = [AppConfigInfo getAppConfigInfo];
    if(info != nil)
    {
        if(info.onlyFriendChat)
        {//加好友才能聊天
            return self.userInfo.user.is_contact;
        }
        if(info.onlyWhiteAddFriend)
        {
            return NO;
        }
    }
    return YES;
}


- (void)complaint{
    
    NSString *url = [NSString stringWithFormat:@"%@?uid=%ld&chatid=%ld", KHostEReport, [UserInfo shareInstance]._id, [self.userInfo.chat_id integerValue]];
    BaseWebViewController *v = [BaseWebViewController new];
    v.hidesBottomBarWhenPushed = YES;
    v.titleString = @"投诉".lv_localized;
    v.urlStr = url;
    v.type = WEB_LOAD_TYPE_URL;
    [self.navigationController pushViewController:v animated:YES];
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
