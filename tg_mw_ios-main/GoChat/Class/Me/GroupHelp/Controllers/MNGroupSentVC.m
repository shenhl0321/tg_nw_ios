//
//  MNGroupSentVC.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/14.
//

#import "MNGroupSentVC.h"
#import "MNGroupSentSendVC.h"
#import "MNAddGroupVC.h"

#import "MNGroupHelpCell.h"

#import "MNGroupSentHelper.h"
#import "PlayAudioManager.h"

@interface MNGroupSentVC ()<MNChooseUserDelegate>

@property (nonatomic, strong) UIButton *bottomBtn;

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) NSIndexPath *voiceIndexPath;

@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIImageView *logoImageV;
@property (strong, nonatomic) UILabel *contentLab;
@property (nonatomic, strong) UIButton *addBtn;

@end

static long const GroupSentVoiceChatId = 100001;

@implementation MNGroupSentVC

- (UIView *)backView{
    if (!_backView){
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = HEXCOLOR(0xFFFFFF);
    }
    return _backView;
}
- (UILabel *)contentLab{
    if (!_contentLab){
        _contentLab = [[UILabel alloc] init];
        _contentLab.numberOfLines = 2;
        _contentLab.textColor = HEXCOLOR(0x333333);
        _contentLab.text = @"您可以通过群发助手，\n将消息一剑发送给200个好友，省时高效！";
        _contentLab.font = [UIFont systemFontOfSize:16];
        _contentLab.textAlignment = NSTextAlignmentCenter;
    }
    return _contentLab;
}
- (UIImageView *)logoImageV{
    if (!_logoImageV){
        _logoImageV = [[UIImageView alloc] init];
        _logoImageV.image = [UIImage imageNamed:@"icon_qunfazhushou"];
    }
    return _logoImageV;
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter xhq_removeAllObserveNotification];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"群发助手".lv_localized];
//    self.view.backgroundColor = [UIColor colorForF5F9FA];
    self.tableView.backgroundColor = HEXCOLOR(0xF5F9FA);
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 60, 0));
    }];
    
    [self.contentView addSubview:self.bottomBtn];
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(50);
        make.height.mas_equalTo(44);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    [self.view addSubview:self.backView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(kBottomSafeHeight);
        make.top.equalTo(self.contentView);
    }];
    
    [self.backView addSubview:self.logoImageV];
    [self.logoImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.backView).offset(30);
        make.right.equalTo(self.backView).offset(-30);
        make.centerY.equalTo(self.backView).offset(-100);
        make.height.equalTo(self.logoImageV.mas_width).multipliedBy(0.84);
    }];
    
    [self.backView addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerX.equalTo(self.backView);
        make.top.equalTo(self.logoImageV.mas_bottom).offset(10);
    }];
    [self.backView addSubview:self.addBtn];
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.backView);
        make.left.equalTo(self.backView).offset(50);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.contentLab.mas_bottom).offset(50);
    }];
    
}

- (void)dy_initData {
    [super dy_initData];
    [self xhq_addObserveNotification:IMAudioPlayFinishedNotification];
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(voiceStopNoti:) name:IMAudioPlayFinishedNotification object:nil];
}

- (void)dy_reloadData {
    self.messages = [[MNGroupSentHelper getMessages] mutableCopy];
    self.backView.hidden = !(self.messages.count==0);
    [self.tableView reloadData];
}

- (void)bottomAction {
    MNAddGroupVC *add = [[MNAddGroupVC alloc] init];
    add.delegate = self;
    add.chooseType = MNContactChooseType_Group_Sent;
    add.isPresent = YES;
    [self presentViewController:add animated:YES completion:nil];
}

- (void)voicePlay:(NSIndexPath *)indexPath {
    [self voiceStop];
    self.voiceIndexPath = indexPath;
    GroupSentMessage *msg = self.messages[indexPath.row];
    [PlayAudioManager.sharedPlayAudioManager playAudio:msg.mediaPath chatId:GroupSentVoiceChatId msgId:0];
}

- (void)voiceStop {
    if (!self.voiceIndexPath) {
        return;;
    }
    MNGroupHelpCell *cell = [self.tableView cellForRowAtIndexPath:self.voiceIndexPath];
    [cell voiceStop];
    self.voiceIndexPath = nil;
}

#pragma mark - Noti

- (void)xhq_handleNotification:(NSNotification *)notification {
    if ([notification xhq_isNotification:IMAudioPlayFinishedNotification]) {
        long chatId = [notification.object longValue];
        if (chatId != GroupSentVoiceChatId) {
            return;
        }
        [self voiceStop];
    }
}

#pragma mark - getter

-(UIButton *)addBtn{
    if (!_addBtn) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addBtn.titleLabel.font = fontRegular(16);
        _addBtn.backgroundColor = HEXCOLOR(0x08CF98);
        _addBtn.clipsToBounds = YES;
        _addBtn.layer.cornerRadius = 22;
        [_addBtn setTitle:@"+  新建群发".lv_localized forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn addTarget:self action:@selector(bottomAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addBtn;
}
-(UIButton *)bottomBtn{
    if (!_bottomBtn) {
        _bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomBtn.titleLabel.font = fontRegular(16);
        _bottomBtn.backgroundColor = HEXCOLOR(0x08CF98);
        _bottomBtn.clipsToBounds = YES;
        _bottomBtn.layer.cornerRadius = 22;
        [_bottomBtn setTitle:@"+  新建群发".lv_localized forState:UIControlStateNormal];
        [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bottomBtn addTarget:self action:@selector(bottomAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBtn;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"MNGroupHelpCell";
    MNGroupHelpCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[MNGroupHelpCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.msg = self.messages[indexPath.row];
    @weakify(self);
    @weakify(cell);
    cell.resendBlock = ^{
        @strongify(self);
        @strongify(cell);
        GroupSentMessage *sent = [[GroupSentMessage alloc] init];
        sent.users = cell.msg.users;
        sent.usernames = cell.msg.usernames;
        [self pushSendWithSent:sent];
    };
    cell.voiceBlock = ^{
        @strongify(self);
        [self voicePlay:indexPath];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 270;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - MNChooseUserDelegate
- (void)chooseUsers:(NSArray<UserInfo *> *)users {
    NSMutableArray *ids = NSMutableArray.array;
    NSMutableArray *names = NSMutableArray.array;
    for (UserInfo *user in users) {
        [ids addObject:@(user._id)];
        [names addObject:user.displayName];
    }
    GroupSentMessage *sent = [[GroupSentMessage alloc] init];
    sent.users = ids;
    sent.usernames = [names componentsJoinedByString:@","];
    
    [self pushSendWithSent:sent];
}

- (void)pushSendWithSent:(GroupSentMessage *)sent {
    MNGroupSentSendVC *send = [[MNGroupSentSendVC alloc] init];
    send.sent = sent;
    [self.navigationController pushViewController:send animated:YES];
}

@end
