//
//  C2CCallViewController.m
//  GoChat
//
//  Created by wangyutao on 2021/3/1.
//

#import "C2CCallViewController.h"
#import "UIImage+ImageEffects.h"

@interface C2CCallViewController ()<BusinessListenerProtocol>
@property (nonatomic, weak) IBOutlet UIView *voiceCallLayout;   //语音通话界面
@property (nonatomic, weak) IBOutlet UIView *videoCallLayout;   //视频通话界面
@property (nonatomic, weak) IBOutlet UIView *toolbarIncoming;   //接听工具栏
@property (nonatomic, weak) IBOutlet UIView *toolbarAudio;      //语音工具栏
@property (nonatomic, weak) IBOutlet UIView *toolbarVideo;      //视频工具栏

//语音通话界面相关
@property (nonatomic, weak) IBOutlet UIImageView *voiceCall_bk_imageView;
@property (nonatomic, weak) IBOutlet UIImageView *voiceCall_header_imageView;
@property (nonatomic, weak) IBOutlet UILabel *voiceCall_display_name_label;
@property (nonatomic, weak) IBOutlet UILabel *voiceCall_state_label;
@property (nonatomic, weak) IBOutlet UILabel *voiceCall_time_label;

//视频通话界面相关
@property (nonatomic) BOOL smallVideoViewIsTarget;
@property (nonatomic, weak) IBOutlet UIView *videoCall_bigVideoView;
@property (nonatomic, weak) IBOutlet UIView *videoCall_smallVideoView;
@property (nonatomic, weak) IBOutlet UIImageView *videoCall_bk_imageView;
@property (nonatomic, weak) IBOutlet UIImageView *videoCall_header_imageView;
@property (nonatomic, weak) IBOutlet UILabel *videoCall_display_name_label;
@property (nonatomic, weak) IBOutlet UILabel *videoCall_state_label;
@property (nonatomic, weak) IBOutlet UILabel *videoCall_time_label;

//语音工具栏
@property (nonatomic, weak) IBOutlet UIButton *toolbarAudio_Speaker;
@property (nonatomic, weak) IBOutlet UIButton *toolbarAudio_Mute;
@property (nonatomic, weak) IBOutlet UIButton *toolbarAudio_HangUp;

//视频工具栏
@property (nonatomic, weak) IBOutlet UIButton *toolbarVideo_ToggleCarmeraBAndFMode;
@property (nonatomic, weak) IBOutlet UIButton *toolbarVideo_ToggleVoiceFromVideo;
@property (nonatomic, weak) IBOutlet UIButton *toolbarVideo_HangUp;

//接听工具栏
@property (nonatomic, weak) IBOutlet UIButton *toolbarIncoming_Accept;
@property (nonatomic, weak) IBOutlet UIButton *toolbarIncoming_HangUp;

@end

@implementation C2CCallViewController

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.contentView removeFromSuperview];
    [self.customNavBar removeFromSuperview];
    self.view.backgroundColor = HexRGB(0x333333);
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];

    [self resetCallUI];
    [self resetC2CUserUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏导航栏
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //白色标题
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (IBAction)click_back:(id)sender
{
    [[CallManager shareInstance] showSmallTopView];
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetCallUI
{
    if([CallManager shareInstance].isInCalling)
    {
        self.videoCall_header_imageView.hidden = NO;
        self.videoCall_display_name_label.hidden = NO;
        self.videoCall_time_label.hidden = NO;
        self.voiceCall_time_label.hidden = NO;
        switch ([CallManager shareInstance].currentCallState)
        {
            case CallingState_Init:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                if([CallManager shareInstance].isIncoming)
                {//来电
                    [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:YES];
                    if([CallManager shareInstance].isVideo)
                    {
                        self.videoCall_state_label.text = @"邀请您视频通话".lv_localized;
                    }
                    else
                    {
                        self.voiceCall_state_label.text = @"邀请您语音通话".lv_localized;
                    }
                }
                else
                {//呼出
                    [self makeContentLayoutVisible:YES showToolbar:YES showIncomingToolbar:NO];
                    if([CallManager shareInstance].isVideo)
                    {
                        self.videoCall_state_label.text = @"视频通话准备中...".lv_localized;
                    }
                    else
                    {
                        self.voiceCall_state_label.text = @"语音通话准备中...".lv_localized;
                    }
                }
            }
                break;
            case CallingState_Outgoing_Prepare:
            case CallingState_Outgoing_Prepare_error:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:YES showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"视频通话准备中...".lv_localized;
                }
                else
                {
                    self.voiceCall_state_label.text = @"语音通话准备中...".lv_localized;
                }
            }
                break;
            case CallingState_Outgoing_Calling:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                //视频呼叫中，隐藏视频相关的头像、昵称等
                //self.videoCall_header_imageView.hidden = YES;
                //self.videoCall_display_name_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:YES showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    //显示本地视频
                    [[CallManager shareInstance] showLocalVideoToView:self.videoCall_bigVideoView];
                }
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"正在等待对方接受邀请".lv_localized;
                }
                else
                {
                    self.voiceCall_state_label.text = @"正在等待对方接受邀请".lv_localized;
                }
            }
                break;
            case CallingState_Incoming_Waiting:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:YES];
                if([CallManager shareInstance].isVideo)
                {
                    [self.toolbarIncoming_Accept setImage:[UIImage imageNamed:@"接听视频".lv_localized] forState:UIControlStateNormal];
                    self.videoCall_state_label.text = @"邀请您视频通话".lv_localized;
                }
                else
                {
                    [self.toolbarIncoming_Accept setImage:[UIImage imageNamed:@"接听".lv_localized] forState:UIControlStateNormal];
                    self.voiceCall_state_label.text = @"邀请您语音通话".lv_localized;
                }
            }
                break;
            case CallingState_Incoming_Prepare:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:YES];
                if([CallManager shareInstance].isVideo)
                {
                    [self.toolbarIncoming_Accept setImage:[UIImage imageNamed:@"接听视频".lv_localized] forState:UIControlStateNormal];
                    self.videoCall_state_label.text = @"视频通话准备中...".lv_localized;
                }
                else
                {
                    [self.toolbarIncoming_Accept setImage:[UIImage imageNamed:@"接听".lv_localized] forState:UIControlStateNormal];
                    self.voiceCall_state_label.text = @"语音通话准备中...".lv_localized;
                }
            }
                break;
            case CallingState_Canceled:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"视频通话已取消".lv_localized;
                }
                else
                {
                    self.voiceCall_state_label.text = @"语音通话已取消".lv_localized;
                }
            }
                break;
            case CallingState_Canceled_2_Timeout:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"对方无应答".lv_localized;
                }
                else
                {
                    self.voiceCall_state_label.text = @"对方无应答".lv_localized;
                }
            }
                break;
            case CallingState_C2C_Canceled:
            {
                //隐藏时间
                self.videoCall_time_label.hidden = YES;
                self.voiceCall_time_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"视频通话已取消".lv_localized;
                }
                else
                {
                    self.voiceCall_state_label.text = @"语音通话已取消".lv_localized;
                }
            }
                break;
            case CallingState_In_Calling:
            {
                //视频通话中，隐藏视频相关的头像、昵称等
                self.videoCall_header_imageView.hidden = YES;
                self.videoCall_display_name_label.hidden = YES;
                [self makeContentLayoutVisible:YES showToolbar:YES showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"";
                    self.videoCall_time_label.text = @"00:00";
                    //显示本地视频
                    [[CallManager shareInstance] showLocalVideoToView:self.videoCall_smallVideoView];
                    //显示远程视频
                    if(self.videoCall_bigVideoView.subviews.count>0)
                    {
                        for(UIView *view in self.videoCall_bigVideoView.subviews)
                        {
                            [view removeFromSuperview];
                        }
                    }
                    [[CallManager shareInstance] showRemoteVideoToView:self.videoCall_bigVideoView];
                }
                else
                {
                    self.voiceCall_state_label.text = @"";
                    self.voiceCall_time_label.text = @"00:00";
                }
            }
                break;
            case CallingState_Call_End:
            {
                [self makeContentLayoutVisible:YES showToolbar:NO showIncomingToolbar:NO];
                if([CallManager shareInstance].isVideo)
                {
                    self.videoCall_state_label.text = @"视频通话已结束".lv_localized;
                    self.videoCall_time_label.text = @"00:00";
                }
                else
                {
                    self.voiceCall_state_label.text = @"语音通话已结束".lv_localized;
                    self.voiceCall_time_label.text = @"00:00";
                }
            }
                break;
            default:
                break;
        }
    }
    else
    {
        [self click_back:nil];
    }
}

- (void)resetCallingTime
{
    if([CallManager shareInstance].isVideo)
    {
        self.videoCall_time_label.text = [[CallManager shareInstance] callDisplayTime];
    }
    else
    {
        self.voiceCall_time_label.text = [[CallManager shareInstance] callDisplayTime];
    }
}

- (void)resetSpeakerBtn
{
    if([CallManager shareInstance].hasHeadset)
    {
        self.toolbarAudio_Speaker.enabled = NO;
        [self.toolbarAudio_Speaker setImage:[UIImage imageNamed:@"免提_关闭".lv_localized] forState:UIControlStateNormal];
    }
    else
    {
        self.toolbarAudio_Speaker.enabled = YES;
        if([CallManager shareInstance].isEnableSpeaker)
        {
            [self.toolbarAudio_Speaker setImage:[UIImage imageNamed:@"免提_打开".lv_localized] forState:UIControlStateNormal];
        }
        else
        {
            [self.toolbarAudio_Speaker setImage:[UIImage imageNamed:@"免提_关闭".lv_localized] forState:UIControlStateNormal];
        }
    }
}

- (void)makeContentLayoutVisible:(BOOL)showContentLayout showToolbar:(BOOL)showToolbar showIncomingToolbar:(BOOL)showIncomingToolbar
{
    if(showContentLayout)
    {
        if([CallManager shareInstance].isVideo)
        {
            self.videoCallLayout.hidden = NO;
            self.voiceCallLayout.hidden = YES;
        }
        else
        {
            self.videoCallLayout.hidden = YES;
            self.voiceCallLayout.hidden = NO;
        }
    }
    else
    {
        self.videoCallLayout.hidden = YES;
        self.voiceCallLayout.hidden = YES;
    }
    
    if(showToolbar)
    {
        if([CallManager shareInstance].isVideo)
        {
            self.toolbarVideo.hidden = NO;
            self.toolbarAudio.hidden = YES;
        }
        else
        {
            self.toolbarVideo.hidden = YES;
            self.toolbarAudio.hidden = NO;
        }
    }
    else
    {
        self.toolbarVideo.hidden = YES;
        self.toolbarAudio.hidden = YES;
    }
    
    if(showIncomingToolbar)
    {
        self.toolbarIncoming.hidden = NO;
    }
    else
    {
        self.toolbarIncoming.hidden = YES;
    }
}

- (void)resetC2CUserUI
{
    [self.videoCall_header_imageView setClipsToBounds:YES];
    [self.videoCall_header_imageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.voiceCall_header_imageView setClipsToBounds:YES];
    [self.voiceCall_header_imageView setContentMode:UIViewContentModeScaleAspectFill];
    if([CallManager shareInstance].isVideo)
    {//视频
        UserInfo *user = [[CallManager shareInstance] c2cUser];
        if(user != nil)
        {
            self.videoCall_display_name_label.text = user.displayName;
            //头像&背景
            [self resetC2CVideoUserHeader:user];
        }
        else
        {
            long userId = [CallManager shareInstance].c2cUserId;
            self.videoCall_display_name_label.text = [NSString stringWithFormat:@"%ld", userId];
            //本地头像
            self.videoCall_header_imageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.videoCall_display_name_label.text.length>0)
            {
                text = [[self.videoCall_display_name_label.text uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.videoCall_header_imageView withSize:CGSizeMake(120, 120) withChar:text];
            self.videoCall_bk_imageView.image = nil;
            
            //请求用户信息
            [self requestUserInfo:userId];
        }
    }
    else
    {//语音
        UserInfo *user = [[CallManager shareInstance] c2cUser];
        if(user != nil)
        {
            self.voiceCall_display_name_label.text = user.displayName;
            //头像&背景
            [self resetC2CVoiceUserHeader:user];
        }
        else
        {
            long userId = [CallManager shareInstance].c2cUserId;
            self.voiceCall_display_name_label.text = [NSString stringWithFormat:@"%ld", userId];
            //本地头像
            self.voiceCall_header_imageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.voiceCall_display_name_label.text.length>0)
            {
                text = [[self.voiceCall_display_name_label.text uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.voiceCall_header_imageView withSize:CGSizeMake(120, 120) withChar:text];
            self.voiceCall_bk_imageView.image = nil;
            
            //请求用户信息
            [self requestUserInfo:userId];
        }
    }
}

- (void)resetC2CVideoUserHeader:(UserInfo *)user
{
    if(user.profile_photo != nil)
    {
        if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
            //本地头像
            self.videoCall_header_imageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.videoCall_header_imageView withSize:CGSizeMake(120, 120) withChar:text];
            self.videoCall_bk_imageView.image = nil;
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.videoCall_header_imageView];
            self.videoCall_header_imageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
            self.videoCall_bk_imageView.image = [self.videoCall_header_imageView.image applyDarkEffect];
        }
    }
    else
    {
        //本地头像
        self.videoCall_header_imageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(user.displayName.length>0)
        {
            text = [[user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.videoCall_header_imageView withSize:CGSizeMake(120, 120) withChar:text];
        self.videoCall_bk_imageView.image = nil;
    }
}

- (void)resetC2CVoiceUserHeader:(UserInfo *)user
{
    if(user.profile_photo != nil)
    {
        if(!user.profile_photo.isSmallPhotoDownloaded && user.profile_photo.small.remote.unique_id.length > 1)
        {
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", user._id] fileId:user.profile_photo.fileSmallId download_offset:0 type:FileType_Photo];
            //本地头像
            self.voiceCall_header_imageView.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(user.displayName.length>0)
            {
                text = [[user.displayName uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.voiceCall_header_imageView withSize:CGSizeMake(120, 120) withChar:text];
            self.voiceCall_bk_imageView.image = nil;
        }
        else
        {
            [UserInfo cleanColorBackgroundWithView:self.voiceCall_header_imageView];
            self.voiceCall_header_imageView.image = [UIImage imageWithContentsOfFile:user.profile_photo.localSmallPath];
            self.voiceCall_bk_imageView.image = [self.voiceCall_header_imageView.image applyDarkEffect];
        }
    }
    else
    {
        //本地头像
        self.voiceCall_header_imageView.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(user.displayName.length>0)
        {
            text = [[user.displayName uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.voiceCall_header_imageView withSize:CGSizeMake(120, 120) withChar:text];
        self.voiceCall_bk_imageView.image = nil;
    }
}

- (void)requestUserInfo:(long)userId
{
    [[TelegramManager shareInstance] requestContactInfo:userId resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
        if(obj != nil && [obj isKindOfClass:UserInfo.class])
        {
            UserInfo *user = obj;
            if(user != nil)
            {
                [self resetC2CUserUI];
            }
        }
    } timeout:^(NSDictionary *request) {
    }];
}

#pragma mark - 语音 click
- (IBAction)toolbarAudio_Speaker_click:(id)sender
{//麦克风
    if([CallManager shareInstance].hasHeadset)
    {
        [UserInfo showTips:nil des:@"耳机模式，无法设置".lv_localized];
    }
    else
    {
        [[CallManager shareInstance] enableSpeaker:![[CallManager shareInstance] isEnableSpeaker]];
    }
    [self resetSpeakerBtn];
}

- (IBAction)toolbarAudio_Mute_click:(id)sender
{//静音
    [[CallManager shareInstance] muteLocalAudio];
}

- (IBAction)toolbarAudio_HangUp_click:(id)sender
{//挂断
    [[CallManager shareInstance] endCurrentCall];
}

#pragma mark - 视频 click
- (IBAction)toolbarVideo_ToggleCarmeraBAndFMode_click:(id)sender
{//前后摄像头切换
    [[CallManager shareInstance] toggleCamera];
}

- (IBAction)toolbarVideo_ToggleVoiceFromVideo_click:(id)sender
{//切换到语音通话
    //暂时不实现
}

- (IBAction)toolbarVideo_HangUp_click:(id)sender
{//挂断
    [[CallManager shareInstance] endCurrentCall];
}

#pragma mark - 接听 click
- (IBAction)toolbarIncoming_Accept_click:(id)sender
{//接听
    [[CallManager shareInstance] acceptNewCall];
}

- (IBAction)toolbarIncoming_HangUp_click:(id)sender
{//拒绝
    [[CallManager shareInstance] endCurrentCall];
}

//切换视频
- (IBAction)click_exchange_video_view:(id)sender
{
    self.smallVideoViewIsTarget = !self.smallVideoViewIsTarget;
    if(self.videoCall_bigVideoView.subviews.count>0)
    {
        for(UIView *view in self.videoCall_bigVideoView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if(self.videoCall_smallVideoView.subviews.count>0)
    {
        for(UIView *view in self.videoCall_smallVideoView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    if(self.smallVideoViewIsTarget)
    {
        [[CallManager shareInstance] showRemoteVideoToView:self.videoCall_smallVideoView];
        [[CallManager shareInstance] showLocalVideoToView:self.videoCall_bigVideoView];
    }
    else
    {
        [[CallManager shareInstance] showRemoteVideoToView:self.videoCall_bigVideoView];
        [[CallManager shareInstance] showLocalVideoToView:self.videoCall_smallVideoView];
    }
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Contact_Photo_Ok):
        {
            UserInfo *updateUser = inParam;
            if(updateUser != nil && [updateUser isKindOfClass:[UserInfo class]])
            {
                if([CallManager shareInstance].c2cUserId == updateUser._id)
                {
                    [self resetC2CUserUI];
                }
            }
        }
            break;
        case MakeID(EUserManager, EUser_Call_State_Changed):
        {
            if([[CallManager shareInstance] isInCalling])
            {
                [self resetCallUI];
            }
            else
            {//通话已结束
//                [self.navigationController popViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        case MakeID(EUserManager, EUser_Headset_State_Changed):
        {
            [self resetSpeakerBtn];
        }
            break;
        case MakeID(EUserManager, EUser_Refresh_Call_Time):
        {//刷新时间
            [self resetCallingTime];
        }
            break;
        case MakeID(EUserManager, EUser_Call_Local_Voice_Mute_Changed):
        {
            if([[CallManager shareInstance] isMuteLocalAudio])
            {
                [self.toolbarAudio_Mute setImage:[UIImage imageNamed:@"静音_打开".lv_localized] forState:UIControlStateNormal];
            }
            else
            {
                [self.toolbarAudio_Mute setImage:[UIImage imageNamed:@"静音_关闭".lv_localized] forState:UIControlStateNormal];
            }
        }
            break;
        default:
            break;
    }
}

@end
