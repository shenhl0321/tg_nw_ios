//
//  MNContactSearchTextVC.m
//  GoChat
//
//  Created by Autumn on 2022/3/14.
//

#import "MNContactSearchTextVC.h"

#import "MNContactSearchTestCell.h"

@interface MNContactSearchTextVC ()

@property (nonatomic, assign) long fromId;

@end

@implementation MNContactSearchTextVC

- (void)dy_initData {
    [super dy_initData];
    
    [self.customNavBar setTitle:@"搜索结果".lv_localized];
    
    self.emptyTitle = @"暂无搜索结果".lv_localized;
    self.addLoadFooter = YES;
    [self.dataArray addObject:self.sectionArray0];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.tableView xhq_registerCell:MNContactSearchTestCell.class];
    
    self.fromId = 0;
}

- (void)dy_request {
    NSDictionary *parameters = @{
        @"@type": @"searchChatMessages",
        @"chat_id": _chatId,
        @"offset": @(0),
        @"limit": @(50),
        @"from_message_id": @(self.fromId),
        @"query": self.keyword
    };
    
    [TelegramManager.shareInstance jw_request:parameters result:^(NSDictionary *request, NSDictionary *response) {
        if (self.isDropdownRefresh) {
            [self.sectionArray0 removeAllObjects];
        }
        if ([TelegramManager isResultError:response]) {
            return;
        }
        NSArray *lists = response[@"messages"];
        for (NSDictionary *list in lists) {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:list];
            [TelegramManager parseMessageContent:list[@"content"] message:msg];
            if (msg.messageType != MessageType_Text || msg.transferInfo) {
                continue;
            }
            MNContactSearchTestCellItem *item = MNContactSearchTestCellItem.item;
            item.msg = msg;
            item.keyword = self.keyword;
            [self.sectionArray0 addObject:item];
        }
        [self dy_tableViewReloadData];
    } timeout:^(NSDictionary *request) {
        
    }];
    
}

- (void)dy_refresh {
    self.fromId = 0;
    [super dy_refresh];
}

- (void)dy_load {
    MessageInfo *info = self.sectionArray0.lastObject;
    self.fromId = info._id;
    [super dy_load];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MNContactSearchTestCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    MessageInfo *msg = item.msg;
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:msg.chat_id];
    [AppDelegate gotoChatView:chat destMsgId:msg._id];
}

@end
