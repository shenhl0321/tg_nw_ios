//
//  MNGroupSentSendVC.m
//  GoChat
//
//  Created by Autumn on 2022/2/22.
//

#import "MNGroupSentSendVC.h"
#import "MNChatViewController.h"
#import "MNGroupSentSendVC+ImagePicker.h"
#import "MNGroupSentHelper.h"
#import "VideoCompress.h"

#import "ModelPannelView.h"
#import "ChatEmojiView.h"
#import "CustomTextView.h"

#import "AudioAlertView.h"
#import "RecordAudio.h"
#import "PlayAudioManager.h"

/// 阅后即焚
#import "MNChatDelayView.h"
#import "ChatFireConfig.h"

#import "IQKeyboardManager.h"
#import "TF_RequestManager.h"

#define INPUT_CONTAINER_DEFAILT_HEIGHT 60

@interface MNGroupSentSendVC ()<
ModelPannelViewDelegate,
MNChatDelayViewDelegate,
UITextViewDelegate,
ChatEmojiViewDelegate,
RecordAudioDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

@property (strong, nonatomic) IBOutlet UIView *userContainer;
@property (strong, nonatomic) IBOutlet UILabel *userTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) IBOutlet UIView *inputContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputContainerViewHeight;
/// 语音
@property (strong, nonatomic) IBOutlet UIButton *audioModeBtn;
@property (strong, nonatomic) IBOutlet UIButton *audioBtn;
@property (assign, nonatomic) BOOL recordAudioTimeOverFlag;
@property (strong, nonatomic) RecordAudio *recordAudio;
@property (strong, nonatomic) AudioAlertView *audioAlertView;

/// 底部功能区
@property (strong, nonatomic) IBOutlet UIView *toolContainerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toolContainerViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewToPBottomOffset;
/// 功能区
@property (strong, nonatomic) IBOutlet ModelPannelView *modelPannelView;
/// 表情
@property (strong, nonatomic) IBOutlet ChatEmojiView *emojiPannelView;
/// 输入框
@property (strong, nonatomic) IBOutlet CustomTextView *inputTextView;
/// 阅后即焚按钮
@property (strong, nonatomic) IBOutlet UIButton *fireMsgBtn;
/// 表情按钮
@property (strong, nonatomic) IBOutlet UIButton *faceBtn;
/// 阅后即焚面板
@property (nonatomic, strong) MNChatDelayView *delayView;

/// 显示面板
@property (nonatomic) BOOL willShowPanel;
/// 键盘显示隐藏
@property (nonatomic) BOOL isKeyboardVisible;

/// 阅后即焚时间
@property (nonatomic, strong) NSString *selectPickTime;

@end

@implementation MNGroupSentSendVC

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    IQKeyboardManager.sharedManager.enableAutoToolbar = NO;
    IQKeyboardManager.sharedManager.shouldResignOnTouchOutside = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    IQKeyboardManager.sharedManager.enableAutoToolbar = YES;
}

- (void)dy_initData {
    [super dy_initData];
    
    [self addNotification];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    [self.customNavBar setTitle:@"群发".lv_localized];
    self.contentView.hidden = YES;
    
    [self setupTopUsersData];
    [self setupXibViews];
    [self initAudioView];
    
    [self.view addSubview:self.delayView];
    [self.delayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(APP_SCREEN_WIDTH, 81));
        make.centerX.mas_equalTo(0);
        make.bottom.equalTo(self.inputContainerView.mas_top).with.offset(0.5);;
    }];
    
    [self endEdit:NO];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupTopUsersData {
    [self.userContainer xhq_cornerRadius:5];
    self.userTitleLabel.text = [NSString stringWithFormat:@"你将发送消息给%ld位收信人：".lv_localized, _sent.users.count];
    self.usernameLabel.text = _sent.usernames;
}

- (void)setupXibViews {
    self.inputTextView.backgroundColor = [UIColor colorForF5F9FA];
    CGFloat xMargin = 8, yMargin = 10;
    self.inputTextView.textContainerInset = UIEdgeInsetsMake(yMargin, xMargin, 0, xMargin);
    self.inputTextView.contentInset = UIEdgeInsetsMake(0, 0, yMargin, 0);
    self.inputTextView.layoutManager.allowsNonContiguousLayout = NO;
    self.inputTextView.delegate = self;
    [self.inputTextView setMylimitCount:@4000];
    
    [self.modelPannelView initGroupSentModel];
    self.modelPannelView.delegate = self;
    self.emojiPannelView.delegate = self;
}

- (void)initAudioView {
    self.audioBtn.backgroundColor = [UIColor colorForF5F9FA];
    self.audioBtn.layer.cornerRadius = 5;
    self.audioBtn.layer.masksToBounds = YES;
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

#pragma mark - XibAction
- (IBAction)click_more:(id)sender {
    self.willShowPanel = YES;
    if (self.isKeyboardVisible) {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.0 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = NO;
            self.emojiPannelView.hidden = YES;
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = NO;
            self.emojiPannelView.hidden = YES;
            [self.view layoutIfNeeded];
        }];
    }
    //退出语音模式
    [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
    self.audioBtn.hidden = YES;
    self.fireMsgBtn.hidden = NO;
    self.faceBtn.hidden = NO;
    self.inputTextView.hidden = NO;
    [self resetInputContainerHeight];
}

- (IBAction)click_emotion:(id)sender {
    self.willShowPanel = YES;
    if (self.isKeyboardVisible) {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.0 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = YES;
            self.emojiPannelView.hidden = NO;
            [self.view layoutIfNeeded];
        }];
    } else {
        [self.view endEditing:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            self.toolContainerView.hidden = NO;
            self.toolContainerViewHeight.constant = 240;
            self.modelPannelView.hidden = YES;
            self.emojiPannelView.hidden = NO;
            [self.view layoutIfNeeded];
        }];
    }
    //退出语音模式
    [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
    self.audioBtn.hidden = YES;
    self.inputTextView.hidden = NO;
    [self resetInputContainerHeight];
}

- (IBAction)click_fireRead:(id)sender {
    
    [self.view endEditing:YES];
    [self.delayView refreshDataWithValue:[self.selectPickTime integerValue]];
    self.delayView.hidden = NO;
    self.fd_interactivePopDisabled = YES;
}

- (IBAction)click_Audio:(id)sender {
    
    /// 退出语音模式，进入键盘模式
    if (!self.audioBtn.isHidden) {
        [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatTalk"] forState:UIControlStateNormal];
        self.audioBtn.hidden = YES;
        self.fireMsgBtn.hidden = NO;
        self.faceBtn.hidden = NO;
        self.inputTextView.hidden = NO;
        [self.inputTextView becomeFirstResponder];
        [self resetInputContainerHeight];
        return;
    }
    
    /// 进入语音模式
    if (self.isKeyboardVisible) {
        /// 隐藏键盘
        [self.inputTextView resignFirstResponder];
        self.inputTextView.hidden = YES;
        if (self.inputContainerViewHeight.constant > INPUT_CONTAINER_DEFAILT_HEIGHT) {
            [self.view layoutIfNeeded];
            [UIView animateWithDuration:0.35 animations:^{
                self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
                [self.view layoutIfNeeded];
            }];
        }
    } else {
        /// 隐藏功能面板
        self.inputTextView.hidden = YES;
        if (self.toolContainerViewHeight.constant > 0) {
            [self.view layoutIfNeeded];
            [UIView animateWithDuration:0.35 animations:^{
                self.toolContainerView.hidden = YES;
                self.toolContainerViewHeight.constant = 0;
                self.inputContainerViewHeight.constant = INPUT_CONTAINER_DEFAILT_HEIGHT;
                self.bottomViewToPBottomOffset.constant = 0;
                [self.view layoutIfNeeded];
            }];
        }
    }
    [self.audioModeBtn setImage:[UIImage imageNamed:@"ChatKeyboard"] forState:UIControlStateNormal];
    self.audioBtn.hidden = NO;
    self.fireMsgBtn.hidden = YES;
    self.faceBtn.hidden = YES;
}

- (void)click_photo {
    [self openAlbumResult:^(NSArray * _Nonnull videos, NSArray * _Nonnull photos, NSArray * _Nonnull gifs) {
        if (photos.count > 0) {
            NSMutableArray *images = NSMutableArray.array;
            [photos enumerateObjectsUsingBlock:^(HXPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.photoEdit) {
                    [images addObject:obj.photoEdit.editPreviewImage];
                } else {
                    [images addObject:obj.previewPhoto];
                }
            }];
            [self sendPhotoMessage:images];
        }
        if (gifs.count > 0) {
            [self sendGifPhotoMessages:gifs];
        }
        if (videos.count > 0) {
            HXPhotoModel *model = videos.firstObject;
            [self sendVideoMessage:model.previewPhoto video:model.asset];
        }
    }];
}

- (void)click_camera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showNeedCameraAlert];
        return;
    }
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage,(NSString*)kUTTypeMovie, nil];
        imagePickerController.videoMaximumDuration = 30.f;
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        [self showNeedCameraAlert];
    }
}

#pragma mark - Audio Action

/// 这个时候需要开始录音 设置AudioAlterView状态
- (void)audioTouchDown:(id)sender {
    if ([PlayAudioManager sharedPlayAudioManager].isPlaying) {
        [[PlayAudioManager sharedPlayAudioManager] stopPlayAudio:NO];
    }
    
    @weakify(self)
    [RecordAudio testMicrophone:^(BOOL available, BOOL shouldIgnore) {
        @strongify(self)
        if (shouldIgnore) {
            [self startRecord];
            return;
        }
        if (!available) {
            [self showNeedMicrophoneAlert];
            return;
        }
        if (self.audioBtn.state == UIControlStateNormal) {
            return;
        }
        [self startRecord];
    }];
}

- (void)startRecord {
    [self.recordAudio beginRecord];
    self.recordAudioTimeOverFlag = NO;
    if (self.recordAudio.isRecording) {
        [self.audioBtn setTitle:@"松开发送".lv_localized forState:UIControlStateNormal];
        [self.audioAlertView setViewWithRecordStatus:RecordStatusIsRecording];
        [self.view addSubview:self.audioAlertView];
    }
}

//停止录音，检测时间，发送
- (void)audioTouchUpInside:(id)sender {
    if (self.recordAudioTimeOverFlag == YES) {//超时后再抬起不用处理
        return;
    }
    [self.recordAudio stopRecord];
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    //少于1s的录音
    if (self.recordAudio.duration <= 1) {
        [self.audioAlertView setViewWithRecordStatus:RecordStatusTimeTooShort];
        self.audioBtn.enabled = NO;
        [self performSelector:@selector(handleTouchDownRepeat) withObject:nil afterDelay:1];
        return;
    }
    [self.audioAlertView  removeFromSuperview];
    
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.recordAudio.fileName];
    [self sendVoiceMessage:localPath duration:self.recordAudio.duration];
}

//针对多次恶意点击的情况，将限制按钮的可用与否
- (void)handleTouchDownRepeat {
    [self.audioAlertView removeFromSuperview];
    self.audioBtn.enabled = YES;
}

//取消操作，不需要检测时间以及发送
- (void)audioTouchUpOutside:(id)sender {
    [self.recordAudio stopRecord];
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    [self.audioAlertView removeFromSuperview];
}

//手指在外部移动，更新AudioAlertView状态
- (void)audioTouchDragOutside:(id)sender {
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    [self.audioAlertView setViewWithRecordStatus:RecordStatusWillCancelRecording];
}

- (void)audioTouchDragInside:(id)sender {
    if (self.recordAudio.isRecording) {
        [self.audioBtn setTitle:@"松开发送".lv_localized forState:UIControlStateNormal];
    }
    [self.audioAlertView setViewWithRecordStatus:RecordStatusIsRecording];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEdit:YES];
}

#pragma mark - Send Message
- (void)sendTextMessage {
    
    NSString *text = self.inputTextView.text;
    if (text.length <= 0) {
        [UserInfo showTips:nil des:@"请输入消息内容".lv_localized];
        return;
    }
    [UserInfo show];
    @weakify(self);
    [self.sent fetchChatIds:^(NSArray<NSNumber *> * _Nonnull chatIds) {
        @strongify(self);
        if (chatIds.count == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群发成员信息失败".lv_localized];
            return;
        }
        dispatch_group_t group = dispatch_group_create();
        for (NSNumber *chatId in chatIds) {
            dispatch_group_enter(group);
            if (self.fireMsgBtn.selected) {
//                [[ChatFireConfig shareInstance].fireConfigDic setObject:self.selectPickTime forKey:chatId];
                [[TelegramManager shareInstance] sendReadFireMessage:chatId.longValue Text:text CountDown:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    dispatch_group_leave(group);
                } timeout:^(NSDictionary *request) {
                    dispatch_group_leave(group);
                }];
            } else {
                [[TelegramManager shareInstance] sendTextMessage:chatId.longValue replyid:0 text:text withUserInfoArr:@[] replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    if ([TelegramManager isResultError:response]) {
                        
                    }
                    dispatch_group_leave(group);
                } timeout:^(NSDictionary *request) {
                    dispatch_group_leave(group);
                }];
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [UserInfo dismiss];
            self.inputTextView.text = nil;
            self.fireMsgBtn.hidden = NO;
            self.sent.message = text;
            self.sent.type = GroupSentMsgType_Text;
            [self pop];
        });
    }];
}

- (void)sendVoiceMessage:(NSString *)audioPath duration:(int)duration {
    
    [UserInfo show];
    @weakify(self);
    [self.sent fetchForwadingChatIds:^(NSNumber * _Nonnull firstChatId, NSArray<NSNumber *> * _Nonnull fChatIds) {
        @strongify(self);
        if (!firstChatId || fChatIds.count == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群发成员信息失败".lv_localized];
            return;
        }
        
        if (self.fireMsgBtn.selected) {
            [[TelegramManager shareInstance] sendFireAudioMessage:firstChatId.longValue localAudioPath:audioPath duration:duration fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if ([TelegramManager isResultError:response]) {
                    [UserInfo showTips:nil des:response[@"message"]];
                    return;
                }
                [self forwardMessage:response to:fChatIds];
                self.sent.message = audioPath.lastPathComponent;
                self.sent.duration = duration;
                self.sent.type = GroupSentMsgType_Voice;
                [self pop];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
            }];
        } else {
            [[TelegramManager shareInstance] sendVoiceMessage:firstChatId.longValue localAudioPath:audioPath duration:duration resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if ([TelegramManager isResultError:response]) {
                    [UserInfo showTips:nil des:response[@"message"]];
                    return;
                }
                [self forwardMessage:response to:fChatIds];
                self.sent.message = audioPath.lastPathComponent;
                self.sent.duration = duration;
                self.sent.type = GroupSentMsgType_Voice;
                [self pop];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
            }];
        }
    }];
}

- (void)sendPhotoMessage:(NSArray *)photos {
    
    [UserInfo show];
    @weakify(self);
    [self.sent fetchForwadingChatIds:^(NSNumber * _Nonnull firstChatId, NSArray<NSNumber *> * _Nonnull fChatIds) {
        @strongify(self);
        if (!firstChatId || fChatIds.count == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群发成员信息失败".lv_localized];
            return;
        }
        NSString *firstImagePath;
        dispatch_group_t group = dispatch_group_create();
        for (NSInteger index = 0; index < photos.count; index ++) {
            dispatch_group_enter(group);
            UIImage *image = photos[index];
            UIImage *toSendImage = [Common fixOrientation:image];
            NSString *path = [MNChatViewController localPhotoPath:toSendImage];
            if (index == 0) {
                firstImagePath = path;
            }
            if (!path) {
                dispatch_group_leave(group);
                continue;
            }
            if (self.fireMsgBtn.selected) {
                [[TelegramManager shareInstance] sendFirePhotoMessage:firstChatId.longValue localPath:path photoSize:toSendImage.size fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    if ([TelegramManager isResultError:response]) {
                        [UserInfo showTips:nil des:response[@"message"]];
                        dispatch_group_leave(group);
                        return;
                    }
                    [self forwardMessage:response to:fChatIds];
                    dispatch_group_leave(group);
                } timeout:^(NSDictionary *request) {
                    dispatch_group_leave(group);
                }];
                continue;
            }
            [[TelegramManager shareInstance] sendPhotoMessage:firstChatId.longValue localPath:path photoSize:toSendImage.size replyMarkup:nil resultBlock:^(NSDictionary *request, NSDictionary *response) {
                if ([TelegramManager isResultError:response]) {
                    [UserInfo showTips:nil des:response[@"message"]];
                    dispatch_group_leave(group);
                    return;
                }
                [self forwardMessage:response to:fChatIds];
                dispatch_group_leave(group);
            } timeout:^(NSDictionary *request) {
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [UserInfo dismiss];
            self.sent.message = firstImagePath.lastPathComponent;
            self.sent.type = GroupSentMsgType_Photo;
            [self pop];
        });
    }];
}

- (void)sendGifPhotoMessages:(NSArray<HXPhotoModel *> *)models {
    
    [UserInfo show];
    @weakify(self);
    [self.sent fetchForwadingChatIds:^(NSNumber * _Nonnull firstChatId, NSArray<NSNumber *> * _Nonnull fChatIds) {
        @strongify(self);
        if (!firstChatId || fChatIds.count == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群发成员信息失败".lv_localized];
            return;
        }
        __block NSString *firstImagePath;
        dispatch_group_t group = dispatch_group_create();
        for (NSInteger index = 0; index < models.count; index ++) {
            dispatch_group_enter(group);
            HXPhotoModel *model = models[index];
            NSArray *resourceList = [PHAssetResource assetResourcesForAsset:model.asset];
            PHAssetResource *resource = [resourceList firstObject];
            if (!resource) {
                dispatch_group_leave(group);
                continue;
            }
            UIImage *gifImage = model.previewPhoto;
            [CZCommonTool saveGifImage:resource withImage:gifImage withblock:^(NSString * _Nonnull str) {
                if (!str) {
                    dispatch_group_leave(group);
                    return;
                }
                if (index == 0) {
                    firstImagePath = str;
                }
                [[TelegramManager shareInstance] sendGifPhotoMessage:firstChatId.longValue localPath:str photoSize:gifImage.size resultBlock:^(NSDictionary *request, NSDictionary *response) {
                    if ([TelegramManager isResultError:response]) {
                        [UserInfo showTips:nil des:response[@"message"]];
                        dispatch_group_leave(group);
                        return;
                    }
                    [self forwardMessage:response to:fChatIds];
                    dispatch_group_leave(group);
                } timeout:^(NSDictionary *request) {
                    dispatch_group_leave(group);
                }];
            }];
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [UserInfo dismiss];
            self.sent.message = firstImagePath.lastPathComponent;
            self.sent.type = GroupSentMsgType_Gif;
            [self pop];
        });
    }];
}

- (void)sendVideoMessage:(UIImage *)coverImage video:(id)videoObj {
    NSURL *tempPrivateFileURL = nil;
    if ([videoObj isKindOfClass:[PHAsset class]]) {
        PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:videoObj] firstObject];
        tempPrivateFileURL = [resource valueForKey:@"privateFileURL"];
    } else {
        tempPrivateFileURL = videoObj;
    }
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:tempPrivateFileURL options:nil];
    [UserInfo show:@"正在处理视频文件，请耐心等待".lv_localized];
    [VideoCompress createVideoFileWithAVURLAssert:avAsset result:^(NSError *error, NSString *videoPath, CGSize videoSize, int duration) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UserInfo dismiss];
            if (error != nil) {
                [UserInfo showTips:nil des:error.domain];
            } else {
                [self sendVideoMessage:nil videoPath:videoPath videoSize:videoSize duration:duration];
            }
        });
    }];
}

- (void)sendVideoMessage:(NSString *)coverImagePath videoPath:(NSString *)videoPath videoSize:(CGSize)videoSize duration:(int)duration {
    [UserInfo show];
    @weakify(self);
    [self.sent fetchForwadingChatIds:^(NSNumber * _Nonnull firstChatId, NSArray<NSNumber *> * _Nonnull fChatIds) {
        @strongify(self);
        if (!firstChatId || fChatIds.count == 0) {
            [UserInfo dismiss];
            [UserInfo showTips:nil des:@"获取群发成员信息失败".lv_localized];
            return;
        }
        if (self.fireMsgBtn.selected) {
            [[TelegramManager shareInstance] sendFireVideoMessage:firstChatId.longValue localCoverPath:coverImagePath localVideoPath:videoPath  videoSize:videoSize duration:duration fireLimie:self.selectPickTime resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if ([TelegramManager isResultError:response]) {
                    [UserInfo showTips:nil des:response[@"message"]];
                    return;
                }
                [self forwardMessage:response to:fChatIds];
                self.sent.message = videoPath.lastPathComponent;
                self.sent.duration = duration;
                self.sent.type = GroupSentMsgType_Video;
                [self pop];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
            }];
        } else {
            [[TelegramManager shareInstance] sendVideoMessage:firstChatId.longValue localCoverPath:coverImagePath localVideoPath:videoPath  videoSize:videoSize duration:duration resultBlock:^(NSDictionary *request, NSDictionary *response) {
                [UserInfo dismiss];
                if ([TelegramManager isResultError:response]) {
                    [UserInfo showTips:nil des:response[@"message"]];
                    return;
                }
                [self forwardMessage:response to:fChatIds];
                self.sent.message = videoPath.lastPathComponent;
                self.sent.duration = duration;
                self.sent.type = GroupSentMsgType_Video;
                [self pop];
            } timeout:^(NSDictionary *request) {
                [UserInfo dismiss];
            }];
        }
    }];
}


- (void)forwardMessage:(NSDictionary *)response to:(NSArray *)chatIds {
    MessageInfo *msg = [MessageInfo mj_objectWithKeyValues:response];
    [TelegramManager parseMessageContent:response[@"content"] message:msg];
    for (NSNumber *chatId in chatIds) {
        [TelegramManager.shareInstance forwardMessage:chatId.longValue msg:msg resultBlock:^(NSDictionary *request, NSDictionary *response) {
            
        } timeout:^(NSDictionary *request) {
            
        }];
    }
}

#pragma mark - Method

- (void)pop {
    [MNGroupSentHelper saveMessage:self.sent];
    [self.navigationController popViewControllerAnimated:YES];
    [UserInfo showTips:nil des:@"发送成功".lv_localized];
}

- (void)endEdit:(BOOL)animated {
    [self.view endEditing:YES];
    if(self.toolContainerViewHeight.constant > 0) {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:animated ? 0.35 : 0 animations:^{
            self.toolContainerViewHeight.constant = 0;
            self.toolContainerView.hidden = YES;
            [self.view layoutIfNeeded];
        }];
    }
}

/// 计算文本高度
- (void)resetInputContainerHeight {
    
    NSString *text = self.inputTextView.text;
    CGFloat height = [text boundingRectWithSize: CGSizeMake(SCREEN_WIDTH - 150 - 16, MAXFLOAT)
                                        options: NSStringDrawingUsesLineFragmentOrigin
                                     attributes: @{ NSFontAttributeName: fontRegular(17) }
                                        context: nil].size.height + 18 + 10 + 5;
    CGFloat heightLim = MIN(160, MAX(height, INPUT_CONTAINER_DEFAILT_HEIGHT));
    self.inputContainerViewHeight.constant = heightLim;
}

- (void)showPlaceHolder {
    if (self.fireMsgBtn.selected) {
        if (self.inputTextView.text.length > 0) {
            self.inputTextView.placeholder = @"";
        } else {
            self.inputTextView.placeholder = [NSString stringWithFormat:@"将在%@秒后删除".lv_localized,self.selectPickTime];
        }
    } else {
        self.inputTextView.placeholder = @"";
    }
}

- (void)showNeedCameraAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用相机".lv_localized message:@"请在iPhone的\"设置-隐私-相机\"中允许访问相机".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showNeedMicrophoneAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法使用麦克风".lv_localized message:@"请在iPhone的\"设置-隐私-麦克风\"中允许访问麦克风".lv_localized preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"确定".lv_localized style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Noti
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
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
    
    if([[notification name] isEqualToString:UIKeyboardWillHideNotification]) {
        self.isKeyboardVisible = NO;
        if (self.willShowPanel) {
            self.bottomViewToPBottomOffset.constant = 0;
        } else {
            [self.view layoutIfNeeded];
            [UIView animateWithDuration:0.35 animations:^{
                self.bottomViewToPBottomOffset.constant = 0;
                [self.view layoutIfNeeded];
            }];
        }
    } else {
        self.isKeyboardVisible = YES;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.35 animations:^{
            self.toolContainerView.hidden = YES;
            self.toolContainerViewHeight.constant = 0;
            self.bottomViewToPBottomOffset.constant = endFrame.size.height - kBottomSafeHeight;
            [self.view layoutIfNeeded];
        }];
    }
    self.willShowPanel = NO;
}

#pragma mark - Delegate

#pragma mark MNChatDelayViewDelegate
- (void)chatDelayView:(MNChatDelayView *)chatDelayView isOn:(BOOL)isOn value:(NSInteger)value {
    if (isOn) {
        self.selectPickTime = [NSString stringWithFormat:@"%ld",value];
    } else {
        self.selectPickTime = @"0";
    }
    self.fireMsgBtn.selected = isOn;
    [self showPlaceHolder];
    self.fd_interactivePopDisabled = NO;
}

#pragma mark ModelPannelViewDelegate
- (void)ModelPannelView_Click_Model:(ChatModelType)type {
    switch (type) {
        case ChatModelType_Photo:
            [self click_photo];
            break;
        case ChatModelType_Camera:
            [self click_camera];
            break;
        default:
            break;
    }
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendTextMessage];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

    [self resetInputContainerHeight];
    
    if (textView == self.inputTextView) {
        if (self.inputTextView.hasText) {
            self.inputTextView.placeholder = @"";
            self.fireMsgBtn.hidden = YES;
        } else {
            [self showPlaceHolder];
            self.fireMsgBtn.hidden = NO;
        }
    }
}

#pragma mark RecordAudioDelegate

- (void)timeRemained:(RecordAudio *)recordAudio remainedTime:(double)remainedTime {
    [self.audioAlertView setViewWithRecordStatus:RecordStatusRecordingWillBeOver];
    self.audioAlertView.alertLabel.text = [NSString stringWithFormat:@"%@%ld%@", @"录音还剩".lv_localized, lround(remainedTime), @"秒".lv_localized];
}

- (void)timeIsOver:(RecordAudio*)recordAudio {
    self.recordAudioTimeOverFlag = YES;
    [self.audioAlertView removeFromSuperview];
    [self.audioBtn setTitle:@"按住说话".lv_localized forState:UIControlStateNormal];
    
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", UserVideoPath([UserInfo shareInstance]._id), self.recordAudio.fileName];
    [self sendVoiceMessage:localPath duration:self.recordAudio.duration];
}

#pragma mark ChatEmojiViewDelegate
- (void)ChatEmojiView_Choose:(ChatEmojiView *)view emoji:(NSString *)emoji {
    if(!IsStrEmpty(emoji)) {
        [self.inputTextView insertText:emoji];
        [self resetInputContainerHeight];
    }
}

- (void)ChatEmojiView_Send:(ChatEmojiView *)view {
    [self sendTextMessage];
}

- (void)ChatCollectEmojiView_Choose:(AnimationInfo *)collectModel {
    if(NotNilAndNull(collectModel)) {
//        [[TelegramManager shareInstance] sendCollectGifPhotoMessage:self.chatInfo._id collectEmoji:collectModel resultBlock:^(NSDictionary *request, NSDictionary *response) {
//            if (![TelegramManager isResultError:response]) {
//
//
//
//            }
//        } timeout:^(NSDictionary *request) {
//
//        }];
    }
}
- (void)ChatCollectEmojiView_Delete:(AnimationInfo *)collectModel {
    if(NotNilAndNull(collectModel))
    {
//        [[TelegramManager shareInstance] removeSavedAnimation:collectModel.animation.remote._id resultBlock:^(NSDictionary *request, NSDictionary *response) {
//            if (![TelegramManager isResultError:response]) {
//
//                [self getSavedAnimations];
//
//            }
//        } timeout:^(NSDictionary *request) {
//
//        }];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self sendPhotoMessage:@[image]];
    } else {
        NSURL *video_url = info[UIImagePickerControllerMediaURL];
        [self sendVideoMessage:nil video:video_url];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter
- (MNChatDelayView *)delayView {
    if (!_delayView) {
        _delayView = [[MNChatDelayView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 81)];
        _delayView.delegate = self;
        _delayView.hidden = YES;
    }
    return _delayView;
}

- (RecordAudio *)recordAudio {
    if (!_recordAudio) {
        _recordAudio = [[RecordAudio alloc] init];
        _recordAudio.delegate = self;
    }
    return _recordAudio;
}

- (AudioAlertView *)audioAlertView {
    if (!_audioAlertView) {
        CGRect frame = self.view.bounds;
        _audioAlertView = [[AudioAlertView alloc] initWithFrame:frame];
    }
    return _audioAlertView;
}

@end
