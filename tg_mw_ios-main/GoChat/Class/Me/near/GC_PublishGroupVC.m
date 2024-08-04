//
//  GC_PublishGroupVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/16.
//

#import "GC_PublishGroupVC.h"
#import "GC_NearCell.h"
#import "TF_RequestManager.h"
#import "LocationManager.h"
//#import "GC_NearGroupChatInfo.h"

@interface GC_PublishGroupVC ()
/// <#code#>
@property (nonatomic,strong) NSMutableArray <NearGroupChatInfo *>*groupList;
/// 当前定位信息
@property (nonatomic,assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, strong) EmptyView *emptyView;

@end

@implementation GC_PublishGroupVC

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
    [self initData];
}
- (void)initData{
    MJWeakSelf
    [TF_RequestManager searchPublicChatsWithQuery:nil resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *lt = obj;
            for(NSNumber *chatId in lt)
            {
                [TF_RequestManager getChatWithId:chatId.longValue resultBlock:^(NSDictionary *request, NSDictionary *response, ChatInfo *chat) {
                    [weakSelf dealGroup:chat];
                    
                    
                } timeout:^(NSDictionary *request) {
                    
                }];
            }
            [weakSelf showEmptyView:lt.count < 1];
        } else {
            [weakSelf showEmptyView:YES];
        }
//
        
        //刷新列表
        [weakSelf.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        
    }];
}
- (void)dealGroup:(ChatInfo *)chatInfo{
    
    __block NearGroupChatInfo *chat = [[NearGroupChatInfo alloc] init];
    chat.chatInfo = chatInfo;
    
    MJWeakSelf
    
    [TF_RequestManager requestOnlieNumberWithChannelID:[ChatInfo toServerPeerId:chatInfo._id] resultBlock:^(NSDictionary *request, NSDictionary *response, NSString *count) {
        chat.onlineNum = [count integerValue];
    } timeout:^(NSDictionary *request) {
        
    }];
    
    if(chatInfo.isSuperGroup)
    {//超级群组
        [[TelegramManager shareInstance] getSuperGroupFullInfo:chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, SuperGroupFullInfo *obj) {
            if(obj != nil && [obj isKindOfClass:[SuperGroupFullInfo class]])
            {
                chat.totalNum = obj.member_count;
                [weakSelf.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    else
    {//普通群组
        [[TelegramManager shareInstance] getBasicGroupFullInfo:chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, BasicGroupFullInfo *groupFullInfo) {
            chat.membersList = groupFullInfo.members;
            [weakSelf.tableView reloadData];
        } timeout:^(NSDictionary *request) {
        }];
    }
    
    
    NSArray *list = [[TelegramManager shareInstance] getGroups];
    
    //判断当前用户是否在群中
    for (ChatInfo *localChat in list){
        if (chatInfo._id == localChat._id) {
            chat.selfInChat = YES;
            break;
        }
    }
    
    [self.groupList addObject:chat];
    
    
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupList.count;
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
    cell.chat = self.groupList[indexPath.row];
    cell.addBtn.hidden = NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NearGroupChatInfo *model = self.groupList[indexPath.row];
    if (model.isSelfInChat) {
        [AppDelegate gotoChatView:model.chatInfo];
    }
}

- (NSMutableArray<NearGroupChatInfo *> *)groupList{
    if (!_groupList) {
        _groupList = [NSMutableArray array];


    }
    return _groupList;
}
- (EmptyView *)emptyView
{
    if(_emptyView == nil)
    {
        _emptyView = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
    }
    return _emptyView;
}


- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateChatOnlineMemberCount)://群在线人数更新
        {
            if ([inParam isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = inParam;
                NSString *chatId = dic[@"chatId"];
                __block NSString *count = dic[@"count"];
                [self.groupList enumerateObjectsUsingBlock:^(NearGroupChatInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.chatInfo._id == chatId.longLongValue) {
                        obj.onlineNum = count.integerValue;
                        *stop = YES;
                    }
                }];
            }
        }
            break;
        
            
        default:
            break;
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
