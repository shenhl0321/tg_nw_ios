//
//  GC_NotifcationSetVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_NotifcationSetVC.h"

#import "GC_MySetCell.h"
#import "GC_MySetSwitchCell.h"

#import "SettingHelper.h"

@interface GC_NotifcationSetVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSArray *values;

@property (nonatomic, strong) NotificationSoundInfo *info;

@end


@implementation GC_NotifcationSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"通知与声音".lv_localized];
    [self initUI];
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

//        _tableView.canMove = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            self.tableView.sectionHeaderTopPadding = 0;
         }
    }
    return _tableView;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[
            @{
                @"title": @"消息通知".lv_localized,
                @"sub": @[@"显示通知".lv_localized]
            },
            @{
                @"title": @"应用内通知".lv_localized,
                @"sub": @[@"应用内播放提示音".lv_localized, @"应用内震动提醒".lv_localized]
            }
        ].mutableCopy;
    }
    return  _dataArr;
}

- (NSArray *)values {
    if (!_values) {
        _values = @[@[@YES], @[@YES, @YES]];
    }
    return _values;
}


- (void)initUI{

    [self.contentView addSubview:self.tableView];
    self.tableView.rowHeight = 60;
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetSwitchCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetSwitchCell"];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [self tableFooterView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
}

- (void)dy_request {
    @weakify(self);
    [SettingHelper getNotificationSettings:^(NotificationSoundInfo * _Nonnull info) {
        @strongify(self);
        self.info = info;
        self.values = info.values;
        [self.tableView reloadData];
    }];
}

- (void)modifyValueWithTitle:(NSString *)title isOn:(BOOL)on {
    [UserInfo show];
    if ([title isEqualToString:@"显示通知".lv_localized]) {
        self.info.showNotification = on;
    } else if ([title isEqualToString:@"应用内震动提醒".lv_localized]) {
        self.info.inAppVibration = on;
    } else if ([title isEqualToString:@"应用内播放提示音".lv_localized]) {
        self.info.inAppSound = on;
    }
    [self modifyInfo:self.info];
}

- (void)modifyInfo:(NotificationSoundInfo *)info {
    [SettingHelper modifyNotificationSettings:info completion:^(BOOL success) {
        if (success) {
            [self dy_request];
        }
        [UserInfo dismiss];
    }];
}

- (void)resetAction {
    MMPopupItemHandler block = ^(NSInteger index) {
        [self modifyInfo:NotificationSoundInfo.defaultSetting];
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, nil),
                       MMItemMake(@"重置".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"重置所有通知".lv_localized detail:@"您确定要重置所有通知设置？".lv_localized items:items];
    [view show];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic  = self.dataArr[section];
    return [dic arrayValueForKey:@"sub" defaultValue:@[]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic  = self.dataArr[indexPath.section];
    GC_MySetSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetSwitchCell"];
    NSArray *titles = dic[@"sub"];
    NSString *title = titles[indexPath.row];
    cell.titleLab.text = title;
    cell.openSwitch.on = [self.values[indexPath.section][indexPath.row] boolValue];
    @weakify(self);
    cell.switchBlock = ^(BOOL isOn) {
        @strongify(self);
        [self modifyValueWithTitle:title isOn:isOn];
    };
    return cell;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 15;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor colorForF5F9FA];
    NSDictionary *dic  = self.dataArr[section];
    
    
    UIView *tempV = [UIView new];
    tempV.frame = CGRectMake(0, 40, SCREEN_WIDTH, 15);
    tempV.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:tempV];
    
    UIView *topV = [UIView new];
    topV.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [headerView addSubview:topV];
    
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(15, 0, 200, 40);
    titleLab.text = [dic stringValueForKey:@"title" defaultValue:@""];
    titleLab.font = [UIFont regularCustomFontOfSize:15];
    titleLab.textColor = [UIColor colorFor878D9A];
    [topV addSubview:titleLab];
    
    return headerView;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerV = [UIView new];
    footerV.backgroundColor = [UIColor colorForF5F9FA];
    
    UIView *tempV = [UIView new];
    tempV.frame = CGRectMake(0, 0, SCREEN_WIDTH, 15);
    tempV.backgroundColor = [UIColor whiteColor];
    [footerV addSubview:tempV];
    return footerV;
}

- (UIView *)tableFooterView {
    UIView *container = ({
        UIView *view = UIView.new;
        view.frame = CGRectMake(0, 0, kScreenWidth(), 80);
        view;
    });
    UIButton *resetButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"重设所有通知选项".lv_localized forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.xhq_content forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularCustomFontOfSize:16];
        [btn xhq_addTarget:self action:@selector(resetAction)];
        [btn xhq_cornerRadius:10];
        [btn xhq_borderColor:UIColor.xhq_content borderWidth:1];
        btn;
    });
    [container addSubview:resetButton];
    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(15, 15, 15, 15));
    }];
    return container;
}

@end
