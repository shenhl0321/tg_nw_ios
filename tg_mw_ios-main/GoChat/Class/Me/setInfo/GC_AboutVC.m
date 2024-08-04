//
//  GC_AboutVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_AboutVC.h"

#import "GC_MySetCell.h"
#import "GC_MySetButtonCell.h"

@interface GC_AboutVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *timeArr;

@end


@implementation GC_AboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"关于我们".lv_localized];
    [self initUI];
    // Do any additional setup after loading the view from its nib.
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - kNavBarAndStatusBarHeight) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//        _tableView.canMove = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        if (@available(iOS 15.0, *)) {
            self.tableView.sectionHeaderTopPadding = 0;
         }

        
    }
    return _tableView;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[@"官方网站".lv_localized, @"功能介绍".lv_localized, @"我有疑问".lv_localized,
                     @"常见问题".lv_localized, @"意见反馈".lv_localized, @"去评分".lv_localized].mutableCopy;
        _dataArr = @[@"官方网站".lv_localized, @"隐私政策".lv_localized, @"用户协议".lv_localized, @"我要投诉".lv_localized].mutableCopy;
    }
    return  _dataArr;
}

- (void)createHeaderRefresh{
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(initDataWithCache:)];
}

- (void)initUI{

    [self.contentView addSubview:self.tableView];
    self.tableView.rowHeight = 60;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetButtonCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetButtonCell"];
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
//    if (indexPath.row == self.dataArr.count - 1) {
//        GC_MySetButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetButtonCell"];
//        cell.titleLab.text = self.dataArr[indexPath.row];
//        return cell;
//    }
    
    
    GC_MySetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLab.text = self.dataArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BaseWebViewController *web = [[BaseWebViewController alloc] init];
    NSString *title = self.dataArr[indexPath.row];
    web.titleString = title;
    if ([title isEqualToString:@"官方网站".lv_localized]) {
        web.urlStr = KHostAddress;
    } else if ([title isEqualToString:@"隐私政策".lv_localized]) {
        web.urlStr = KHostPrivacyAddress;
    } else if ([title isEqualToString:@"用户协议".lv_localized]) {
        web.urlStr = KHostUserAgreementAddress;
    } else if ([title isEqualToString:@"我要投诉".lv_localized]) {
        web.urlStr = KHostEReport;
    }
    web.type = WEB_LOAD_TYPE_URL;
    [self.navigationController pushViewController:web animated:YES];
}


@end
