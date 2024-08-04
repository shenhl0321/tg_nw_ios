//
//  MNAddContactGroupVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNAddContactGroupVC.h"
#import "SearchGroupCell.h"
#import "ContactSearchBar.h"
#import "MNAddContactHeaderView.h"
#import "TF_RequestManager.h"
#import "MNAddContactGroupEmptyCell.h"

@interface MNAddContactGroupVC ()
<MNContactSearchBarDelegate>

@property (nonatomic, strong) ContactSearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray * groupArr;
@property (nonatomic) int searchPublicContactsTaskId;

@end

#define kMNAddContactGroupEmptyCell @"MNAddContactGroupEmptyCell"
@implementation MNAddContactGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)initUI{
    [self.contentView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(2);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(42);
        make.right.mas_equalTo(0);
    }];
    [self.searchBar styleNoCancel];
    
    
   
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(15);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:kMNAddContactGroupEmptyCell bundle:nil] forCellReuseIdentifier:kMNAddContactGroupEmptyCell];
}

-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.searchTf.placeholder = @"请输入群名/群ID".lv_localized;
        _searchBar.searchTf.font = [UIFont systemFontOfSize:14];
        _searchBar.cornerRadius = 21;
    }
    return _searchBar;
}

- (NSMutableArray *)groupArr{
    if (!_groupArr) {
        _groupArr = [NSMutableArray array];
    }
    return _groupArr;
}
#pragma mark - UITextFieldDelegate
-(void)searchBar:(ContactSearchBar *)bar textFieldDidBeginEditing:(UITextField *)textField{
  
    [self.searchBar styleHasCancel];
}
-(void)searchBar:(ContactSearchBar *)bar textFieldShouldReturn:(UITextField *)textField{

}
-(void)searchBar:(ContactSearchBar *)bar touchUpInsideCancelBtn:(UIButton *)cancel{
 
    [bar.searchTf resignFirstResponder];
    [self.searchBar styleNoCancel];
}

-(void)searchBar:(ContactSearchBar *)bar textFieldValueChanged:(UITextField *)textField{
    [self doSearch:textField.text];
}

#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupArr.count==0?1:self.groupArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.groupArr.count==0?400:72.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.groupArr.count == 0){
        MNAddContactGroupEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:kMNAddContactGroupEmptyCell forIndexPath:indexPath];
        cell.logoImageV.image = [UIImage imageNamed:@"icon_place_logo01"];
        cell.contentLab.text = @"只有超级群才有群ID哦";
        return cell;
    }else{
        static NSString *cellId = @"SearchGroupCell";
        SearchGroupCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell== nil) {
            cell = [[SearchGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
    //    ChatInfo
        cell.chatInfo = self.groupArr[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.groupArr.count > 0){
        ChatInfo *chatInfo = self.groupArr[indexPath.row];
        NSArray *list = [[TelegramManager shareInstance] getGroups];
        for (ChatInfo *localChat in list){
            if (chatInfo._id == localChat._id) {
                [AppDelegate gotoChatView:chatInfo];
                return;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    MNAddContactHeaderView *view = [[MNAddContactHeaderView alloc] init];
    view.aLabel.text = @"公开群".lv_localized;
    return view;
}


- (void)doSearch:(NSString *)keyword {
    if(self.searchPublicContactsTaskId > 0)
    {//结束之前的请求任务
        [[TelegramManager shareInstance] cancelTask:self.searchPublicContactsTaskId];
    }

    [self.groupArr removeAllObjects];
    if (keyword == nil || keyword.length <= 0) {
        [self.tableView reloadData];
        return;
    }
    
    [self search:keyword];
    return;
    
    __weak typeof(self) weak_self = self;
    [[TelegramManager shareInstance] searchPublicChatsList:keyword task:^(int taskId) {
        self.searchPublicContactsTaskId = taskId;
    } resultBlock:^(NSDictionary *request, NSDictionary *response, NSArray *obj) {
        if ([obj isKindOfClass:[NSArray class]] && obj.count > 0) {
            for (NSNumber *chatId in obj) {
                [TF_RequestManager getChatWithId:chatId.longValue resultBlock:^(NSDictionary *request, NSDictionary *response, ChatInfo *chat) {
                    if (chat != nil && [chat isGroup]) {
                        BOOL contain = NO;
                        for (ChatInfo *localChat in weak_self.groupArr) {
                            if (localChat._id == chat._id) {
                                contain = YES;
                                break;
                            }
                            
                        }
                        if (!contain) {
                            [weak_self.groupArr addObject:chat];
                        }
                        [weak_self.tableView reloadData];
                    }
                } timeout:^(NSDictionary *request) {
                    
                }];
            }
        }
        //刷新列表
        [weak_self.tableView reloadData];
    } timeout:^(NSDictionary *request) {//不做处理
        NSLog(@"");
    }];
    
    [TF_RequestManager searchChatsWithQuery:keyword resultBlock:^(NSDictionary *request, NSDictionary *response, NSArray *obj) {
        if ([obj isKindOfClass:[NSArray class]] && obj.count > 0) {
            for (NSNumber *chatId in obj) {
                [TF_RequestManager getChatWithId:chatId.longValue resultBlock:^(NSDictionary *request, NSDictionary *response, ChatInfo *chat) {
                    if(chat != nil && [chat isGroup])
                    {
                        BOOL contain = NO;
                        for (ChatInfo *localChat in weak_self.groupArr) {
                            if (localChat._id == chat._id) {
                                contain = YES;
                                break;
                            }
                            
                        }
                        if (!contain) {
                            [weak_self.groupArr addObject:chat];
                        }
                        
                        [weak_self.tableView reloadData];
                    }
                } timeout:^(NSDictionary *request) {
                    
                }];
            }
        }
        //刷新列表
        [weak_self.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        
    }];
    

    //刷新列表
    [self.tableView reloadData];
}

- (void)search:(NSString *)key {
    __block NSMutableArray *ids = NSMutableArray.array;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    @weakify(self);
    [TelegramManager.shareInstance searchPublicChatsList:key task:^(int taskId) {
        @strongify(self);
        self.searchPublicContactsTaskId = taskId;
    } resultBlock:^(NSDictionary *request, NSDictionary *response, NSArray *obj) {
        if (obj.count > 0) {
            [ids addObjectsFromArray:obj];
        }
        dispatch_group_leave(group);
    } timeout:^(NSDictionary *request) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [TF_RequestManager searchChatsWithQuery:key resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if ([obj isKindOfClass:NSArray.class] && ((NSArray *)obj).count > 0) {
            [ids addObjectsFromArray:obj];
        }
        dispatch_group_leave(group);
    } timeout:^(NSDictionary *request) {
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        @strongify(self);
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
        [ids sortUsingDescriptors:@[descriptor]];
        [self getChatFromIds:ids];
    });
}

- (void)getChatFromIds:(NSArray *)ids {
    if (ids.count == 0) {
        [self.tableView reloadData];
        return;
    }
    for (NSNumber *_id in ids) {
        @weakify(self);
        [TF_RequestManager getChatWithId:_id.longValue resultBlock:^(NSDictionary *request, NSDictionary *response, ChatInfo *chat) {
            @strongify(self);
            if (!chat || !chat.isGroup) {
                return;
            }
            if (![self.groupArr containsObject:chat]) {
                [self.groupArr addObject:chat];
                [self getMemberWithChat:chat];
            }
            [self.tableView reloadData];
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}

- (void)getMemberWithChat:(ChatInfo *)chat {
    [TF_RequestManager requestOnlieNumberWithChannelID:[ChatInfo toServerPeerId:chat._id] resultBlock:^(NSDictionary *request, NSDictionary *response, NSString *count) {
        chat.onlineNumber = [count integerValue];
        [self.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        
    }];
    @weakify(self);
    if (chat.isSuperGroup) { /// 超级群组
        [[TelegramManager shareInstance] getSuperGroupFullInfo:chat.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, SuperGroupFullInfo *obj) {
            @strongify(self);
            if (obj != nil && [obj isKindOfClass:[SuperGroupFullInfo class]]) {
                chat.totalNumber = obj.member_count;
                [self.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    } else { /// 普通群组
        [[TelegramManager shareInstance] getBasicGroupFullInfo:chat.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, BasicGroupFullInfo *groupFullInfo) {
            @strongify(self);
            chat.totalNumber = groupFullInfo.members.count;
            [self.tableView reloadData];
        } timeout:^(NSDictionary *request) {
        }];
    }
}

@end


@implementation ChatInfo (NumberOfMember)

- (NSInteger)totalNumber {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setTotalNumber:(NSInteger)totalNumber {
    objc_setAssociatedObject(self, @selector(totalNumber), @(totalNumber), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)onlineNumber {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setOnlineNumber:(NSInteger)onlineNumber {
    objc_setAssociatedObject(self, @selector(onlineNumber), @(onlineNumber), OBJC_ASSOCIATION_ASSIGN);
}

@end
