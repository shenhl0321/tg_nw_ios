//
//  MNDetailHeaderView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNDetailHeaderView.h"
#import "UserinfoHelper.h"

@interface MNDetailHeaderView ()
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UserInfo *user;
@property (nonatomic, strong) ChatInfo *chat;
@property (nonatomic, strong) OrgUserInfo *orgUser;

@property (nonatomic, strong) UIButton *ageButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *onlineButton;
@property (nonatomic, strong) UIImageView *genderIcon;

@property (strong, nonatomic) UIView *safeView;
@property (strong, nonatomic) UIImageView *safeImageV;
@property (strong, nonatomic) UILabel *safeTitleLab;

@property (strong, nonatomic) UIView *lineView01;


@property (strong, nonatomic) UIImageView *openImageV;

@end
@implementation MNDetailHeaderView

#define kLeftWid 20
#define kRightWid 15
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

- (void)refreshUIWithUserInfo:(UserInfo *)userInfo orgUserInfo:(OrgUserInfo *)orgUserInfo{
    self.user = userInfo;
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:userInfo._id];
   
    self.chat = chat;
    
    if(self.user.profile_photo != nil)
    {
        if(!self.user.profile_photo.isSmallPhotoDownloaded)
        {
            [[FileDownloader instance] downloadImage:[NSString stringWithFormat:@"%ld", self.user._id] fileId:self.user.profile_photo.fileSmallId type:FileType_Photo];
            //本地头像
            self.iconImgV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.user.displayName.length>0)
            {
                text = [[self.user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(72, 72) withChar:text];
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.iconImgV];
            self.iconImgV.image = [UIImage imageWithContentsOfFile:self.user.profile_photo.localSmallPath];
        }
    }
    else
    {
        //本地头像
        self.iconImgV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.user.displayName.length>0)
        {
            text = [[self.user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.iconImgV withSize:CGSizeMake(72, 72) withChar:text];
    }
    
    
    if (orgUserInfo) {
        self.nameLabel.text = [orgUserInfo displayName];
    }else{
        self.nameLabel.text = userInfo.displayName;
    }
    
    [self refreshMuteBtn];
   
    if (userInfo.type.isDeleted) {
        self.nameLabel.text = userInfo.displayName;
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:UIButton.class]) {
                view.hidden = YES;
            }
        }
    }
//    self.onlineButton.hidden = NO;
    NSString *online = [NSString stringWithFormat:@" %@", userInfo.onlineStatus];
    [self.onlineButton setTitle:online forState:UIControlStateNormal];
    @weakify(self);
    [UserinfoHelper getUserExtInfo:userInfo._id completion:^(UserInfoExt * _Nonnull ext) {
        @strongify(self);
        NSString *age = [NSString stringWithFormat:@" 年龄%ld岁".lv_localized, ext.age];
        NSString *country = [NSString stringWithFormat:@" %@", ext.countrys];
        [self.ageButton setTitle:age forState:UIControlStateNormal];
        [self.locationButton setTitle:country forState:UIControlStateNormal];
        self.genderIcon.image = ext.sexIcon;
//        self.locationButton.hidden = self.ageButton.hidden = NO;
    }];
}
- (UIImageView *)openImageV{
    if (!_openImageV){
        _openImageV = [[UIImageView alloc] init];
    }
    return _openImageV;
}

- (void)refreshMuteBtn{
    self.muteBtn.selected = !self.chat.default_disable_notification;
    self.openImageV.image = [UIImage imageNamed:self.muteBtn.selected==YES?@"icon_kaiguan_open":@"icon_kaiguan_close"];
}
- (void)initData{
    _titles = @[@"消息免打扰".lv_localized];
//    if(ShowLocal_VoiceChat){
//        _titles = @[@"发消息".lv_localized,@"语音通话".lv_localized,@"视频通话".lv_localized,@"消息免打扰".lv_localized];
//    }else{
//        _titles = @[@"发消息".lv_localized,@"消息免打扰".lv_localized];
//    }
}

- (UIButton *)avatarBtn{
    if (!_avatarBtn){
        _avatarBtn = [[UIButton alloc] init];
        [_avatarBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarBtn;
}

- (UIButton *)nicknameBtn{
    if (!_nicknameBtn){
        _nicknameBtn = [[UIButton alloc] init];
        [_nicknameBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nicknameBtn;
}
- (void)initUI{
    [self addSubview:self.iconImgV];
    [self addSubview:self.avatarBtn];
    [self addSubview:self.nameLabel];
    [self addSubview:self.nicknameBtn];
    [self addSubview:self.genderIcon];
    [self addSubview:self.safeView];
    [self.safeView addSubview:self.safeImageV];
    [self.safeView addSubview:self.safeTitleLab];
    [self addSubview:self.lineView01];
    
    /** 这部分隐藏了**/
    [self addSubview:self.onlineButton];
    [self addSubview:self.ageButton];
    [self addSubview:self.locationButton];
    
    self.onlineButton.hidden = YES;
    self.ageButton.hidden = YES;
    self.locationButton.hidden = YES;
    /** 这部分隐藏了**/
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(30);
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.left.mas_equalTo(self).offset(kLeftWid);
    }];
    [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(self.iconImgV);
    }];
    [self.genderIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(17);
        make.trailing.bottom.equalTo(self.iconImgV);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconImgV).offset(-20);
        make.left.equalTo(self.iconImgV.mas_right).offset(10);
    }];
    [self.nicknameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.nameLabel);
        make.right.top.bottom.equalTo(self);
    }];
    [self.safeView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.nameLabel);
        make.centerY.equalTo(self.iconImgV).offset(15);
        make.height.mas_offset(26);
    }];
    [self.safeImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.safeView).offset(10);
        make.centerY.equalTo(self.safeView);
        make.width.height.mas_offset(14);
    }];
    [self.safeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(self.safeImageV.mas_right).offset(5);
        make.right.equalTo(self.safeView).offset(-10);
        make.top.bottom.equalTo(self.safeView);
    }];
    [self.lineView01 mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.right.equalTo(self);
        make.top.equalTo(self.iconImgV.mas_bottom).offset(30);
        make.height.mas_offset(10);
    }];
    
    /** 这部分隐藏了**/
    [self.ageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.equalTo(self.onlineButton);
        make.leading.mas_equalTo(kAdapt(25));
    }];
    [self.onlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.lineView01.mas_bottom).with.offset(40);
        make.height.mas_equalTo(20);
    }];
    [self.locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.equalTo(self.onlineButton);
        make.trailing.mas_equalTo(kAdapt(-25));
        make.leading.greaterThanOrEqualTo(self.onlineButton.mas_trailing).offset(10);
    }];
    /** 这部分隐藏了**/
    
    CGFloat btnHeight = 60;
    CGFloat top = 150;
    // 发起群聊
    [self addQunLiaoViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 10)];
    top += (btnHeight + 10);
    
    // 聊天内容
    [self addLiaoTianNeiRongViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 1)];
    top += (btnHeight + 1);
    
    // 收发图片
    [self addShouFaTuPianViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 1)];
    top += (btnHeight + 1);
    
    // 聊天背景
    [self addLiaoTianBeiJingViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 10)];
    top += (btnHeight + 10);
    
    for (int i = 0; i < self.titles.count; i++) {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, btnHeight*i + top, SCREEN_WIDTH, btnHeight)];
        [self addSubview:backView];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.text = self.titles[i];
        titleLab.font = [UIFont systemFontOfSize:16];
        titleLab.textColor = HEXCOLOR(0x333333);
        [backView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.left.equalTo(backView).offset(kLeftWid);
            make.centerY.equalTo(backView);
        }];
        
        if (i+1 < self.titles.count){
            UIView *lineV = [[UIView alloc] init];
            lineV.backgroundColor = HEXCOLOR(0xF0F0F0);
            [backView addSubview:lineV];
            [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.bottom.right.equalTo(backView);
                make.left.equalTo(backView).offset(kLeftWid);
                make.height.mas_offset(1);
            }];
            
            UIImageView *nextImageV = [[UIImageView alloc] init];
            nextImageV.image = [UIImage imageNamed:@"icon_next"];
            [backView addSubview:nextImageV];
            [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.centerY.equalTo(backView);
                make.right.equalTo(backView).offset(-kRightWid);
                make.width.height.mas_offset(16);
            }];
        }else{ // 最后一个
            [backView addSubview:self.openImageV];
            [self.openImageV mas_makeConstraints:^(MASConstraintMaker *make) {
                //
                make.centerY.equalTo(backView);
                make.right.equalTo(backView).offset(-kRightWid);
                make.width.height.mas_offset(50);
            }];
        }
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.edges.equalTo(backView);
        }];
        
        self.muteBtn = btn;
//        if(ShowLocal_VoiceChat){
//            if (i == 0) {
//                self.sendMsgBtn = btn;
//            }else if (i == 1) {
//                self.voiceBtn = btn;
//            }else if (i == 2) {
//                self.videoBtn = btn;
//            }else if (i == 3) {
//                self.muteBtn = btn;
//            }else {
//                self.moreBtn = btn;
//            }
//        }else{
//            if (i == 0) {
//                self.sendMsgBtn = btn;
//            }else if (i == 1) {
//                self.muteBtn = btn;
//            }else {
//                self.moreBtn = btn;
//            }
//        }
//
    }
    top += btnHeight*self.titles.count;
    
    // 推荐给好友
    [self addTuiJianGeiHaoYouViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 1)];
    top += (btnHeight + 1);
    
    if([AppConfigInfo sharedInstance].can_see_private_chat){
        // 私密聊天
        [self addKaiQiSiMiLiaoTianViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 1)];
        top += (btnHeight + 1);
    }
   
    
    [self addTouSuViewFrame:CGRectMake(0, top, SCREEN_WIDTH, btnHeight + 10)];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [self addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.left.right.equalTo(self);
        make.height.mas_offset(10);
    }];
}

/// 投诉View
- (void)addTouSuViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.top.left.right.equalTo(backView);
        make.height.mas_offset(10);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.bottom.right.equalTo(backView);
        make.top.equalTo(lineV.mas_bottom);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"投诉";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.tousuBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 发起群聊View
- (void)addQunLiaoViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.left.right.equalTo(backView);
        make.height.mas_offset(10);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.right.equalTo(backView);
        make.bottom.equalTo(lineV.mas_top);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"发起群聊";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.qunliaoBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 推荐给好友
- (void)addTuiJianGeiHaoYouViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.right.equalTo(backView);
        make.height.mas_offset(1);
        make.left.equalTo(backView).offset(kLeftWid);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.right.equalTo(backView);
        make.bottom.equalTo(lineV.mas_top);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"推荐给好友";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.tjghyBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 查找收发的图片/视频
- (void)addShouFaTuPianViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.right.equalTo(backView);
        make.height.mas_offset(1);
        make.left.equalTo(backView).offset(kLeftWid);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.right.equalTo(backView);
        make.bottom.equalTo(lineV.mas_top);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"查找收发的图片/视频";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.shoufatupianBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 查找聊天内容
- (void)addLiaoTianNeiRongViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.right.equalTo(backView);
        make.height.mas_offset(1);
        make.left.equalTo(backView).offset(kLeftWid);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.right.equalTo(backView);
        make.bottom.equalTo(lineV.mas_top);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"查找聊天记录";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.ltnrBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 开启私密聊天
- (void)addKaiQiSiMiLiaoTianViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.right.equalTo(backView);
        make.height.mas_offset(1);
        make.left.equalTo(backView).offset(kLeftWid);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.right.equalTo(backView);
        make.bottom.equalTo(lineV.mas_top);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"开启私密聊天";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.kqsmltBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

/// 聊天背景
- (void)addLiaoTianBeiJingViewFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    backView.backgroundColor = [UIColor clearColor];
    [self addSubview:backView];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEXCOLOR(0xF5F9FA);
    [backView addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.bottom.left.right.equalTo(backView);
        make.height.mas_offset(10);
    }];
    
    UIView *detailView =[[UIView alloc] init];
    [backView addSubview:detailView];
    [detailView mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.top.right.equalTo(backView);
        make.bottom.equalTo(lineV.mas_top);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    [detailView addSubview:titleLab];
    titleLab.text = @"设置当前聊天背景";
    titleLab.textColor = HEXCOLOR(0x333333);
    titleLab.font = [UIFont systemFontOfSize:16];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.left.equalTo(detailView).offset(kLeftWid);
        make.centerY.equalTo(detailView);
    }];
    
    UIImageView *nextImageV = [[UIImageView alloc] init];
    nextImageV.image = [UIImage imageNamed:@"icon_next"];
    [detailView addSubview:nextImageV];
    [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.centerY.equalTo(detailView);
        make.right.equalTo(detailView).offset(-kRightWid);
        make.width.height.mas_offset(16);
    }];
    
    UIButton *button = [[UIButton alloc] init];
    [detailView addSubview:button];
    self.ltbjBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        //
        make.edges.equalTo(detailView);
    }];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction:(UIButton *)btn{
    if (btn == self.muteBtn) {
        [self muteClick];
    }else{
        if (self.clickBtnBlock) {
            self.clickBtnBlock(btn);
        }
    }
}

- (UIView *)lineView01{
    if (!_lineView01){
        _lineView01 = [[UIView alloc] init];
        _lineView01.backgroundColor = HEXCOLOR(0xF5F9FA);
    }
    return _lineView01;
}
- (UILabel *)safeTitleLab{
    if (!_safeTitleLab){
        _safeTitleLab = [[UILabel alloc] init];
        _safeTitleLab.text = @"消息通道端对端加密";
        _safeTitleLab.font = [UIFont systemFontOfSize:12];
        _safeTitleLab.textColor = HEXCOLOR(0x666666);
    }
    return _safeTitleLab;
}
- (UIImageView *)safeImageV{
    if (!_safeImageV){
        _safeImageV = [[UIImageView alloc] init];
        _safeImageV.image = [UIImage imageNamed:@"icon_tips_safe"];
    }
    return _safeImageV;
}
- (UIView *)safeView{
    if (!_safeView){
        _safeView = [[UIView alloc] init];
        _safeView.backgroundColor = HEXCOLOR(0xF5F9FA);
        _safeView.clipsToBounds = YES;
        _safeView.layer.cornerRadius = 13;
        _safeView.userInteractionEnabled = NO;
    }
    return _safeView;
}
-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        [_iconImgV mn_iconStyleWithRadius:40];
        
    }
    return _iconImgV;
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontSemiBold(20);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UIImageView *)genderIcon {
    if (!_genderIcon) {
        _genderIcon = [[UIImageView alloc] init];
    }
    return _genderIcon;
}

- (UIButton *)ageButton {
    if (!_ageButton) {
        _ageButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:UIColor.colorFor878D9A forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
            btn.userInteractionEnabled = NO;
            [btn setImage:[UIImage imageNamed:@"icon_info_birthday"] forState:UIControlStateNormal];
            btn.hidden = YES;
            btn;
        });
    }
    return _ageButton;
}

- (UIButton *)locationButton {
    if (!_locationButton) {
        _locationButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:UIColor.colorFor878D9A forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
            btn.userInteractionEnabled = NO;
            [btn setImage:[UIImage imageNamed:@"icon_info_address"] forState:UIControlStateNormal];
            btn.hidden = YES;
            btn;
        });
    }
    return _locationButton;
}

- (UIButton *)onlineButton {
    if (!_onlineButton) {
        _onlineButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:UIColor.colorFor878D9A forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
            btn.userInteractionEnabled = NO;
            [btn setImage:[UIImage imageNamed:@"icon_info_online"] forState:UIControlStateNormal];
            btn.hidden = YES;
            btn;
        });
    }
    return _onlineButton;
}

#pragma mark - 静音
- (void)muteClick{
    [UserInfo show];
    MJWeakSelf
    
    [[TelegramManager shareInstance] toggleChatDisableNotification:self.chat._id isDisableNotification:!self.chat.default_disable_notification resultBlock:^(NSDictionary *request, NSDictionary *response) {
        [UserInfo dismiss];
        if([TelegramManager isResultError:response])
        {
            [UserInfo showTips:nil des:@"静音设置失败，请稍后重试".lv_localized errorMsg:[TelegramManager errorMsg:response]];
        }
        else
        {
            [weakSelf syncChatInfo];
            
        }
    } timeout:^(NSDictionary *request) {
        [UserInfo dismiss];
        [UserInfo showTips:nil des:@"静音设置失败，请稍后重试".lv_localized];
    }];
}

- (void)syncChatInfo
{
    ChatInfo *chat = [[TelegramManager shareInstance] getChatInfo:self.chat._id];
    if(chat != nil)
    {
        self.chat = chat;
    } else {
        self.chat.default_disable_notification = !self.chat.default_disable_notification;
        
    }
    [self refreshMuteBtn];
}

@end
