//
//  GC_NearPeopleVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/16.
//

#import "GC_NearPeopleVC.h"
#import "GC_NearCell.h"
#import "TF_RequestManager.h"
#import "LocationManager.h"
#import "BlogInfo.h"
#import "ChatsNearby.h"
#import "GC_OtherPersonalInfoVC.h"
#import "UserTimelineVC.h"

@interface GC_NearPeopleVC ()
/// <#code#>
@property (nonatomic,strong) NSMutableArray *dataSource;
/// 当前定位信息
@property (nonatomic,assign) CLLocationCoordinate2D locationCoordinate;


@property (nonatomic, strong) EmptyView *emptyView;

@end

@implementation GC_NearPeopleVC

- (void)dealloc{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.customNavBar.hidden = YES;
    self.contentView.hidden = YES;
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)initUI{

    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_NearCell" bundle:nil] forCellReuseIdentifier:@"GC_NearCell"];
   
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    MJWeakSelf

    [[LocationManager shareInstance] startSerialLocationSuccess:^(CLLocationCoordinate2D locationCoordinate) {
        weakSelf.locationCoordinate = locationCoordinate;
        [weakSelf loadData];
    }];
   
    [self addEmptyView];
}
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
 
    }
    return _dataSource;
}
- (void)loadData{
    MJWeakSelf
    BlogLocationList *location = [[BlogLocationList alloc] init];
    location.longitude = self.locationCoordinate.longitude;
    location.latitude = self.locationCoordinate.latitude;
    location.horizontal_accuracy = 10000;
    
    // 先更新一下自己的位置
    [TF_RequestManager setLocation:location result:^(NSDictionary *request, NSDictionary *response) {
        // 请求附近的人的
        [TF_RequestManager searchChatsNearby:location result:^(NSDictionary *request, NSDictionary *response, ChatsNearby *obj) {
            NSLog(@"invoke request %@ \n response %@", request, response);
            [weakSelf.dataSource removeAllObjects];
            [weakSelf dealUserInfo:obj];
            [weakSelf.tableView reloadData];
        } timeout:^(NSDictionary *request) {
            
        }];
    } timeout:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (GC_NearCell *)extracted:(UITableView * _Nonnull)tableView {
    GC_NearCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_NearCell"];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GC_NearCell * cell = [self extracted:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInfo = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatNearby *model = self.dataSource[indexPath.row];
    if ([model.chat_id integerValue] != [UserInfo shareInstance]._id) {
        GC_OtherPersonalInfoVC *vc = [[GC_OtherPersonalInfoVC alloc] init];
        vc.userInfo = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UserTimelineVC *vc = [[UserTimelineVC alloc] initWithUserid:[model.chat_id integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)dealUserInfo:(ChatsNearby *)chatsNearby{
    NSArray<ChatNearby *> *users_nearby = chatsNearby.users_nearby;
    [self.dataSource addObjectsFromArray:users_nearby];
    MJWeakSelf
    for (ChatNearby *chat in users_nearby) {
        __block ChatNearby *blockChat = chat;
        [[TelegramManager shareInstance] getUserSimpleInfo_inline:chat.chat_id.longLongValue resultBlock:^(NSDictionary *request, NSDictionary *response) {
            UserInfo *user = [UserInfo mj_objectWithKeyValues:response];
            blockChat.user = user;
            [weakSelf.tableView reloadData];
        } timeout:nil];
    }
    [self showEmptyView:chatsNearby.users_nearby.count < 1];
}
- (void)addEmptyView{
    [self.tableView addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(SCREEN_HEIGHT - 200);
    }];
}
- (void)showEmptyView:(BOOL)show{
    self.emptyView.hidden = !show;
}

- (EmptyView *)emptyView
{
    if(_emptyView == nil)
    {
        _emptyView = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    return _emptyView;
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
