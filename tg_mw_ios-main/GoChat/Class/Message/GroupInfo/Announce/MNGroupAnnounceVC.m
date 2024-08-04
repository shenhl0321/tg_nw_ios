//
//  MNGroupAnnounceVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "MNGroupAnnounceVC.h"
#import "MNGroupInfoTvCell.h"
#import "MNGroupInfoTopCell.h"

@interface MNGroupAnnounceVC ()
<ASwitchDelegate>
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL isPinned;
@property (nonatomic, strong) UITextView *tv;
@property (nonatomic, strong) MessageInfo *sendingMsg;
@end

@implementation MNGroupAnnounceVC

-(void)dealloc{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    [self.customNavBar setTitle:@"群公告".lv_localized];
    if (self.canEdit) {
        self.deleteBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"删除".lv_localized highlightedImageName:nil];
        [self.deleteBtn setTitleColor:[UIColor colorTextForFD4E57] forState:UIControlStateNormal];
        [self.contentView addSubview:self.publishBtn];
        [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(55);
            make.left.mas_equalTo(30);
            make.bottom.mas_equalTo(-50);
            make.centerX.mas_equalTo(0);
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, -105, 0));
        }];
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    self.isPinned = self.chat.is_pinned;
    self.name = self.originName;
    [self initTableData];
    [self.tableView reloadData];
}


- (void)toggleChatPinned:(BOOL)pinned
{
    [UserInfo show];
    BOOL isPind = !self.isPinned;
    WS(weakSelf)
   
    [[TelegramManager shareInstance] toggleChatIsPinned:self.chat._id isPinned:isPind resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            
            [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }else{
            
//            [UserInfo showTips:nil des:@"置顶设置成功"];
            weakSelf.isPinned = isPind;
        }
        [weakSelf.tableView reloadData];
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized];
        [weakSelf.tableView reloadData];
    }];
}
- (void)initTableData{
    _rows = [[NSMutableArray alloc] init];
    if (self.canEdit) {
        [_rows addObject:@"top"];
    }
    [_rows addObject:@"content"];
}

- (void)publishAction{
    //发布的命令
    [self.view endEditing:YES];
    self.name = self.tv.text;
    [self setGroupPinnedMessage_step1:self.name];
}

- (void)setGroupPinnedMessage_step1:(NSString *)content
{
    //第一步，发送文本消息
    //第二步，设置为pinned消息
    if(!IsStrEmpty(content))
    {
        content = [NSString stringWithFormat:@"%@%@", GROUP_NOTICE_PREFIX, content];
        [UserInfo show];
        [[TelegramManager shareInstance] sendTextMessage:self.chat._id replyid:0 text:content withUserInfoArr:nil replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
            [UserInfo dismiss];
            if([TelegramManager isResultError:response])
            {
                [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
            else
            {
                MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
                if(msg.sendState == MessageSendState_Success)
                {//发送成功
                    [self setGroupPinnedMessage_step2:msg._id];
                }
                else if(msg.sendState == MessageSendState_Pending)
                {//等待回调结果
                    self.sendingMsg = msg;
                }
                else
                {
                    [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
                }
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
        }];
    }
    else
    {
        [UserInfo showTips:nil des:@"请填写群公告".lv_localized];
    }
}
//这个是置顶操作
- (void)setGroupPinnedMessage_step2:(long)msgId
{
    [UserInfo show];
    [[TelegramManager shareInstance] setPinMessage:self.chat._id long:msgId resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultOk:response])
        {
            [UserInfo showTips:nil des:@"群公告设置成功".lv_localized];
        }
        else
        {
            [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];

        [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
    }];
}


-(UIButton *)publishBtn{
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishBtn setTitle:@"发布群公告".lv_localized forState:UIControlStateNormal];
        [_publishBtn mn_loginStyle];
        [_publishBtn addTarget:self action:@selector(publishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}

#pragma mark - tableview代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.rows.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *rowName = self.rows[indexPath.row];
    if ([rowName isEqualToString:@"top"]) {
        return 52;
    }
    return 200;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 17.5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *rowName = self.rows[indexPath.row];
    
    if ([rowName isEqualToString:@"top"]) {
        static NSString *cellId = @"MNGroupInfoTopCell";
        MNGroupInfoTopCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNGroupInfoTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.rcSwitch.aSwitchDelegate = self;
            
        }
        cell.lcLabel.text = @"设为置顶".lv_localized;
            [cell.rcSwitch setOnWithOutAnimation:self.isPinned];
        return cell;
    }else{
        static NSString *cellId = @"MNGroupInfoTvCell";
        MNGroupInfoTvCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[MNGroupInfoTvCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            self.tv = cell.tv;
        }
        if (self.canEdit) {
            [cell fillDataWithText:[Util objToStr:self.name] placeholder:@"请编辑群公告".lv_localized];
        }else{
            [cell fillDataWithText:[Util objToStr:self.name] placeholder:@"未设置".lv_localized];
        }
    
        
        return cell;
    }
}

-(void)aSwitch:(ASwitch *)aSwitch isOn:(BOOL)isOn{
    [self.view endEditing:YES];
    self.name = self.tv.text;
    [self toggleChatPinned:isOn];
}


#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Success):
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Fail):
        {
            //@{@"msg":msg, @"old_message_id":[dic objectForKey:@"old_message_id"]}
            NSDictionary *params = inParam;
            if(params != nil && [params isKindOfClass:[NSDictionary class]])
            {
                MessageInfo *msg = [params objectForKey:@"msg"];
                if(msg != nil && [msg isKindOfClass:[MessageInfo class]])
                {
                    if(msg.chat_id == self.chat._id)
                    {//当前会话
                        long oldMsgId = -1;
                        NSNumber *old_message_id = [params objectForKey:@"old_message_id"];
                        if(old_message_id != nil && [old_message_id isKindOfClass:[NSNumber class]])
                        {
                            oldMsgId = [old_message_id longValue];
                        }
                        if(self.sendingMsg._id == oldMsgId)
                        {
                            if(msg.sendState == MessageSendState_Success)
                            {//发送成功
                                [UserInfo show];
                                [self setGroupPinnedMessage_step2:msg._id];
                            }
                            else
                            {
                                [UserInfo showTips:nil des:@"群公告设置失败，请稍后重试".lv_localized];
                            }
                        }
                    }
                }
            }
        }
            break;
    
       
        default:
            break;
    }
}


@end
