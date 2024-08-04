//
//  MNContactSearchContentVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/4.
//

#import "MNContactSearchContentVC.h"
#import "MNContactSearchFriendCell.h"
#import "MNContactSearchChatCell.h"
#import "MNScanVC.h"
#import "MNContactDetailVC.h"
#import "QTGroupPersonInfoVC.h"

@interface MNContactSearchContentVC ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation MNContactSearchContentVC

- (instancetype)initWithType:(MNContactSearchType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}
-(void)dealloc{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self initData];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)initData{
    _dataArray = [[NSMutableArray alloc] init];
}

-(void)refreshViewWithData:(NSMutableArray *)dataArray{
    if (dataArray == nil) {
        [self.dataArray removeAllObjects];
    }else{
        self.dataArray = dataArray;
    }
   
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{// 根据searchMsgTimer.data是否为nil 判断是否显示空白页默认的“我的用户名”

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == MNContactSearchTypeChat) {
        static NSString *cellId = @"MNContactSearchChatCell";
        MNContactSearchChatCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNContactSearchChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        MessageInfo *message = self.dataArray[indexPath.row];
        [cell resetMessageInfo:message];
        return cell;
    }else{
        static NSString *cellId = @"MNContactSearchFriendCell";
        MNContactSearchFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNContactSearchFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        if (self.type == MNContactSearchTypeFriend) {
            UserInfo *user = self.dataArray[indexPath.row];
            [cell resetUserInfo:user];
        }else{
            ChatInfo *chat = self.dataArray[indexPath.row];
            [cell resetGroupInfo:chat];
        }
       
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (!self.searchMsgTimer.data)
//    {// 跳转SB指定VC
//        UIStoryboard *sbMe = [UIStoryboard storyboardWithName:@"Me" bundle:nil];
//        UIViewController *vc = [sbMe instantiateViewControllerWithIdentifier:@"MyQrViewController"];
//        [self.navigationController pushViewController:vc animated:YES];
//        return;
//    }
//
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSObject *obj =  self.dataArray[indexPath.row];
    if([obj isKindOfClass:[UserInfo class]])
    {
        UserInfo *user = (UserInfo *)obj;
//        MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//        v.user = user;
//        [self.navigationController pushViewController:v animated:YES];
        
        if (user.is_contact){
            QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
            vc.user = user;
            [self presentViewController:vc animated:YES completion:nil];
        }else{
            QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
            vc.user = user;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    if([obj isKindOfClass:[MessageInfo class]])
    {
        MessageInfo *msg = (MessageInfo *)obj;
        ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:msg.chat_id];
        [AppDelegate gotoChatView:chat destMsgId:msg._id];
    }
    if ([obj isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chat = (ChatInfo *)obj;
        [AppDelegate gotoChatView:chat];
    }
}

-(void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam{
    
}
@end
