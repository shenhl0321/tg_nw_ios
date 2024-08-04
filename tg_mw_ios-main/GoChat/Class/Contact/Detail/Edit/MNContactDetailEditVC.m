//
//  MNContactDetailEditVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNContactDetailEditVC.h"

@interface MNContactDetailEditVC ()
<BusinessListenerProtocol>

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextField *tf;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *blackBtn;

@property (nonatomic, strong) OrgUserInfo *orgUserInfo;
@property (nonatomic, strong) ChatInfo *chatInfo;
@end

@implementation MNContactDetailEditVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.customNavBar setTitle:@"编辑".lv_localized];
    [self.customNavBar setRightBtnWithImageName:nil title:@"完成".lv_localized highlightedImageName:nil];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    self.chatInfo = [[TelegramManager shareInstance] getChatInfo:self.toBeModifyUser._id];
    [self initUI];
    self.prevValueString = self.toBeModifyUser.displayName;
    [self refreshView];
    
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    //编辑名字的
    if (self.tf.text != self.prevValueString) {
        [self saveUserNickname:self.tf.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUserNickname:(NSString *)name
{
    [UserInfo show];
    [[TelegramManager shareInstance] setContactNickName:self.toBeModifyUser nickName:name resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"备注设置失败，请稍后重试".lv_localized];
    }];
}
#pragma mark - 按钮点按动作
- (void)btnAction:(UIButton *)btn{
    if (self.blackBtn == btn) {
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
        };
        [MMPopupWindow sharedWindow].touchWildToHide = YES;
        [sheetView show];
    }else if (self.deleteBtn == btn){
        [self deleteFriendClick];
    }
}
//从黑名单移除来
- (void)blockUser
{
    [UserInfo show];
    MJWeakSelf
    BOOL isBlock = !self.chatInfo.is_blocked;
    [[TelegramManager shareInstance] blockUser:self.toBeModifyUser._id isBlock:isBlock resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            weakSelf.chatInfo.is_blocked = isBlock;
            [weakSelf refreshBtn];
        }
    } timeout:^(NSDictionary *request) {
        
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"加入黑名单失败，请稍后重试".lv_localized];
    }];
}

//删除好友
- (void)deleteFriendClick{
    MMPopupItemHandler block = ^(NSInteger index) {
        if(index == 1)
        {
            [self performSelector:@selector(doDeleteContactRequest) withObject:nil afterDelay:0.4];
        }
    };
    NSArray *items = @[MMItemMake(@"取消".lv_localized, MMItemTypeNormal, block),
                       MMItemMake(@"确定".lv_localized, MMItemTypeHighlight, block)];
    MMAlertView *view = [[MMAlertView alloc] initWithTitle:@"提示".lv_localized detail:[NSString stringWithFormat:@"确定删除好友[%@]吗？".lv_localized, self.toBeModifyUser.displayName] items:items];
    [view show];
}

//删除好友的
- (void)doDeleteContactRequest
{
    WS(weakSelf)
    [UserInfo show];
    [[TelegramManager shareInstance] deleteContact:self.toBeModifyUser._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除好友失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [UserInfo showTips:nil des:[NSString stringWithFormat:@"[%@]已您的好友列表中删除".lv_localized, weakSelf.toBeModifyUser.displayName]];
            [self toggleChatDelete:self.chatInfo];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除好友失败，请稍后重试".lv_localized];
    }];
}

- (void)toggleChatDelete:(ChatInfo *)chat
{
    [UserInfo show];
    [[TelegramManager shareInstance] deleteChatHistory:chat._id isDeleteChat:YES resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"删除好友会话失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"删除好友会话失败，请稍后重试".lv_localized];
    }];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_UpdateContactInfo):
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]])
            {
                if(self.toBeModifyUser._id == updateUser._id)
                {
                    self.toBeModifyUser = updateUser;
                    [self refreshView];
                    [self.tableView reloadData];
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 刷新 名称的方法
- (void)refreshView{
    [self refreshNickName];
    [self refreshIconImgV];
    [self refreshBtn];
}

- (void)refreshNickName{
    NSString *nickName = @"";
    nickName = self.toBeModifyUser.displayName;
    self.tf.text = nickName;
}


- (void)refreshIconImgV{
    if(self.toBeModifyUser.profile_photo != nil)
    {
        if(!self.toBeModifyUser.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", self.toBeModifyUser._id] fileId:self.toBeModifyUser.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.iconImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.toBeModifyUser.displayName.length>0)
            {
                text = [[self.toBeModifyUser.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(70, 70) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.iconImgV];
            self.iconImgV.image = [UIImage imageWithContentsOfFile:self.toBeModifyUser.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.iconImgV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.toBeModifyUser.displayName.length>0)
        {
            text = [[self.toBeModifyUser.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(70, 70) withChar:text];
    }
}

- (void)refreshBtn{
    if (self.chatInfo.is_blocked) {
        [self.blackBtn setTitle:@"移出黑名单".lv_localized forState:UIControlStateNormal];
    }else{
        [self.blackBtn setTitle:@"加入黑名单".lv_localized forState:UIControlStateNormal];
    }
}

- (void)initUI{
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView addSubview:self.blackBtn];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(75, 75));
        make.centerX.mas_equalTo(0);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImgV.mas_bottom).with.offset(30);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(24);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.left.mas_equalTo(40);
    }];
    [self.blackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.bottom.mas_equalTo(-125);
    }];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(55);
        make.bottom.mas_equalTo(-70);
    }];

    
}



-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        _iconImgV.contentMode = UIViewContentModeScaleAspectFill;
        [_iconImgV mn_iconStyleWithRadius:37.5];
        
    }
    return _iconImgV;
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontRegular(16);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

-(UITextField *)tf{
    if (!_tf) {
        _tf = [[UITextField alloc] init];
        [_tf mn_defalutStyleWithFont:fontRegular(16)];
        _tf.textAlignment = NSTextAlignmentCenter;
        _tf.placeholder = @"点击填写备注名".lv_localized;
   
        [_tf setMylimitCount:@12];
    }
    return _tf;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(40, 0, APP_SCREEN_WIDTH-80, 55)];
        _bgView.layer.cornerRadius = 13;
        _bgView.layer.masksToBounds =  YES;
        _bgView.backgroundColor = [UIColor colorForF5F9FA];
        [_bgView addSubview:self.tf];
        [self.tf mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.center.mas_equalTo(0);
            make.top.mas_equalTo(2);
        }];
    }
    return _bgView;
}

-(UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [self createBtnWithTitle:@"删除好友".lv_localized needBottomLine:YES red:YES];
    }
    return _deleteBtn;
}

-(UIButton *)blackBtn{
    if (!_blackBtn) {
        _blackBtn = [self createBtnWithTitle:@"加入黑名单".lv_localized needBottomLine:NO red:NO];
//        [_blackBtn setTitle:@"移出黑名单".lv_localized forState:UIControlStateSelected];
        
    }
    return _blackBtn;
}

- (UIButton *)createBtnWithTitle:(NSString *)title needBottomLine:(BOOL)needBottomLine red:(BOOL)red{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = fontRegular(16);
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    if (needBottomLine) {
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = HexRGB(0xE5EAF0);
        [btn addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    UIView *lineTop = [[UIView alloc] init];
    lineTop.backgroundColor = HexRGB(0xE5EAF0);
    [btn addSubview:lineTop];
    [lineTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    if (red) {
        [btn setTitleColor:[UIColor colorTextForFD4E57] forState:UIControlStateNormal];
    }else{
        [btn setTitleColor:[UIColor colorTextFor23272A] forState:UIControlStateNormal];
    }
    
    
    return btn;
}
@end
