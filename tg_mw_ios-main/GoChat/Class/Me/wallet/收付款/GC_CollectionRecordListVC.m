//
//  GC_CollectionRecordListVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/10.
//

#import "GC_CollectionRecordListVC.h"
#import "GC_CollectionRecordCell.h"

@interface GC_CollectionRecordListVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *timeArr;

@end

@implementation GC_CollectionRecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"收款记录".lv_localized];
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - APP_NAV_BAR_HEIGHT-APP_STATUS_BAR_HEIGHT - kBottom34()) style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//        _tableView.canMove = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (@available(iOS 15.0, *)) {

            self.tableView.sectionHeaderTopPadding = 0;


         }

        
    }
    return _tableView;
}
- (NSMutableArray *)timeArr{
    if (!_timeArr) {
        _timeArr = @[@"2021年12月".lv_localized,@"2021年11月".lv_localized,@"2021月10月".lv_localized].mutableCopy;
    }
    return  _timeArr;
}

- (void)createHeaderRefresh{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(initDataWithCache:)];
}

- (void)initUI{

    [self.contentView addSubview:self.tableView];
    self.tableView.rowHeight = 83;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_CollectionRecordCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.timeArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GC_CollectionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.lineLab.hidden =  indexPath.row == 2 ? YES : NO;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor colorForF5F9FA];
    
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(15, 0, 200, 45);
    titleLab.text = self.timeArr[section];
    titleLab.font = [UIFont regularCustomFontOfSize:15];
    titleLab.textColor = [UIColor colorFor878D9A];
    [headerView addSubview:titleLab];
    return headerView;
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
