//
//  TF_CacheNumVC.m
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import "TF_CacheNumVC.h"
#import "TF_CommonSettingCell.h"
#import "TF_RequestManager.h"
#import "GC_DataSetInfo.h"
#import "TF_DiskUseCell.h"
#import "TF_MemoryUseSettingCell.h"
@interface TF_CacheNumVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/// 数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
/// 分组标题
@property (nonatomic,strong) NSArray *sectionTitles;
/// 数据设置
@property (nonatomic,strong) GC_DataSetInfo *dataSetting;
@end

@implementation TF_CacheNumVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"存储用量".lv_localized];
    
    GC_DataSetInfo *dataSetting = [GC_DataSetInfo getUserDataSetInfo];
    self.dataSetting = dataSetting;

    [self initUI];
    
    self.sectionTitles = @[@"保留缓存时间".lv_localized, @"语音通话".lv_localized];
    
}

-(UITableView *)tableView{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT - kNavBarAndStatusBarHeight) style:UITableViewStyleGrouped];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        [_tableView registerClass:[TF_DiskUseCell class] forCellReuseIdentifier:@"TF_DiskUseCell"];
        [_tableView registerClass:[TF_MemoryUseSettingCell class] forCellReuseIdentifier:@"TF_MemoryUseSettingCell"];
        [_tableView registerClass:[TF_SettingSectionHeaderV class] forHeaderFooterViewReuseIdentifier:@"TF_SettingSectionHeaderV"];
        
//        _tableView.canMove = NO;
//        _tableView.rowHeight = 60;
        _tableView.backgroundColor = [UIColor colorForF5F9FA];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        
    }
    return _tableView;
}
    
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:5];
    }
    return _dataSource;
}
    


- (void)initUI{

    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        TF_DiskUseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TF_DiskUseCell" forIndexPath:indexPath];
        
        return cell;
    } else {
        TF_MemoryUseSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TF_MemoryUseSettingCell" forIndexPath:indexPath];
        cell.model = self.dataSetting.memoryUse;
        cell.setData = self.dataSetting;
        return cell;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 120;
    } else {
        return 95;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    TF_SettingSectionHeaderV *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TF_SettingSectionHeaderV"];
    view.title = self.sectionTitles[section];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}




@end
