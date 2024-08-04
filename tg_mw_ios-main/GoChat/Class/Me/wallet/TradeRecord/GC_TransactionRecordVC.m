//
//  GC_TransactionRecordVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/13.
//

#import "GC_TransactionRecordVC.h"
#import "GC_TransactionRecordCell.h"
#import "UserinfoHelper.h"

@interface GC_TransactionRecordVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)NSMutableArray *dataArr;

@property (nonatomic, assign) int page;

@end

@implementation GC_TransactionRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}
- (void)initUI{
    [self.customNavBar setTitle:@"交易记录".lv_localized];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_TransactionRecordCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarAndStatusBarHeight);
    }];
    //设置下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [footer setTitle:@"上拉加载更多".lv_localized forState:MJRefreshStateIdle];
    [footer setTitle:@"正在刷新...".lv_localized forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据".lv_localized forState:MJRefreshStateNoMoreData];

    footer.triggerAutomaticallyRefreshPercent = 0.5;
    self.tableView.mj_footer = footer;
    [self refreshData];
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

#pragma mark - request
- (void)requestData:(int)page {
    [[TelegramManager shareInstance] queryWalletOrderListCall:WT_ORDER_PAGE_COUNT page:page resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (page == 1) {
            [self.dataArr removeAllObjects];
        }
        
        NSArray *list = obj;
        if (list.count>0) {
            for (WalletOrderInfo *order in list) {
                [self.dataArr addObject:order];
                [self loadRPInfoIfNeeded:order];
            }
            [self.tableView.mj_footer resetNoMoreData];
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
        
    } timeout:^(NSDictionary *request) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)refreshData {
    self.page = 1;
    [self requestData:self.page];
}

- (void)startLoadingMore {
    self.page ++;
    [self requestData:self.page];
}

- (void)loadMoreData {
    [self startLoadingMore];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GC_TransactionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell resetOrderInfo:self.dataArr[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 94;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)loadRPInfoIfNeeded:(WalletOrderInfo *)info {
    if (!info.isRPtype) {
        return;
    }
    /// 5.创建红包 6.领取红包 7.红包退回
    NSInteger index = [self.dataArr indexOfObject:info];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [TelegramManager.shareInstance queryRp:info.related resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if (![obj isKindOfClass:RedPacketInfo.class]) {
            return;
        }
        RedPacketInfo *rp = (RedPacketInfo *)obj;
        if (info.type == 6) {
            [UserinfoHelper getUsernames:@[@(rp.from)] completion:^(NSArray * _Nonnull names) {
                if (names.count > 0) {
                    info.rpContent = [NSString stringWithFormat:@"来自%@".lv_localized, names.firstObject];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                          withRowAnimation:UITableViewRowAnimationNone];
                }
            }];
            return;
        }
        //1.单聊红包 2.拼手气红包 3.普通红包
        if (rp.type != 1) {
            info.rpContent = @"发出群红包".lv_localized;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        ChatInfo *chat = [TelegramManager.shareInstance getChatInfo:rp.chatId];
        if (!chat) {
            return;
        }
        [UserinfoHelper getUsernames:@[@(chat.userId)] completion:^(NSArray * _Nonnull names) {
            if (names.count > 0) {
                info.rpContent = [NSString stringWithFormat:@"发给%@".lv_localized, names.firstObject];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    } timeout:^(NSDictionary *request) {
        
    }];
}

@end
