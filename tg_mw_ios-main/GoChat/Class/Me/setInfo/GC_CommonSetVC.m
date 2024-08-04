//
//  GC_CommonSetVC.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_CommonSetVC.h"
#import "MNChatBgTableViewController.h"
#import "MNGroupSentVC.h"

#import "QTTongYongCell.h"
#import "GC_MySetSwitchCell.h"

@interface GC_CommonSetVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *timeArr;

@end


@implementation GC_CommonSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"通用".lv_localized];
    self.customNavBar.backgroundColor = HEXCOLOR(0xF5F9FA);
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
        _dataArr = @[@"聊天背景".lv_localized, @"群发助手".lv_localized].mutableCopy;
    }
    return  _dataArr;
}

- (void)initUI{

    [self.contentView addSubview:self.tableView];
    self.tableView.rowHeight = 70;
    [self.tableView registerNib:[UINib nibWithNibName:@"QTTongYongCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"GC_MySetSwitchCell" bundle:nil] forCellReuseIdentifier:@"GC_MySetSwitchCell"];
    
    self.tableView.backgroundColor = [UIColor colorForF5F9FA];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = self.dataArr[indexPath.row];
    if ([title isEqualToString:@"回车键发送消息".lv_localized]) {
        GC_MySetSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GC_MySetSwitchCell"];
        cell.titleLab.text = title;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    QTTongYongCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.titleLab.text = title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.dataArr[indexPath.row];
    if ([title isEqualToString:@"聊天背景".lv_localized]) {
        MNChatBgTableViewController *vc = [[MNChatBgTableViewController alloc] init];
        vc.currentChatId = CHAT_GLOBAL_ID;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([title isEqualToString:@"群发助手".lv_localized]) {
        MNGroupSentVC *vc = [[MNGroupSentVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
