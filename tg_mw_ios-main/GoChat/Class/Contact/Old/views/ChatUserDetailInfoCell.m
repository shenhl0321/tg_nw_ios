//
//  ChatUserDetailInfoCell.m
//  GoChat
//
//  Created by apple on 2021/12/22.
//

#import "ChatUserDetailInfoCell.h"

@interface ChatUserDetailInfoCell ()

/// 用户头像
@property (nonatomic,strong) UIImageView *iconV;
/// 用户名称
@property (nonatomic,strong) UILabel *nameL;
/// 静音图标
@property (nonatomic,strong) UIImageView *muteV;

@end

@implementation ChatUserDetailInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupUI{
    
    UIImageView *iconV = [[UIImageView alloc] init];
    self.iconV = iconV;
    [self.contentView addSubview:iconV];
    iconV.layer.cornerRadius = 38;
    iconV.clipsToBounds = YES;
    iconV.layer.borderColor = XHQHexColor(0xE5EAF0).CGColor;
    iconV.layer.borderWidth = 1;
    
    UILabel *nameL = [[UILabel alloc] init];
    [self.contentView addSubview:nameL];
    self.nameL = nameL;
    nameL.font = XHQFont(20);
    nameL.textAlignment = NSTextAlignmentCenter;
    
    [self.iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.top.mas_equalTo(20);
        make.width.height.mas_equalTo(76);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.iconV);
        make.top.mas_equalTo(self.iconV.mas_bottom).offset(15);
    }];
    
    UIView *bottomV = [[UIView alloc] init];
    [self.contentView addSubview:bottomV];
    bottomV.backgroundColor = XHQHexColor(0xdadada);
    [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(10);
    }];
    
    NSArray *arr = @[@{@"icon" : @"ChatUser_Send_mess", @"title" : @"发消息".lv_localized},
                     @{@"icon" : @"ChatUser_Voice_calls", @"title" : @"语音通话".lv_localized},
                     @{@"icon" : @"ChatUser_Video_call", @"title" : @"视频通话"},
                     @{@"icon" : @"ChatUser_mute1", @"title" : @"静音"},
                     @{@"icon" : @"ChatUser_more", @"title" : @"更多"}];
    
    CGFloat height = 80;
    CGFloat width = (SCREEN_WIDTH - 20) / 5;
    for (int i = 0; i < arr.count; i++) {
        UIView *view = [[UIView alloc] init];
        view.tag = 100 + i;
        [self.contentView addSubview:view];
        
        NSDictionary *dic = arr[i];
        
        UIImageView *iconV = [[UIImageView alloc] init];
        iconV.image = [UIImage imageNamed:dic[@"icon"]];
        [view addSubview:iconV];
        if (i == 3) {
            self.muteV = iconV;
        }
        
        UILabel *nameL = [[UILabel alloc] init];
        nameL.font = XHQFont(14);
        nameL.textColor = XHQHexColor(0x0DBFC0);
        nameL.text = dic[@"title"];
        nameL.textAlignment = NSTextAlignmentCenter;
        [view addSubview:nameL];
        
        [iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(view);
            make.top.mas_equalTo(5);
            make.width.height.mas_equalTo(40);
        }];
        
        [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(iconV);
            make.top.mas_equalTo(iconV.mas_bottom).offset(7);
        }];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10 + width * i);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(height);
            make.bottom.mas_equalTo(bottomV).mas_offset(-15);
        }];
        
        MJWeakSelf
        [view xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            if (gestureRecoginzer.view.tag == 103) { // 消息免打扰
                [weakSelf muteClick];
            }else{
                if (weakSelf.callBack) {
                    weakSelf.callBack(gestureRecoginzer.view);
                }
            }
            
        }];
    }
    
    
    
}

- (void)setUserInfo:(UserInfo *)userInfo{
    _userInfo = userInfo;
//    [self.iconV sd_setImageWithURL:[NSURL URLWithString:[userInfo.profile_photo localSmallPath]] placeholderImage:[UIImage imageNamed:@"image_default_1"]];
    self.nameL.text = userInfo.displayName;
    [self setIconUI];
}

- (void)setOrgUserInfo:(OrgUserInfo *)orgUserInfo{
    _orgUserInfo = orgUserInfo;
    self.nameL.text = [orgUserInfo displayName];
}

- (void)setChatInfo:(ChatInfo *)chatInfo{
    _chatInfo = chatInfo;
    // 之前是免打扰
    self.muteV.image = self.chatInfo.default_disable_notification ? [UIImage imageNamed:@"ChatUser_mute"] : [UIImage imageNamed:@"ChatUser_mute1"];
}


- (void)setIconUI{
    [self.iconV setClipsToBounds:YES];
    [self.iconV setContentMode:UIViewContentModeScaleAspectFill];
    if(self.userInfo.profile_photo != nil)
    {
        if(!self.userInfo.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", self.userInfo._id] fileId:self.userInfo.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.iconV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.userInfo.displayName.length>0)
            {
                text = [[self.userInfo.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconV withSize:CGSizeMake(72, 72) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.iconV];
            self.iconV.image = [UIImage imageWithContentsOfFile:self.userInfo.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.iconV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.userInfo.displayName.length>0)
        {
            text = [[self.userInfo.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconV withSize:CGSizeMake(72, 72) withChar:text];
    }
}

- (void)muteClick{
    [UserInfo show];
    MJWeakSelf
    [[TelegramManager shareInstance] toggleChatDisableNotification:self.chatInfo._id isDisableNotification:!self.chatInfo.default_disable_notification resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"静音设置失败，请稍后重试" errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [weakSelf syncChatInfo];
            
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"静音设置失败，请稍后重试"];
    }];
}


- (void)syncChatInfo
{
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.chatInfo._id];
    if(chat != nil)
    {
        self.chatInfo = chat;
    } else {
        self.chatInfo.default_disable_notification = !self.chatInfo.default_disable_notification;
        self.chatInfo = self.chatInfo;
    }
}

@end
