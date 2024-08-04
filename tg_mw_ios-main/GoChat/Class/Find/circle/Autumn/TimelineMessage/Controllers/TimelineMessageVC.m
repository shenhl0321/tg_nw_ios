//
//  TimelineMessageVC.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineMessageVC.h"
#import "TimelineInfoVC.h"

#import "TimelineMessageHelper.h"

#import "TimelineMessageCell.h"

@interface TimelineMessageVC ()
@property (nonatomic, strong)UIButton *saveBtn;
@end

@implementation TimelineMessageVC

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"评论消息".lv_localized];
    self.emptyTitle = @"暂无最新消息".lv_localized;
    [self.dataArray addObject:self.sectionArray0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.rightBarButtonItem.tintColor = UIColor.xhq_base;
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveBtn setTitle:@"清空".lv_localized forState:UIControlStateNormal];
        [_saveBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:17];
        [_saveBtn addTarget:self action:@selector(clearMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}


- (void)dy_initUI {
    [super dy_initUI];
    [self.customNavBar addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.height.mas_equalTo(50);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.tableView xhq_registerCell:TimelineMessageCell.class];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth(), kHomeIndicatorHeight())];
}

- (void)dy_request {
    [TimelineMessageHelper fetchMessagesCompletion:^(NSArray<BlogMessage *> * _Nonnull messages) {
        [self.sectionArray0 removeAllObjects];
        for (BlogMessage *msg in messages) {
            [self dy_configureDataWithModel:msg];
        }
        [self dy_tableViewReloadData];
    }];
}

- (void)clearMessage {
    
    if (self.sectionArray0.count == 0) {
        MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"暂无可清空消息".lv_localized detail:nil items:@[MMItemMake(@"清空".lv_localized, MMItemTypeHighlight, nil)]];
        [view show];
        return;
    }
    
    @weakify(self);
    MMPopupItemHandler block = ^(NSInteger index) {
        @strongify(self);
        if (index == 1) {
            [TimelineMessageHelper clearMessagesSuccessful:^{
                [self dy_refresh];
            }];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"清空".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"确定要清空当前评论消息列表？".lv_localized items:items];
    [view show];
}

#pragma mark - ConfigureData
- (void)dy_configureDataWithModel:(DYModel *)model {
    TimelineMessageCellItem *item = TimelineMessageCellItem.item;
    item.cellModel = model;
    [self.sectionArray0 addObject:item];
}

#pragma mark - UITableViewDataSource

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineMessageCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    BlogMessage *msg = (BlogMessage *)item.cellModel;
    if (msg.blog) {
        [self pushInfo:msg.blog];
        return;
    }
    [UserInfo show];
    @weakify(self);
    [msg fetchBlogInfo:^{
        @strongify(self);
        [UserInfo dismiss];
        if (msg.blog) {
            [self pushInfo:msg.blog];
        } else {
            [UserInfo showTips:nil des:@"动态不存在或已被删除".lv_localized];
        }
    }];
}

- (void)pushInfo:(BlogInfo *)blog {
    TimelineInfoVC *info = [[TimelineInfoVC alloc] init];
    info.blog = blog;
    [self.navigationController pushViewController:info animated:YES];
}

@end
