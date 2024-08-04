//
//  TimelinePostProgressView.m
//  GoChat
//
//  Created by Autumn on 2021/12/22.
//

#import "TimelinePostProgressView.h"

#import "UserinfoHelper.h"
#import "TimelineHelper.h"
#import "BlogInfo.h"

@interface TimelinePostProgressView ()<BusinessListenerProtocol>

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIButton *stateButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIProgressView *progress;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *fileIds;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *fileSizes;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *uploadIds;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *uploadSizes;

@property (nonatomic, assign, getter=isShow) BOOL show;

@end

@implementation TimelinePostProgressView

- (void)dealloc {
    [BusinessFramework.defaultBusinessFramework unregisterBusinessListener:self];
}

- (void)dy_initUI {
    [super dy_initUI];
    self.show = NO;
    [BusinessFramework.defaultBusinessFramework registerBusinessListener:self];
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:4];
        iv;
    });
    _stateButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"正在发布".lv_localized forState:UIControlStateNormal];
        [btn setTitle:@"  发布失败，请重试".lv_localized forState:UIControlStateSelected];
        [btn setTitleColor:XHQHexColor(0x878D9A) forState:UIControlStateNormal];
        [btn setTitleColor:XHQHexColor(0xFD4E57) forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"timeline_refresh"] forState:UIControlStateSelected];
        [btn setImage:UIImage.new forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn xhq_addTarget:self action:@selector(reSendTimeline:)];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.enabled = NO;
        btn;
    });
    _closeButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"timeline_close"] forState:UIControlStateNormal];
        [btn xhq_addTarget:self action:@selector(closeSelf)];
        btn.hidden = YES;
        btn;
    });
    _progress = ({
        UIProgressView *view = UIProgressView.new;
        view.trackTintColor = XHQHexColor(0xE5EAF0);
        view.progressTintColor = UIColor.xhq_base;
        view;
    });
    [self addSubview:_avatar];
    [self addSubview:_closeButton];
    [self addSubview:_stateButton];
    [self addSubview:_progress];
    [UserinfoHelper setUserAvatar:UserInfo.shareInstance._id inImageView:_avatar];
    [self fetchSendingBlog];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.leading.mas_equalTo(15);
        make.size.mas_equalTo(30);
    }];
    [_stateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatar.mas_trailing).offset(10);
        make.centerY.height.equalTo(_avatar);
        make.width.mas_equalTo(150);
    }];
    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-10);
        make.centerY.equalTo(_stateButton);
        make.size.mas_equalTo(40);
    }];
    [_progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.height.mas_equalTo(3);
        make.bottom.mas_equalTo(-5);
    }];
}

- (void)fetchSendingBlog {
    [TimelineHelper querySendingBlog:^(NSArray<BlogInfo *> * _Nonnull blogs) {
        if (blogs.count == 0) {
            return;
        }
        self.sendingBlog = blogs.firstObject;
    }];
}

- (void)reSendTimeline:(UIButton *)sender {
    sender.enabled = NO;
    [self.xhq_currentController.view makeToastActivity:CSToastPositionCenter];
    [TimelineHelper resendBlog:self.sendingBlog.ids completion:^(BOOL success) {
        [self.xhq_currentController.view hideToastActivity];
        if (success) {
            [self reloadUIWithFail:NO];
        }
        sender.enabled = YES;
    }];
}

- (void)closeSelf {
    self.show = NO;
    [self resetDatas];
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam {
    switch (notifcationId) {
            /// 文件下载中
        case MakeID(EUserManager, EUser_Td_Message_Video_Ok):
            if ([inParam isKindOfClass:FileInfo.class]) {
                [self processUpdateFile:(FileInfo *)inParam];
            }
            break;
        case MakeID(EUserManager, EUser_Timeline_Update_Fail):
            [self reloadUIWithFail:YES];
            break;
        case MakeID(EUserManager, EUser_Timeline_Update_Success):
            self.show = NO;
            break;
        default:
            break;
    }
}

#pragma mark - event
- (void)processUpdateFile:(FileInfo *)file {
    if (![self.fileIds containsObject:@(file._id)]) {
        return;
    }
    if (![self.uploadIds containsObject:@(file._id)]) {
        [self.uploadIds addObject:@(file._id)];
        [self.uploadSizes addObject:@(file.remote.uploaded_size)];
    } else {
        NSInteger index = [self.uploadIds indexOfObject:@(file._id)];
        [self.uploadSizes replaceObjectAtIndex:index withObject:@(file.remote.uploaded_size)];
    }
    float upload = [[self.uploadSizes valueForKeyPath:@"@sum.floatValue"] floatValue];
    float total = [[self.fileSizes valueForKeyPath:@"@sum.floatValue"] floatValue];
    self.progress.progress = upload / total;
}

- (void)resetDatas {
    _fileIds = NSMutableArray.array;
    _fileSizes = NSMutableArray.array;
    _uploadIds = NSMutableArray.array;
    _uploadSizes = NSMutableArray.array;
    _progress.progress = 0;
}

- (void)reloadUIWithFail:(BOOL)isFail {
    if (isFail) {
        self.closeButton.hidden = NO;
        self.stateButton.selected = YES;
        self.stateButton.enabled = YES;
    } else {
        self.closeButton.hidden = YES;
        self.stateButton.selected = NO;
        self.stateButton.enabled = NO;
    }
}

#pragma mark - setter
- (void)setSendingBlog:(BlogInfo *)sendingBlog {
    _sendingBlog = sendingBlog;
    self.show = YES;
    [self reloadUIWithFail:NO];
    [self resetDatas];
    if (sendingBlog.content.isVideoContent) {
        [self.fileIds addObject:@(sendingBlog.content.video.video._id)];
        [self.fileSizes addObject:@(sendingBlog.content.video.video.expected_size)];
    } else if (sendingBlog.content.isPhotoContent) {
        for (PhotoInfo *photo in sendingBlog.content.photos) {
            [self.fileIds addObject:@(photo.previewPhoto.photo._id)];
            [self.fileSizes addObject:@(photo.previewPhoto.photo.expected_size)];
        }
    }
}

- (void)setShow:(BOOL)show {
    _show = show;
    self.hidden = !show;
    !self.changedBlock ? : self.changedBlock();
}


@end
