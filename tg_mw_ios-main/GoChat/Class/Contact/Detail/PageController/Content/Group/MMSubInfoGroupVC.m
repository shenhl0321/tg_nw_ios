//
//  MMSubInfoGroupVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/20.
//

#import "MMSubInfoGroupVC.h"
#import "MNSubInfoGroupCell.h"
#import "TF_RequestManager.h"

@interface MMSubInfoGroupVC ()

@end

@implementation MMSubInfoGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)initDataCompleteFunc{
    [super initDataCompleteFunc];
    [self.tableView reloadData];
}

//覆盖一下方法就行
- (void)initDataComplete:(NullBlock)complete loadMore:(BOOL)loadMore{
    WS(weakSelf)
    [TF_RequestManager getGroupsInCommonWithId:self.userInfo._id offsetChatId:0 resultBlock:^(NSDictionary *request, NSDictionary *response, NSMutableArray *obj) {
        if (loadMore==NO) {
            [self.dataArray removeAllObjects];
        }
        NSInteger total_count = [response[@"total_count"] integerValue];
        // 本地群聊列表
        NSArray *list = [[TelegramManager shareInstance] getGroups];
        // 匹配查找对应详情
        __block NSMutableArray *tempArr = [[NSMutableArray alloc] init];
        [obj enumerateObjectsUsingBlock:^(NSString *chatId, NSUInteger idx, BOOL * _Nonnull stop) {
            
            for (ChatInfo *chat in list)
            {
                if ([[NSString stringWithFormat:@"%@", chatId] isEqualToString:[NSString stringWithFormat:@"%ld", chat._id]]) {
                    [tempArr addObject:chat];
                    break;
                }
            }
            weakSelf.dataArray = tempArr;
        }];

        [weakSelf initDataCompleteFunc];
        
    } timeout:^(NSDictionary *request) {
        [weakSelf initDataCompleteFunc];

    }];

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"MNSubInfoGroupCell";
    MNSubInfoGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNSubInfoGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    ChatInfo *chat = self.dataArray[indexPath.row];
    [cell fillDataWithChat:chat];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [AppDelegate gotoChatView:[self.dataArray objectAtIndex:indexPath.row]];
}

-(UITableViewStyle)style{
    return UITableViewStylePlain;
}

@end
