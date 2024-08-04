//
//  TF_MediaDataSetVC.m
//  GoChat
//
//  Created by apple on 2022/2/15.
//

#import "TF_MediaDataSetVC.h"
#import "TF_CommonSettingCell.h"
#import "TF_RequestManager.h"
#import "GC_DataSetInfo.h"
@interface TF_MediaDataSetVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/// 数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
/// 分组标题
@property (nonatomic,strong) NSArray *sectionTitles;
/// 数据设置
@property (nonatomic,strong) GC_DataSetInfo *dataSetting;
@end

@implementation TF_MediaDataSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.netType == 1) {
        [self.customNavBar setTitle:@"使用WIFI时".lv_localized];
    } else {
        [self.customNavBar setTitle:@"使用移动数据时".lv_localized];
    }
    
    
    GC_DataSetInfo *dataSetting = [GC_DataSetInfo getUserDataSetInfo];
    self.dataSetting = dataSetting;

    
    [self initData];
    
    [self initUI];
    
    self.sectionTitles = @[@"媒体类型".lv_localized];
    
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

        [_tableView registerClass:[TF_CommonSettingCell class] forCellReuseIdentifier:@"TF_CommonSettingCell"];
        [_tableView registerClass:[TF_SettingSectionHeaderV class] forHeaderFooterViewReuseIdentifier:@"TF_SettingSectionHeaderV"];
        
//        _tableView.canMove = NO;
        _tableView.rowHeight = 60;
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
    
- (void)initData{
    GC_DataSetMedia *mediaSetting;
    if (self.netType == 1) {
        mediaSetting = self.dataSetting.wifiMediaSet;
    } else {
        mediaSetting = self.dataSetting.mobileMediaSet;
    }
    NSArray *datas = @[
                        @[@{@"title" : @"自动下载媒体".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(mediaSetting.autoDownload),},
                        ],
                        @[@{@"title" : @"图片".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(mediaSetting.image),},
                          @{@"title" : @"视频".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(mediaSetting.video),},
                          @{@"title" : @"文件".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(mediaSetting.file),},
                        ],
                        ];
    
    [datas enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *mut = [NSMutableArray array];
        [arr enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
            TF_settingModel *model = [[TF_settingModel alloc] init];
            model.title = dic[@"title"];
            model.targetVC = dic[@"target"];
            model.tipValue = dic[@"value"];
            model.switchOn = [dic[@"switchOn"] boolValue];
            model.identityName = dic[@"identityName"];
            NSString *type = dic[@"type"];
            NSString *vcModelN = dic[@"vcModel"];
            if (type.intValue == 2) {
                model.tipType = TF_settingTipTypeSwith;
            } else {
                model.tipType = TF_settingTipTypeArrow;
            }
            if (!IsStrEmpty(vcModelN)) {
                [self setValue:model forKey:vcModelN];
            }
            [mut addObject:model];
        }];
        [self.dataSource addObject:mut];
    }];
}

- (void)initUI{

    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    [self.tableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.dataSource[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TF_CommonSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TF_CommonSettingCell" forIndexPath:indexPath];
    NSArray *arr = self.dataSource[indexPath.section];
    cell.model = arr[indexPath.row];
    MJWeakSelf
    cell.controlCall = ^(TF_settingModel * _Nonnull model) {
        
        GC_DataSetMedia *mediaSetting;
        if (weakSelf.netType == 1) {
            mediaSetting = weakSelf.dataSetting.wifiMediaSet;
        } else {
            mediaSetting = weakSelf.dataSetting.mobileMediaSet;
        }
        
        if ([model.title isEqualToString:@"自动下载媒体".lv_localized]) {
            mediaSetting.autoDownload = !mediaSetting.autoDownload;
        } else if ([model.title isEqualToString:@"图片".lv_localized]){
            mediaSetting.image = !mediaSetting.image;
        } else if ([model.title isEqualToString:@"视频".lv_localized]){
            mediaSetting.video = !mediaSetting.video;
        } else if ([model.title isEqualToString:@"文件".lv_localized]){
            mediaSetting.file = !mediaSetting.file;
        }
        [GC_DataSetInfo saveUserDataSetInfo:weakSelf.dataSetting];
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return 0.01;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (0 == section) {
        return nil;
    }
    TF_SettingSectionHeaderV *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TF_SettingSectionHeaderV"];
    view.title = self.sectionTitles[section - 1];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}




@end
