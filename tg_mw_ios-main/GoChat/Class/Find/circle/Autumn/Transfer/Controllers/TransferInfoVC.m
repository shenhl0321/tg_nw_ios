//
//  TransferInfoVC.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferInfoVC.h"

#import "TransferInfoMoneyCell.h"
#import "TransferInfoContentCell.h"
#import "TransferInfoReceivedView.h"

#import "TransferHelper.h"
#import "Transfer.h"

@interface TransferInfoVC ()

@property (nonatomic, strong) TransferInfoReceivedView *tableFooterView;

@end

@implementation TransferInfoVC

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"转账详情".lv_localized];
    
    [self dy_configureData];
}

- (void)dy_initUI {
    [super dy_initUI];
    self.tableView.backgroundColor = UIColor.whiteColor;
    [self.tableView xhq_registerCell:TransferInfoMoneyCell.class];
    [self.tableView xhq_registerCell:TransferInfoContentCell.class];
}

- (void)dy_request {
    [TransferHelper transferInfo:self.transfer.ids completion:^(Transfer * _Nullable transfer) {
        self.transfer = transfer;
        [self dy_configureData];
        [self.tableView reloadData];
    }];
}

- (void)received {
    [UserInfo show];
    [TransferHelper received:self.transfer.ids completion:^(NSString * _Nullable error) {
        [UserInfo dismiss];
        if (error) {
            [UserInfo showTips:nil des:error];
            return;
        }
        [UserInfo showTips:nil des:@"领取成功".lv_localized];
        [self dy_request];
        !self.transferStateChanged ? : self.transferStateChanged();
    }];
}

- (void)refund {
    [UserInfo show];
    [TransferHelper refund:self.transfer.ids completion:^(NSString * _Nullable error) {
        [UserInfo dismiss];
        if (error) {
            [UserInfo showTips:nil des:error];
            return;
        }
        [UserInfo showTips:nil des:@"已退还".lv_localized];
        [self dy_request];
        !self.transferStateChanged ? : self.transferStateChanged();
    }];
}

- (void)remind {
    [UserInfo show];
    [TransferHelper remind:self.transfer.ids completion:^(NSString * _Nullable error) {
        [UserInfo dismiss];
        if (error) {
            [UserInfo showTips:nil des:error];
            return;
        }
        [UserInfo showTips:nil des:@"提醒接受转账成功".lv_localized];
    }];
}

- (void)dy_configureData {
    [self.sectionArray0 removeAllObjects];
    [self.dataArray removeAllObjects];
    TransferInfoMoneyCellItem *item = TransferInfoMoneyCellItem.item;
    item.cellModel = self.transfer;
    [self.sectionArray0 addObject:item];
    
    if ([NSString xhq_notEmpty:self.transfer.descriptions]) {
        TransferInfoContentCellItem *item = TransferInfoContentCellItem.item;
        item.title = @"转账描述".lv_localized;
        item.content = self.transfer.descriptions;
        [self.sectionArray0 addObject:item];
    }
    
    NSString *formatter = @"yyyy年MM月dd日 HH:mm:ss".lv_localized;
    TransferInfoContentCellItem *cItem = TransferInfoContentCellItem.item;
    cItem.title = @"转账时间".lv_localized;
    cItem.content = [NSDate timeStringFromTimestamp:self.transfer.remittedAt formatter:formatter];
    [self.sectionArray0 addObject:cItem];
    
    if (self.transfer.receivedAt > 0) {
        TransferInfoContentCellItem *item = TransferInfoContentCellItem.item;
        item.title = @"收款时间".lv_localized;
        item.content = [NSDate timeStringFromTimestamp:self.transfer.receivedAt formatter:formatter];
        [self.sectionArray0 addObject:item];
    }
    
    if (self.transfer.refundedAt > 0) {
        TransferInfoContentCellItem *item = TransferInfoContentCellItem.item;
        item.title = @"退还时间".lv_localized;
        item.content = [NSDate timeStringFromTimestamp:self.transfer.refundedAt formatter:formatter];
        [self.sectionArray0 addObject:item];
    }
    
    [self.dataArray addObject:self.sectionArray0];
    if (self.transfer.showReceivedView) {
        self.tableView.tableFooterView = self.tableFooterView;
    } else {
        self.tableView.tableFooterView = nil;
    }
}

- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath {
    if ([item isKindOfClass:TransferInfoMoneyCellItem.class]) {
        NSString *title = @"你将在聊天里发送一条消息，对方将收到一次收款提醒（不可撤回）".lv_localized;
        XHQAlertSingleAction(title, nil, @"确定".lv_localized, @"取消".lv_localized, ^{
            [self remind];
        });
    }
}

- (TransferInfoReceivedView *)tableFooterView {
    if (!_tableFooterView) {
        _tableFooterView = [[TransferInfoReceivedView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth(), 200)];
        @weakify(self);
        _tableFooterView.receivedBlock = ^{
            @strongify(self);
            [self received];
        };
        _tableFooterView.refundBlock = ^{
            @strongify(self);
            NSString *title = [NSString stringWithFormat:@"确定退还给 %@ 的转账？".lv_localized, self.transfer.payerName];
            XHQAlertSingleAction(title, nil, @"确定".lv_localized, @"取消".lv_localized, ^{
                [self refund];
            });
        };
    }
    return _tableFooterView;
}

@end
