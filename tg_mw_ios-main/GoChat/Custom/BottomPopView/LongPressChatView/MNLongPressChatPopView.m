//
//  MNLongPressChatPopView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "MNLongPressChatPopView.h"
#import "UIButton+LXMImagePosition.h"

@interface MNLongPressChatPopView ()
<BusinessListenerProtocol>
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *topBtn;
@property (nonatomic, strong) UIButton *notiBtn;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) ChatInfo *chat;

@end
@implementation MNLongPressChatPopView


+ (MNLongPressChatPopView *)showWithChat:(ChatInfo *)chat touchBtnBlock:(PopViewTouchBtnBlock)touchBtnBlock{
    MNLongPressChatPopView *popView = [[MNLongPressChatPopView alloc] init];
    popView.touchBtnBlock = touchBtnBlock;
    [popView showWithChat:chat];
    [popView show];
    return popView;
}

- (void)showWithChat:(ChatInfo *)chat{
    self.chat = chat;
    [self initUI];
    //开始布局
    [MNChatUtil headerImgV:self.iconImgV chat:chat size:CGSizeMake(37, 37)];
    self.titleLabel.text = [MNChatUtil titleFromChat:chat];
    [self refreshTopBtnWithIsTop:self.chat.is_pinned];
    [self refreshNoticeBtnNotice:!self.chat.default_disable_notification];
   
}

- (void)initUI{
    self.bottomView.frame = CGRectMake((APP_SCREEN_WIDTH-300)*0.5, (APP_SCREEN_HEIGHT-210)*0.5, 300, 210);
    [self.bottomView addSubview:self.iconImgV];
    [self.bottomView addSubview:self.titleLabel];
    [self.bottomView addSubview:self.topBtn];
    [self.bottomView addSubview:self.notiBtn];
    [self.bottomView addSubview:self.deleteBtn];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(25);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(10);
        make.right.mas_equalTo(-20);
        make.centerY.equalTo(self.iconImgV);
        make.height.mas_equalTo(22.5);
    }];
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    [self.bottomView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(77);
    }];
    [self.topBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(76, 85));
        make.top.mas_equalTo(102);
        make.left.mas_equalTo(20);
    }];
    [self.notiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.topBtn);
        make.centerY.equalTo(self.topBtn);
        make.centerX.mas_equalTo(0);
    }];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.topBtn);
        make.centerY.equalTo(self.topBtn);
        make.right.mas_equalTo(-20);
    }];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
        [_iconImgV mn_iconStyleWithRadius:18.5];
    }
    return _iconImgV;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontSemiBold(16);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _titleLabel;
}

-(UIButton *)topBtn{
    if (!_topBtn) {
        _topBtn = [self createBtnWithTitle:@"置顶".lv_localized imageName:@"PopTop"];
        [_topBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
    }
    return _topBtn;
}

-(UIButton *)notiBtn{
    if (!_notiBtn) {
        _notiBtn = [self createBtnWithTitle:@"免打扰".lv_localized imageName:@"PopNotice"];
        [_notiBtn setTitleColor:[UIColor colorTextFor878D9A] forState:UIControlStateNormal];
    }
    return _notiBtn;
}

-(UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [self createBtnWithTitle:@"删除".lv_localized imageName:@"PopDelete"];
        [_deleteBtn setTitleColor:[UIColor colorTextForFD4E57] forState:UIControlStateNormal];
    }
    return _deleteBtn;
}

- (UIButton *)createBtnWithTitle:(NSString *)title imageName:(NSString *)imageName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = fontRegular(15);
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self refreshBtn:btn title:title imageName:imageName];
//    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
//    [btn setTitle:title forState:UIControlStateNormal];
//
////    [btn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
//    [btn setImagePosition:LXMImagePositionTop spacing:10.5];
   
    return btn;
}

- (void)refreshBtn:(UIButton *)btn title:(NSString *)title imageName:(NSString *)imageName {
  
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
   
//    [btn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
    [btn setImagePosition:LXMImagePositionTop spacing:10.5];
   
}
- (void)refreshTopBtnWithIsTop:(BOOL)isTop{
    if (isTop) {
        [self refreshBtn:self.topBtn title:@"取消置顶".lv_localized imageName:@"PopTopCancel"];
    }else{
        [self refreshBtn:self.topBtn title:@"置顶".lv_localized imageName:@"PopTop"];
    }
}

- (void)refreshNoticeBtnNotice:(BOOL)notice{
    if (notice) {
        [self refreshBtn:self.notiBtn title:@"免打扰".lv_localized imageName:@"PopNoticeCancel"];
    }else{
        [self refreshBtn:self.notiBtn title:@"打开通知".lv_localized imageName:@"PopNotice"];
    }
}

- (void)btnAction:(UIButton *)btn{
    if (self.touchBtnBlock) {
        self.touchBtnBlock(self,btn);
    }
    if (btn == self.notiBtn) {
        [self toggleChatNotification:self.chat];
    }else if(btn ==  self.topBtn){
        [self toggleChatPinned:self.chat];
    }else if (btn == self.deleteBtn){
        [self toggleChatDeleteConfirm:self.chat];
    }
    [self hide];
}


- (void)toggleChatNotification:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatDisableNotification:chat._id isDisableNotification:!chat.default_disable_notification  resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"通知设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatPinned:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] toggleChatIsPinned:chat._id isPinned:!chat.is_pinned resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"置顶设置失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatDeleteConfirm:(ChatInfo *)chat
{
    __block NSInteger tag = -1;
    MMPopupItemHandler block = ^(NSInteger index) {
        tag = index;
    };
    NSArray *items = @[MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:@"确定删除吗？".lv_localized
                                                          items:items];
    sheetView.hideCompletionBlock = ^(MMPopupView *pop, BOOL finish){
        if(tag == 0)
        {//删除
            [self toggleChatDelete:chat];
        }
    };
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)toggleChatDelete:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteChatHistory:chat._id isDeleteChat:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
//        else
//        {
//            [[TelegramManager shareInstance] deleteChat:chat._id];
//            [self.chatList removeObject:chat];
//            [self.tableView reloadData];
//            [self refreshTotalUnreadCount];
//        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除会话失败，请稍后重试".lv_localized];
    }];
}


//- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
//{
//    switch(notifcationId)
//    {
//        case MakeID(EUserManager, EUser_Td_Chat_List_Changed):
//        {
//            [self refreshTopBtnWithIsTop:self.chat.is_pinned];
//        }
//            break;
//       
//        case MakeID(EUserManager, EUser_Td_Chat_Permissions_Changed):
//            [self refreshNoticeBtnNotice:!self.chat.default_disable_notification];
//
//            break;
//        
//        default:
//            break;
//    }
//}
@end
