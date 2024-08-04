//
//  GC_GiveRecordVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_GiveRecordVC.h"
#import "GC_ReceiveTopCell.h"
#import "RedPacketDetailViewController.h"
#import "GC_RedRecordCell.h"

@interface GC_GiveRecordVC ()
@property (nonatomic, strong)NSMutableArray *orderList;
@property (nonatomic, assign)double totalPrice;
@property (nonatomic, assign)NSInteger total;
@end

@implementation GC_GiveRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customNavBar.hidden = YES;
    // Do any additional setup after loading the view.
    [self initUI];
}

- (void)initUI{
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_ReceiveTopCell" bundle:nil] forCellReuseIdentifier:@"GC_ReceiveTopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_RedRecordCell" bundle:nil] forCellReuseIdentifier:@"GC_RedRecordCell"];
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    //设置下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self refreshData];
}

#pragma mark - request
- (void)requestData:(int)page
{
    
    [[TelegramManager shareInstance] queryRedHistoryCall:1 count:WT_ORDER_PAGE_COUNT page:page resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        self.totalPrice = 0.;
        if(page == 1)
        {

            //clean
            [self.orderList removeAllObjects];
        }
        
        NSArray *list = obj;
        if(list.count>0)
        {
            [self.orderList addObjectsFromArray:list];
        }
        
        for (RedPacketInfo *info in self.orderList) {
            self.totalPrice = self.totalPrice + info.total_price;
        }
        
        
        [self.tableView reloadData];
        
        
        
        [self.tableView.mj_header endRefreshing];
   
    } timeout:^(NSDictionary *request) {
        [self.tableView.mj_header endRefreshing];
       
    }];
}

- (void)refreshData
{
    [self requestData:1];
}

- (void)startLoadingMore
{
    [self requestData:(int)(self.orderList.count/WT_ORDER_PAGE_COUNT+1)];
}

- (NSMutableArray *)orderList
{
    if(_orderList == nil)
    {
        _orderList = [NSMutableArray array];
    }
    return _orderList;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return self.orderList.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        GC_ReceiveTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_ReceiveTopCell"];
        cell.subTitleLab.text = @"一共发出".lv_localized;
        cell.priceLab.text = [NSString stringWithFormat:@"¥%.2f",self.totalPrice];
        cell.numLab.text = [NSString stringWithFormat:@"发出红包%ld个".lv_localized,self.orderList.count];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    GC_RedRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_RedRecordCell" forIndexPath:indexPath];
    [cell resetRpInfo:[self.orderList objectAtIndex:indexPath.row] isSendRp:YES];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 265.;
    }
    return 87.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *rpSb = [UIStoryboard storyboardWithName:@"RedPacket" bundle:nil];
    RedPacketDetailViewController *v = [rpSb instantiateViewControllerWithIdentifier:@"RedPacketDetailViewController"];
    v.rpInfo = [self.orderList objectAtIndex:indexPath.row];
    v.hidesBottomBarWhenPushed = YES;
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
