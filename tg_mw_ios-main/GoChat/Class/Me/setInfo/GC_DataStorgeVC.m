//
//  GC_DataStorgeVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/14.
//

#import "GC_DataStorgeVC.h"
#import "TF_CommonSettingCell.h"
#import "TF_RequestManager.h"
#import "GC_DataSetInfo.h"
#import "TF_MediaDataSetVC.h"
#import "TF_DiskCache.h"
#import "TF_CacheNumVC.h"
#import "XFTextTranslateRequest.h"
#import "SliceIdGenerator.h"
@interface GC_DataStorgeVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
/// 数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
/// 分组标题
@property (nonatomic,strong) NSArray *sectionTitles;
/// 数据设置
@property (nonatomic,strong) GC_DataSetInfo *dataSetting;
@end

@implementation GC_DataStorgeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"数据与存储".lv_localized];
    
    GC_DataSetInfo *dataSetting = [GC_DataSetInfo getUserDataSetInfo];
    self.dataSetting = dataSetting;
    
    
    [self initData];
    
    [self initUI];
    
    self.sectionTitles = @[@"存储和网络用量".lv_localized, @"自动下载媒体软件".lv_localized, @"语言通话".lv_localized, @"其他".lv_localized];
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
    
    NSArray *datas = @[
                        @[@{@"title" : @"存储用量".lv_localized, @"identityName" : @"TF_CacheNumVC"},
                          @{@"title" : @"网络用量".lv_localized, @"target" : @""},
                        ],
                        @[@{@"title" : @"使用移动数据时".lv_localized, @"identityName" : @"MobilMedia"},
                          @{@"title" : @"使用WI-FI时".lv_localized, @"identityName" : @"WIFIMedia"},
                        ],
                        @[@{@"title" : @"使用更少的流量".lv_localized, @"target" : @""}],
                        @[@{@"title" : @"自动保存图片".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(self.dataSetting.autoSaveImg),},
                          @{@"title" : @"保存已编辑的图片".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(self.dataSetting.saveEditedImg),},
                          @{@"title" : @"自动播放GIF".lv_localized, @"target" : @"",@"type" : @"2", @"switchOn" : @(self.dataSetting.autoPlayGif),},
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
        if ([model.title isEqualToString:@"自动保存图片".lv_localized]) {
            weakSelf.dataSetting.autoSaveImg = !weakSelf.dataSetting.autoSaveImg;
        } else if ([model.title isEqualToString:@"保存已编辑的图片".lv_localized]){
            weakSelf.dataSetting.saveEditedImg = !weakSelf.dataSetting.saveEditedImg;
        } else if ([model.title isEqualToString:@"自动播放GIF".lv_localized]){
            weakSelf.dataSetting.autoPlayGif = !weakSelf.dataSetting.autoPlayGif;
        }
        [GC_DataSetInfo saveUserDataSetInfo:weakSelf.dataSetting];
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    TF_SettingSectionHeaderV *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TF_SettingSectionHeaderV"];
    view.title = self.sectionTitles[section];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataSource[indexPath.section];
    TF_settingModel *model = arr[indexPath.row];
    NSString *identityName = model.identityName;
    
    if ([identityName isEqualToString:@"MobilMedia"]) {
        TF_MediaDataSetVC *vc = [[TF_MediaDataSetVC alloc] init];
        vc.netType = 0;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([identityName isEqualToString:@"WIFIMedia"]) {
        TF_MediaDataSetVC *vc = [[TF_MediaDataSetVC alloc] init];
        vc.netType = 1;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([identityName isEqualToString:@"TF_CacheNumVC"]) {
        TF_CacheNumVC *vc = [[TF_CacheNumVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    
    
}




@end
