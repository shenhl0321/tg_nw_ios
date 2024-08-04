//
//  CallsSingleTableViewController.m
//  GoChat
//
//  Created by 李标 on 2021/5/22.
//

#import "CallsSingleTableViewController.h"
#import "GC_RecentCallsCell.h"

#define ALL_CALLS_PAGE_COUNT  20

@interface CallsSingleTableViewController ()

@property (nonatomic, strong) NSMutableArray *allCallsList;
@end

@implementation CallsSingleTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.sectionIndexColor = COLOR_CG1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = HEX_COLOR(@"#f2f2f2");
    //设置下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self refreshData];
   self.customNavBar.hidden = YES;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_RecentCallsCell" bundle:nil] forCellReuseIdentifier:@"GC_RecentCallsCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(0);
    }];
  
}

// 请求数据
- (void)refreshData:(int)pageNumber
{
    [[TelegramManager shareInstance] queryHistoryCall:self.type count:ALL_CALLS_PAGE_COUNT page:pageNumber resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            if(pageNumber == 1)
            {
                //clean
                [self.allCallsList removeAllObjects];
            }
            
            NSArray *list = obj;
            if ([list count]>0)
            {
                [self.allCallsList addObjectsFromArray:list];
                [self.tableView reloadData];
            }
            
            //more...
            if(list.count==ALL_CALLS_PAGE_COUNT)
            {
                [self setNeedLoadMore:YES];
            }
            else
            {
                [self setNeedLoadMore:NO];
            }
            
            [self.tableView.mj_header endRefreshing];
            [self stopLoadMore];
        }
        
    } timeout:^(NSDictionary *request) {
        [self.tableView.mj_header endRefreshing];
        [self stopLoadMore];
    }];
}

- (void)refreshData
{// 初始化数据
    [self refreshData:1];
}

- (void)startLoadingMore
{// 上拉加载更多
    [self refreshData:(int)(self.allCallsList.count/ALL_CALLS_PAGE_COUNT+1)];
}

- (void)toOnlineVideoOrVoice:(BOOL)isVideo toId:(long)toId
{// 单聊
    LocalCallInfo *call = [LocalCallInfo new];
    call.channelName = [Common generateGuid];
    call.from = [UserInfo shareInstance]._id;
    call.to = @[[NSNumber numberWithLong:toId]];
    call.chatId = toId;
    call.isVideo = isVideo;
    call.isMeetingAV = NO;
    call.callState = CallingState_Init;
    call.callTime = [NSDate new].timeIntervalSince1970;
    [[CallManager shareInstance] newCall:call fromView:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allCallsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GC_RecentCallsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_RecentCallsCell" forIndexPath:indexPath];
        
    RemoteCallInfo *model = [self.allCallsList objectAtIndex:indexPath.row];
    // 获取当前用户的id
    long currUserId = [UserInfo shareInstance]._id;
    // 判断是呼出还是呼入
    if (currUserId == model.from)
    {// 自己发起的
        // 邀请对象用户的id
        long toUserId = [[model.to objectAtIndex:0] longValue];
        // 会话被邀请者
        NSString *toName = [UserInfo userDisplayName:toUserId];
        cell.lbTitle.text = toName;
        // 状态设置
        cell.lbSubTitle.text = model.isVideo ? @"拨打视频".lv_localized: @"拨打语音".lv_localized;
    }
    else
    {// 被邀请
        // 会话发起者
        NSString *formName = [UserInfo userDisplayName:model.from];
        cell.lbTitle.text = formName;
        // 状态设置
        cell.lbSubTitle.text = model.isVideo ? @"接听视频".lv_localized: @"接听语音".lv_localized;
    }
    // icon设置
    if (model.isVideo)
    {
        cell.imgIcon.image = [UIImage imageNamed:@"call_message_video"];
    }
    else
    {
        cell.imgIcon.image = [UIImage imageNamed:@"call_message_voice"];
    }

    cell.lbTime.text = [Common getFullMessageTime:model.createAt showDetail:YES];
    if (0 == model.enterAt || 0 == model.leaveAt)
    {
        cell.lbDuration.text = @"未接听".lv_localized;
    }
    else
    {// 通话时长计算: 挂断时间-进入时间
        long durationTime = model.leaveAt - model.enterAt;
        cell.lbDuration.text = [NSString stringWithFormat:@"时长:%@".lv_localized,[Common timeFormattedForRp:(int)durationTime]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 判断通话对象:
    // 1. 被叫取model的 from
    // 2. 主叫取model的 to
    RemoteCallInfo *model = [self.allCallsList objectAtIndex:indexPath.row];
    // 获取当前用户的id
    long currUserId = [UserInfo shareInstance]._id;
    // 判断是呼出还是呼入
    if (currUserId == model.from)
    {// 自己发起的
        // 邀请对象用户的id
        long toUserId = [[model.to objectAtIndex:0] longValue];
        [self toOnlineVideoOrVoice:model.isVideo toId:toUserId];
    }
    else
    {// 被邀请
        [self toOnlineVideoOrVoice:model.isVideo toId:model.from];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - 懒加载
- (NSMutableArray *)allCallsList
{
    if(_allCallsList == nil)
    {
        _allCallsList = [NSMutableArray array];
    }
    return _allCallsList;
}

@end
