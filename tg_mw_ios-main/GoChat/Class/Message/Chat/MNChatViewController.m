//
//  MNMNChatViewController.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/10.
//

#import "MNChatViewController.h"
#import "MNChatViewController+VideoPlayer.h"
#import "MNChatViewController+imagePicker.h"
#import "MNChatViewController+SendMessage.h"

#import "IQKeyboardManager.h"
#import "BaseChatTableView.h"
#import "TZImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MNContactDetailVC.h"
#import "RecordAudio.h"
#import "AudioAlertView.h"
#import "PlayAudioManager.h"
#import "PhotoAVideoPreviewPagesViewController.h"
#import "BaseWebViewController.h"
#import <MessageUI/MessageUI.h>
#import "MNAddGroupVC.h"
#import "ChatEmojiView.h"
#import "CallInfo.h"
#import "C2CCallViewController.h"
#import "ModelPannelView.h"
#import "CreateGroupRedPacketViewController.h"
#import "CreateP2pRedPacketViewController.h"
#import "GotRpDialog.h"
#import "RedPacketDetailViewController.h"
#import "TransferVC.h"
#import "TransferInfoVC.h"
#import "ChatMultiSelOptToolView.h"
#import "ChatChooseViewController.h"
#import "FilePreviewViewController.h"
//#import "LocationViewController.h"
#import "CZChatSectionHeadView.h"
#import "CZChatTisTableViewCell.h"
#import "QTChatTisTableViewCell.h"
//#import "CZGroupMsgDetailViewController.h"
#import "PersonalCardView.h"
#import "ChatFireConfig.h"
#import "CustomTextView.h"
#import "ReadyEditViewController.h"
#import "MNLocationViewController.h"
#import "MNLocationNavigationVC.h"
#import "MNP2PRedPacketVC.h"
#import "MNGroupRedPacketVC.h"
#import "MNGroupInfoVC.h"
#import "GC_MyInfoVC.h"
#import "MNChatDelayView.h"
#import "MNChatUtil.h"
#import "MNGroupAnnounceHeaderView.h"
#import "MNPrivateWaitView.h"
#import "VoiceTransferTool.h"
#import "XFTextTranslateRequest.h"
#import "TF_SecreatChatTipV.h"
#import "GroupMemberNicknameUpdate.h"
#import "TF_RequestManager.h"
#import "QTGroupPersonInfoVC.h"

#define INPUT_CONTAINER_DEFAILT_HEIGHT 60
#define INPUT_CONTAINER_QUOTE_HEIGHT 120


@interface MNChatViewController ()
<BusinessListenerProtocol, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MessageViewBaseCellDelegate, RecordAudioDelegate, UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, ChatEmojiViewDelegate, ModelPannelViewDelegate, GotRpDialogDelegate, ChatMultiSelOptToolViewDelegate, ChatChooseViewControllerDelegate, UIDocumentPickerDelegate, MNLocationViewDelegate,AnimationMessageCellDelegate,TimerCounterDelegate,PersonalCardCellDelegate,UIPickerViewDelegate,UIPickerViewDataSource,MNChooseUserDelegate,MNChatDelayViewDelegate>
@property (nonatomic, strong) UILabel *countLabel;

@property (nonatomic, weak) IBOutlet BaseChatTableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopOffset;

@property (weak, nonatomic) IBOutlet UIButton *fireMsgBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputTrailing; //输入框左侧边距

@property (nonatomic) BOOL iqOgKeyboardEnable;
@property (nonatomic) BOOL iqOgKeyboardAutoToolbarEnable;
@property (nonatomic) BOOL willShowPanel;
@property (nonatomic) BOOL isKeyboardVisible;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomViewToPBottomOffset;
//tip
@property (nonatomic, weak) IBOutlet UIView *tipContainerView;
@property (nonatomic, weak) IBOutlet UILabel *tipLabel;
//input base - 60/18/42
@property (nonatomic, weak) IBOutlet UIView *inputContainerView;//输入框视图
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *inputContainerViewHeight;
@property (nonatomic) CGFloat orgInputHeight;
@property (weak, nonatomic) IBOutlet UILabel *quateLabel;//引用内容
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIView *quoteBgView;//引用文本图
@property (nonatomic,strong) MessageInfo *replyInfo;
@property (nonatomic,assign) BOOL   isQuote;//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomwithSuper;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomwithquote;
//audio
@property (nonatomic, weak) IBOutlet UIButton *audioModeBtn;
@property (nonatomic, weak) IBOutlet UIButton *audioBtn;
@property (assign) BOOL recordAudioTimeOverFlag;//表示录音是否超时了
@property (nonatomic, strong) RecordAudio *recordAudio;
@property (strong, nonatomic) AudioAlertView *audioAlertView;
//tool
@property (nonatomic, weak) IBOutlet UIView *toolContainerView;//功能选择视图
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toolContainerViewHeight;
//功能区
@property (nonatomic, weak) IBOutlet ModelPannelView *modelPannelView;
//表情区
@property (nonatomic, weak) IBOutlet ChatEmojiView *emojiPannelView;
@property (weak, nonatomic) IBOutlet UIView *inputBgView;
@property (nonatomic, weak) IBOutlet CustomTextView *inputTextView;
@property (nonatomic, strong) BasicGroupInfo *groupInfo;
@property (nonatomic, strong) SuperGroupInfo *super_groupInfo;
//群管理员列表
@property (nonatomic, strong) NSArray *memberIsManagersList;
//群成员列表
@property (nonatomic, strong) NSArray *membersList;
//文件选择器
@property (nonatomic, strong) UIDocumentPickerViewController *documentPickerVC;
//bg
@property (nonatomic, weak) IBOutlet UIImageView *bgImageView;
@property (nonatomic, weak) IBOutlet UIView *bgColorView;
//多选模式
//是否多选模式，默认NO
@property (nonatomic, assign) BOOL isMultiSelectedMode;
//多选操作工具栏
@property (nonatomic, strong) ChatMultiSelOptToolView *multiSelOptView;
@property (nonatomic,strong) CZPermissionsModel *cusPermissionsModel;
@property (nonatomic,strong) NSArray *keysWords;//聊天屏蔽词
@property (nonatomic, strong) UserFullInfo *userFullInfo;
//@人
@property (nonatomic,strong) UserInfo *backinfo;
@property (nonatomic,strong) UILabel *subtitleLabel;
@property (nonatomic,strong) NSMutableArray *selecteMembers;
//在线人数
@property (nonatomic, strong) TimerCounter *reloadMembersTimer;
//是否展示
@property (nonatomic, assign) BOOL curPageShow;
//收藏表情
@property (nonatomic, strong) NSArray *collectList;

@property (nonatomic, strong) NSTimer * delMsgTimer;
@property (nonatomic, strong) NSMutableArray * fireMsgArr;
@property (nonatomic, strong) NSMutableArray * fireMsgIDArr;
@property (nonatomic, strong) UIPickerView * pickV;
@property (nonatomic, strong) NSArray * pickArr;
@property (nonatomic, strong) NSArray * paserArr;

@property (nonatomic, strong) NSString * selectPickTime;
//@property (nonatomic, strong) UIView * bgView;

@property (nonatomic, strong) UILabel * unreadAtL;
@property (nonatomic, strong) UIButton * atBtn;
@property (nonatomic, strong) UILabel * unreadL;
@property (nonatomic, strong) UIButton * showLastBtn;
@property (nonatomic, strong) NSMutableArray * unreadAtMsgArr;
@property (nonatomic, strong) MNChatDelayView *delayView;
@property (nonatomic, strong) UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UIButton *faceBtn;

@property (nonatomic, strong) MessageInfo *groupPinnedMessage;//


/// 首次进入加载数据是，不需要延迟滑动到底部
@property (nonatomic, assign, getter=isScrollToBottomWithoutDelay) BOOL scrollToBottomWithoutDelay;

/// 群聊时，当前正在输入用户的缓存
@property (nonatomic,strong) NSMutableDictionary *groupInputCache;
/// 群在线人数
@property (nonatomic,assign) NSInteger onlineNumber;
@property (weak, nonatomic) IBOutlet MNPrivateWaitView *privateWaitView;

/// 是否是 dm@ 输入
@property (nonatomic,assign) BOOL dmInput;
/// 语音转文字
@property (nonatomic,strong) VoiceTransferTool *transfer;
/// <#code#>
@property (nonatomic,strong) TF_SecreatChatTipV *secreatChatTipv;
@property (nonatomic,strong) NSMutableArray *memberAndContacts;
@end

@implementation MNChatViewController

- (NSMutableArray *)memberAndContacts{
    if(!_memberAndContacts){
        _memberAndContacts = [NSMutableArray new];
    }
    return _memberAndContacts;
}

-(MNChatDelayView *)delayView{
    if (!_delayView) {
        _delayView = [[MNChatDelayView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 81)];
        _delayView.delegate = self;
        _delayView.hidden = YES;
    }
    return _delayView;
}

- (UILabel *)unreadL{
    if (!_unreadL) {
        _unreadL = [[UILabel alloc] init];
        _unreadL.textColor = [UIColor whiteColor];
        _unreadL.backgroundColor  = [UIColor colorMain];
//        _unreadAtL.backgroundColor = [UIColor greenColor];
        _unreadL.frame = CGRectMake(SCREEN_WIDTH-45, SCREEN_HEIGHT*2/3+45, 30, 30);
        _unreadL.layer.masksToBounds = YES;
        _unreadL.layer.cornerRadius = 15;
        _unreadL.font = [UIFont systemFontOfSize:11];
        _unreadL.textAlignment = NSTextAlignmentCenter;
    }
    
    return _unreadL;
}



- (UIButton *)showLastBtn{
    if (!_showLastBtn) {
        _showLastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showLastBtn setBackgroundImage:[UIImage imageNamed:@"icon_showLast"] forState:UIControlStateNormal];
        _showLastBtn.frame = CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT*2/3+60, 40, 40);
        _showLastBtn.backgroundColor = [UIColor whiteColor];
        _showLastBtn.layer.masksToBounds = YES;
        _showLastBtn.layer.cornerRadius = 20;
        [_showLastBtn addTarget:self action:@selector(showLastBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _showLastBtn;
}
- (UIButton *)atBtn{
    if (!_atBtn) {
        _atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_atBtn setBackgroundImage:[UIImage imageNamed:@"icon_At"] forState:UIControlStateNormal];
        _atBtn.frame = CGRectMake(SCREEN_WIDTH-50, SCREEN_HEIGHT*2/3-20, 40, 40);
        _atBtn.backgroundColor = [UIColor whiteColor];
        _atBtn.layer.masksToBounds = YES;
        _atBtn.layer.cornerRadius = 20;
        [_atBtn addTarget:self action:@selector(atBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _atBtn;
}
- (UILabel *)unreadAtL{
    if (!_unreadAtL) {
        _unreadAtL = [[UILabel alloc] init];
        _unreadAtL.textColor = [UIColor whiteColor];
        _unreadAtL.backgroundColor  = HEX_COLOR(@"#37CCA4");
//        _unreadAtL.backgroundColor = [UIColor greenColor];
        _unreadAtL.frame = CGRectMake(SCREEN_WIDTH-45, SCREEN_HEIGHT*2/3-20-20, 30, 30);
        _unreadAtL.layer.masksToBounds = YES;
        _unreadAtL.layer.cornerRadius = 15;
        _unreadAtL.font = [UIFont systemFontOfSize:11];
        _unreadAtL.textAlignment = NSTextAlignmentCenter;
    }
    
    return _unreadAtL;
}

- (NSMutableArray *)unreadAtMsgArr{
    if (!_unreadAtMsgArr) {
        _unreadAtMsgArr = [NSMutableArray array];
    }
    return _unreadAtMsgArr;
}
- (NSMutableArray *)selecteMembers{
    if (!_selecteMembers) {
        _selecteMembers = [NSMutableArray array];
    }
    return _selecteMembers;
}

- (UIPickerView *)pickV{
    if (!_pickV) {
        _pickV = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-300, SCREEN_WIDTH, 300)];
        _pickV.backgroundColor = [UIColor whiteColor];
        _pickV.delegate = self;
        _pickV.dataSource = self;
    }
    return _pickV;
}

- (NSArray *)pickArr{
    if (!_pickArr) {
        _pickArr = @[@"关".lv_localized,@"5秒".lv_localized,@"10秒".lv_localized,@"30秒".lv_localized,@"1分钟".lv_localized,@"5分钟".lv_localized,@"10分钟".lv_localized];
    }
    return _pickArr;
}
- (NSArray *)paserArr{
    if (!_paserArr) {
        _paserArr = @[@"",@"5",@"10",@"30",@"60",@"300",@"600"];
    }
    return _paserArr;
}

- (UILabel *)subtitleLabel{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, 200, 44-24)];
        _subtitleLabel.textColor = HEX_COLOR(@"#C0C0C0");
        _subtitleLabel.font = [UIFont boldSystemFontOfSize:FONT_S4];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _subtitleLabel;
}

- (TF_SecreatChatTipV *)secreatChatTipv{
    if (!_secreatChatTipv) {
        _secreatChatTipv = [[TF_SecreatChatTipV alloc] init];
        
        CGFloat width = 280;
        CGFloat height = 200;
        CGFloat x = (SCREEN_WIDTH - width) * 0.5;
        CGFloat y = (CGRectGetHeight(self.view.frame) - height) * 0.5 - kAdapt(150);
        _secreatChatTipv.frame = CGRectMake(x, y, width, height);
        _secreatChatTipv.hidden = YES;
        _secreatChatTipv.chatInfo = self.chatInfo;
    }
    return _secreatChatTipv;
}

- (void)dealloc
{
    if(self.recordAudio != nil)
    {
        _recordAudio.delegate = nil;
        [_recordAudio stopRecord];
        _recordAudio = nil;
    }
    
    if ([PlayAudioManager sharedPlayAudioManager].isPlaying)
    {
        [[PlayAudioManager sharedPlayAudioManager] stopPlayAudio:YES];
    }
    
    [[TelegramManager shareInstance] updateCurChatId:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAudioPlayFinishedNotification object:nil];
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
    
    //输入框草稿
    NSString *text = self.inputTextView.text;
    [CZCommonTool saveUserMsgdraftchatid:self.chatInfo._id saveArray:self.selecteMembers];
    [CZCommonTool savedraftchatid:self.chatInfo._id saveString:text];
    [self.reloadMembersTimer stopCountProcess];
    self.reloadMembersTimer = nil;
    
    if ([self.delMsgTimer isValid]){
        [self.delMsgTimer invalidate];
        self.delMsgTimer = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //刷新头像的
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.chatInfo._id];
    [MNChatUtil headerImgV:self.iconImgV chat:chat size:CGSizeMake(32, 32)];
    
    self.curPageShow = YES;
    self.iqOgKeyboardEnable = [IQKeyboardManager sharedManager].enable;
    self.iqOgKeyboardAutoToolbarEnable = [IQKeyboardManager sharedManager].enableAutoToolbar;
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    //返回+未读数
    [self initBackView];
    
    
    //输入框草稿
    if (!self.backinfo && self.inputTextView.text.length < 1) {
        NSString *text = [CZCommonTool getdraftchatid:self.chatInfo._id];
        self.selecteMembers = [[CZCommonTool getUserMsgdraftchatid:self.chatInfo._id] mutableCopy];
        if (text) {
            self.inputTextView.text = text;
            self.inputTextView.placeholder = @"";
            if (text.length == 0) {
                if([AppConfigInfo sharedInstance].enabled_destroy_after_reading){
                    self.fireMsgBtn.hidden = NO;
                }
                self.inputTrailing.constant = 90;

            }else{
                self.fireMsgBtn.hidden = YES;
//                self.inputTrailing.constant = 85;
                self.inputTrailing.constant = 90;

            }
        }
    }
    self.player.viewControllerDisappear = NO;
    
    //键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    // 截屏监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenShots) name:UIApplicationUserDidTakeScreenshotNotification  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.curPageShow = NO;
    [IQKeyboardManager sharedManager].enable = self.iqOgKeyboardEnable;
    [IQKeyboardManager sharedManager].enableAutoToolbar = self.iqOgKeyboardAutoToolbarEnable;
    self.player.viewControllerDisappear = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self prepareToPlay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.fd_interactivePopDisabled = B;
    [self.contentView removeFromSuperview];
    self.inputContainerView.backgroundColor = HEXCOLOR(0xF5F9FA);
    self.tipContainerView.backgroundColor = [UIColor colorMain:0.7];
//    self.inputBgView.backgroundColor = [UIColor colorForF5F9FA];
    self.quoteBgView.backgroundColor =HexRGB(0xf5f5f5);
    self.quoteBgView.layer.cornerRadius = 5;
    self.quoteBgView.layer.masksToBounds = YES;
    self.customNavBar.backgroundColor = HEXCOLOR(0xF5F9FA);
    
    self.inputTextView.backgroundColor = [UIColor whiteColor];
//    self.inputBgView.layer.cornerRadius = 5;
//    self.inputBgView.layer.masksToBounds = YES;
    self.audioBtn.backgroundColor = [UIColor colorForF5F9FA];
    self.audioBtn.layer.cornerRadius = 5;
    self.audioBtn.layer.masksToBounds = YES;
    
    [self.view addSubview:self.delayView];
    [self.delayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(APP_SCREEN_WIDTH, 81));
        make.centerX.mas_equalTo(0);
        make.bottom.equalTo(self.inputContainerView.mas_top).with.offset(0.5);;
    }];
    self.tableViewTopOffset.constant = APP_NAV_BAR_HEIGHT;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding=0;
    } else {
        // Fallback on earlier versions
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.fireMsgArr = @[].mutableCopy;
    self.fireMsgIDArr = @[].mutableCopy;
    [self.view addSubview:self.atBtn];
    [self.view addSubview:self.unreadAtL];
    [self.view addSubview:self.showLastBtn];
    [self.view addSubview:self.unreadL];
    
    self.onlineNumber = 0;
    self.scrollToBottomWithoutDelay = YES;
    self.atBtn.hidden = YES;
    self.unreadAtL.hidden = YES;
    self.unreadL.text = [NSString stringWithFormat:@"%d",self.chatInfo.unread_count];
    if (self.chatInfo.unread_count>99) {
        self.unreadL.text = @"99+";
    }
    self.unreadL.hidden = self.chatInfo.unread_count == 0;
    self.showLastBtn.hidden = self.chatInfo.unread_count == 0;
//    [self.bgView addSubview:self.pickV];
    if ([[ChatFireConfig shareInstance].fireConfigDic.allKeys containsObject:[NSNumber numberWithLong:self.chatInfo._id]] ) {
        self.selectPickTime = [[ChatFireConfig shareInstance].fireConfigDic objectForKey:[NSNumber numberWithLong:self.chatInfo._id]];
//        [self sureBtnClick];
        [self.delayView refreshDataWithValue:[self.selectPickTime integerValue]];
    }
    [[TelegramManager shareInstance] updateCurChatId:self.chatInfo._id];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    //语音结束播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayStop:) name:IMAudioPlayFinishedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess) name:@"NetWork_ConnectSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transferMessageInfoChangedNoti:) name:@"TransferMessageInfoDidChanged" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dwonLoadVideoFinish:) name:@"VideoDownLoadFinish" object:nil];
    
    //关闭引用
    [self.closeBtn addTarget:self action:@selector(closeQuoteClick) forControlEvents:UIControlEventTouchUpInside];
    
    //背景
    self.tableView.backgroundColor = [UIColor clearColor];
    self.bgImageView.backgroundColor = HEXCOLOR(0xF5F9FA);
    [self resetChatBg];
    self.bgColorView.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = HEXCOLOR(0xF5F9FA);
    //滚动偏差导致页面跳动
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    //是否是群组聊天
    self.tableView.isGroup = self.chatInfo.isGroup;
    //是否我的收藏
    self.tableView.isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);
    
    //导航栏标题、菜单
    [self resetTitle];
    if(!self.chatInfo.isGroup)
    {
        [self.modelPannelView initP2pModel:self.chatInfo._id==[UserInfo shareInstance]._id];
        [self resetNavBar];
    }
    else
    {
        [self.modelPannelView initGroupModel];
        [self resetNavBar];
    }
    self.modelPannelView.delegate = self;
    //初始状态
    [self endEdit:NO];
    //显示群公告
    if(self.chatInfo.isGroup)
    {
        [self showGroupNotice:NO];
    }
//    //加载数据
//    if(self.destMsgId != 0)
//    {
//        [self.tableView addHeaderView];
//        RunBlockAfterDelay(0.3, ^
//                           {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self prepareToDestPageMessages:self.destMsgId];
//            });
//        });
//    }
//    else
//    {
//        [self loadMoreMessages];
//    }
    [self openChat];
    //设置输入框
    CGFloat xMargin = 8, yMargin = 10;
    // 使用textContainerInset设置top、left、right
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(yMargin, xMargin, 0, xMargin);
    //当光标在最后一行时，始终显示低边距，需使用contentInset设置bottom.
    self.inputTextView.contentInset = UIEdgeInsetsMake(0, 0, yMargin, 0);
    //防止在拼音打字时抖动
    self.inputTextView.layoutManager.allowsNonContiguousLayout=NO;
    //输入框代理
    self.inputTextView.delegate = self;
    //输入框最大字符数-4000字符
    [self.inputTextView setMylimitCount:@4000];
    
    //语音录入
    [self initAudioView];
    
    //检查当前会话-用户状态
    [self checkUserChatState];
    
    /// 视频播放
    [self setupPlayerWithScrollView:self.tableView];
    
    //表情
    self.emojiPannelView.delegate = self;
    [self gettingExtendedPermissions];
    [self queryGroupShieldWordsWithchtid];
    [self getChatDetail];
    self.reloadMembersTimer = [TimerCounter new];
    self.reloadMembersTimer.delegate = self;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(APP_TOP_BAR_HEIGHT);
//        make
    }];
    if (self.chatInfo.isSecretChat) {
        [self refreshPrivateBottomView];
    }
    [self settingQuoteStyle:NO];
//    [self refreshTableHeaderView:YES];
    if(![AppConfigInfo sharedInstance].enabled_destroy_after_reading){
        self.fireMsgBtn.hidden = YES;
    }
}
-(void)openChat{
    __weak typeof(self) weak_self = self;
    [[TelegramManager shareInstance] openChat:_chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response]){
           [weak_self loadMessageData];
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}
-(void)closeChat{
    [[TelegramManager shareInstance] closeChat:_chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response]){
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}
-(void)loadMessageData{
    //加载数据
    if(self.destMsgId != 0)
    {
        [self.tableView addHeaderView];
        RunBlockAfterDelay(0.3, ^
                           {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareToDestPageMessages:self.destMsgId];
            });
        });
    }
    else
    {
        [self loadMoreMessages];
    }
}

- (void)initBackView
{
//    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 66, 44)];
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(0, 0, 44, 44);
//    if(Is_Special_Theme)
//    {
//        [backBtn setImage:[UIImage imageNamed:@"com_nav_ic_back_white"] forState:UIControlStateNormal];
//        [backBtn setImage:[UIImage imageNamed:@"com_nav_ic_back_white"] forState:UIControlStateHighlighted];
//    }
//    else
//    {
//        [backBtn setImage:[UIImage imageNamed:@"com_nav_ic_back_black"] forState:UIControlStateNormal];
//        [backBtn setImage:[UIImage imageNamed:@"com_nav_ic_back_black"] forState:UIControlStateHighlighted];
//    }
//    [backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
//    [backView addSubview:backBtn];
//    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 46, 44)];
//    countLabel.textAlignment = NSTextAlignmentLeft;
//    countLabel.textColor = COLOR_NAV_TINT_COLOR;
//    countLabel.font = [UIFont systemFontOfSize:FONT_S2];
//    self.countLabel = countLabel;
//    [backView addSubview:countLabel];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backView];
   self.countLabel = [self.customNavBar setCountLabelText:@""];
    [self refreshBackTitle];

}

- (void)refreshBackTitle
{
    if([UserInfo shareInstance].msgUnreadTotalCount<=0)
    {
        self.countLabel.text = nil;
    }
    else if([UserInfo shareInstance].msgUnreadTotalCount<=99)
    {
        self.countLabel.text = [NSString stringWithFormat:@"(%d)", [UserInfo shareInstance].msgUnreadTotalCount];
    }
    else
    {
        self.countLabel.text = @"(99+)";
    }
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    if (self.isMultiSelectedMode) {
        [self click_cancelMultiSelectedMode];
    }else{
        if (self.chatInfo.isGroup) {
            [self click2_group_settings];
        }else{
            if(self.chatInfo._id==[UserInfo shareInstance]._id) {
                
            }else{
                [self click_contact_settings];
            }
        }
    }
}
-(void)navigationBar:(MNNavigationBar *)navationBar didClickSecondRightBtn:(UIButton *)btn{
    if (self.chatInfo.isGroup) {
        
    }else{
        if(self.chatInfo._id==[UserInfo shareInstance]._id)
        {//我的收藏
//            self.navigationItem.rightBarButtonItems = nil;
//            self.navigationItem.rightBarButtonItem = nil;
        }
        else{
            [self click_OnlineVideoOrVoice];
        }
    }
}
- (void)resetNavBar
{
    if(self.isMultiSelectedMode)
    {
        [self.customNavBar style_title_LeftBtn_RightBtn];
        self.customNavBar.titleLabel.frame = CGRectMake((kScreenWidth()-200)*0.5, 0, 200, 26);
        [self.customNavBar setRightBtnWithImageName:nil title:@"取消".lv_localized highlightedImageName:nil];
//        self.navigationItem.rightBarButtonItems = nil;
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(click_cancelMultiSelectedMode)];
        return;
    }
    //nav_contact_set
    UIImageView *imgV= [[UIImageView alloc] init];
//    imgV.layer.masksToBounds=YES;
//    imgV.layer.cornerRadius = 16;
    [imgV mn_iconStyleWithRadius:16];
    [MNChatUtil headerImgV:imgV chat:self.chatInfo size:CGSizeMake(32, 32)];
    self.iconImgV = imgV;
//    [btn sd_];
    if(self.chatInfo.isGroup)
    {
       
//        UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        settingBtn.frame = CGRectMake(0, 0, 40, 44);
//        [settingBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_group_set_white":@"nav_group_set"] forState:UIControlStateNormal];
//        [settingBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_group_set_white":@"nav_group_set"] forState:UIControlStateHighlighted];
//        [settingBtn addTarget:self action:@selector(click_group_settings) forControlEvents:UIControlEventTouchUpInside];
//
//        UIButton *settingBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
//        settingBtn2.frame = CGRectMake(0, 0, 40, 44);
//        [settingBtn2 setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_group_set_white":@"nav_group_set"] forState:UIControlStateNormal];
//        [settingBtn2 setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_group_set_white":@"nav_group_set"] forState:UIControlStateHighlighted];
//        [settingBtn2 addTarget:self action:@selector(click2_group_settings) forControlEvents:UIControlEventTouchUpInside];
//
//
//        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:settingBtn2]];
        //        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingBtn];
        AppConfigInfo *config = [AppConfigInfo sharedInstance];
        if(config.shown_online_members){
            [self.customNavBar style_Chat];
        }
       UIButton *btn = [self.customNavBar setRightBtnWithImageName:nil title:nil highlightedImageName:nil];
        [btn addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.centerY.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
       
    }
    else
    {
        if(self.chatInfo._id==[UserInfo shareInstance]._id)
        {//我的收藏
//            self.navigationItem.rightBarButtonItems = nil;
//            self.navigationItem.rightBarButtonItem = nil;
        }
        else
        {
            //contact setting
//            UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            settingBtn.frame = CGRectMake(0, 0, 40, 44);
//            [settingBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_contact_set_white":@"nav_contact_set"] forState:UIControlStateNormal];
//            [settingBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_contact_set_white":@"nav_contact_set"] forState:UIControlStateHighlighted];
//            [settingBtn addTarget:self action:@selector(click_contact_settings) forControlEvents:UIControlEventTouchUpInside];
//
//            //call
//            UIButton *callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            callBtn.frame = CGRectMake(0, 0, 40, 44);
//            [callBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_call_white":@"nav_call"] forState:UIControlStateNormal];
//            [callBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"nav_call_white":@"nav_call"] forState:UIControlStateHighlighted];
//            [callBtn addTarget:self action:@selector(click_OnlineVideoOrVoice) forControlEvents:UIControlEventTouchUpInside];
//
//            self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:settingBtn], [[UIBarButtonItem alloc] initWithCustomView:callBtn]];
            if (self.chatInfo.isSecretChat)  {
                //有个小锁
                [self.customNavBar style_ChatPrivate];
            }else{
                [self.customNavBar style_Chat];
            }
            
            UIButton *btn = [self.customNavBar setRightBtnWithImageName:nil title:nil highlightedImageName:nil];
            [btn addSubview:imgV];
            [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
                make.centerY.mas_equalTo(0);
                make.size.mas_equalTo(CGSizeMake(32, 32));
            }];
            if(ShowLocal_VoiceChat){
                [self.customNavBar setRightBtn2WithImageName:@"nav_call" title:nil highlightedImageName:@"nav_call"];
            }
            
            
        }
    }
}

- (void)resetTitle
{
    if(self.chatInfo.isGroup)
    {
        [self settingGroupNav];
    }else{
        if(self.chatInfo._id==[UserInfo shareInstance]._id)
        {
            [self.customNavBar setTitle:@"我的收藏".lv_localized];
        }
        else
        {
            [self settingNavTitleView];
        }
    }
}

//群组设置
-(void)settingGroupNav{
//    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
//    headView.backgroundColor = [UIColor clearColor];
//    headView.autoresizesSubviews = NO;
//    self.navigationItem.titleView = headView;
//
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 200, 24)];
//    titleLabel.textColor = COLOR_C1;
//    titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//    titleLabel.font = [UIFont boldSystemFontOfSize:FONT_S1];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//
//    [headView addSubview:titleLabel];
//    [headView addSubview:self.subtitleLabel];
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    if(config.shown_online_members){
        self.subtitleLabel = [self.customNavBar setSecondTitle:@""];
    }
    
    NSString *titleStr = nil;
    if(self.chatInfo.isSuperGroup && self.super_groupInfo != nil && self.super_groupInfo.member_count>0)
    {
        [[ChatExCacheManager shareInstance] setGroupMemberCount:self.chatInfo._id count:self.super_groupInfo.member_count];
        titleStr = [NSString stringWithFormat:@"%@(%d)", self.chatInfo.title, self.super_groupInfo.member_count];
    }
    else
    {
        int count = [[ChatExCacheManager shareInstance] getGroupMemberCount:self.chatInfo._id];
        if(count > 0)
        {
            titleStr = [NSString stringWithFormat:@"%@(%d)", self.chatInfo.title, count];
        }
        else
        {
            titleStr = self.chatInfo.title;
        }
    }
//    titleLabel.text = titleStr;
    [self.customNavBar setTitle:titleStr];
    _subtitleLabel.text = [NSString stringWithFormat:@"%ld人在线".lv_localized,self.onlineNumber];
}

//设置导航标题视图
- (void)settingNavTitleView{
//    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
//    headView.backgroundColor = [UIColor clearColor];
//    headView.autoresizesSubviews = NO;
//    self.navigationItem.titleView = headView;
//
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 2, 200, 24)];
//    titleLabel.textColor = COLOR_C1;
//    titleLabel.font = [UIFont boldSystemFontOfSize:FONT_S1];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//
//    [headView addSubview:titleLabel];
//    [headView addSubview:self.subtitleLabel];
    self.subtitleLabel = [self.customNavBar setSecondTitle:@""];
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.userId];
    if(user != nil)
    {
//        titleLabel.text = user.displayName;
        NSString *subtitleStr = nil;
        NSString *onlineStyle = [user.status objectForKey:@"@type"];
        if ([onlineStyle isEqualToString:@"userStatusEmpty"]) {
            subtitleStr = @"";
        }else if ([onlineStyle isEqualToString:@"userStatusLastMonth"]){
            subtitleStr = @"一月前上线".lv_localized;
        }else if ([onlineStyle isEqualToString:@"userStatusLastWeek"]){
            subtitleStr = @"一周前上线".lv_localized;
        }else if ([onlineStyle isEqualToString:@"userStatusOffline"]){//计算时间
            NSString *str = [NSString stringWithFormat:@"%@",[user.status objectForKey:@"was_online"]];
            subtitleStr = [CZCommonTool labelFinallyTime:str];
        }else if ([onlineStyle isEqualToString:@"userStatusOnline"]){
            subtitleStr = @"在线".lv_localized;
        }else if ([onlineStyle isEqualToString:@"userStatusRecently"]){
            subtitleStr = @"最近在线".lv_localized;
        }
        [self.customNavBar setTitle:user.displayName];
        self.subtitleLabel.text = subtitleStr;
    }
    else
    {
//        titleLabel.text = self.chatInfo.title;
        [self.customNavBar setSecondTitle:self.chatInfo.title];
    }
}

- (void)resetChatBg
{
    if(!self.chatInfo.isGroup && self.chatInfo._id==[UserInfo shareInstance]._id)
    {//我的收藏
        self.bgImageView.image = nil;
        return;
    }
    if([[ChatExCacheManager shareInstance] chatBgIsFromAssets:self.chatInfo._id])
    {
        self.bgImageView.image = [UIImage imageNamed:[[ChatExCacheManager shareInstance] chatBg:self.chatInfo._id]];
    }
    else if([[ChatExCacheManager shareInstance] chatBgIsFromLocalFile:self.chatInfo._id])
    {
        NSString *localPath = [[ChatExCacheManager shareInstance] chatBg:self.chatInfo._id];
        if([Common fileIsExist:localPath])
        {
            self.bgImageView.image = [UIImage imageWithContentsOfFile:localPath];
        }
        else
        {
            self.bgImageView.image = nil;
        }
    }
    else
    {
        self.bgImageView.image = nil;
    }
}


- (void)click2_group_settings{
  
    MNGroupInfoVC *vc = [[MNGroupInfoVC alloc] init];
    vc.chatInfo = self.chatInfo;
    vc.cusPermissionsModel = self.cusPermissionsModel;
    vc.messageList = self.messageList;
    [self.navigationController pushViewController:vc animated:YES];
//    CZGroupMsgDetailViewController  *vc = [CZGroupMsgDetailViewController new];
//    vc.chatInfo = self.chatInfo;
//    vc.cusPermissionsModel = self.cusPermissionsModel;
//    vc.messageList = self.messageList;
//    [self.navigationController pushViewController:vc animated:YES];
    
    //    GroupChatSettingsViewController *v = segue.destinationViewController;
    //    v.hidesBottomBarWhenPushed = YES;
    //    v.chatInfo = self.chatInfo;
    //    v.cusPermissionsModel = self.cusPermissionsModel;
}

- (void)click_contact_settings
{
    MNContactDetailVC *vc = [[MNContactDetailVC alloc] init];
    long userId = self.chatInfo._id;
    if (self.chatInfo.isSecretChat) {
        userId = self.chatInfo.type.user_id;
    }
    vc.user = [[TelegramManager shareInstance] contactInfo:userId];
    [self.navigationController pushViewController:vc animated:YES];
    
//        QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
//        long userId = self.chatInfo._id;
//        if (self.chatInfo.isSecretChat) {
//            userId = self.chatInfo.type.user_id;
//        }
//        vc.user = [[TelegramManager shareInstance] contactInfo:userId];
//        [self presentViewController:vc animated:YES completion:nil];

}

- (void)getSuperAdminMembers
{
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterAdministrators" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = (NSArray *)obj;
            self.memberIsManagersList = list;
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)getSuperMembers
{
    [[TelegramManager shareInstance] getSuperGroupMembers:self.chatInfo.type.supergroup_id type:@"supergroupMembersFilterRecent" keyword:nil offset:0 limit:200 resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[NSArray class]])
        {
            NSArray *list = (NSArray *)obj;
            self.membersList = list;
            [self compileAndGetRealyData];
            [self resetTitle];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

//获取群中的好友  获取其真实信息
- (void)compileAndGetRealyData{
    [self.memberAndContacts removeAllObjects];
    NSArray *contactList = [[TelegramManager shareInstance] getContacts];
    for (int i=0; i<self.membersList.count; i++) {
        GroupMemberInfo *gropMemberItem = [self.membersList objectAtIndex:i];
        for (int j=0; j<contactList.count; j++) {
            UserInfo *contactItem = [contactList objectAtIndex:j];
            if(contactItem._id == gropMemberItem.user_id){
                [self getRealyMessageWithMember:contactItem];
            }
        }
    }
}

//获取真实信息  即是群友又是好友
- (void)getRealyMessageWithMember:(UserInfo *)userinfo{
    [[TelegramManager shareInstance] requestOrgContactInfo:userinfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
        {
            [self.memberAndContacts addObject:obj];
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)checkUserChatState
{
    if(self.chatInfo.isGroup)
    {
        if(self.chatInfo.isSuperGroup)
        {//超级群组
            [[TelegramManager shareInstance] getSuperGroupInfo:self.chatInfo.type.supergroup_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if(obj != nil && [obj isKindOfClass:[SuperGroupInfo class]])
                {
                    //超级群组管理员列表
                    [self getSuperAdminMembers];
                    //成员
                    [self getSuperMembers];
                    //
                    [self resetUIFromSuperGroupInfo:obj];
                }
            } timeout:^(NSDictionary *request) {
            }];
        }
        else
        {//普通群组
            //获得群组基本资料
            [[TelegramManager shareInstance] getBasicGroupInfo:self.chatInfo.type.basic_group_id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if(obj != nil && [obj isKindOfClass:[BasicGroupInfo class]])
                {
                    [self resetUIFromBasicGroupInfo:obj];
                }
            } timeout:^(NSDictionary *request) {
            }];
        }
    }
}

- (void)resetUIFromBasicGroupInfo:(BasicGroupInfo *)groupInfo
{
    self.groupInfo = groupInfo;
    if(groupInfo.is_active)
    {//是否激活
        [self resetUIFromMemberState:groupInfo.status];
    }
    else
    {//未激活
        [self Ban_SendMessage:@"群组未激活".lv_localized];
    }
}

- (void)resetUIFromSuperGroupInfo:(SuperGroupInfo *)groupInfo
{
    self.super_groupInfo = groupInfo;
    [self resetTitle];
    [self resetUIFromMemberState:groupInfo.status];
}

- (void)resetUIFromMemberState:(Group_ChatMemberStatus *)status
{
    switch ([status getMemberState])
    {
        case GroupMemberState_Administrator:
            //管理员
            [self CanSendMessage];
            break;
        case GroupMemberState_Creator:
            //创建者
            if(!status.is_member)
            {//创建者已不在群组
                [self Ban_SendMessage:@"您已不在群组里".lv_localized];
            }
            else
            {
                [self CanSendMessage];
            }
            break;
        case GroupMemberState_Left:
            //不在群组
            [self Ban_SendMessage:@"您已不在群组里".lv_localized];
            break;
        case GroupMemberState_Member:
            //普通成员
            if(self.chatInfo.permissions.can_send_messages)//can_send_messages
            {
                [self CanSendMessage];
            }
            else
            {
                [self Ban_SendMessage:@"管理员已开启全体禁言".lv_localized];
            }
            break;
        case GroupMemberState_Banned:
            //被禁用
            [self Ban_SendMessage:@"您已不在群组里".lv_localized];
            break;
        case GroupMemberState_Restricted:
            //被禁言
            [self Ban_SendMessage:@"您被禁言".lv_localized];
            break;
        default:
            break;
    }
}

- (void)Ban_SendMessage:(NSString *)des
{
    self.orgInputHeight = self.inputContainerViewHeight.constant;
    self.inputContainerView.hidden = YES;
    self.toolContainerView.hidden = YES;
    self.inputContainerViewHeight.constant = 0;
    self.toolContainerViewHeight.constant = 0;
    //self.navigationItem.rightBarButtonItem = nil;
    self.tipContainerView.hidden = NO;
    self.tipLabel.text = des;
}

- (void)CanSendMessage
{
    if(self.inputContainerView.hidden && self.orgInputHeight>0)
    {
        self.inputContainerView.hidden = NO;
        self.inputContainerViewHeight.constant = self.orgInputHeight;
    }
    self.tipContainerView.hidden = YES;
    [self resetNavBar];
}

- (void)closeQuoteClick{
    self.isQuote = NO;
    [self settingQuoteStyle:YES];
}

- (void)settingQuoteStyle:(BOOL)scrollToBottom {
    if (self.isQuote) {
        //        self.inputContainerViewHeight.constant = INPUT_CONTAINER_QUOTE_HEIGHT;
        [self.inputTextView becomeFirstResponder];
        self.quoteBgView.hidden = NO;//引用内容显示
        self.bottomwithSuper.priority = UILayoutPriorityDefaultLow;
        self.bottomwithquote.priority = UILayoutPriorityRequired;
    }else{
        //        self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
        self.quateLabel.text = @"";
        self.quoteBgView.hidden = YES;//引用内容显示
        self.bottomwithSuper.priority = UILayoutPriorityRequired;
        self.bottomwithquote.priority = UILayoutPriorityDefaultLow;
    }
    [self resetInputContainerHeight];
    if (scrollToBottom) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showLastCell];
        });
    }
}

- (NSMutableArray *)messageList
{
    if(_messageList == nil)
    {
        _messageList = [NSMutableArray array];
    }
    return _messageList;
}

#pragma mark - load data
void RunBlockAfterDelay(NSTimeInterval delay, void(^block)(void))
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*delay),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), block);
}

- (BOOL)hasNextPageMessages
{
    if(self.messageList.count>0)
    {
        MessageInfo *last = [self.messageList lastObject];
        return [[TelegramManager shareInstance] getChatInfo:self.chatInfo._id].lastMessage._id != last._id;
    }
    return NO;
}
-(void)connectSuccess{
    if(self.messageList.count<=0)
    {
        [self loadLastMessage:YES];
    }
}
- (void)loadMoreMessages
{
    [self.tableView addHeaderView];
    RunBlockAfterDelay(0.1, ^
                       {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.messageList.count<=0)
            {
                if (self.chatInfo.unread_count == 0) {
                    [self loadLastMessage:YES];
                }else{
                    [self loadLastMessage:YES LastMessageID:0 needReq:YES];
                }
            }
            else
            {
                MessageInfo *first = [self.messageList firstObject];
                [self preparePrevPageMessages:first._id];
            }
        });
    });
}

-(void)loadLastMessage:(BOOL)isScrollToBottom LastMessageID:(long)msgID needReq:(BOOL)needReq{
    int limit = 40;
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:msgID offset:0 limit:limit only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]] && list.count>0)
            {
//                [self.messageList removeAllObjects];
                
                NSMutableArray *msgIds = [NSMutableArray array];
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    [self autoDownloadAudio:msg];
                    [self.messageList insertObject:msg atIndex:0];
                    [self changeUnreadAtMessage];

                    [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                }
            }
        }
        
        if (self.messageList.count>0&&needReq) {
            MessageInfo *msg = self.messageList.firstObject;
            if (self.messageList.count<self.chatInfo.unread_count) {
                [self loadLastMessage:YES LastMessageID:msg._id needReq:YES];
            }
            else if(self.messageList.count==self.chatInfo.unread_count){
                //数量一致多请求一次方便定位
                [self loadLastMessage:YES LastMessageID:msg._id needReq:NO];
            }
            else{
                [self reloadView:isScrollToBottom];
            }
        }else{
            [self reloadView:isScrollToBottom];
        }
    } timeout:^(NSDictionary *request) {
        [self reloadView:isScrollToBottom];
    }];

}

-(void)reloadView:(BOOL)isScrollToBottom {
    [self setMessagesIsNeedShowDayText];
    [self.tableView reloadData];
    if (isScrollToBottom) {
        [self showLastCell];
    } else {
        [self prepareToPlay];
    }
    [self.tableView removeHeaderView];
}



- (void)loadLastMessage:(BOOL)isScrollToBottom {
    int limit = 20;
    if (self.chatInfo.unread_count>0) {
        limit = limit + self.chatInfo.unread_count;
    }

    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:0 offset:0 limit:limit only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //    加载表情收藏
            [self getSavedAnimations];
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]] && list.count>0)
            {
                [self.messageList removeAllObjects];
                
                NSMutableArray *msgIds = [NSMutableArray array];
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                   
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    [self autoDownloadAudio:msg];
                    [self.messageList insertObject:msg atIndex:0];
                    [self changeUnreadAtMessage];
                    [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                }
                //服务器同步，比较差异
                RunBlockAfterDelay(0.1, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadLastPageMessages:isScrollToBottom];
                    });
                });
            }
        }
        [self.tableView removeHeaderView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeHeaderView];
    }];
}
- (void)autoDownloadAudio:(MessageInfo *)msg{
    if (msg.messageType == MessageType_Audio) {
        AudioInfo *audioInfo = msg.content.audio;
        if(audioInfo != nil && !audioInfo.isAudioDownloaded)
        {
            //未下载，启动下载
            if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.audio._id type:FileType_Message_Audio])
            {
                NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                if(audioInfo.audio.remote.unique_id.length > 1 && audioInfo.audio.remote.unique_id.length > 1){
                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.audio._id download_offset:0 type:FileType_Message_Audio];
                }
                
            }
        }
    }else if (msg.messageType == MessageType_Voice) {
        VoiceInfo *audioInfo = msg.content.voice_note;
        if(audioInfo != nil && !audioInfo.isAudioDownloaded)
        {
            //未下载，启动下载
            if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.voice._id type:FileType_Message_Voice]
               && audioInfo.voice.remote.unique_id.length > 1)
            {
                NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.voice._id download_offset:0 type:FileType_Message_Voice];
            }
        }
    }
}

- (void)loadLastPageMessages:(BOOL)isScrollToBottom {
    int limit = 20;
    if (self.chatInfo.unread_count>0) {
        limit = limit + self.chatInfo.unread_count;
    }
    
    long fromId = 0;
    if (self.messageList.count > 0) {
        MessageInfo *first = self.messageList.firstObject;
        fromId = first._id;
    }

    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:fromId offset:0 limit:limit only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]] && list.count>0 && self.messageList.count != list.count)
            {
//                [self.messageList removeAllObjects];
                
                NSMutableArray *msgIds = [NSMutableArray array];
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    [self autoDownloadAudio:msg];
                    [self.messageList insertObject:msg atIndex:0];
                    [self changeUnreadAtMessage];

                    [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                }
//                if(msgIds.count>0)
//                {
//                    [[TelegramManager shareInstance] setMessagesReaded:self.chatInfo._id msgIds:msgIds];
//                }
                //放到外边  第二次请求异常就按第一次的来
//                [self setMessagesIsNeedShowDayText];
//                [self.tableView reloadData];
//                if(isScrollToBottom)
//                {
//                    [self showLastCell];
//                }
            }
        }
        
        [self setMessagesIsNeedShowDayText];
        [self.tableView reloadData];
        if(isScrollToBottom)
        {
            [self showLastCell];
        }
        [self.tableView removeHeaderView];
    } timeout:^(NSDictionary *request) {
        [self setMessagesIsNeedShowDayText];
        [self.tableView reloadData];
        if(isScrollToBottom)
        {
            [self showLastCell];
        }
        [self.tableView removeHeaderView];
    }];
}

- (void)preparePrevPageMessages:(long)lastId
{
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:lastId offset:0 limit:1  only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            [self loadPrevPageMessages:lastId];
            return;
        }
        [self.tableView removeHeaderView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeHeaderView];
    }];
}

- (void)loadPrevPageMessages:(long)lastId
{
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:lastId offset:0 limit:20 only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            //    加载表情收藏
            [self getSavedAnimations];
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]])
            {
                NSMutableArray *msgIds = [NSMutableArray array];
                int count = 0;
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    [self autoDownloadAudio:msg];
                    if(msg._id!=lastId)
                    {
                        [self.messageList insertObject:msg atIndex:0];
                        [self changeUnreadAtMessage];

                        [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                        count++;
                    }
                }
//                if(msgIds.count>0)
//                {
//                    [[TelegramManager shareInstance] setMessagesReaded:self.chatInfo._id msgIds:msgIds];
//                }
                
                [self smothRefreshPrevPageUI:count];
            }
        }
        [self.tableView removeHeaderView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeHeaderView];
    }];
}

- (void)prepareNextPageMessages:(long)lastId
{
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:lastId offset:-1 limit:1 only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            [self loadNextPageMessages:lastId];
            return;
        }
        [self.tableView removeFooterView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeFooterView];
    }];
}

- (void)loadNextPageMessages:(long)lastId
{
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:lastId offset:-20 limit:20  only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]])
            {
                NSMutableArray *msgsListTemp = [NSMutableArray array];
                NSMutableArray *msgIds = [NSMutableArray array];
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    [self autoDownloadAudio:msg];
                    if(msg._id!=lastId)
                    {
                        [msgsListTemp insertObject:msg atIndex:0];
                        [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                    }
                }
//                if(msgIds.count>0)
//                {
//                    [[TelegramManager shareInstance] setMessagesReaded:self.chatInfo._id msgIds:msgIds];
//                }
                if(msgsListTemp.count>0)
                {
                    [self.messageList addObjectsFromArray:msgsListTemp];
                    [self changeUnreadAtMessage];
                    [self setMessagesIsNeedShowDayText];
                    [self.tableView reloadData];
                    NSIndexPath *lastRow = [NSIndexPath indexPathForRow:self.messageList.count-msgsListTemp.count inSection:0];
                    [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
            }
        }
        [self.tableView removeFooterView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeFooterView];
    }];
}

- (void)smothRefreshPrevPageUI:(int)updateMsgCount
{
    if(updateMsgCount>0)
    {
        [self setMessagesIsNeedShowDayText];
        [self.tableView reloadData];
        if(updateMsgCount>1)
        {
            NSIndexPath *lastRow = [NSIndexPath indexPathForRow:updateMsgCount-2 inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        else
        {
            NSIndexPath *lastRow = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}

- (void)prepareToDestPageMessages:(long)msgId
{
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:msgId offset:-10 limit:20  only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            [self loadToDestPageMessages:msgId];
            return;
        }
        [self.tableView removeHeaderView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeHeaderView];
    }];
}

- (void)loadToDestPageMessages:(long)msgId
{
    [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:msgId offset:-10 limit:20  only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"messages"];
            if(list != nil && [list isKindOfClass:[NSArray class]])
            {
                [self.messageList removeAllObjects];
                
                MessageInfo *destMsg = nil;
                NSMutableArray *msgIds = [NSMutableArray array];
                for(NSDictionary *msgDic in list)
                {
                    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                    [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                    [self autoDownloadAudio:msg];
                    [self.messageList insertObject:msg atIndex:0];
                    [self changeUnreadAtMessage];

                    [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                    if(msg._id == msgId)
                    {
                        destMsg = msg;
                    }
                }
//                if(msgIds.count>0)
//                {
//                    [[TelegramManager shareInstance] setMessagesReaded:self.chatInfo._id msgIds:msgIds];
//                }
                
                [self setMessagesIsNeedShowDayText];
                [self.tableView reloadData];
                
                if(destMsg != nil)
                {
                    NSIndexPath *destRow = [NSIndexPath indexPathForRow:[self.messageList indexOfObject:destMsg] inSection:0];
                    [self changeUnreadAtMessage];

                    [self.tableView scrollToRowAtIndexPath:destRow atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                }
            }
        }
        [self.tableView removeHeaderView];
    } timeout:^(NSDictionary *request) {
        [self.tableView removeHeaderView];
    }];
}

#pragma mark 收藏表情列表
- (void)getSavedAnimations {
    [[TelegramManager shareInstance] getSavedAnimationsWithresultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            NSArray *list = [response objectForKey:@"animations"];
            if(list != nil && [list isKindOfClass:[NSArray class]])
            {
                self.collectList = [[AnimationInfo mj_objectArrayWithKeyValuesArray:list] copy];
            }
            self.emojiPannelView.collectList = self.collectList;
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)addOrUpdateMessage:(MessageInfo *)msg oldMsgId:(long)oldMsgId
{
    int pIndex = -1;
    if(oldMsgId > 0){
        int oldIndex = [self isMsgLoaded:oldMsgId];
        if(oldIndex != -1){
            pIndex = oldIndex;
        }
    }
    if(pIndex == -1){
        pIndex = [self isMsgLoaded:msg._id];
    }
    BOOL needShowLastCell = NO;
    if(pIndex != -1){//更新消息
        [self.messageList replaceObjectAtIndex:pIndex withObject:msg];
        [self changeUnreadAtMessage];

    }else{//新增消息
        if (msg.is_outgoing) {
            needShowLastCell = YES;
        } else {
            /// 已经在最底部了的话，就去掉未读，滚动到底部
            NSIndexPath *indexPath = self.tableView.indexPathsForVisibleRows.lastObject;
            NSInteger count = self.messageList.count - 1;
            if (self.isDisplayEncryptionTip) {
                count --;
            }
            if (indexPath && indexPath.row >= count) {
                needShowLastCell = YES;
                self.chatInfo.unread_count = 0;
            }
            self.unreadL.text = [NSString stringWithFormat:@"%d",self.chatInfo.unread_count];
            if (self.chatInfo.unread_count>99) {
                self.unreadL.text = @"99+";
            }
            self.showLastBtn.hidden = self.chatInfo.unread_count==0;
            self.unreadL.hidden = self.chatInfo.unread_count==0;
        }
        [self.messageList addObject:msg];
        [self changeUnreadAtMessage];
    }
    //刷新并判断是否跳转到底部
    if(!needShowLastCell)
    {
        if(self.tableView.contentOffset.y + self.tableView.frame.size.height + 60 >= self.tableView.contentSize.height)
        {
            needShowLastCell = YES;
        }
    }
    [self setMessagesIsNeedShowDayText];
    [self.tableView reloadData];
    if(needShowLastCell)
    {
        [self showLastCell];
    }
}

- (void)updatePhotoMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.photo.messagePhoto.photo = file;
        [self.tableView reloadData];
    }
}

- (void)updateAudioMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.audio.audio = file;
        [self.tableView reloadData];
    }
}

- (void)updateVoiceMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.voice_note.voice = file;
        [self.tableView reloadData];
    }
}

- (void)updateVideoMsg:(long)msgId file:(FileInfo *)file
{
    NSArray *indexs = [self isMsgLoadedVideo:file];
    if (indexs.count == 0) {
        return;
    }
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id == [UserInfo shareInstance]._id);//收藏
    for (NSNumber *idx in indexs) {
        int index = idx.intValue;
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.video.video = file;
        
//        wl 临时修改不刷新问题
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadVideoCell" object:msgInfo];
        
        if (!(self.chatInfo.isGroup || isMyFov || [self isSystemChat])) {//群聊
            index ++;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (self.curPageShow && cell && [cell isKindOfClass:VideoMessageCell.class]) {
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            VideoMessageCell *vCell = (VideoMessageCell *)cell;
            [vCell reloadVideoInfo:msgInfo.content.video];
        }
    }
}

- (void)updateGifMsg:(long)msgId file:(FileInfo *)file
{
    int index = [self isMsgLoaded:msgId];
    if(index != -1)
    {
        MessageInfo *msgInfo = [self.messageList objectAtIndex:index];
        msgInfo.content.animation.animation = file;
        [self.tableView reloadData];
    }
}

- (void)deleteMsg:(long)msgId isRefresh:(BOOL)isRefresh
{
    for(MessageInfo *msg in self.messageList)
    {
        if(msg._id == msgId)
        {
            [self.messageList removeObject:msg];
            [self changeUnreadAtMessage];

            return;
        }
    }
}

- (int)isMsgLoaded:(long)msgId
{
    for(int i=0; i<self.messageList.count; i++)
    {
        MessageInfo *msg = [self.messageList objectAtIndex:i];
        if(msg._id == msgId)
            return i;
    }
    return -1;
}

//FileInfo
- (NSArray *)isMsgLoadedVideo:(FileInfo *)info
{
    NSMutableArray *array = NSMutableArray.array;
    for(int i=0; i<self.messageList.count; i++)
    {
        MessageInfo *msg = [self.messageList objectAtIndex:i];
        if (msg.messageType == MessageType_Video) {
            if (msg.content.video.video._id == info._id) {
                [array addObject:@(i)];
            }
        }
    }
    return array;
}

- (void)setMessagesIsNeedShowDayText
{
    if(self.messageList.count>0)
    {
        long curDate = 0;
        for(MessageInfo *msg in self.messageList)
        {
            if(curDate <= 0)
            {
                if(!msg.isShowDayText)
                {
                    msg.msg_cell_height = 0;
                    msg.isShowDayText = YES;
                }
                curDate = msg.date;
            }
            else
            {
                if(![Common isSameDay:curDate time2:msg.date])
                {
                    if(!msg.isShowDayText)
                    {
                        msg.msg_cell_height = 0;
                        msg.isShowDayText = YES;
                    }
                    curDate = msg.date;
                }
                else
                {
                    if(msg.isShowDayText)
                    {
                        msg.msg_cell_height = 0;
                        msg.isShowDayText = NO;
                    }
                }
            }
        }
    }
}

- (NSArray *)getCurrentPhotoList
{
    NSMutableArray *list = [NSMutableArray array];
    for(MessageInfo *msg in self.messageList)
    {
        if(msg.messageType == MessageType_Photo)
        {
            [list addObject:msg];
        }
    }
    return list;
}

#pragma mark - click
- (IBAction)click_more:(id)sender
{
    self.willShowPanel = YES;
    if(self.isKeyboardVisible)
    {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.0 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = NO;
            self.emojiPannelView.hidden = YES;
            [self.view layoutIfNeeded];
            //消息到列表底部
            [self showLastCell];
        }];
    }
    else
    {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = NO;
            self.emojiPannelView.hidden = YES;
            [self.view layoutIfNeeded];
            //消息到列表底部
            [self showLastCell];
        }];
    }
    //退出语音模式
    if (!self.audioBtn.hidden) {
        [self click_Audio:self.audioBtn];
    } else {
        [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
        self.audioBtn.hidden = YES;
        self.inputTextView.hidden = NO;
    }
    
    [self resetInputContainerHeight];
}

- (IBAction)click_emotion:(id)sender
{
    self.willShowPanel = YES;
    if(self.isKeyboardVisible)
    {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.0 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = YES;
            self.emojiPannelView.hidden = NO;
            [self.view layoutIfNeeded];
            //消息到列表底部
            [self showLastCell];
        }];
    }
    else
    {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = YES;
            self.emojiPannelView.hidden = NO;
            [self.view layoutIfNeeded];
            //消息到列表底部
            [self showLastCell];
        }];
    }
    //退出语音模式
    [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
    self.audioBtn.hidden = YES;
    self.inputTextView.hidden = NO;
    [self resetInputContainerHeight];
}
- (IBAction)click_fireRead:(id)sender {
//    if (self.chatInfo.isGroup || self.chatInfo.isSuperGroup) {
//        [SVProgressHUD showInfoWithStatus:@"群组暂不可用"];
//        return;
//    }
    
//    [self.view endEditing:YES];
//    if (self.selectPickTime.length>0) {
//        [self.pickV selectRow:[self.paserArr indexOfObject:self.selectPickTime] inComponent:0 animated:NO];
//    }
//    self.bgView.hidden = NO;
//    self.delayView.hidden = NO;
    
    [self.view endEditing:YES];
    [self.delayView refreshDataWithValue:[self.selectPickTime integerValue]];
    self.delayView.hidden = NO;
    self.fd_interactivePopDisabled = YES;
    NSLog(@"%@",self.fireMsgBtn.selected?@"开".lv_localized:@"关".lv_localized);
}

- (IBAction)click_Audio:(id)sender
{
    if(self.audioBtn.hidden)
    {//进入语音模式
        if (self.isQuote && !self.isKeyboardVisible) {
            if(self.inputContainerViewHeight.constant>INPUT_CONTAINER_DEFAILT_HEIGHT)
            {
                [self.view layoutIfNeeded];
                [UIView animateWithDuration:0.35 animations:^{
                    self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
                    [self.view layoutIfNeeded];
                }];
            }
        }
        if(self.isKeyboardVisible)
        {//隐藏键盘
            [self.inputTextView resignFirstResponder];
            self.inputTextView.hidden = YES;
            if(self.inputContainerViewHeight.constant>INPUT_CONTAINER_DEFAILT_HEIGHT)
            {
                [self.view layoutIfNeeded];
                [UIView animateWithDuration:0.35 animations:^{
                    self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
                    [self.view layoutIfNeeded];
                }];
            }
        }
        else
        {//隐藏功能面板
            self.inputTextView.hidden = YES;
            if(self.toolContainerViewHeight.constant>0)
            {
                [self.view layoutIfNeeded];
                [UIView animateWithDuration:0.35 animations:^{
                    self.toolContainerView.hidden = YES;
                    self.toolContainerViewHeight.constant = 0;
                    self.bottomViewToPBottomOffset.constant = 0;
                    self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
                    [self.view layoutIfNeeded];
                }];
            }
        }
        [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatKeyboard"] forState:UIControlStateNormal];
        self.audioBtn.hidden = NO;
        self.fireMsgBtn.hidden = YES;
        self.faceBtn.hidden = YES;
    }
    else
    {//退出语音模式，进入键盘模式
        [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
        self.audioBtn.hidden = YES;
        if([AppConfigInfo sharedInstance].enabled_destroy_after_reading){
            self.fireMsgBtn.hidden = NO;
        }
        self.faceBtn.hidden = NO;
        self.inputTextView.hidden = NO;
        [self.inputTextView becomeFirstResponder];
        [self resetInputContainerHeight];
    }
}

//图片处理相关
+ (NSData *)imageData:(UIImage *)image
{
    @autoreleasepool
    {
        NSData *tmpImageData = UIImageJPEGRepresentation(image, 0.8);
        return tmpImageData;
    }
}

+ (NSString *)writeFile2LocalFile:(NSData *)data path:(NSString *)imagePath
{
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage createFileAtPath:imagePath contents:data attributes:nil])
    {
        return imagePath;
    }
    return nil;
}

+ (NSString *)localPhotoPath:(UIImage *)image
{
    NSString *localPath = [NSString stringWithFormat:@"%@/%@.jpg", UserImagePath([UserInfo shareInstance]._id), [Common generateGuid]];
    return [MNChatViewController writeFile2LocalFile:[MNChatViewController imageData:image] path:localPath];
}

+ (NSString *)localGifPhotoPath:(UIImage *)image
{
    NSString *localPath = [NSString stringWithFormat:@"%@/%@.gif", UserImagePath([UserInfo shareInstance]._id), [Common generateGuid]];
    return [MNChatViewController writeFile2LocalFile:[MNChatViewController imageData:image] path:localPath];
}

//本地视频处理
static AVAssetExportSession *videoExportSession = nil;
+ (void)createVideoFileWithAVURLAssert:(AVURLAsset *)asset result:(void(^)(NSError *error, NSString *videoPath, CGSize size, int duration))block
{
    __block NSError *error = nil;
    
    NSString *quality = nil;
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality])
    {
        quality = AVAssetExportPresetHighestQuality;
    }
    else if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
    {
        quality = AVAssetExportPresetMediumQuality;
    }
    else if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality])
    {
        quality = AVAssetExportPresetLowQuality;
    }
    else
    {
        if (block)
        {
            error = [NSError errorWithDomain:@"无质量".lv_localized code:101 userInfo:nil];
            block(error, nil, CGSizeZero, 0);
        }
        return;
    }
    
    int videoDuration = asset.duration.value*1.0/asset.duration.timescale;
    NSString *videoPath = [NSString stringWithFormat:@"%@/%@.mp4", UserVideoPath([UserInfo shareInstance]._id), [Common generateGuid]];
    videoExportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:quality];
    videoExportSession.outputURL = [NSURL fileURLWithPath:videoPath];
    videoExportSession.shouldOptimizeForNetworkUse = YES;
    videoExportSession.outputFileType = AVFileTypeMPEG4;
    [videoExportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([videoExportSession status])
        {
            case AVAssetExportSessionStatusFailed:
            {
                if (block)
                {
                    block([videoExportSession error], nil, CGSizeZero, 0);
                }
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                if (block)
                {
                    error = [NSError errorWithDomain:@"取消".lv_localized code:102 userInfo:nil];
                    block(error, nil, CGSizeZero, 0);
                }
                break;
            }
            case AVAssetExportSessionStatusCompleted:
            {
                if (block)
                {
                    AVURLAsset *convertAvAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
                    AVAssetTrack *track = [[convertAvAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                    CGSize videoSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
                    block(nil, videoPath, videoSize, videoDuration);
                }
                break;
            }
            default:
            {
                if (block)
                {
                    error = [NSError errorWithDomain:@"未知".lv_localized code:103 userInfo:nil];
                    block(error, nil, CGSizeZero, 0);
                }
                break;
            }
        }
    }];
}

- (void)click_photo
{
    BOOL isGroupAdmin = [@[@(GroupMemberState_Administrator), @(GroupMemberState_Creator)] containsObject:@(self.super_groupInfo.status.getMemberState)];
    [self openAlbum:isGroupAdmin result:^(NSArray * _Nonnull videos, NSArray * _Nonnull photos, NSArray * _Nonnull gifs) {
        if (photos.count > 0) {
            NSMutableArray *images = NSMutableArray.array;
            [photos enumerateObjectsUsingBlock:^(HXPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.photoEdit) {
                    [images addObject:obj.photoEdit.editPreviewImage];
                } else {
                    [images addObject:obj.previewPhoto];
                }
                if (obj.ADContent && obj.ADContent.length > 0) {
                    self.photoAdContent = obj.ADContent;
                    self.photoAdIndex = idx;
                }
            }];
            [self sendImageMessage:images];
        }
        if (gifs.count > 0) {
            for (HXPhotoModel *model in gifs) {
                NSArray *resourceList=[PHAssetResource assetResourcesForAsset:model.asset];
                PHAssetResource *resouLim = [resourceList firstObject];
                if (resouLim) {
                    [self sendGifPhotoMessage:model.previewPhoto withPHAssetResource:resouLim];
                }
            }
        }
        if (videos.count > 0) {
            HXPhotoModel *model = videos.firstObject;
            [self sendVideoMessage:model.previewPhoto video:model.asset];
        }
    }];
}

- (void)showNeedCameraAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    if(state == GroupMemberState_Administrator || state == GroupMemberState_Creator){
        //管理
    }else{
        if(!self.chatInfo.permissions.can_send_messages){//全体禁言
            [UserInfo showTips:nil des:@"全体禁言".lv_localized];
            return;
        }
        if(!self.chatInfo.permissions.can_send_media_messages){//禁止媒体
            [UserInfo showTips:nil des:@"禁止发送媒体消息".lv_localized];
            return;
        }
    }
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *toSendImage = [Common fixOrientation:image];
        
        if(state == GroupMemberState_Administrator || state == GroupMemberState_Creator){
            //管理
        }else{
            if (self.cusPermissionsModel.banSendQRcode) {//禁二维码
                BOOL isQRcode = [CZCommonTool isQRcodeImage:toSendImage];
                if (isQRcode) {
                    [UserInfo showTips:nil des:@"禁止发送二维码".lv_localized];
                    return;
                }
            }
        }
        
        NSString *path = [MNChatViewController localPhotoPath:toSendImage];
        if(path != nil)
        {
            if (self.fireMsgBtn.selected) {
                [[TelegramManager shareInstance] sendFirePhotoMessage:self.chatInfo._id localPath:path photoSize:toSendImage.size fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    if([TelegramManager isResultError:response])
                    {//表示发送失败
                    }
                } timeout:^(NSDictionary *request) {
                }];
            }else{
                //发送图片
                [[TelegramManager shareInstance] sendPhotoMessage:self.chatInfo._id localPath:path photoSize:toSendImage.size replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    if([TelegramManager isResultError:response])
                    {//表示发送失败
                    }
                } timeout:^(NSDictionary *request) {
                }];
            }
        }
    }
    else
    {
        NSURL *video_url = info[UIImagePickerControllerMediaURL];
        [self sendVideoMessage:nil video:video_url];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)click_camera
{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage,(NSString*)kUTTypeMovie, nil];
        imagePickerController.videoMaximumDuration = 30.f;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;//UIImagePickerControllerCameraCaptureModeVideo
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else
    {
        [self showNeedCameraAlert];
    }
}


//发图片
- (void)sendPhotoMessage:(NSArray *)photos
{
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    BOOL isGroupAdmin = (state == GroupMemberState_Administrator || state == GroupMemberState_Creator);
    if (!isGroupAdmin) {
        if(!self.chatInfo.permissions.can_send_messages){//全体禁言
            [UserInfo showTips:nil des:@"全体禁言".lv_localized];
            return;
        }
        if(!self.chatInfo.permissions.can_send_media_messages){//禁止媒体
            [UserInfo showTips:nil des:@"禁止发送媒体消息".lv_localized];
            return;
        }
        if (self.cusPermissionsModel.banSendQRcode) {//禁二维码
            for(UIImage *image in photos){
                BOOL isQRcode = [CZCommonTool isQRcodeImage:image];
                if (isQRcode) {
                    [UserInfo showTips:nil des:@"禁止发送二维码".lv_localized];
                    return;
                }
            }
        }
    }
    for (NSInteger index = 0; index < photos.count; index ++) {
        UIImage *image = photos[index];
        UIImage *toSendImage = [Common fixOrientation:image];
        NSString *path = [MNChatViewController localPhotoPath:toSendImage];
        if (!path) {
            continue;
        }
        if (self.fireMsgBtn.selected) {
            [[TelegramManager shareInstance] sendFirePhotoMessage:self.chatInfo._id localPath:path photoSize:toSendImage.size fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                if ([TelegramManager isResultError:response]) {//表示发送失败
                }
            } timeout:^(NSDictionary *request) {

            }];
            continue;
        }
        
        /// 不存在广告内容
        /// 存在广告内容，不为图文, 索引匹配
        /// 存在广告内容，不为图文, 索引不匹配
        /// 存在广告内容，为图文, 索引匹配
        /// 存在广告内容，为图文, 索引不匹配
        
        if (!self.isAdSend || (self.isAdSend && self.photoAdIndex != index)) {
            [[TelegramManager shareInstance] sendPhotoMessage:self.chatInfo._id localPath:path photoSize:toSendImage.size replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) { } timeout:^(NSDictionary *request) { }];
            continue;
        }
        /// 到此处为存在且索引匹配
        if (self.photoMarkup) {
            [[TelegramManager shareInstance] sendPhotoMessage:self.chatInfo._id localPath:path photoSize:toSendImage.size replyMarkup:self.photoMarkup resultBlock:^(NSDictionary *request, NSDictionary *response) {
                self.photoAdContent = nil;
            } timeout:^(NSDictionary *request) {
                self.photoAdContent = nil;
            }];
            continue;
        }
        /// 到此处为图文发送
        [TelegramManager.shareInstance sendPhotoTextMessage:self.chatInfo._id localPath:path photoSize:toSendImage.size text:self.photoAdContent resultBlock:^(NSDictionary *request, NSDictionary *response) {
            self.photoAdContent = nil;
        } timeout:^(NSDictionary *request) {
            self.photoAdContent = nil;
        }];
    }
}

- (void)sendImageMessage:(NSArray *)photos {
    [self sendPhotoMessage:photos];
}
//发送gif
- (void)sendGifPhotoMessage:(UIImage *)gifimage withPHAssetResource:(PHAssetResource *)resource
{
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    if(state == GroupMemberState_Administrator || state == GroupMemberState_Creator){
        //管理
    }else{
        if(!self.chatInfo.permissions.can_send_messages){//全体禁言
            [UserInfo showTips:nil des:@"全体禁言".lv_localized];
            return;
        }
    }
    UIImage *toSendImage = gifimage;
    [CZCommonTool saveGifImage:resource withImage:gifimage withblock:^(NSString * _Nonnull str) {
        if(str != nil)
        {
            //发送图片
            [[TelegramManager shareInstance] sendGifPhotoMessage:self.chatInfo._id localPath:str photoSize:toSendImage.size resultBlock:^(NSDictionary *request, NSDictionary *response) {
                if([TelegramManager isResultError:response])
                {//表示发送失败
                    
                }
            } timeout:^(NSDictionary *request) {
                
            }];
        }
    }];
}

//发送视频
- (void)sendVideoMessage:(UIImage *)coverImage video:(id)videoObj
{
    NSURL *tempPrivateFileURL = nil;
    if([videoObj isKindOfClass:[PHAsset class]])
    {
        PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:videoObj] firstObject];
        tempPrivateFileURL = [resource valueForKey:@"privateFileURL"];
    }
    else
    {
        tempPrivateFileURL = videoObj;
    }
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:tempPrivateFileURL options:nil];
    [UserInfo show:@"正在处理视频文件，请耐心等待".lv_localized];
    [MNChatViewController createVideoFileWithAVURLAssert:avAsset result:^(NSError *error, NSString *videoPath, CGSize videoSize, int duration) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UserInfo dismiss];
            if(error != nil)
            {
                [UserInfo showTips:nil des:error.domain];
            }
            else
            {
                if(coverImage != nil)
                {
                    //                    UIImage *toSendImage = [Common fixOrientation:coverImage];
                    //                    //缩略图-less than 200 KB in size
                    //                    //width & height usually shouldn't exceed 320
                    //                    toSendImage = [toSendImage resizedImageToFitInSize:CGSizeMake(250, 250) scaleIfSmaller:NO];
                    //                    toSendImage = [toSendImage compressImageToFileSizeKB:200];
                    //                    NSString *coverImagePath = [MNChatViewController localPhotoPath:toSendImage];
                    //                    if(coverImagePath != nil)
                    {
                        [self sendVideoMessage:nil videoPath:videoPath videoSize:videoSize duration:duration];
                    }
                }
                else
                {
                    [self sendVideoMessage:nil videoPath:videoPath videoSize:videoSize duration:duration];
                }
            }
        });
    }];
}

- (void)sendVideoMessage:(NSString *)coverImagePath videoPath:(NSString *)videoPath videoSize:(CGSize)videoSize duration:(int)duration
{
    if (self.fireMsgBtn.selected) {
        [[TelegramManager shareInstance] sendFireVideoMessage:self.chatInfo._id localCoverPath:coverImagePath localVideoPath:videoPath  videoSize:videoSize duration:duration fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response])
            {//表示发送失败
            }
        } timeout:^(NSDictionary *request) {
        }];
    }else{
        [[TelegramManager shareInstance] sendVideoMessage:self.chatInfo._id localCoverPath:coverImagePath localVideoPath:videoPath  videoSize:videoSize duration:duration resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response])
            {//表示发送失败
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

- (void)sendVoiceMessage:(NSString *)audioPath duration:(int)duration
{
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    if(state == GroupMemberState_Administrator || state == GroupMemberState_Creator){
        //管理
    }else{
        if(!self.chatInfo.permissions.can_send_messages){//全体禁言
            [UserInfo showTips:nil des:@"全体禁言".lv_localized];
            return;
        }
        if(!self.chatInfo.permissions.can_send_media_messages){//禁止媒体
            [UserInfo showTips:nil des:@"禁止发送媒体消息".lv_localized];
            return;
        }
    }
    
    if (self.fireMsgBtn.selected) {
        [[TelegramManager shareInstance] sendFireAudioMessage:self.chatInfo._id localAudioPath:audioPath duration:duration fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response])
            {//表示发送失败
            }
        } timeout:^(NSDictionary *request) {
        }];
    }else{
        [[TelegramManager shareInstance] sendVoiceMessage:self.chatInfo._id localAudioPath:audioPath duration:duration resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response])
            {//表示发送失败
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    
    

}

- (void)sendTextMessage
{
    
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    BOOL isGroupAdmin = (state == GroupMemberState_Administrator || state == GroupMemberState_Creator);
    if (!isGroupAdmin) {
        if (!self.chatInfo.permissions.can_send_messages) {//全体禁言
            [UserInfo showTips:nil des:@"全体禁言".lv_localized];
            return;
        }
    }
    NSString *text = self.inputTextView.text;
    if (text.length <= 0) {
        [UserInfo showTips:nil des:@"请输入消息内容".lv_localized];
        return;
    }
    
    NSArray *urlarr = [CZCommonTool getURLFromStr:text];
    /// 有链接 、不是管理员、禁止发送链接
    if (urlarr && urlarr.count > 0 && !isGroupAdmin && self.cusPermissionsModel.banSendWebLink) {
        [UserInfo showTips:nil des:@"禁止发送链接".lv_localized];
        return;
    }
    
    /// keysWords  有敏感词
    BOOL cansend = [CZCommonTool chatMessageContainsKeys:self.keysWords withmsg:text];
    if (!isGroupAdmin && cansend) {
        if (!self.cusPermissionsModel.kickWhoSendKeyword) {
            [UserInfo showTips:nil des:@"包含屏蔽敏感词,禁止发送".lv_localized];
            return;
        }
        /// 群组开启了敏感词被踢权限
        long chatId = [ChatInfo toServerPeerId:self.chatInfo._id];
        [UserInfo show];
        [TelegramManager.shareInstance kickedBySendSensitiveWordsInGroup:chatId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            [UserInfo dismiss];
            if ([obj boolValue]) {
                self.inputTextView.text = nil;
                if([AppConfigInfo sharedInstance].enabled_destroy_after_reading){
                    self.fireMsgBtn.hidden = NO;
                }
                self.inputTrailing.constant = 90;
                self.backinfo = nil;
                [CZCommonTool saveUserMsgdraftchatid:self.chatInfo._id saveArray:@[]];
                [CZCommonTool savedraftchatid:self.chatInfo._id saveString:@""];
                [self.selecteMembers removeAllObjects];
                [self closeQuoteClick];
                [self gotoBack];
                [UserInfo showTips:nil des:@"你因发送敏感词被踢出群聊".lv_localized];
            }
        } timeout:^(NSDictionary *request) { [UserInfo dismiss]; }];
        return;
    }
    
    [self resetInputContainerHeight];
    long replyid = 0;
    if (self.isQuote) {
        replyid = self.replyInfo._id;
    }
    
    /// 处理管理员发 `文字+按钮` 广告
    NSDictionary *replyMarkup = nil;
    if (isGroupAdmin) {
        NSArray *matchs = [self ADMsgMatchsFromText:text];
        /// 有规则内容
        if (matchs.count > 0) {
            NSString *temp = [self text:text forReplaceMatchs:matchs];
            /// 去掉规则后内容还存在 才可以发送广告
            if (temp.length > 0) {
                replyMarkup = [self ADReplyMarkup:matchs];
                text = temp;
            }
        }
    }
    
    if (self.fireMsgBtn.selected) {
        [[TelegramManager shareInstance] sendReadFireMessage:self.chatInfo._id Text:text CountDown:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    
        } timeout:^(NSDictionary *request) {
            
        }];
    } else {
        [[TelegramManager shareInstance] sendTextMessage:self.chatInfo._id replyid:replyid text:text withUserInfoArr:self.selecteMembers replyMarkup:replyMarkup resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response]){//表示发送失败
                
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }
    
    //发送后的UI处理
    self.inputTextView.text = nil;
    if([AppConfigInfo sharedInstance].enabled_destroy_after_reading){
        self.fireMsgBtn.hidden = NO;
    }
    self.inputTrailing.constant = 90;
    self.backinfo = nil;
    [CZCommonTool saveUserMsgdraftchatid:self.chatInfo._id saveArray:@[]];
    [CZCommonTool savedraftchatid:self.chatInfo._id saveString:@""];
    [self.selecteMembers removeAllObjects];
    [self closeQuoteClick];
}
#pragma mark - 发送名片
- (void)sendPersonCard:(id)chat {
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    if(state == GroupMemberState_Administrator || state == GroupMemberState_Creator){
        //管理
    }else{
        if(!self.chatInfo.permissions.can_send_messages){//全体禁言
            [UserInfo showTips:nil des:@"全体禁言".lv_localized];
            return;
        }
    }
    
    UserInfo *user = nil;
    if ([chat isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chatlin = (ChatInfo *)chat;
        user = [[TelegramManager shareInstance] contactInfo:chatlin.userId];
    } else if ([chat isKindOfClass:[UserInfo class]]) {
        user = chat;
    }
    
    [[TelegramManager shareInstance] requestOrgContactInfo:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:[OrgUserInfo class]])
        {
            [self sendContactWithRaw:obj withChat:chat];
        }
    } timeout:^(NSDictionary *request) {
    }];
    }

- (void)sendContactWithRaw:(OrgUserInfo *)obj withChat:(id)chat{
    if (self.fireMsgBtn.selected) {
        [[TelegramManager shareInstance] sendFireContentMessage:self.chatInfo._id withRwa:obj withChatInfo:chat fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response])
            {//表示发送失败
                NSLog(@"TelegramManager isResultError");
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }else{
        [[TelegramManager shareInstance] sendContentMessage:self.chatInfo._id withRwa:obj withChatInfo:chat resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if([TelegramManager isResultError:response])
            {//表示发送失败
                NSLog(@"TelegramManager isResultError");
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}

- (void)click_OnlineVideoOrVoice
{
    if([CallManager shareInstance].canNewCall && ![CallManager shareInstance].isInCalling)
    {
        __block NSInteger tag = -1;
        MMPopupItemHandler block = ^(NSInteger index) {
            tag = index;
        };
        NSArray *items = @[MMItemMake(@"视频通话".lv_localized, MMItemTypeNormal, block),
                           MMItemMake(@"语音通话".lv_localized, MMItemTypeNormal, block)];
        MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                              items:items];
        sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
            if(tag == 0)
            {//视频通话
                [self toOnlineVideoOrVoice:YES];
            }
            if(tag == 1)
            {//语音通话
                [self toOnlineVideoOrVoice:NO];
            }
        };
        [MMPopupWindow sharedWindow].touchWildToHide = YES;
        [sheetView show];
    }
    else
    {
        [UserInfo showTips:nil des:@"无法发起视频通话".lv_localized];
    }
}

- (void)toOnlineVideoOrVoice:(BOOL)isVideo
{
    if([self.chatInfo isGroup])
    {//群组
        //[[CallManager shareInstance] newCall:[LocalCallInfo new] fromView:self];
    }
    else
    {//单聊
        LocalCallInfo *call = [LocalCallInfo new];
        call.channelName = [Common generateGuid];
        call.from = [UserInfo shareInstance]._id;
        call.to = @[[NSNumber numberWithLong:self.chatInfo._id]];
        call.chatId = self.chatInfo._id;
        call.isVideo = isVideo;
        call.isMeetingAV = NO;
        call.callState = CallingState_Init;
        call.callTime = [NSDate new].timeIntervalSince1970;
        [[CallManager shareInstance] newCall:call fromView:self];
        
        //createOnlineAV
        //        [[TelegramManager shareInstance] sendCustomRequest:@"relayData" parameters:@"{\"action\":\"test\",\"from\":136817707,\"to\":[136817689],\"data\":{\"uid\":\"123\"}}" resultBlock:^(NSDictionary *request, NSDictionary *response) {
        //        } timeout:^(NSDictionary *request) {
        //        }];
        //[[CallManager shareInstance] newCall:call fromView:self];
        
        //        [[TelegramManager shareInstance] createRtcToken:call.channelName uid:[UserInfo shareInstance]._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        //        } timeout:^(NSDictionary *request) {
        //        }];
        
        //        CallBaseInfo *new_call = [CallBaseInfo new];
        //        new_call.channelName = [Common generateGuid];
        //        new_call.from = [UserInfo shareInstance]._id;
        //        new_call.to = @[[NSNumber numberWithLong:self.chatInfo._id]];z
        //        new_call.chatId = self.chatInfo._id;
        //        new_call.isVideo = isVideo;
        //        new_call.isMeetingAV = NO;
        //        [[TelegramManager shareInstance] createCall:new_call resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        //        } timeout:^(NSDictionary *request) {
        //        }];
    }
}

- (void)click_Hongbao
{
//    UIStoryboard *rp = [UIStoryboard storyboardWithName:@"RedPacket" bundle:nil];
    if(self.chatInfo.isGroup)
    {
//        CreateGroupRedPacketViewController *v = [rp instantiateViewControllerWithIdentifier:@"CreateGroupRedPacketViewController"];
//        v.hidesBottomBarWhenPushed = YES;
//        v.chatId = self.chatInfo._id;
//        [self.navigationController pushViewController:v animated:YES];
        MNGroupRedPacketVC *v = [[MNGroupRedPacketVC alloc] init];
       
        v.chatId = self.chatInfo._id;
        [self.navigationController pushViewController:v animated:YES];
        
    }
    else
    {
        
//        CreateP2pRedPacketViewController *v = [rp instantiateViewControllerWithIdentifier:@"CreateP2pRedPacketViewController"];
//        v.hidesBottomBarWhenPushed = YES;
//        v.chatId = self.chatInfo._id;
//        [self.navigationController pushViewController:v animated:YES];
        MNP2PRedPacketVC *v = [[MNP2PRedPacketVC alloc] init];
        v.chatId = self.chatInfo._id;
        [self.navigationController pushViewController:v animated:YES];
    }
}

#pragma mark 转账

- (void)click_transfer {
    TransferVC *transfer = [[TransferVC alloc] initWithChatId:self.chatInfo._id userid:self.chatInfo.userId type:TransferChatType_Single];
    [self.navigationController pushViewController:transfer animated:YES];
}

/// 转账消息状态变更
- (void)processTransferIfNeeded:(MessageInfo *)msg {
    if (msg.messageType != MessageType_Text_Transfer) {
        return;
    }
    NSInteger tId = msg.transferInfo.remittanceId;
    for (MessageInfo *m in self.messageList) {
        if (m.messageType == MessageType_Text_Transfer && m.transferInfo.remittanceId == tId) {
            [m.transferInfo fetchInfo];
        }
    }
}

- (void)transferMessageInfoChangedNoti:(NSNotification *)noti {
    NSInteger tId = [noti.object integerValue];
    NSArray *cells = self.tableView.visibleCells;
    if (cells.count == 0) {
        return;
    }
    for (UITableViewCell *cell in cells) {
        if (![cell isKindOfClass:MessageViewBaseCell.class]) {
            continue;
        }
        MessageViewBaseCell *mCell = (MessageViewBaseCell *)cell;
        if (mCell.chatRecordDTO.messageType != MessageType_Text_Transfer) {
            continue;
        }
        if (mCell.chatRecordDTO.transferInfo.remittanceId == tId) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:mCell];
            if (indexPath) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
            }
            return;
        }
    }
}

- (void)click_location
{//发送位置
//    LocationViewController *locationVC = [[LocationViewController alloc] initWithNibName:@"LocationViewController" bundle:nil];
//    locationVC.delegate = self;
//    [self.navigationController pushViewController:locationVC animated:YES];
    MNLocationViewController *vc = [[MNLocationViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)click_personal_card
{
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
    //    chooseView.toSendMsgsList = [self selectedMsgs];
    chooseView.type = 1;
    chooseView.hidesBottomBarWhenPushed = YES;
    chooseView.delegate = self;
    chooseView.sendChatInfo = self.chatInfo;
    [self.navigationController pushViewController:chooseView animated:YES];
}

- (void)click_file
{//发送文件
    [self presentViewController:self.documentPickerVC animated:YES completion:nil];
}

#pragma mark - 发送位置
- (void)SendCurrentLocation:(CLLocationCoordinate2D)centerCoordinate
{//发送位置
    if(self.fireMsgBtn.selected){
        [[TelegramManager shareInstance] sendFireLocationMessage:self.chatInfo._id latitude:centerCoordinate.latitude longitude:centerCoordinate.longitude fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
        }];
    }else{
        [[TelegramManager shareInstance] sendLocationMessage:self.chatInfo._id latitude:centerCoordinate.latitude longitude:centerCoordinate.longitude resultBlock:^(NSDictionary *request, NSDictionary *response) {
        } timeout:^(NSDictionary *request) {
        }];
    }
}

#pragma mark - 选择文件
- (UIDocumentPickerViewController *)documentPickerVC
{
    if (!_documentPickerVC)
    {
        NSArray *types = @[@"public.data"];
        self.documentPickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeOpen];
        // 设置代理
        _documentPickerVC.delegate = self;
        // 设置模态弹出方式
        _documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    return _documentPickerVC;
}


- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied)
    {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            // 读取文件
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error)
            {
                [UserInfo showTips:nil des:@"文件获取失败，请重试手机或者换个文件再试".lv_localized];
            }
            else
            {
                NSLog(@"%@", [Common bytesToAvaiUnit:fileData.length showDecimal:YES]);
                if(fileData.length>MAX_SEND_FILE_SIZE)
                {
                    [UserInfo showTips:nil des:[NSString stringWithFormat:@"文件大于%@，无法发送".lv_localized, [Common bytesToAvaiUnit:MAX_SEND_FILE_SIZE showDecimal:NO]]];
                }
                else
                {
                    //文件保存到当前沙盒中
                    NSString *org_fileName = [newURL lastPathComponent];
                    if(IsStrEmpty(org_fileName))
                    {
                        org_fileName = @"";
                    }
                    NSString *localFileName = [NSString stringWithFormat:@"%@_%@", [Common generateGuid], org_fileName];
                    NSString *localPath = [NSString stringWithFormat:@"%@/%@", UserFilePath([UserInfo shareInstance]._id), localFileName];
                    NSLog(@"org_fileName: %@, localPath:%@", org_fileName, localPath);
                    if([MNChatViewController writeFile2LocalFile:fileData path:localPath] != nil)
                    {
                        if (self.fireMsgBtn.selected) {
                            //发送文件
                            [[TelegramManager shareInstance] sendFireFileMessage:self.chatInfo._id realFileName:org_fileName localFilePath:localPath fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                            } timeout:^(NSDictionary *request) {
                            }];
                        }else{
                            //发送文件
                            [[TelegramManager shareInstance] sendFileMessage:self.chatInfo._id realFileName:org_fileName localFilePath:localPath resultBlock:^(NSDictionary *request, NSDictionary *response) {
                            } timeout:^(NSDictionary *request) {
                            }];
                        }
                    }
                    else
                    {
                        [UserInfo showTips:nil des:@"文件拷贝失败，请检查手机磁盘空间是否已满".lv_localized];
                    }
                }
            }
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
        [urls.firstObject stopAccessingSecurityScopedResource];
    }
}

#pragma mark - ModelPannelViewDelegate
- (void)ModelPannelView_Click_Model:(ChatModelType)type
{
    switch (type) {
        case ChatModelType_Photo:
            [self click_photo];
            break;
        case ChatModelType_Camera:
            [self click_camera];
            break;
        case ChatModelType_AVCall:
            [self click_OnlineVideoOrVoice];
            break;
        case ChatModelType_Hongbao:
            [self click_Hongbao];
            break;
        case ChatModelType_Transfer:
            [self click_transfer];
            break;
        case ChatModelType_File:
            [self click_file];
            break;
        case ChatModelType_Location:
            [self click_location];
            break;
        case ChatModelType_Card:
            [self click_personal_card];
            break;
        default:
            break;
    }
}

#pragma mark - about audio - RecordAudioDelegate
- (RecordAudio *)recordAudio
{
    if (nil == _recordAudio)
    {
        _recordAudio = [[RecordAudio alloc] init];
        _recordAudio.delegate = self;
    }
    return _recordAudio;
}

- (AudioAlertView *)audioAlertView
{
    if (nil == _audioAlertView)
    {
        CGRect frame = self.view.bounds;
        _audioAlertView = [[AudioAlertView alloc] initWithFrame:frame];
    }
    return _audioAlertView;
}

- (void)initAudioView
{
    //按下
    [self.audioBtn addTarget:self action:@selector(audioTouchDown:) forControlEvents:UIControlEventTouchDown];
    //按下内部抬起
    [self.audioBtn addTarget:self action:@selector(audioTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    //按下 外部抬起
    [self.audioBtn addTarget:self action:@selector(audioTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    //外部拖动
    [self.audioBtn addTarget:self action:@selector(audioTouchDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    //内部拖动
    [self.audioBtn addTarget:self action:@selector(audioTouchDragInside:) forControlEvents:UIControlEventTouchDragInside];
}

- (void)showNeedMicrophoneAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用麦克风".lv_localized message:@"请在iPhone的\"设置-隐私-麦克风\"中允许访问麦克风".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

//这个时候需要开始录音 设置AudioAlterView状态
- (void)audioTouchDown:(id)sender
{
    if ([PlayAudioManager sharedPlayAudioManager].isPlaying)
    {
        [[PlayAudioManager sharedPlayAudioManager] stopPlayAudio:NO];
    }
    
    __block MNChatViewController *bSelf = self;
    [RecordAudio testMicrophone:^(BOOL available, BOOL shouldIgnore) {
        if (shouldIgnore)
        {
            [bSelf startRecord];
        }
        else
        {
            if (available)
            {
                if (self.audioBtn.state == UIControlStateNormal)
                {
                    return;
                }
                [bSelf startRecord];
            }
            else
            {
                [self showNeedMicrophoneAlert];
            }
        }
    }];
}

- (void)startRecord
{
    [self.recordAudio beginRecord];
    self.recordAudioTimeOverFlag = NO;
    if (self.recordAudio.isRecording)
    {
        [self.audioBtn setTitle:@"松开发送".lv_localized forState:UIControlStateNormal];
        [self.audioAlertView setViewWithRecordStatus:RecordStatusIsRecording];
        [self.view addSubview:self.audioAlertView];
    }
}

//停止录音，检测时间，发送
- (void)audioTouchUpInside:(id)sender
{
    if (self.recordAudioTimeOverFlag == YES)
    {//超时后再抬起不用处理
        return;
    }
    [self.recordAudio stopRecord];
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    //少于1s的录音
    if (self.recordAudio.duration <= 1)
    {
        [self.audioAlertView setViewWithRecordStatus:RecordStatusTimeTooShort];
        self.audioBtn.enabled = NO;
        [self performSelector:@selector(handleTouchDownRepeat) withObject:nil afterDelay:1];
        return;
    }
    [self.audioAlertView  removeFromSuperview];
    
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.recordAudio.fileName];
    [self sendVoiceMessage:localPath duration:self.recordAudio.duration];
    //测试
    //self.recordAudio.duration
    //[[PlayAudioManager sharedPlayAudioManager] playAudio:localPath msgId:1];
}

//针对多次恶意点击的情况，将限制按钮的可用与否
- (void)handleTouchDownRepeat
{
    [self.audioAlertView removeFromSuperview];
    self.audioBtn.enabled = YES;
}

//取消操作，不需要检测时间以及发送
- (void)audioTouchUpOutside:(id)sender
{
    [self.recordAudio stopRecord];
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    [self.audioAlertView removeFromSuperview];
}

//手指在外部移动，更新AudioAlertView状态
- (void)audioTouchDragOutside:(id)sender
{
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    [self.audioAlertView setViewWithRecordStatus:RecordStatusWillCancelRecording];
}

- (void)audioTouchDragInside:(id)sender
{
    if (self.recordAudio.isRecording)
    {
        [self.audioBtn setTitle:@"松开发送".lv_localized forState:UIControlStateNormal];
    }
    [self.audioAlertView setViewWithRecordStatus:RecordStatusIsRecording];
}

- (void)timeRemained:(RecordAudio *)recordAudio remainedTime:(double)remainedTime
{
    [self.audioAlertView setViewWithRecordStatus:RecordStatusRecordingWillBeOver];
    self.audioAlertView.alertLabel.text = [NSString stringWithFormat:@"%@%ld%@", @"录音还剩".lv_localized, lround(remainedTime), @"秒".lv_localized];
}

- (void)timeIsOver:(RecordAudio*)recordAudio
{
    self.recordAudioTimeOverFlag = YES;
    [self.audioAlertView removeFromSuperview];
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.recordAudio.fileName];
    [self sendVoiceMessage:localPath duration:self.recordAudio.duration];
    //self.recordAudio.duration
    //[[PlayAudioManager sharedPlayAudioManager] playAudio:localPath msgId:1];
}

- (void)audioPlayStop:(NSNotification *)notification
{
    NSNumber *chatId = [notification object];
    if(chatId && [chatId isKindOfClass:[NSNumber class]])
    {
        if(self.chatInfo._id == chatId.longValue)
        {
            //刷新页面
            [self.tableView reloadData];
        }
    }
}

#pragma mark - 群公告相关
- (void)showGroupNotice:(BOOL)isMust
{
    long last_read_inbox_message_id = self.chatInfo.last_read_inbox_message_id;
    [[TelegramManager shareInstance] getChatPinnedMessage:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
            self.groupPinnedMessage = msg;
            [self.tableView reloadData];
            [TelegramManager parseMessageContent:[response objectForKey:@"content"] message:msg];
            [self autoDownloadAudio:msg];
            if(isMust)
            {
                [self showNotice:msg.description];
            }
            else
            {
                if(msg._id>last_read_inbox_message_id)
                {//群通知未看过
                    [self showNotice:msg.description];
                }
            }
        }
    } timeout:^(NSDictionary *request) {
    }];
}

- (void)showNotice:(NSString *)notice
{
    NSString *text = notice;
    if([text hasPrefix:GROUP_NOTICE_PREFIX])
    {
        text = [text substringFromIndex:GROUP_NOTICE_PREFIX.length];
    }
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, nil)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"群通知".lv_localized detail:text items:items];
    [view show];
}

#pragma mark - ChatEmojiViewDelegate
- (void)ChatEmojiView_Choose:(ChatEmojiView *)view emoji:(NSString *)emoji
{
    if(!IsStrEmpty(emoji))
    {
        [self.inputTextView insertText:emoji];
        [self resetInputContainerHeight];
    }
}

- (void)ChatCollectEmojiView_Choose:(AnimationInfo *)collectModel {
    if(NotNilAndNull(collectModel))
    {
        [[TelegramManager shareInstance] sendCollectGifPhotoMessage:self.chatInfo._id collectEmoji:collectModel resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if (![TelegramManager isResultError:response]) {
                
                
                
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}
- (void)ChatCollectEmojiView_Delete:(AnimationInfo *)collectModel {
    if(NotNilAndNull(collectModel))
    {
        [[TelegramManager shareInstance] removeSavedAnimation:collectModel.animation.remote._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if (![TelegramManager isResultError:response]) {
                
                [self getSavedAnimations];
                
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}

#pragma mark - message cell
- (void)showLastCell {
    [self.view layoutSubviews];
    
    [self tableVScrollToBottom];
}

- (void)tableVScrollToBottom {
    if (self.isScrollToBottomWithoutDelay) {
        self.scrollToBottomWithoutDelay = NO;
        [self scrollToBottom];
        return;
    }
    /// 原始代码为 0.5 秒延迟，具体原因不清楚
    /// 新增上述代码↑↑↑，解决首次进入页面短暂暂停后再滚动到底部
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToBottom];
        self.tableView.hidden = NO;
    });
}

- (void)scrollToBottom {
    if ([self isPrivateOffline]) {
        return;
    }
    NSInteger sectionCount = [self.tableView numberOfSections];
    if (sectionCount < 1) {
        return;
    }
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    NSArray<MessageInfo *> *messages = self.messageList.mutableCopy;
    if (messages.count == 0 || rows <= 0) {
        return;
    }
    __block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rows - 1 inSection:0];
    [messages enumerateObjectsUsingBlock:^(MessageInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 存在未读，则滚动到未读的位置
        if (obj._id > self.chatInfo.last_read_inbox_message_id && !obj.is_outgoing) {
            NSInteger index = idx;
            if (self.isDisplayEncryptionTip) {
                index ++;
            }
            indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            *stop = YES;
        }
    }];
    if (rows > indexPath.row) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    [self prepareToPlay];
}

#pragma mark - MessageViewBaseCellDelegate
- (BOOL)isGroupChat
{
    return self.chatInfo.isGroup;
}

- (BOOL)canManageSomeone:(MessageViewBaseCell *)cell
{
    if(self.chatInfo.isGroup)
    {
        if(self.chatInfo.isSuperGroup)
        {
            if(self.super_groupInfo.status.getMemberState == GroupMemberState_Administrator)
            {
                //不可以禁言管理员和创建者
                if(self.memberIsManagersList.count>0)
                {
                    BOOL isAdmin = NO;
                    for(GroupMemberInfo *info in self.memberIsManagersList)
                    {
                        if(info.user_id == cell.chatRecordDTO.sender.user_id)
                        {
                            isAdmin = YES;
                            break;
                        }
                    }
                    if(!isAdmin)
                    {
                        return YES;
                    }
                }
            }
            if(self.super_groupInfo.status.getMemberState == GroupMemberState_Creator)
            {
                if(self.super_groupInfo.status.is_member)
                {//群组创建者可以禁言任何人
                    return YES;
                }
            }
        }
        else
        {
            //普通群组不支持禁言某人
            //            if(self.groupInfo.is_active)
            //            {
            //                if(self.groupInfo.status.getMemberState == GroupMemberState_Administrator)
            //                {
            //                    return YES;
            //                }
            //                if(self.groupInfo.status.getMemberState == GroupMemberState_Creator)
            //                {
            //                    if(self.groupInfo.status.is_member)
            //                    {
            //                        return YES;
            //                    }
            //                }
            //            }
        }
    }
    return NO;
}

- (void)messageCellWillBan:(MessageViewBaseCell *)cell
{//禁言此人
    [UserInfo show];
    [[TelegramManager shareInstance] banMemberFromSuperGroup:self.chatInfo._id member:cell.chatRecordDTO.sender.user_id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"禁言失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:@"已禁言".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"禁言失败，请稍后重试".lv_localized];
    }];
}

- (void)messageCellWillDelOneHis:(MessageViewBaseCell *)cell
{//删除此人某条消息
    
}

- (void)messageCellWillDelAllHis:(MessageViewBaseCell *)cell
{//删除此人所有消息
    [UserInfo show];
    [[TelegramManager shareInstance] delAllHisMessagesFromSuperGroup:self.chatInfo._id member:cell.chatRecordDTO.sender.user_id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:@"已删除此人发送的所有消息".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除失败，请稍后重试".lv_localized];
    }];
}

- (void)messageCellWillTransferMessage:(MessageViewBaseCell *)cell{
    
    __block MessageInfo *message = cell.chatRecordDTO;
    BOOL isdownLoad = message.content.audio.isAudioDownloaded;
    if (!isdownLoad) {
        [UserInfo showTips:nil des:@"音频文件还没下载完成，请稍后再试".lv_localized];
        return;
    }
    NSString *path = message.content.audio.localAudioPath;
    if (!path) {
        [UserInfo showTips:nil des:@"音频文件还没下载完成，请稍后再试".lv_localized];
        return;
    }
    __block AudioMessageCell *audioC = (AudioMessageCell *)cell;
    [audioC startActivityAnimating:YES];
    __block VoiceTransferTool *transfer = [[VoiceTransferTool alloc] init];
    self.transfer = transfer;
    [transfer transferInPath:path success:^(NSArray<TransferResModel *> *response, NSString *text) {
        [audioC startActivityAnimating:NO];
        if (IsStrEmpty(text)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UserInfo showTips:nil des:@"语音内容解析错误".lv_localized];
            });
        } else {
            message.msg_cell_height = 0;
            message.content.audio.transferText = text;
            message.content.audio.showTransfer = YES;
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [audioC startActivityAnimating:NO];
        if (transfer.isCanceled) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [UserInfo showTips:self.view des:@"语音转换失败，请稍后再试".lv_localized];
        });
        
    }];
}

- (void)messageCellWillTranslateMessage:(MessageViewBaseCell *)cell{
    
    __block MessageInfo *message = cell.chatRecordDTO;
    __block TextMessageCell *textC = (TextMessageCell *)cell;
    [textC startActivityAnimating:YES];
    
    [XFTextTranslateRequest translateText:message.textTypeContent success:^(NSString *text) {
        [textC startActivityAnimating:NO];
        if (IsStrEmpty(text)) {
            [UserInfo showTips:nil des:@"翻译失败，请稍后再试".lv_localized];
        } else {
            message.msg_cell_height = 0;
            message.translateText = text;
            message.showTranslate = YES;
            [self.tableView reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        [textC startActivityAnimating:NO];
        [UserInfo showTips:nil des:@"翻译失败，请稍后再试".lv_localized];
    }];
    
    
}

/**
 *  他人的头像被点击的回调
 */
- (void)messageCell:(MessageViewBaseCell *)cell someoneHeadPhotoWasTapped:(long)userId
{
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId];
    [self previewUserDetails:user];
}



/**
 *  我的头像被点击
 */
- (void)messageCellMyHeadPhotoWasTapped:(MessageViewBaseCell *)cell
{
    [self gotoMyInfoIfNeeded:UserInfo.shareInstance];
}

//点击引用  滚动到指定的cell
- (void)quoteMsgClickWithCell:(MessageViewBaseCell *)cell{
    [self getQuoteMessageAndJump:cell.chatRecordDTO.reply_to_message_id];
}

- (void)messageCell:(MessageViewBaseCell *)cell shouldAtSomeone:(long)userId
{
    UserInfo *user = [[[TelegramManager shareInstance] contactInfo:userId] copy];
    if(user != nil && self.chatInfo.permissions.can_send_messages)
    {
        for (GroupMemberInfo *m in self.membersList) {
            if (m.user_id == user._id && [NSString xhq_notEmpty:m.nickname]) {
                user.groupNickname = m.nickname;
                break;
            }
        }
        [self.selecteMembers addObject:user];
        [self.inputTextView insertText:[NSString stringWithFormat:@"@%@ ", user.displayName]];
        [self resetInputContainerHeight];
    }
}

/**
 *  消息重发
 */
- (void)messageCellWillResend:(MessageViewBaseCell *)cell
{
    if(cell.chatRecordDTO.messageType == MessageType_Text)
    {//文本重发
        [[TelegramManager shareInstance] reSendMessage:self.chatInfo._id ids:@[[NSNumber numberWithLong:cell.chatRecordDTO._id]] resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if(![TelegramManager isResultError:response])
            {
                [self deleteMsg:cell.chatRecordDTO._id isRefresh:YES];
            }
            else
            {
                [UserInfo showTips:nil des:@"消息重发失败".lv_localized errorMsg:[TelegramManager errorMsg:response]];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
    //其它待完成
}

- (void)messageCellWillDeleteMessage:(MessageViewBaseCell *)cell
{//单条消息删除
    MMPopupItemHandler block = nil;
    NSArray *items = nil;
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if(self.chatInfo.isGroup){//群组
        block = ^(NSInteger index){
            [self deleteSuperGroupMessage:@[[NSNumber numberWithLong:cell.chatRecordDTO._id>>20]]];
        };
        items = @[
            MMItemMake(@"仅为我删除".lv_localized, MMItemTypeNormal, block)
        ];
    }else if(isMyFov){//收藏
        block = ^(NSInteger index){
            [self deleteMessageRequest:@[[NSNumber numberWithLong:cell.chatRecordDTO._id]] isRevoke:NO];
        };
        items = @[
            MMItemMake(@"仅为我删除".lv_localized, MMItemTypeNormal, block)
        ];
    }else{//单聊
        block = ^(NSInteger index){
            NSLog(@"index : %ld",index);
            if (index == 0) {
                [self deleteMessageRequest:@[[NSNumber numberWithLong:cell.chatRecordDTO._id]] isRevoke:YES];
            }else if(index == 1){
                [self deleteMessageRequest:@[[NSNumber numberWithLong:cell.chatRecordDTO._id]] isRevoke:NO];
            }
        };
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.userId];
        if(user != nil)
        {
            items = @[
                MMItemMake([NSString stringWithFormat:@"为我和%@删除".lv_localized,user.displayName], MMItemTypeNormal, block),
                MMItemMake(@"仅为我删除".lv_localized, MMItemTypeNormal, block)
            ];
        }
    }
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)click_deledate
{
    MMPopupItemHandler block = ^(NSInteger index){
        if(index == 0)
        {//拍照
            [self click_camera];
        }
        if(index == 1)
        {//从手机相册选择
            [self click_photo];
        }
    };
    NSArray *items =
    @[MMItemMake(@"拍照".lv_localized, MMItemTypeNormal, block),
      MMItemMake(@"从手机相册选择".lv_localized, MMItemTypeNormal, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                          items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)messageCellWillRevokeMessage:(MessageViewBaseCell *)cell
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定撤销这条消息吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//撤销
            [self deleteMessageRequest:@[[NSNumber numberWithLong:cell.chatRecordDTO._id]] isRevoke:YES];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)deleteMessages:(NSArray *)msgs
{//单条消息删除
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定删除这些消息吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//删除
            //退出多选模式
            [self click_cancelMultiSelectedMode];
            //执行具体逻辑
            if(!self.chatInfo.isSuperGroup)
            {
                NSMutableArray *ids = [NSMutableArray array];
                for(MessageInfo *msg in msgs)
                {
                    [ids addObject:[NSNumber numberWithLong:msg._id]];
                }
                [self deleteMessageRequest:ids isRevoke:NO];
            }
            else
            {
                NSMutableArray *ids = [NSMutableArray array];
                for(MessageInfo *msg in msgs)
                {
                    [ids addObject:[NSNumber numberWithLong:msg._id>>20]];
                }
                [self deleteSuperGroupMessage:ids];
            }
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)revokeMessages:(NSArray *)msgs
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定撤销这些消息吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//撤销
            //退出多选模式
            [self click_cancelMultiSelectedMode];
            //执行具体逻辑
            NSMutableArray *ids = [NSMutableArray array];
            for(MessageInfo *msg in msgs)
            {
                [ids addObject:[NSNumber numberWithLong:msg._id]];
            }
            [self deleteMessageRequest:ids isRevoke:YES];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)deleteSuperGroupMessage:(NSArray *)ids
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteSuperGroupMessage:[ChatInfo toServerPeerId:self.chatInfo._id] msgIds:ids resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        [UserInfo dismiss];
        if(![obj boolValue])
        {
            [UserInfo showTips:nil des:@"删除失败，请稍后重试".lv_localized];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除失败，请稍后重试".lv_localized];
    }];
}

- (void)deleteMessageRequest:(NSArray *)ids isRevoke:(BOOL)isRevoke
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteMessage:self.chatInfo._id msgIds:ids revoke:isRevoke resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除失败，请稍后重试".lv_localized];
    }];
}

/**
 *  转发回调，即长按菜单选择了转发消息
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellWillForwardMessage:(MessageViewBaseCell *)cell
{
    if (cell.chatRecordDTO.isAdMessage) {
        MMPopupItemHandler block = ^(NSInteger index) {
            [self ChatChooseViewController_Chat_Choose:self.chatInfo msg:@[cell.chatRecordDTO]];
        };
        NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block),
                           MMItemMake(@"取消".lv_localized, MMItemTypeNormal, nil)];
        MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:@"是否要在本群中转发当前消息？".lv_localized items:items];
        [view show];
        return;
    }
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
    chooseView.toSendMsgsList = @[cell.chatRecordDTO];
    chooseView.hidesBottomBarWhenPushed = YES;
    chooseView.delegate = self;
    [self.navigationController pushViewController:chooseView animated:YES];
}

//引用 - 调用
- (void)messageCellWillQuoteMessage:(MessageViewBaseCell *)cell{
    if (!self.audioBtn.hidden) {//语音模式
        [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
        self.audioBtn.hidden = YES;
        self.inputTextView.hidden = NO;
        [self.inputTextView becomeFirstResponder];
        [self resetInputContainerHeight];
    }
    self.replyInfo = cell.chatRecordDTO;
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:cell.chatRecordDTO.sender.user_id];
    NSString *username = user.displayName;
    for (GroupMemberInfo *m in self.membersList) {
        if (m.user_id == user._id && [NSString xhq_notEmpty:m.nickname]) {
            username = m.nickname;
            break;
        }
    }
    self.quateLabel.text = [NSString stringWithFormat:@"%@:%@", username, cell.chatRecordDTO.description];
    
    self.isQuote = YES;
    [self settingQuoteStyle:YES];
}

/**
 *  收藏
 */
- (void)messageCellWillFavorMessage:(MessageViewBaseCell *)cell
{
    //
    //退出多选模式
    [self click_cancelMultiSelectedMode];
    [[TelegramManager shareInstance] forwardMessage:[UserInfo shareInstance]._id msgs:@[cell.chatRecordDTO]];
    [UserInfo showTips:nil des:@"已收藏".lv_localized];
    
    
}

/**
 *  需要播放语音的代理
 *
 *  @param cell 语音所在cell
 */
- (void)messageCellShouldStartPlayAudio:(MessageViewBaseCell *)cell
{
    //
    MessageInfo *msg = cell.chatRecordDTO;
    if(msg.messageType == MessageType_Audio)
    {//语音消息
        AudioInfo *audioInfo = msg.content.audio;
        if(audioInfo != nil)
        {
            if(!audioInfo.isAudioDownloaded)
            {//未下载，启动下载
                [UserInfo showTips:nil des:@"语音下载中...".lv_localized];
                if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.audio._id type:FileType_Message_Audio]
                   && audioInfo.audio.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.audio._id download_offset:0 type:FileType_Message_Audio];
                }
            }
            else
            {//播放
                [[PlayAudioManager sharedPlayAudioManager] playAudio:msg.content.audio.localAudioPath chatId:self.chatInfo._id msgId:msg._id];
                [self.tableView reloadData];
            }
        }
    }else if(msg.messageType == MessageType_Voice)
    {//语音消息
        VoiceInfo *audioInfo = msg.content.voice_note;
        if(audioInfo != nil)
        {
            if(!audioInfo.isAudioDownloaded)
            {//未下载，启动下载
                [UserInfo showTips:nil des:@"语音下载中...".lv_localized];
                if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.voice._id type:FileType_Message_Voice]
                   && audioInfo.voice.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.voice._id download_offset:0 type:FileType_Message_Voice];
                }
            }
            else
            {//播放
                [[PlayAudioManager sharedPlayAudioManager] playAudio:msg.content.voice_note.localAudioPath chatId:self.chatInfo._id msgId:msg._id];
                [self.tableView reloadData];
            }
        }
    }

}

/**
 *  需要停止播放语音的代理
 *
 *  @param cell 语音所在cell
 */
- (void)messageCellShouldStopPlayAudio:(MessageViewBaseCell *)cell
{
    if ([PlayAudioManager sharedPlayAudioManager].isPlaying)
    {
        [[PlayAudioManager sharedPlayAudioManager] stopPlayAudio:NO];
    }
    [self.tableView reloadData];
}

/**
 *  点击了图片的代理
 *
 *  @param cell 图片所在cell
 */
- (void)messageCellShouldShowImage:(MessageViewBaseCell *)cell
{
    [self previewMediaOnSelectedCell:cell isVideo:NO];
//    NSArray *list = [self getCurrentPhotoList];
//    int curIndex = (int)[list indexOfObject:cell.chatRecordDTO];
//    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
//
//    v.previewList = list;
//    v.curIndex = curIndex;
//    v.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:v animated:YES];
}

//gif
- (void)messageCellShouldShowAnimation:(MessageViewBaseCell *_Nullable)cell{
    [self previewMediaOnSelectedCell:cell isVideo:NO];
//    NSLog(@"gif点击");
//    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
//
//    v.previewList = @[cell.chatRecordDTO];
//    v.curIndex = 0;
//    v.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:v animated:YES];
}
/**
 *  点击了视频的代理
 *
 *  @param cell 图片所在cell
 */
- (void)messageCellShouldShowVideo:(MessageViewBaseCell *)cell {
    [self previewMediaOnSelectedCell:cell isVideo:YES];
}
//添加表情
- (void)messageCellAddEmoji:(MessageViewBaseCell *)cell {
    [[TelegramManager shareInstance] addSavedAnimation:cell.chatRecordDTO.content.animation.animation.remote._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if([TelegramManager isResultError:response])
        {//表示收藏失败
            NSLog(@"TelegramManager isResultError");
            [UserInfo showTips:nil des:@"添加表情失败".lv_localized];
        } else {
            [UserInfo showTips:nil des:@"已添加表情".lv_localized];
            [self getSavedAnimations];
        }
    } timeout:^(NSDictionary *request) {
        NSLog(@"%@", @"请求超时".lv_localized);
    }];
}


/**
 *  点击了call的代理
 */
- (void)messageCellShouldCall:(MessageViewBaseCell *)cell
{
    [self toOnlineVideoOrVoice:cell.chatRecordDTO.callInfo.isVideo];
}

/**
 *  点击了文件的代理
 *
 *  @param cell 红包所在cell
 */
- (void)messageCellShouldOpenFile:(MessageViewBaseCell *)cell
{
    NSString *fileName = cell.chatRecordDTO.content.document.file_name;
    if([DocumentInfo isImageFile:fileName])
    {//图片文件
        PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
        v.previewList = @[cell.chatRecordDTO];
        v.curIndex = 0;
        v.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:v animated:YES];
    }
    else if([DocumentInfo isVideoFile:fileName])
    {//视频文件
        PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
        v.previewList = @[cell.chatRecordDTO];
        v.curIndex = 0;
        v.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:v animated:YES];
    }
    else
    {//文件浏览器
        FilePreviewViewController *vc = [[FilePreviewViewController alloc] initWithNibName:@"FilePreviewViewController" bundle:nil];
        vc.previewMessage = cell.chatRecordDTO;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/**
 *  点击了位置的代理
 *
 *  @param cell 位置所在cell
 */
- (void)messageCellShouldShowLocation:(MessageViewBaseCell *)cell
{
    //todo libiao
//    LocationNavigationViewController *VC = [[LocationNavigationViewController alloc] initWithNibName:@"LocationNavigationViewController" bundle:nil];
//    CLLocationCoordinate2D locationCoordinate;
//    locationCoordinate.latitude = cell.chatRecordDTO.content.location.latitude;
//    locationCoordinate.longitude =  cell.chatRecordDTO.content.location.longitude;
//    VC.locationCoordinate = locationCoordinate;
//    VC.chatRecordDTO = cell.chatRecordDTO;
//    [self.navigationController pushViewController:VC animated:YES];
    
    MNLocationNavigationVC *VC = [[MNLocationNavigationVC alloc] init];
    CLLocationCoordinate2D locationCoordinate;
    locationCoordinate.latitude = cell.chatRecordDTO.content.location.latitude;
    locationCoordinate.longitude =  cell.chatRecordDTO.content.location.longitude;
    VC.locationCoordinate = locationCoordinate;
    VC.chatRecordDTO = cell.chatRecordDTO;
    [self.navigationController pushViewController:VC animated:YES];
    
}

/**
 *  选择了某个特殊的文本
 */
- (void)messageCell:(MessageViewBaseCell *)cell didSelectedTextUnit:(TextUnit *)textUnit
{
    switch (textUnit.textUnitType)
    {
        case TextUnitTypeURL:
            //链接
        {
            NSString *url = textUnit.originalContent;
            if ([url containsString:@"joinchat"]) {
                NSString *invitelink = [[UserInfo shareInstance] userIdFromInvitrLink:[NSURL URLWithString:url]];
                if(invitelink && invitelink.length > 5){
                    //链接进群
                    [UserInfo shareInstance].inviteLink = invitelink;
                    [((AppDelegate*)([UIApplication sharedApplication].delegate)) addGroupWithInviteLink];
                }
            }else{
                if(![url hasPrefix:@"https://"] && ![url hasPrefix:@"http://"])
                {
                    url = [NSString stringWithFormat:@"http://%@", url];
                }
                BaseWebViewController *v = [BaseWebViewController new];
                v.hidesBottomBarWhenPushed = YES;
                v.titleString = @"";
                v.urlStr = url;
                v.type = WEB_LOAD_TYPE_URL;
                [self.navigationController pushViewController:v animated:YES];
            }
        }
            break;
        case TextUnitTypeEmail:
            //邮箱
        {
            if ([MFMailComposeViewController canSendMail])
            {
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[textUnit.originalContent]];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
        }
            break;
        case TextUnitTypePhoneNumber:
            //电话号码
        {
            NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"tel:%@", textUnit.originalContent];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
        }
            break;
        case TextUnitTypeSomeone:
            //@某人
        {
            UserInfo *user = textUnit.selUserInfo;
            [self previewUserDetails:user];
        }
            break;
        case TextUnitTypeTransferRemind:
            [self messageCellShouldShowTransferInfo:cell];
            break;
        default:
            break;
    };
}

- (BOOL)messageCell_Outing_Message_IsRead:(MessageViewBaseCell *)cell
{
    return cell.chatRecordDTO._id<=self.chatInfo.last_read_outbox_message_id;
}

- (void)messageCellShouldShowTransferInfo:(MessageViewBaseCell *)cell {
    TransferInfoVC *info = [[TransferInfoVC alloc] init];
    info.transfer = cell.chatRecordDTO.transferInfo.transfer;
    [self.navigationController pushViewController:info animated:YES];
    info.transferStateChanged = ^{
        [self.tableView reloadData];
    };
}

- (void)messageCellShouldOpenRedPacket:(MessageViewBaseCell *)cell
{//红包
    MessageInfo *msg = cell.chatRecordDTO;
    if(msg.rpInfo != nil)
    {
        [UserInfo show];
        [[TelegramManager shareInstance] queryRp:msg.rpInfo.redPacketId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            [UserInfo dismiss];
            if(obj != nil && [obj isKindOfClass:[RedPacketInfo class]])
            {
                [self dealRp:obj];
            }
            else
            {
                [UserInfo showTips:nil des:@"红包信息获取失败".lv_localized];
            }
        } timeout:^(NSDictionary *request) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"红包信息获取失败".lv_localized];
        }];
    }
    
}

- (void)dealRp:(RedPacketInfo *)rp
{
    RpState state = [rp getRpState];
    if(state == RpState_To_Get){//待领取
        //不记录
    }else{//记录点击  置灰
        NSDictionary *dic = @{
            @"redPacketId" : @(rp.redPacketId),
            @"RpState" : @(state),
            @"type" : @(rp.type)
        };
        [CZCommonTool saveGreyRedpadID:dic];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    if(rp.type == 1){//单聊红包
        if(rp.from == [UserInfo shareInstance]._id)
        {
            [self rpDetailView:rp];
        }
        else
        {
            RpState state = [rp getRpState];
            if(state == RpState_Got || state == RpState_GotADone)
            {//已领取
                [self rpDetailView:rp];
            }
            else
            {//未领取
                GotRpDialog *dialog = [[GotRpDialog alloc] initDialog:rp];
                dialog.delegate = self;
                [dialog show];
            }
        }
    }
    else
    {
        RpState state = [rp getRpState];
        if(rp.from == [UserInfo shareInstance]._id)
        {
            if(state == RpState_To_Get)
            {
                GotRpDialog *dialog = [[GotRpDialog alloc] initDialog:rp];
                dialog.delegate = self;
                [dialog show];
            }
            else
            {
                [self rpDetailView:rp];
            }
        }
        else
        {
            if(state == RpState_Got || state == RpState_GotADone)
            {
                [self rpDetailView:rp];
            }
            else
            {
                GotRpDialog *dialog = [[GotRpDialog alloc] initDialog:rp];
                dialog.delegate = self;
                [dialog show];
            }
        }
    }
}

- (void)rpDetailView:(RedPacketInfo *)rp
{
    UIStoryboard *rpSb = [UIStoryboard storyboardWithName:@"RedPacket" bundle:nil];
    RedPacketDetailViewController *v = [rpSb instantiateViewControllerWithIdentifier:@"RedPacketDetailViewController"];
    v.rpInfo = rp;
    v.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:v animated:YES];
}

#pragma mark - 预览媒体【图片、视频、Gif】
- (void)previewMediaOnSelectedCell:(MessageViewBaseCell *)cell isVideo:(BOOL)isVideo {
    NSArray *list = [self getCurrentPreviewLists];
    int curIndex = (int)[list indexOfObject:cell.chatRecordDTO];
    PhotoAVideoPreviewPagesViewController *v = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PhotoAVideoPreviewPagesViewController"];
    
    if (isVideo) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (self.player.playingIndexPath != indexPath) {
            [self.player stopCurrentPlayingCell];
        }
        v.previewPopCallback = ^{
            if (!self.player.currentPlayerManager.isPlaying) {
                [self playTheVideoAtIndexPath:indexPath scrollAnimated:NO];
            }
            if ([cell isKindOfClass:VideoMessageCell.class]) {
                [((VideoMessageCell *)cell) reloadVideoInfo:cell.chatRecordDTO.content.video];
            }
        };
    }
    
    v.previewList = list;
    v.curIndex = curIndex;
    v.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:v animated:YES];
    
}

- (NSArray *)getCurrentPreviewLists {
    NSMutableArray *list = [NSMutableArray array];
    NSArray *types = @[@(MessageType_Photo), @(MessageType_Video), @(MessageType_Animation)];
    for (MessageInfo *msg in self.messageList) {
        if ([types containsObject:@(msg.messageType)]) {
            [list addObject:msg];
        }
    }
    return list;
}

#pragma mark - 查看名片详情
- (void)personalCard:(MessageInfo *)chatRecordDTO {
    NSDictionary *dict = [chatRecordDTO.content.contact mj_JSONObject];
    //NSString *userId = nil;
    long userId = 0;
    if (NotNilAndNull(dict)) {
        userId = [dict[@"user_id"]longLongValue];
    }
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId];
    if(user != nil)
    {
        if ([self gotoMyInfoIfNeeded:user]) {
            return;
        }
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
    } else {
        
        [[TelegramManager shareInstance] requestContactInfo:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:UserInfo.class])
            {
                UserInfo *usernew = obj;
                if(usernew == nil){
                    [UserInfo showTips:nil des:@"用户不存在".lv_localized];
                    return;
                }
                if ([self gotoMyInfoIfNeeded:user]) {
                    return;
                }
//                MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//                v.user = usernew;
//                [self.navigationController pushViewController:v animated:YES];
                
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
        } timeout:^(NSDictionary *request) {
        }];
        
    }
}

#pragma mark 查看用户页面
- (void)previewUserDetails:(UserInfo *)user {
    if (!user) {
        return;
    }
    /// 群组禁止单聊时，普通成员无法点击用户头像 22-01-07
    BOOL isGroupChat = (self.chatInfo.isSuperGroup && self.super_groupInfo);
    BOOL isGroupAdmin = [@[@(GroupMemberState_Administrator), @(GroupMemberState_Creator)] containsObject:@(self.super_groupInfo.status.getMemberState)];
    /// 是群组 不是管理员 群组禁止私聊
    if (isGroupChat && !isGroupAdmin && self.cusPermissionsModel.banWhisper) {
        return;
    }
    if ([self gotoMyInfoIfNeeded:user]) {
        return;
    }
//    MNContactDetailVC *v = [[MNContactDetailVC alloc] init];
//    v.user = user;
//    if (isGroupChat && isGroupAdmin) {
//        /// 可以查看进群方式
//        v.toShowInvidePath = YES;
//        v.chatId = self.chatInfo._id;
//    } else {//普通成员，是否禁止单聊、互发消息
//        v.blockContact = self.cusPermissionsModel.banWhisper;
//    }
//    [self.navigationController pushViewController:v animated:YES];
    
    if (user.is_contact){
        QTGroupPersonInfoVC *vc = [[QTGroupPersonInfoVC alloc] init];
        vc.user = user;
        if (isGroupChat && isGroupAdmin) {
            /// 可以查看进群方式
            vc.toShowInvidePath = YES;
            vc.chatId = self.chatInfo._id;
        } else {//普通成员，是否禁止单聊、互发消息
            vc.blockContact = self.cusPermissionsModel.banWhisper;
        }
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        QTAddPersonVC *vc = [[QTAddPersonVC alloc] init];
        vc.user = user;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

/// 查看自己信息
- (BOOL)gotoMyInfoIfNeeded:(UserInfo *)user {
    if (user._id != UserInfo.shareInstance._id) {
        return NO;
    }
    GC_MyInfoVC *info = [[GC_MyInfoVC alloc] init];
    [self.navigationController pushViewController:info animated:YES];
    return YES;
}

#pragma mark - 发送名片
- (void)ChatChooseViewController_PersonalCard_Choose:(id)chat {
    [self sendPersonCard:chat];
}


#pragma mark - 多选模式
- (ChatMultiSelOptToolView *)multiSelOptView
{
    if(_multiSelOptView == nil)
    {
        _multiSelOptView = [[[NSBundle mainBundle] loadNibNamed:@"ChatMultiSelOptToolView" owner:self options:nil] objectAtIndex:(!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id)?0:1];
        _multiSelOptView.delegate = self;
        _multiSelOptView.chatInfo = self.chatInfo;
    }
    return _multiSelOptView;
}

- (void)resetMultiOptState
{
    int canForwordCnt = 0;
    int canFovCnt = 0;
    int canRevoke = 0;
    int canDelete = 0;
    for(MessageInfo *msg in self.messageList)
    {
        if(msg.isSelected)
        {
            canForwordCnt++;
            canFovCnt++;
            canDelete++;
            if(self.chatInfo.isGroup)
            {
                if(msg.is_outgoing)
                {
                    canRevoke++;
                }
            }
            else
            {
                canRevoke++;
            }
        }
    }
    self.multiSelOptView.forwordBtn.enabled = canForwordCnt>0;
    self.multiSelOptView.fovBtn.enabled = canFovCnt>0;
    self.multiSelOptView.revokeBtn.enabled = canRevoke>0 && canRevoke==canDelete;
    self.multiSelOptView.delBtn.enabled = canDelete>0;
}

/**
 *  进入多选模式
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellWillGotoMultiSelectingMode:(MessageViewBaseCell *)cell
{
    if(!self.isMultiSelectedMode)
    {
        for(MessageInfo *msg in self.messageList)
        {
            msg.isSelected = NO;
        }
        cell.chatRecordDTO.isSelected = YES;
        self.isMultiSelectedMode = YES;
        [self.tableView reloadData];
        [self resetNavBar];
        
        //opt bar
        [self.inputTextView resignFirstResponder];
        self.orgInputHeight = self.inputContainerViewHeight.constant;
        self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
        self.multiSelOptView.frame = self.inputContainerView.bounds;
        [UIView transitionWithView:self.inputContainerView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^ { [self.inputContainerView addSubview:self.multiSelOptView]; }
                        completion:nil];
        [self resetMultiOptState];
    }
}

//关闭多选模式
- (void)click_cancelMultiSelectedMode
{
    if(self.isMultiSelectedMode)
    {
        self.isMultiSelectedMode = NO;
        [self.tableView reloadData];
        [self resetNavBar];
        
        //opt bar
        self.inputContainerViewHeight.constant = self.orgInputHeight;
        [UIView transitionWithView:self.inputContainerView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^ { [self.multiSelOptView removeFromSuperview]; }
                        completion:nil];
    }
}

/**
 *  是否多选模式-touch屏蔽使用
 */
- (BOOL)messageCellIsMultiSelectingMode
{
    return self.isMultiSelectedMode;
}

/**
 *  是否可以进入多选模式
 *
 *  @param cell 消息所在cell
 */
- (BOOL)messageCellIsCanGotoMultiSelectingMode:(MessageViewBaseCell *)cell
{
    return [cell isKindOfClass:[MessageBubbleCell class]];
}

/**
 *  选择变化事件
 *
 *  @param cell 消息所在cell
 */
- (void)messageCellSelectChanged:(MessageViewBaseCell *)cell
{
    if(cell && cell.chatRecordDTO)
    {
        if(!cell.chatRecordDTO.isSelected)
        {//未选中->选中状态，需要判断是否达到了100条
            int selCnt = 0;
            for(MessageInfo *msg in self.messageList)
            {
                if(msg.isSelected)
                {
                    selCnt++;
                }
            }
            if(selCnt>=100)
            {
                [self.view makeToast:@"聊天记录多选不能超过100条".lv_localized];
                return;
            }
        }
        cell.chatRecordDTO.isSelected = !cell.chatRecordDTO.isSelected;
        [self.tableView reloadData];
        //
        [self resetMultiOptState];
    }
}

#pragma mark - ChatMultiSelOptToolViewDelegate
- (NSArray *)selectedMsgs
{
    NSMutableArray *msgs = [NSMutableArray array];
    for(MessageInfo *msg in self.messageList)
    {
        if(msg.isSelected)
        {
            [msgs addObject:msg];
        }
    }
    return msgs;
}

- (void)ChatMultiSelOptToolView_Forword
{//批量转发
    ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
    chooseView.toSendMsgsList = [self selectedMsgs];
    chooseView.hidesBottomBarWhenPushed = YES;
    chooseView.delegate = self;
    [self.navigationController pushViewController:chooseView animated:YES];
}

- (void)ChatMultiSelOptToolView_Fov
{//批量收藏
    //退出多选模式
    [self click_cancelMultiSelectedMode];
    //转发消息
    [[TelegramManager shareInstance] forwardMessage:[UserInfo shareInstance]._id msgs:[self selectedMsgs]];
    //
    [UserInfo showTips:nil des:@"已收藏".lv_localized];
}

- (void)ChatMultiSelOptToolView_Revoke
{//批量撤销
    [self revokeMessages:[self selectedMsgs]];
}

- (void)ChatMultiSelOptToolView_Delete
{//批量删除
    [self deleteMessages:[self selectedMsgs]];
}

#pragma mark - ChatChooseViewControllerDelegate
// 群发
- (void)ChatChooseViewController_Chats_ChooseArr:(NSArray *)chatArr msg:(NSArray *)msgs{
    for (int i=0; i<chatArr.count; i++) {
        id chat = chatArr[i];
        [self ChatChooseViewController_Chat_Choose:chat msg:msgs];
    }
}

- (void)ChatChooseViewController_Chat_Choose:(id)chat msg:(NSArray *)msgs
{//转发消息
    if ([chat isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chatinfo = chat;
        //转发消息
        //退出多选模式
        [self click_cancelMultiSelectedMode];
        //转发消息
        [[TelegramManager shareInstance] forwardMessage:chatinfo._id msgs:msgs];
        //
        [UserInfo showTips:nil des:@"已发送".lv_localized];
    }else if([chat isKindOfClass:[UserInfo class]]){
        UserInfo *user = chat;
        [[TelegramManager shareInstance] createPrivateChat:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:ChatInfo.class])
            {
                ChatInfo *chatinfo = obj;
                //退出多选模式
                [self click_cancelMultiSelectedMode];
                //转发消息
                [[TelegramManager shareInstance] forwardMessage:chatinfo._id msgs:msgs];
                //
                [UserInfo showTips:nil des:@"已发送".lv_localized];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}


#pragma mark - GotRpDialogDelegate
- (void)GotRpDialog_viewDetail:(RedPacketInfo *)rp
{
    //本人 领取红包成功
    RpState state = [rp getRpState];
    NSDictionary *dic = @{
        @"redPacketId" : @(rp.redPacketId),
        @"RpState" : @(state),
        @"type" : @(rp.type)
    };
    [CZCommonTool saveGreyRedpadID:dic];
    [self rpDetailView:rp];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self isPrivateOffline]) {
        return 0;

    }
    return 1;
}

- (BOOL)isPrivateOffline {
    /// 需要先考虑不是隐私聊天的情况 2022年02月25日00:30:22
    if (!self.chatInfo.isSecretChat) {
        return NO;
    }
    
//    if (self.chatInfo.isSecretChat && [self.chatInfo.secretChatInfo.state isEqualToString:@"secretChatStateReady"]) {
//        return NO;
//    } else {
//        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.type.user_id];
//        self.privateWaitView.userInfo = user;
//        return YES;
//    }
    if (self.chatInfo.isSecretChat) {
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo.type.user_id];
        self.privateWaitView.userInfo = user;
        self.privateWaitView.backgroundColor = HEXCOLOR(0xF5F9FA);
        self.secreatChatTipv.userInfo = user;
        if ([self.chatInfo.secretChatInfo.state isEqualToString:@"secretChatStateReady"]) {
            return NO;
        }
        return YES;
//        if (self.chatInfo.lastMessage) {
//            return NO;
//        }
//        NSString *onlineStyle = [user.status objectForKey:@"@type"];
//        if (!([onlineStyle isEqualToString:@"userStatusOnline"]||
//              [onlineStyle isEqualToString:@"userStatusRecently"])){//        userStatusOffline
//            return YES;
//        }
    }
    return NO;
}

- (void)showSecreatChatTip:(BOOL)show{
    if (show) {
        [self.tableView addSubview:self.secreatChatTipv];
        self.secreatChatTipv.hidden = NO;
    } else {
        [self.secreatChatTipv removeFromSuperview];
        self.secreatChatTipv.hidden = YES;
    }
}

/// 显示加密提示
/// 好友会话的时候有这个cell
/// 所以处理IndexPath的时候，需要考虑这个情况。进行处理;
- (BOOL)isDisplayEncryptionTip {
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    return !(self.chatInfo.isGroup || isMyFov || [self isSystemChat]);
}

- (void)refreshPrivateBottomView{
    BOOL isPrivateOffline = [self isPrivateOffline];
    if (self.chatInfo.isSecretChat) {
        if (self.chatInfo.lastMessage) {
            [self showSecreatChatTip:NO];
        } else {
            [self showSecreatChatTip:YES];
        }
    } else {
        [self showSecreatChatTip:NO];
    }
    
    self.privateWaitView.hidden = !isPrivateOffline;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self checkSouceList];
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        return self.messageList.count;
    }else{
        return self.messageList.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        if (self.chatInfo.isGroup && self.groupPinnedMessage) {
            return 57;
        }
    }else{
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo._id];
        if (!user.is_contact) {
            return 50;
        }
    }
    return 0.01;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        if (self.chatInfo.isGroup && self.groupPinnedMessage) {
            MNGroupAnnounceHeaderView *view = [[MNGroupAnnounceHeaderView alloc] init];
            [view refreshDataWithChat:self.chatInfo pinnedMessage:self.groupPinnedMessage superGroup:self.super_groupInfo];
            @weakify(self);
            view.closeBlock = ^{
                @strongify(self);
                self.groupPinnedMessage = nil;
                [self.tableView reloadData];
            };
            return view;
        }
    }else{
        long userId = self.chatInfo._id;
        if (self.chatInfo.isSecretChat) {
            userId = self.chatInfo.type.user_id;
        }
        UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId];
        if (!user.is_contact) {
            __weak __typeof(self) weakSelf = self;
            CZChatSectionHeadView *headview = [[CZChatSectionHeadView alloc]init];
            headview.is_black = self.chatInfo.is_blocked;
            [headview bindClickEventWithfirBtn:^{
                [weakSelf addBlackListClick];
            } withAddFriendBtn:^{
                [weakSelf addFriendClick];
            }];
            return headview;
        }
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        MessageInfo *msg = [self.messageList objectAtIndex:indexPath.row];
        if(msg.messageType == MessageType_Pinned)
        {
            return 0;
        }
        if (msg.reply_to_message_id > 0) {
            
        }else if(msg.msg_cell_height>0){
            return msg.msg_cell_height;//MAX(msg.msg_cell_height, MessageCellContentMinHeight);
        }
        Class messageCellClass = [MessageCellFactory classForChatRecord:msg];
        msg.msg_cell_height = [messageCellClass contentHeightForTableViewWith:msg showNickName:YES];
        if (msg.isShowDayText) {
            msg.msg_cell_height = msg.msg_cell_height +  MessageCellVertMargins + MessageCellTimestampRegionHeight;
        }
        return msg.msg_cell_height;//MAX(msg.msg_cell_height, MessageCellContentMinHeight);
    }else{//私聊
        if (indexPath.row == 0) {
            NSArray *langArr1 = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
            NSString *currentLanguage = langArr1.firstObject;
            if ([currentLanguage isEqualToString:@"en"]) {
                return 70 + 20;
            }
            return 50 + 20;
        }else{
            MessageInfo *msg = [self.messageList objectAtIndex:indexPath.row-1];
            if(msg.messageType == MessageType_Pinned)
            {
                return 0;
            }
            if (msg.reply_to_message_id > 0) {
                
            }else if(msg.msg_cell_height>0){
                return msg.msg_cell_height;//MAX(msg.msg_cell_height, MessageCellContentMinHeight);
            }
            Class messageCellClass = [MessageCellFactory classForChatRecord:msg];
            msg.msg_cell_height = [messageCellClass contentHeightForTableViewWith:msg showNickName:YES];
            return msg.msg_cell_height;//MAX(msg.msg_cell_height, MessageCellContentMinHeight);
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        MessageInfo *msg = [self.messageList objectAtIndex:indexPath.row];
        NSLog(@"msg : %@",msg);
        NSString *identifierStr = [NSString stringWithFormat:@"Chat_%d", (int)msg.messageType];
        MessageViewBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
        if (!cell){
            Class messageCellClass = [MessageCellFactory classForChatRecord:msg];
            cell = [[messageCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
        }
        cell.delegate = self;
        cell.groupMembers = self.membersList;
        [cell loadChatRecord:msg isGroup:self.chatInfo.isGroup];
        [cell setupTapGesture];
        
        //clear color
        [[cell contentView] setBackgroundColor:[UIColor clearColor]];
        [[cell backgroundView] setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    
    if (indexPath.row == 0) {
        //显示加密提示
//        CZChatTisTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CZChatTisTableViewCell"];
//        if (!cell){
//            cell = [[CZChatTisTableViewCell alloc]init];
//        }
        QTChatTisTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QTChatTisTableViewCell"];
        if (!cell){
            cell = [[QTChatTisTableViewCell alloc]init];
        }
        return cell;
    }
    MessageInfo *msg = [self.messageList objectAtIndex:indexPath.row-1];
    NSLog(@"msg : %@",msg);
    NSString *identifierStr = [NSString stringWithFormat:@"Chat_%d", (int)msg.messageType];
    MessageViewBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    if (!cell) {
        Class messageCellClass = [MessageCellFactory classForChatRecord:msg];
        cell = [[messageCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
    }
    
    cell.chatInfo = self.chatInfo;
    cell.delegate = self;
    [cell loadChatRecord:msg isGroup:NO];
    [cell setupTapGesture];
    
    //clear color
    [[cell contentView] setBackgroundColor:[UIColor clearColor]];
    [[cell backgroundView] setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageInfo *msg = nil;
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        msg = [self.messageList objectAtIndex:indexPath.row];
    }else{//私聊
        if (indexPath.row == 0) {
            return;
        }else{
            msg = [self.messageList objectAtIndex:indexPath.row-1];
        }
    }
    if (msg.reply_to_message_id != 0 && (!msg.reply_str || msg.reply_str.length < 1)) {//引用
        [[TelegramManager shareInstance] getMessageWithChatid:self.chatInfo._id withMessageid:msg.reply_to_message_id result:^(NSDictionary *request, NSDictionary *response, id obj) {
            if (obj && [obj isKindOfClass:[MessageInfo class]]) {
                MessageInfo *info = obj;
                if ([info.description isEqualToString:@""]) {
                    return;
                }
                
                NSString *displayName;
                UserInfo *user = [[TelegramManager shareInstance] contactInfo:info.sender.user_id];
                if (user) {
                    displayName = user.displayName;
                    for (GroupMemberInfo *m in self.membersList) {
                        if (m.user_id == user._id && [NSString xhq_notEmpty:m.nickname]) {
                            displayName = m.nickname;
                            break;
                        }
                    }
                }
                msg.reply_content = info.content;
                if (!IsStrEmpty(displayName)) {
                    msg.reply_str = [NSString stringWithFormat:@"%@:%@",displayName,info.description];
                } else {
                    msg.reply_str = info.description;
                }
                
                [self.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }
    if(msg.messageType == MessageType_Photo)
    {//图片消息
        PhotoSizeInfo *photoInfo = msg.content.photo.messagePhoto;
        if(photoInfo != nil)
        {
            if(!photoInfo.isPhotoDownloaded)
            {//未下载，启动下载
                if(![[TelegramManager shareInstance] isFileDownloading:photoInfo.photo._id type:FileType_Message_Photo]
                   && photoInfo.photo.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
//                    [[FileDownloader instance] downloadImage:key fileId:photoInfo.photo._id type:FileType_Message_Photo];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:photoInfo.photo._id download_offset:0 type:FileType_Message_Photo];
                }
            }
        }
    }
    if(msg.messageType == MessageType_Animation)
    {//gif消息
        AnimationInfo *gifInfo = msg.content.animation;
        if(gifInfo != nil)
        {
            if(!gifInfo.isVideoDownloaded)
            {//未下载，启动下载
                if(![[TelegramManager shareInstance] isFileDownloading:gifInfo.animation._id type:FileType_Message_Animation]
                   && gifInfo.animation.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:gifInfo.animation._id download_offset:0 type:FileType_Message_Animation];
                }
            }
        }
    }
    if (msg.messageType == MessageType_Audio) {//音频消息
        AudioInfo *audioInfo = msg.content.audio;
        if (audioInfo != nil) {
            if(!audioInfo.isAudioDownloaded)
            {//未下载，启动下载
                if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.audio._id type:FileType_Message_Audio]
                   && audioInfo.audio.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.audio._id download_offset:0 type:FileType_Message_Audio];
                }
            }
        }
    }else if (msg.messageType == MessageType_Voice) {//语音消息
        VoiceInfo *audioInfo = msg.content.voice_note;
        if (audioInfo != nil) {
            if(!audioInfo.isAudioDownloaded)
            {//未下载，启动下载
                if(![[TelegramManager shareInstance] isFileDownloading:audioInfo.voice._id type:FileType_Message_Voice]
                   && audioInfo.voice.remote.unique_id.length > 1)
                {
                    NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
                    [[TelegramManager shareInstance] DownloadFile:key fileId:audioInfo.voice._id download_offset:0 type:FileType_Message_Voice];
                }
            }
        }
    }
    
    //在这里调用消息已读
    [[TelegramManager shareInstance] setMessagesReaded:self.chatInfo._id msgIds:@[[NSNumber numberWithLong:msg._id]]];
    NSString * indexStr = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    if ([self.unreadAtMsgArr containsObject:indexStr]) {
        [self.unreadAtMsgArr removeObject:indexStr];
        self.unreadAtL.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.unreadAtMsgArr.count];
        if (self.unreadAtMsgArr.count>99) {
            self.unreadAtL.text = @"99+";
        }
        self.atBtn.hidden = (self.unreadAtMsgArr.count == 0);
        self.unreadAtL.hidden = (self.unreadAtMsgArr.count == 0);

    }

    
    
    if (msg._id>self.chatInfo.last_read_inbox_message_id) {
        if (self.chatInfo.unread_count>0) {
            NSInteger count = self.messageList.count - indexPath.row - 1;
            if ([self isDisplayEncryptionTip]) {
                count --;
            }
            self.chatInfo.unread_count = (int)count;
            if (self.chatInfo.unread_count<0) {
                self.chatInfo.unread_count = 0;
            }
            self.unreadL.text = [NSString stringWithFormat:@"%d",self.chatInfo.unread_count];
            if (self.chatInfo.unread_count>99) {
                self.unreadL.text = @"99+";
            }
        }
    }else{
        self.unreadL.text = [NSString stringWithFormat:@"%d",self.chatInfo.unread_count];
        if (self.chatInfo.unread_count>99) {
            self.unreadL.text = @"99+";
        }
    }
    self.showLastBtn.hidden = self.chatInfo.unread_count==0;
    self.unreadL.hidden = self.chatInfo.unread_count==0;

    
    
    if (msg.fireTime.intValue>0&&![self.fireMsgIDArr containsObject:[NSString stringWithFormat:@"%ld",msg._id]]&&!msg.is_outgoing) {
        NSString * msgid = [NSString stringWithFormat:@"%ld",msg._id];
        [self.fireMsgArr insertObject:msg atIndex:0];
        [self.fireMsgIDArr insertObject:msgid atIndex:0];
        [[NSUserDefaults standardUserDefaults] setValue:msg.fireTime forKey:msgid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self startFireTimer];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEdit:YES];
}

- (void)tableViewWasTouched:(UITableView *)tableView
{
    [self endEdit:YES];
}

- (MessageViewBaseCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)getScrollToBottomCanPlayCellIndexPath {
    NSArray<UITableViewCell *> *cells = self.tableView.visibleCells.reverseObjectEnumerator.allObjects;
    NSIndexPath *indexPath = nil;
    for (UITableViewCell *cell in cells) {
        if ([cell isKindOfClass:VideoMessageCell.class]) {
            indexPath = [self.tableView indexPathForCell:cell];
            break;
        }
    }
    return indexPath;
}

#pragma mark - UITextViewDelegate
- (CGFloat)inputTextViewContentWidth
{
    //30图标菜单\15间距\16内边距
//    return SCREEN_WIDTH - 3*30 - 5*15 - 16;
    return SCREEN_WIDTH - 150 - 16;
}

- (void)resetInputContainerHeight
{
    NSString *text = self.inputTextView.text;
    CGFloat height = [text boundingRectWithSize:CGSizeMake([self inputTextViewContentWidth], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:fontRegular(17)} context:nil].size.height+18+10+5;
    CGFloat heightLim = MIN(160, MAX(height, INPUT_CONTAINER_DEFAILT_HEIGHT));
    if (self.isQuote) {
        
        heightLim = MIN(180, MAX(height+60, INPUT_CONTAINER_QUOTE_HEIGHT));
    }
    //    NSLog(@"heightLim : %f",heightLim);
    self.inputContainerViewHeight.constant = heightLim;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self sendTextMessage];
        return NO;
    }
    if (self.chatInfo.isGroup && [text isEqualToString:@"@"])
    {
        [self performSelector:@selector(atSomeone) withObject:nil afterDelay:0.1];
    }
    
    if (self.chatInfo.isGroup && !self.cusPermissionsModel.banSendDmMention && ([text isEqualToString:@"m"] || [text isEqualToString:@"M"])) {
        NSString *text = textView.text;
        if ([text hasSuffix:@"d"] || [text hasSuffix:@"D"]) {
            self.dmInput = YES;
            [self performSelector:@selector(atSomeone) withObject:nil afterDelay:0.1];
        }
    }
    [self resetInputContainerHeight];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.text.length > 0) {
        [[TelegramManager shareInstance] sendChatAction:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [[TelegramManager shareInstance] sendChatActionCancle:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        
    } timeout:^(NSDictionary *request) {
        
    }];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (!textView.text || textView.text.length == 0) {
        [self.selecteMembers removeAllObjects];
    }
    
    if (self.selecteMembers.count > 0 && textView.text > 0) {
        NSArray *inputMembers = [textView.text componentsSeparatedByString:@" "];
        if (inputMembers.count == self.selecteMembers.count) {//多个@
            for (UserInfo *userinfo in self.selecteMembers.reverseObjectEnumerator) {//倒过来遍历
                if ([[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"@%@",userinfo.displayName]]
                    || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"dm@%@",userinfo.displayName]]
                    || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"DM@%@",userinfo.displayName]]
                    || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"dM@%@",userinfo.displayName]]
                    || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"Dm@%@",userinfo.displayName]]) {
                    [self.selecteMembers removeObject:userinfo];
                    if ([[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"@%@",self.backinfo.displayName]]
                        || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"DM@%@",self.backinfo.displayName]]
                        || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"dm@%@",self.backinfo.displayName]]
                        || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"Dm@%@",self.backinfo.displayName]]
                        || [[inputMembers lastObject] isEqualToString:[NSString stringWithFormat:@"dM@%@",self.backinfo.displayName]]) {
                        self.backinfo = nil;
                    }
                    if (self.selecteMembers.count> 0) {
                        NSMutableArray *mutarr = [inputMembers mutableCopy];
                        [mutarr removeLastObject];
                        textView.text = [NSString stringWithFormat:@"%@ ",[mutarr componentsJoinedByString:@" "]];
                    }else{
                        textView.text = @"";
                    }
                    break;
                }
            }
        }
        
    }
    //输入状态
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        //不做处理
    }else{//私聊
        if (textView.text.length > 0) {
            [[TelegramManager shareInstance] sendChatAction:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
                
            } timeout:^(NSDictionary *request) {
                
            }];
        }else{
            [[TelegramManager shareInstance] sendChatActionCancle:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
                
            } timeout:^(NSDictionary *request) {
                
            }];
        }
    }
    [self resetInputContainerHeight];
    [[TelegramManager shareInstance] getWebPagePreview:textView.text resultBlock:^(NSDictionary *request, NSDictionary *response) {
        
    } timeout:^(NSDictionary *request) {
        
    }];
    
    if (textView == self.inputTextView) {
        if (self.inputTextView.hasText) { // textView.text.length
            self.inputTextView.placeholder = @"";
            self.fireMsgBtn.hidden = YES;
//            self.inputTrailing.constant = 85;
            self.inputTrailing.constant = 90;

        } else {
            [self showPlaceHolder];
            if([AppConfigInfo sharedInstance].enabled_destroy_after_reading){
                self.fireMsgBtn.hidden = NO;
            }
//            self.inputTrailing.constant = 135;
            self.inputTrailing.constant = 90;

        }
    }
}

- (void)atSomeone
{
    MNAddGroupVC *chooseView = [[MNAddGroupVC alloc] init];
    chooseView.chooseType = MNContactChooseType_Group_At_Someone;
    chooseView.chatId = self.chatInfo._id;
    chooseView.isSuperGroup = self.chatInfo.isSuperGroup;
    chooseView.supergroup_id = self.chatInfo.superGroupId;
    chooseView.delegate = self;
    [self.navigationController pushViewController:chooseView animated:YES];
}

#pragma mark - ContactChooseViewControllerDelegate
- (void)chooseUser:(UserInfo *)user{
    [self ContactChooseViewController_Choose:user];
}
- (void)ContactChooseViewController_Choose:(UserInfo *)user
{
    if (!user) {
        return;
    }
    UserInfo *nUser = user.copy;
    /// 处理群组内群昵称
    for (GroupMemberInfo *m in self.membersList) {
        if (m.user_id == nUser._id && [NSString xhq_notEmpty:m.nickname]) {
            nUser.groupNickname = m.nickname;
            break;
        }
    }
    
    if (self.dmInput && self.chatInfo.permissions.can_send_messages) {
        self.backinfo = nUser;
        [self.selecteMembers addObject:nUser];
        [self.inputTextView insertText:[NSString stringWithFormat:@"@%@ ", nUser.displayName]];
        [self resetInputContainerHeight];
        self.dmInput = NO;
    } else if(self.chatInfo.permissions.can_send_messages) {
        OrgUserInfo *itemLim = nil;
        for (int i=0; i<self.memberAndContacts.count; i++) {
            OrgUserInfo *item =[self.memberAndContacts objectAtIndex:i];
            if(item.uId == user._id){
                itemLim = item;
                
            }
        }
        if(itemLim){
            NSString *nameLin = [NSString stringWithFormat:@"%@ ", [NSString stringWithFormat:@"%@%@", !itemLim.firstName ? @"":itemLim.firstName, !itemLim.lastName ? @"":itemLim.lastName]];
            [self.inputTextView insertText:nameLin];
            nUser.realyName = nameLin;
        }else{
            [self.inputTextView insertText:[NSString stringWithFormat:@"%@ ", nUser.displayName]];
        }
        
        self.backinfo = nUser;
        [self.selecteMembers addObject:nUser];
        
        
        [self resetInputContainerHeight];
    }
}

- (void)ChatEmojiView_Send:(ChatEmojiView *)view
{
    [self sendTextMessage];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView != self.tableView) {
        return;
    }
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:CGPointMake(0, scrollView.contentOffset.y + CGRectGetHeight(self.tableView.frame)/2)];
    MessageInfo *msg = nil;
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov || [self isSystemChat]) {//群聊
        msg = [self.messageList objectAtIndex:indexPath.row];
    } else {//私聊
        if (indexPath.row == 0) {
            return;
        } else {
            msg = [self.messageList objectAtIndex:indexPath.row-1];
        }
    }
    if (msg.messageType != MessageType_Video) {
        return;
    }
    VideoInfo *videoInfo = msg.content.video;
    if (!videoInfo) {
        return;
    }
    if (!videoInfo.isVideoDownloaded) {
        //未下载，启动下载
        if(![[TelegramManager shareInstance] isFileDownloading:videoInfo.video._id type:FileType_Message_Video]
           && videoInfo.video.remote.unique_id.length > 1) {
            NSString *key = [NSString stringWithFormat:@"%ld_%ld", self.chatInfo._id, msg._id];
            [[TelegramManager shareInstance] DownloadFile:key fileId:videoInfo.video._id download_offset:0 type:FileType_Message_Video];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(scrollView == self.tableView)
    {
        [self endEdit:YES];
        if(scrollView.contentOffset.y <= 0)
        {//加载更多记录,向前请求
            if(![self.tableView isHeaderViewShowing])
            {
                [self loadMoreMessages];
            }
        }
        else
        {
            CGSize contentSize = [self.tableView contentSize];
            CGRect bounds = [self.tableView bounds];
            if (scrollView.contentOffset.y + bounds.size.height >= contentSize.height)
            {//加载更多记录,向后请求
                if(![self.tableView isFooterViewShowing] && [self hasNextPageMessages])
                {
                    [self.tableView addFooterView];
                    RunBlockAfterDelay(0.1, ^
                                       {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            MessageInfo *last = [self.messageList lastObject];
                            [self prepareNextPageMessages:last._id];
                        });
                    });
                }
            }
        }
    }
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    if (!self.viewLoaded || !self.view.window) {
        return;
    }
    
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect endFrame;
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if([[notification name] isEqualToString:UIKeyboardWillHideNotification])
    {
        self.isKeyboardVisible = NO;
        if(self.willShowPanel)
        {
            self.bottomViewToPBottomOffset.constant = 0;
        }
        else
        {
            [self.view layoutIfNeeded];
            [UIView animateWithDuration:0.35 animations:^{
                self.bottomViewToPBottomOffset.constant = 0;
                [self.view layoutIfNeeded];
            }];
        }
    }
    else
    {
        self.isKeyboardVisible = YES;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            self.toolContainerView.hidden = YES;
            self.toolContainerViewHeight.constant = 0;
            self.bottomViewToPBottomOffset.constant = endFrame.size.height-kBottomSafeHeight;
            [self.view layoutIfNeeded];
            if([self hasNextPageMessages])
            {
                [self loadLastMessage:YES];
            }
            else
            {
                //弹出键盘时，消息到列表底部
                [self showLastCell];
            }
        }];
    }
    self.willShowPanel = NO;
}

- (void)endEdit:(BOOL)animated
{
    [self.view endEditing:YES];
    if(self.toolContainerViewHeight.constant > 0)
    {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:animated ? 0.35 : 0 animations:^{
            self.toolContainerView.hidden = YES;
            self.toolContainerViewHeight.constant = 0;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark -截屏监听通知
- (void)screenShots {
    if (self.chatInfo._id == TG_USERID_SYSTEM_NOTICE) {// 系统公告除外
        return;
    }
    //发送截屏消息
    [[TelegramManager shareInstance] sendScreenshotMessage:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
    } timeout:^(NSDictionary *request) {
    }];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateUserUpdateUserStatus)://在线离线
        {
            
            if (self.membersList && self.membersList.count > 0) {
                [self resetTitle];
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_UpdateChatUpdateSecretChatStatus)://私密聊天
        {
            SecretChat *secret = (SecretChat *)inParam;
            if (![secret isKindOfClass:[SecretChat class]]) {
                return;
            }
            if (self.chatInfo.isSecretChat && self.chatInfo.secretChatInfo._id == secret._id) {
                if ([secret.state isEqualToString:@"secretChatStateClosed"]) {
                    [self.view endEditing:YES];
                    [self gotoBack];
                    return;
                }
                self.chatInfo.secretChatInfo = secret;
                [self refreshPrivateBottomView];
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_UpdateChatOnlineMemberCount)://群在线人数更新
        {
            if ([inParam isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = inParam;
                NSString *chatId = dic[@"chatId"];
                NSString *count = dic[@"count"];
                if (chatId.longLongValue == self.chatInfo._id) {
                    self.onlineNumber = count.integerValue;
                    self.subtitleLabel.text = [NSString stringWithFormat:@"%@人在线".lv_localized,count];
                }
            }
//            if (self.membersList && self.membersList.count > 0) {
//                [self resetTitle];
//            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Total_Unread_Changed)://消息未读总数更新
        {
            [self refreshBackTitle];
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Title_Changed)://最近会话标题修改
        {//会话标题修改通知
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo.title = chat.title;
                    [self resetTitle];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Permissions_Changed)://最近会话权限变更
        {//会话权限变更通知
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo.permissions = chat.permissions;
                    [self checkUserChatState];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_OutMessage_Readed)://发送的消息被读
        {//发送消息被对方查看了
            ChatInfo *chat = inParam;
            if(chat != nil && [chat isKindOfClass:[ChatInfo class]])
            {
                if(self.chatInfo._id == chat._id)
                {
                    self.chatInfo.last_read_outbox_message_id = chat.last_read_outbox_message_id;
                    [self.tableView reloadData];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_New_Message)://新消息
        {
            MessageInfo *msg = inParam;
            if(msg != nil && [msg isKindOfClass:[MessageInfo class]])
            {
                [self processTransferIfNeeded:msg];
                if(msg.chat_id == self.chatInfo._id)
                {//当前会话
                    [self addOrUpdateMessage:msg oldMsgId:-1];
                    if(!msg.is_outgoing && msg.messageType == MessageType_Pinned)
                    {
                        [self showGroupNotice:YES];
                    }
                    // 私密聊天，收到新消息，影藏之前的提示弹窗
                    if (self.chatInfo.isSecretChat) {
                        [self showSecreatChatTip:NO];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Delete_Message)://删除消息
        {
            //@{@"msgIds":msgIds, @"chat_id":[dic objectForKey:@"chat_id"], @"is_permanent":[dic objectForKey:@"is_permanent"], @"from_cache":[dic objectForKey:@"from_cache"]}
            NSDictionary *params = inParam;
            if(params != nil && [params isKindOfClass:[NSDictionary class]])
            {
                long chatId = [[params objectForKey:@"chat_id"] longValue];
                BOOL is_permanent = [[params objectForKey:@"is_permanent"] boolValue];
                BOOL from_cache = [[params objectForKey:@"from_cache"] boolValue];
                if(is_permanent && !from_cache && chatId == self.chatInfo._id)
                {
                    NSArray *lt = [params objectForKey:@"msgIds"];
                    for(NSNumber *msgId in lt)
                    {
                        [self deleteMsg:[msgId longValue] isRefresh:NO];
                    }
                    //刷新并判断是否跳转到底部
                    BOOL needShowLastCell = NO;
                    if(self.tableView.contentOffset.y + self.tableView.frame.size.height + 60 >= self.tableView.contentSize.height)
                    {
                        needShowLastCell = YES;
                    }
                    [self setMessagesIsNeedShowDayText];
                    [self.tableView reloadData];
                    if(needShowLastCell)
                    {
                        [self showLastCell];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Success)://发送成功
        case MakeID(EUserManager, EUser_Td_Chat_Send_Message_Fail)://发送失败
        {
            //@{@"msg":msg, @"old_message_id":[dic objectForKey:@"old_message_id"]}
            NSDictionary *params = inParam;
            if(params != nil && [params isKindOfClass:[NSDictionary class]])
            {
                MessageInfo *msg = [params objectForKey:@"msg"];
                if(msg != nil && [msg isKindOfClass:[MessageInfo class]])
                {
                    if(msg.chat_id == self.chatInfo._id)
                    {//当前会话
                        long oldMsgId = -1;
                        NSNumber *old_message_id = [params objectForKey:@"old_message_id"];
                        if(old_message_id != nil && [old_message_id isKindOfClass:[NSNumber class]])
                        {
                            oldMsgId = [old_message_id longValue];
                        }
                        [self addOrUpdateMessage:msg oldMsgId:oldMsgId];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Photo_Ok)://消息图片已准备好
        case MakeID(EUserManager, EUser_Td_Message_Audio_Ok)://消息语音已准备好
        case MakeID(EUserManager, EUser_Td_Message_Voice_Ok)://消息语音已准备好
        case MakeID(EUserManager, EUser_Td_Message_Animation_Ok)://gif已准备好
        {//@{@"task":task, @"file":fileInfo}
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long chatId = [list.firstObject longLongValue];
                        if(self.chatInfo._id == chatId)
                        {//是当前会话的
                            long msgId = [list.lastObject longLongValue];
                            if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Photo_Ok))
                            {//图片
                                [self updatePhotoMsg:msgId file:fileInfo];
                            }
                            else if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Audio_Ok))
                            {//语音
                                [self updateAudioMsg:msgId file:fileInfo];
                            }
                            else if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Voice_Ok))
                            {//语音
                                [self updateVoiceMsg:msgId file:fileInfo];
                            }
                            else if(notifcationId == MakeID(EUserManager, EUser_Td_Message_Animation_Ok))
                            {//gif
                                [self updateGifMsg:msgId file:fileInfo];
                            }
                        }
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Video_Ok)://消息视频已准备好
        {
            // wl 修改 处理视频 下载问题
            //            FileInfo *fileInfo = inParam;
            //            [self updateVideoMsg:0 file:fileInfo];
            NSDictionary *obj = inParam;
            if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
            {
                FileTaskInfo *task = [obj objectForKey:@"task"];
                FileInfo *fileInfo = [obj objectForKey:@"file"];
                if(task != nil && fileInfo != nil)
                {
                    NSArray *list = [task._id componentsSeparatedByString:@"_"];
                    if(list.count == 2)
                    {
                        long chatId = [list.firstObject longLongValue];
                        if(self.chatInfo._id == chatId)
                        {//是当前会话的
                            long msgId = [list.lastObject longLongValue];
                            [self updateVideoMsg:msgId file:fileInfo];
                        }
                    }

                }
            }else{
                FileInfo *fileInfo = inParam;
                [self updateVideoMsg:0 file:fileInfo];
            }
            


        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Basic_Info_Changed):
        {
            if(self.chatInfo.isGroup && !self.chatInfo.isSuperGroup)
            {
                BasicGroupInfo *info = inParam;
                if(info != nil && [info isKindOfClass:[BasicGroupInfo class]])
                {
                    if(self.chatInfo.type.basic_group_id == info._id)
                    {
                        [self resetUIFromBasicGroupInfo:info];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Group_Super_Info_Changed):
        {
            if(self.chatInfo.isGroup && self.chatInfo.isSuperGroup)
            {
                SuperGroupInfo *info = inParam;
                if(info != nil && [info isKindOfClass:[SuperGroupInfo class]])
                {
                    if(self.chatInfo.type.supergroup_id == info._id)
                    {
                        [self getSuperAdminMembers];
                        //成员
                        [self getSuperMembers];
                        [self resetUIFromSuperGroupInfo:info];
                    }
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Group_Member_Nickname_Change):
        {
            [self updateMembersList:inParam];
            break;
        }
        case MakeID(EUserManager, EUser_Td_Chat_Bg_Changed)://会话背景图改变
        {
            NSNumber *chatId = inParam;
            if(chatId != nil && [chatId isKindOfClass:[NSNumber class]])
            {
                if(self.chatInfo._id == [chatId longValue])
                {
                    [self resetChatBg];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Location_ReGeocode_Search):// 逆地址转换
        {
            NSDictionary *dic = inParam;
            NSNumber *chatId =[dic objectForKey:@"ChatId"];
            if(chatId != nil && [chatId isKindOfClass:[NSNumber class]])
            {
                if(self.chatInfo._id == [chatId longValue])
                {
                    [self.tableView reloadData];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Chatcustom_Permissions_Change)://权限变更
        {
            if (inParam) {
                CZPermissionsModel *info = inParam;
                self.cusPermissionsModel = info;
            }
        }
            break;
        case MakeID(EUserManager, EUser_Keys_Change):
        {
            NSArray *keys = inParam;
            if (keys) {
                self.keysWords = keys;
            }
        }
            break;
        case MakeID(EUserManager, EUser_User_Inputing)://正在输入
        {
            NSLog(@"正在输入");
            BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
            if (isMyFov) {
                
            }else if(self.chatInfo.isGroup){
                NSDictionary *dic = inParam;
                long chatId = [[dic objectForKey:@"chat_id"] longValue];
                long userId = [[dic objectForKey:@"user_id"] longValue];
                if (self.chatInfo._id == chatId) {
                    MJWeakSelf
                    [[TelegramManager shareInstance] getUserSimpleInfo_inline:userId resultBlock:^(NSDictionary *request, NSDictionary *response) {
                        UserInfo *user = [UserInfo mj_objectWithKeyValues:response];
                        NSString *userName = user.displayName;
//                        weakSelf.subtitleLabel.text = [NSString stringWithFormat:@"%@正在输入...", userName];
                        weakSelf.groupInputCache[@(userId)] = userName;
                        [weakSelf changeGroupInputTitle];
                    } timeout:^(NSDictionary *request) {
                        weakSelf.subtitleLabel.text = @"...正在输入...".lv_localized;
                    }];
                }
            }
            else{
                NSDictionary *dic = inParam;
                long userid = [[dic objectForKey:@"chat_id"] longValue];
                if (self.chatInfo._id == userid) {
                    _subtitleLabel.text = @"对方正在输入...".lv_localized;
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_User_Inputing_Canale)://无输入
        {
            NSLog(@"无输入");
            NSLog(@"main thread:%@",[NSThread currentThread]);
            NSDictionary *dic = inParam;
            if(self.chatInfo.isGroup){
                NSDictionary *dic = inParam;
                long chatId = [[dic objectForKey:@"chat_id"] longValue];
                long userId = [[dic objectForKey:@"user_id"] longValue];
                if (self.chatInfo._id == chatId) {
                    [self.groupInputCache removeObjectForKey:@(userId)];
                    [self changeGroupInputTitle];
                }
            } else {
                long userid = [[dic objectForKey:@"chat_id"] longValue];
                if (self.chatInfo._id == userid) {
                    [self settingNavTitleView];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Td_Message_Reaction_Update):
        {
            MessageReaction *reaction = (MessageReaction *)inParam;
            if (reaction.chatId != [ChatInfo toServerPeerId:self.chatInfo._id]) {
                return;
            }
            NSInteger index = [self isMsgLoaded:reaction.messageId];
            MessageInfo *msg = self.messageList[index];
            for (MessageReactionList *list in reaction.reactionList) {
                [msg updateRecation:list];
            }
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

- (void)changeGroupInputTitle{
    if (self.groupInputCache.allValues.count < 1) {
        // 没有人输入时，设置成灰色
        self.subtitleLabel.textColor = HEX_COLOR(@"#C0C0C0");
        [self settingGroupNav];
        return;
    }
    NSArray *inputUsers = self.groupInputCache.allValues;
    NSString *inputs = [inputUsers componentsJoinedByString:@","];
    // 有人输入时，设置成主题色
    self.subtitleLabel.textColor = [UIColor colorMain];
    self.subtitleLabel.text = [NSString stringWithFormat:@"...%@", inputs];
    
}

/// 群组内用户更新昵称
- (void)updateMembersList:(id)parameters {
    if (!self.chatInfo.isGroup) {
        return;
    }
    if (self.membersList.count == 0) {
        return;
    }
    NSDictionary *data = parameters;
    GroupMemberNicknameUpdate *update = [GroupMemberNicknameUpdate mj_objectWithKeyValues:data];
    if (self.chatInfo.superGroupId != update.chatId && self.chatInfo.isSuperGroup) {
        return;
    } else if (self.chatInfo.groupId > 0 && self.chatInfo.groupId != update.chatId) {
        return;
    }
    if (update.userId == UserInfo.shareInstance._id) {
        return;
    }
    for (GroupMemberInfo *m in self.membersList) {
        if (m.user_id == update.userId) {
            m.nickname = update.nickname;
            break;
        }
    }
    [self.tableView reloadData];
}

#pragma mark -- UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    return self.view.frame;
}

//2021-07-06
//对消息列表数据进行判断  是否需要增加提示语句
- (void)checkSouceList{
    NSMutableArray *sourceList = [NSMutableArray array];
    GroupMemberState state = self.super_groupInfo.status.getMemberState;
    BOOL isGroupAdmin = (state == GroupMemberState_Administrator || state == GroupMemberState_Creator);
    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    for (int i=0; i < self.messageList.count; i++) {
        MessageInfo *info = [self.messageList objectAtIndex:i];
        //黑名单处理
        if (info.messageType ==  MessageType_Text_Blacklist || info.messageType == MessageType_Text_Stranger) {
            //防止重复添加提示语
        }else if(!isGroupAdmin && [info.content.type isEqualToString:@"messageChatDeleteMember"]  && !config.shown_everyone_member_changes){
            //非管理 且  退群消息  不显示
        }else if(!config.enabled_screenshot_notification && info.messageType == MessageType_Text_Screenshot){
            //后台配置不显示截屏消息
        }
        else{
            [sourceList addObject:info];
            if ([info sendState] == MessageSendState_Fail && info.messageType != MessageType_Text_BeFriend) {
                NSString *errormsg = info.sending_state.error_message;
                if ([errormsg isEqualToString:@"YOU_BLOCKED_USER"]) {
                    //确定是被加入了黑名单
                    MessageInfo *msgModel = [[MessageInfo alloc]init];
                    msgModel.messageType =  MessageType_Text_Blacklist;
                    [sourceList addObject:msgModel];
                } else if ([errormsg isEqualToString:@"USER_PRIVACY_RESTRICTED"]) {
                    MessageInfo *msgModel = [[MessageInfo alloc]init];
                    msgModel.messageType =  MessageType_Text_Stranger;
                    [sourceList addObject:msgModel];
                }
            }
        }
    }
    self.messageList = [sourceList mutableCopy];
    sourceList = nil;
}

//1V1 添加好友
- (void)addFriendClick{
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:self.chatInfo._id];
    [self doAddContactRequestWithid:user];
}

- (void)doAddContactRequestWithid:(UserInfo *)user
{
    [UserInfo show];
    [[TelegramManager shareInstance] addContact:user resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"添加好友失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已被添加到您的好友列表中".lv_localized, user.displayName]];
            [[TelegramManager shareInstance] sendBeFriendMessage:user._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
                
            } timeout:^(NSDictionary *request) {
            }];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"添加好友失败，请稍后重试".lv_localized];
    }];
}

//加黑名
- (void)addBlackListClick{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:self.chatInfo.is_blocked?@"确定从黑名单中移除吗？".lv_localized:@"确定加入黑名单吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {
            [self blockUser];
        }
        else
        {
            
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)blockUser
{
    [UserInfo show];
    [[TelegramManager shareInstance] blockUser:self.chatInfo._id isBlock:!self.chatInfo.is_blocked resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            //成功
            //self.chatInfo.is_blocked = !self.chatInfo.is_blocked;
            [self.tableView reloadData];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized];
    }];
}

//权限
- (void)gettingExtendedPermissions{
    [[TelegramManager shareInstance] gettingExtendedPermissions:[ChatInfo toServerPeerId:self.chatInfo._id] resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj){
            self.cusPermissionsModel = (CZPermissionsModel *)obj;
        }
    } timeout:^(NSDictionary *request) {
        
    }];
}

//查询
- (void)queryGroupShieldWordsWithchtid{
    [[TelegramManager shareInstance] queryGroupShieldWordsWithchtid:[ChatInfo toServerPeerId:self.chatInfo._id] resultBlock:^(NSDictionary *request, NSDictionary *response) {
        if([TelegramManager isResultError:response]){
            //获取数据失败
        }else{
            NSArray *keys = [response objectForKey:@"data"];
            self.keysWords = keys;
        }
    } timeout:^(NSDictionary *request) {
    }];
}

//获取聊天详情  私聊
- (void)getChatDetail{
    BOOL isMyFov = (!self.chatInfo.isGroup&&self.chatInfo._id==[UserInfo shareInstance]._id);//收藏
    if (self.chatInfo.isGroup || isMyFov) {
        
    }else{
        [[TelegramManager shareInstance] requestContactFullInfo:self.chatInfo._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
            if(obj != nil && [obj isKindOfClass:[UserFullInfo class]])
            {
                self.userFullInfo = obj;
                [self.tableView reloadData];
            }
        } timeout:^(NSDictionary *request) {
        }];
    }
}

//是否为系统公告
- (BOOL)isSystemChat{
    long chatid = self.chatInfo._id;
    if (chatid == 777000) {
        return YES;
    }else{
        return NO;
    }
}

//获取引用消息 并跳转
- (void)getQuoteMessageAndJump:(long)quoteid{
    if (quoteid > 0) {
        MessageInfo *firstInfo = [self.messageList firstObject];
        long offset = firstInfo._id - quoteid;
        if (offset > 0) {//不在本地
            [[TelegramManager shareInstance] getChatMessageList:self.chatInfo._id from_message_id:firstInfo._id offset:0 limit:100 only_local:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
                if(![TelegramManager isResultError:response])
                {
                    NSArray *list = [response objectForKey:@"messages"];
                    if(list != nil && [list isKindOfClass:[NSArray class]])
                    {
                        NSMutableArray *msgIds = [NSMutableArray array];
                        int count = 0;
                        for(NSDictionary *msgDic in list)
                        {
                            MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:msgDic];
                            [TelegramManager parseMessageContent:[msgDic objectForKey:@"content"] message:msg];
                            [self autoDownloadAudio:msg];
                            if(msg._id!=firstInfo._id)
                            {
                                [self.messageList insertObject:msg atIndex:0];
                                [self changeUnreadAtMessage];

                                [msgIds addObject:[NSNumber numberWithLong:msg._id]];
                                count++;
                            }
                        }
//                        if(msgIds.count>0)
//                        {
//                            [[TelegramManager shareInstance] setMessagesReaded:self.chatInfo._id msgIds:msgIds];
//                        }
                        
                        [self smothRefreshPrevPageUI:count];
                        [self getQuoteMessageAndJump:quoteid];
                    }
                }
                
            } timeout:^(NSDictionary *request) {
                
            }];
        }else{
            //跳转
            for (int i = 0; i < self.messageList.count;i++) {
                MessageInfo *iteminfo = [self.messageList objectAtIndex:i];
                if (iteminfo._id == quoteid) {
                    NSIndexPath *lastRow = [NSIndexPath indexPathForRow:i inSection:0];
                    [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }
            }
        }
    }
}

#pragma mark - 阅后即焚
-(void) startFireTimer{
    //起刷新线程
    if (!self.delMsgTimer || ![self.delMsgTimer isValid]){
        self.delMsgTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerDeleteMessge) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.delMsgTimer forMode:NSRunLoopCommonModes];
        [self.delMsgTimer fire];
    }
}
-(void)timerDeleteMessge{
//    [self.fireMsgArr enumerateObjectsUsingBlock:^(MessageInfo * obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSLog(@"开始");
    NSArray * arr = [NSArray arrayWithArray:self.fireMsgArr];
    for (NSInteger i = arr.count-1; i>=0; i--) {
        MessageInfo * obj = arr[i];
        NSString * msgID = [NSString stringWithFormat:@"%ld",obj._id];
        NSString * timeStr = [[NSUserDefaults standardUserDefaults] objectForKey:msgID];
        if (timeStr.length == 0) {
//            [self.fireMsgArr removeObject:obj];
//            [self.fireMsgIDArr removeObject:msgID];
//            [self.messageList removeObject:obj];
            [self deleteFireMessage:obj];
            [self changeUnreadAtMessage];

        }else{
            int times = [timeStr intValue];
            times --;
            NSLog(@"times - %d, i-%ld",times,(long)i);
            if (times<1) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:msgID];
                [self deleteFireMessage:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"burnModeDeleteMsg" object:obj];
            }else{
                NSString *timeStr = [NSString stringWithFormat:@"%d",times];
                [[NSUserDefaults standardUserDefaults] setValue:timeStr forKey:msgID];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"BurnTimeLabelChaged" object:self.fireMsgIDArr];
    NSLog(@"BurnTimeLabelChaged");
    
    if (self.fireMsgIDArr.count == 0) {
        if ([self.delMsgTimer isValid]){
            [self.delMsgTimer invalidate];
            self.delMsgTimer = nil;
        }
    }
}

-(void)deleteFireMessage:(MessageInfo *)info{
    NSInteger inx = [self.fireMsgIDArr indexOfObject:[NSString stringWithFormat:@"%ld",info._id]];
    [self.fireMsgArr removeObjectAtIndex:inx];
    [self.fireMsgIDArr removeObjectAtIndex:inx];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%ld",info._id]];
////    [self.messageList removeObject:info];
//    [self deleteMsg:info._id isRefresh:NO];
//    [self.tableView reloadData];
    __weak typeof(self) weak_self = self;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        if (weak_self.chatInfo.isGroup || weak_self.chatInfo.isSuperGroup) {
            [weak_self deleteSuperGroupMessage:@[[NSNumber numberWithLong:info._id>>20]]];
        }
        else{
            [weak_self deleteMessageRequest:@[[NSNumber numberWithLong:info._id]] isRevoke:YES];
        }
    });

}


#pragma mark - pickView
-(void)chatDelayView:(MNChatDelayView *)chatDelayView isOn:(BOOL)isOn value:(NSInteger)value{
    if (isOn) {
        self.selectPickTime = [NSString stringWithFormat:@"%ld",value];
    }else{
        self.selectPickTime = @"0";
    }
    self.fireMsgBtn.selected = isOn;
    [self showPlaceHolder];
    self.fd_interactivePopDisabled = NO;
}
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
//    return 1;
//}
//
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
//    return self.pickArr.count;
//}
//
//
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return self.pickArr[row];
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//
//
//
//    self.selectPickTime = self.paserArr[row];
//    NSLog(@"当前选中:%@",self.selectPickTime);
//
//}
//-(void)sureBtnClick{
//    if ([self anySubViewScrolling:self.pickV]) {
//        return;
//    }
//    NSLog(@"点击确定:%@",self.selectPickTime);
//    self.bgView.hidden = YES;
//    self.fireMsgBtn.selected = self.selectPickTime.intValue>0;
//    [self showPlaceHolder];
//}
-(void)showPlaceHolder{
    if (self.fireMsgBtn.selected) {
        [[ChatFireConfig shareInstance].fireConfigDic setObject:self.selectPickTime forKey:[NSNumber numberWithLong:self.chatInfo._id]];
        if (self.inputTextView.text.length>0) {
            self.inputTextView.placeholder = @"";

        }else{
            self.inputTextView.placeholder = [NSString stringWithFormat:@"将在%@秒后删除".lv_localized,self.selectPickTime];
        }
    }
    else{
        [[ChatFireConfig shareInstance].fireConfigDic removeObjectForKey:[NSNumber numberWithLong:self.chatInfo._id]];
        self.inputTextView.placeholder = @"";
    }
}
- (BOOL)anySubViewScrolling:(UIView *)view{

    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if (scrollView.dragging || scrollView.decelerating) {
            return YES;
        }
    }

    for (UIView *theSubView in view.subviews) {
       if ([self anySubViewScrolling:theSubView]) {
           return YES;
       }
    }
    return NO;
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickLeftBtn:(UIButton *)btn{
    [self gotoBack];
}

-(void)gotoBack{
    if ([self.delMsgTimer isValid]){
        [self.delMsgTimer invalidate];
        self.delMsgTimer = nil;
    }
    
    [self closeChat];
    [self.transfer cancelTransfer];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changeUnreadAtMessage{
    NSArray * arr = [NSArray arrayWithArray:self.messageList];
    NSMutableArray * muArr = @[].mutableCopy;
    for (MessageInfo * info in arr) {
        if (info.contains_unread_mention) {
            [muArr addObject:[NSString stringWithFormat:@"%lu",(unsigned long)[arr indexOfObject:info]]];
        }
    }
    self.unreadAtMsgArr = [NSMutableArray arrayWithArray:muArr];
    self.unreadAtL.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.unreadAtMsgArr.count];
    if (self.unreadAtMsgArr.count>99) {
        self.unreadAtL.text = @"99+";
    }
    self.atBtn.hidden = (self.unreadAtMsgArr.count == 0);
    self.unreadAtL.hidden = (self.unreadAtMsgArr.count == 0);

}

-(void)atBtnClick{
    if (_unreadAtMsgArr.count==0) {
        return;
    }
    if (self.tableView.numberOfSections == 0) {
        return;
    }
    NSString * index = self.unreadAtMsgArr.lastObject;
    NSIndexPath *lastRow = [NSIndexPath indexPathForRow:index.integerValue inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)showLastBtnClick{
    if (self.tableView.numberOfSections == 0) {
        return;
    }
    int iRow = (int)([self.tableView numberOfRowsInSection:0] - 1);
    if (iRow < 0)
    {
        return;
    }
    NSIndexPath *lastRow = [NSIndexPath indexPathForRow:iRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [self.unreadAtMsgArr removeAllObjects];
    self.chatInfo.unread_count = 0;
    self.unreadL.hidden = YES;
    self.unreadAtL.hidden = YES;
    self.atBtn.hidden = YES;
    self.showLastBtn.hidden = YES;
}

-(void)dwonLoadVideoFinish:(NSNotification *)noti{
    NSDictionary *obj = noti.object;
    if(obj != nil && [obj isKindOfClass:[NSDictionary class]])
    {
        FileTaskInfo *task = [obj objectForKey:@"task"];
        FileInfo *fileInfo = [obj objectForKey:@"file"];
        if(task != nil && fileInfo != nil)
        {
            NSArray *list = [task._id componentsSeparatedByString:@"_"];
            if(list.count == 2)
            {
                long chatId = [list.firstObject longLongValue];
                if(self.chatInfo._id == chatId)
                {//是当前会话的
                    long msgId = [list.lastObject longLongValue];
                    [self updateVideoMsg:msgId file:fileInfo];
                }
            }

        }
    }else{
        FileInfo *fileInfo = (FileInfo *)obj;
        [self updateVideoMsg:0 file:fileInfo];
    }
}

- (NSMutableDictionary *)groupInputCache{
    if (!_groupInputCache) {
        _groupInputCache = [NSMutableDictionary dictionary];
    }
    return _groupInputCache;
}

@end
