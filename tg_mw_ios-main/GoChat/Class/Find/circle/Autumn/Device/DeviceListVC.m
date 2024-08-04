//
//  DeviceListVC.m
//  GoChat
//
//  Created by Autumn on 2022/2/9.
//

#import "DeviceListVC.h"

#import "DeviceListCell.h"
#import "DeviceDeleteCell.h"
#import "DeviceSectionHeaderView.h"
#import "DeviceHeaderView.h"

#import "SettingHelper.h"

@interface DeviceListVC ()

@property (nonatomic, assign, getter=isEdit) BOOL edit;

@end

@implementation DeviceListVC

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"设备列表".lv_localized];
    self.style = UITableViewStyleGrouped;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.contentView.backgroundColor = self.tableView.backgroundColor = XHQHexColor(0xF1F1F1);
}

- (void)dy_initUI {
    [super dy_initUI];
 
    [self.customNavBar setRightBtnWithImageName:nil title:@"编辑".lv_localized highlightedImageName:@""];
    [self.tableView xhq_registerCell:DeviceListCell.class];
    [self.tableView xhq_registerCell:DeviceDeleteCell.class];
    [self.tableView xhq_registerView:DeviceSectionHeaderView.class];
    
    DeviceHeaderView *header = [DeviceHeaderView loadFromNib];
    self.tableView.tableHeaderView = header;
}

- (void)dy_request {
    [SettingHelper getActiveSessions:^(NSArray<SessionDevice *> * _Nonnull lists) {
        [self.dataArray removeAllObjects];
        [self.sectionArray0 removeAllObjects];
        [self.sectionArray1 removeAllObjects];
        if (lists.count == 0) {
            [self.tableView reloadData];
            return;
        }
        [lists enumerateObjectsUsingBlock:^(SessionDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DeviceListCellItem *item = DeviceListCellItem.item;
            item.cellModel = obj;
            if (obj.is_current) {
                [self.sectionArray0 addObject:item];
            } else {
                item.edit = self.isEdit;
                [self.sectionArray1 addObject:item];
            }
        }];
        if (self.sectionArray0.count > 0) {
            [self.dataArray addObject:self.sectionArray0];
        }
        if (self.sectionArray1.count > 0) {
            [self.sectionArray0 addObject:DeviceDeleteCellItem.item];
            [self.dataArray addObject:self.sectionArray1];
        }
        [self.tableView reloadData];
    }];
}

- (void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn {
    self.edit = !self.isEdit;
    if (self.isEdit) {
        [btn setTitle:@"完成".lv_localized forState:UIControlStateNormal];
    } else {
        [btn setTitle:@"编辑".lv_localized forState:UIControlStateNormal];
    }
    for (DeviceListCellItem *item in self.sectionArray1) {
        item.edit = self.isEdit;
    }
    [self.tableView reloadData];
}

- (void)deleteSession:(NSIndexPath *)indexPath {
    [UserInfo show];
    DeviceListCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    SessionDevice *session = (SessionDevice *)item.cellModel;
    [SettingHelper terminateSession:session.ids completion:^(BOOL success) {
        [UserInfo dismiss];
        if (success) {
            [self dy_request];
            return;
        }
        [UserInfo showTips:nil des:@"注销失败，请重试".lv_localized];
    }];
    
}

- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:DeviceDeleteCellItem.class]) {
        [SettingHelper terminateAllOtherSessions:^(BOOL success) {
            [self dy_request];
        }];
        return;
    }
    [self deleteSession:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DeviceSectionHeaderView *view = [tableView xhq_dequeueView:DeviceSectionHeaderView.class];
    view.terminal = [@[@(Current), @(Other)][section] integerValue];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return @[];
    }
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"注销账号".lv_localized handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteSession:indexPath];
    }];
    return @[action];
}

@end
