//
//  MNGroupHelpCell.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/14.
//

#import "MNGroupHelpCell.h"
#import "GroupSentMessage.h"
#import "TimeFormatting.h"
#import "PlayAudioManager.h"

@implementation MNGroupHelpCell

- (void)resendAction {
    !self.resendBlock ? : self.resendBlock();
}

- (void)initUI{
    [super initUI];
    self.timeLabel.text = @"10.01 20:48";
    self.titleLabel.text = @"155位收信人:".lv_localized;
    self.contentLabel.text = @"AA巴伦博比、BOB、COC、DOD、EOE、阿里巴巴、安琪拉、王昭君、小乔、夏侯惇、刘禅刘邦...".lv_localized;
    self.displayLabel.text = @"展示群发的最后一句话,最多显示2排,多余用多余用...".lv_localized;
    [self.reSendBtn setTitle:@"再发一条".lv_localized forState:UIControlStateNormal];
    self.contentView.backgroundColor = [UIColor colorForF5F9FA];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.contentLabel];
    [self.bgView addSubview:self.displayLabel];
    [self.bgView addSubview:self.photoImageView];
    [self.photoImageView addSubview:self.playButton];
    [self.photoImageView addSubview:self.GifLabel];
    [self.bgView addSubview:self.reSendBtn];
    [self.bgView addSubview:self.lineView];
    [self.bgView addSubview:self.voiceContainer];
    [self.voiceContainer addSubview:self.voiceImageView];
    [self.contentView addSubview:self.timeLabel];
    
    @weakify(self);
    [self.voiceImageView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        if (self.voiceImageView.isAnimating) {
            [self voiceStop];
        } else {
            [self voicePlay];
        }
    }];
    [self.voiceContainer xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        if (self.voiceImageView.isAnimating) {
            [self voiceStop];
        } else {
            [self voicePlay];
        }
    }];
    
    [self.photoImageView xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        if (self.msg.type == GroupSentMsgType_Video) {
            !self.videoBlock ? : self.videoBlock();
        } else {
            !self.photoBlock ? : self.photoBlock();
        }
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(50);
        make.height.mas_equalTo(220);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14.5);
        make.top.mas_equalTo(15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.height.mas_equalTo(40);
    }];
    [self.displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(48);
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(30);
    }];
    [self.photoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(20);
        make.size.mas_equalTo(100);
    }];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(40);
    }];
    [self.GifLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-5);
        make.bottom.mas_equalTo(-2);
    }];
    [self.voiceContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.displayLabel);
        make.size.mas_equalTo(CGSizeMake(120, 45));
    }];
    [self.voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.size.mas_equalTo(32);
    }];
    [self.reSendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(80, 32));
        make.bottom.mas_equalTo(-15);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(15);
    }];
}

- (void)voicePlay {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:5];
    for (int i = 1; i <= 5; ++i) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"g_ic_voice_0%d", i]];
        [images addObject:image];
    }
    _voiceImageView.animationImages = images;
    _voiceImageView.animationDuration = 1;
    [_voiceImageView startAnimating];
    !self.voiceBlock ? : self.voiceBlock();
}

- (void)voiceStop {
    [_voiceImageView stopAnimating];
    _voiceImageView.image = [UIImage imageNamed:@"g_ic_voice_05"];
    if (PlayAudioManager.sharedPlayAudioManager.isPlaying) {
        [PlayAudioManager.sharedPlayAudioManager stopPlayAudio:NO];
    }
}

#pragma mark - setter
- (void)setMsg:(GroupSentMessage *)msg {
    _msg = msg;
    _contentLabel.text = msg.usernames;
    _titleLabel.text = [NSString stringWithFormat:@"%ld位收信人".lv_localized, msg.users.count];
    _timeLabel.text = [TimeFormatting formatTimeWithTimeInterval:msg.time];
    _displayLabel.hidden = YES;
    _photoImageView.hidden = YES;
    _playButton.hidden = YES;
    _voiceContainer.hidden = YES;
    self.GifLabel.hidden = YES;
    switch (msg.type) {
        case GroupSentMsgType_Text:
            _displayLabel.text = msg.message;
            _displayLabel.hidden = NO;
            break;
        case GroupSentMsgType_Voice:
            _voiceContainer.hidden = NO;
            break;
        case GroupSentMsgType_Photo: {
            _photoImageView.image = [UIImage imageWithContentsOfFile:msg.mediaPath];
            _photoImageView.hidden = NO;
        }
            break;
        case GroupSentMsgType_Gif:
            _photoImageView.image = [UIImage imageWithContentsOfFile:msg.mediaPath];
            _photoImageView.hidden = NO;
            self.GifLabel.hidden = NO;
            break;
        case GroupSentMsgType_Video: {
            _photoImageView.image = [UIImage thumbnailForVideoPath:msg.mediaPath];
            _photoImageView.hidden = NO;
            _playButton.hidden = NO;
        }
            break;
    }
}

#pragma mark - getter

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 13;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

-(UIButton *)reSendBtn{
    if (!_reSendBtn) {
        _reSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reSendBtn setTitle:@"再发一条".lv_localized forState:UIControlStateNormal];
        [_reSendBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        _reSendBtn.titleLabel.font = fontRegular(15);
        _reSendBtn.layer.cornerRadius = 7;
        _reSendBtn.layer.borderColor = [UIColor colorMain].CGColor;
        _reSendBtn.layer.borderWidth = 0.5;
        [_reSendBtn addTarget:self action:@selector(resendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reSendBtn;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontRegular(14);
        _titleLabel.textColor = [UIColor colorFor878D9A];
    }
    return _titleLabel;
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = fontRegular(14);
        _contentLabel.textColor = [UIColor colorFor878D9A];
        _contentLabel.numberOfLines = 2;
    }
    return _contentLabel;
}

-(UILabel *)displayLabel{
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] init];
        _displayLabel.font = fontRegular(17);
        _displayLabel.textColor = [UIColor colorTextFor23272A];
        _displayLabel.numberOfLines = 2;
        _displayLabel.lineBreakMode = NSLineBreakByTruncatingHead;
    }
    return _displayLabel;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = fontRegular(14);
        _timeLabel.textColor = [UIColor colorFor878D9A];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    return _timeLabel;
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] init];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.clipsToBounds = YES;
    }
    return _photoImageView;
}

- (UIImageView *)voiceImageView {
    if (!_voiceImageView) {
        _voiceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"g_ic_voice_05"]];
    }
    return _voiceImageView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"icon_video_play"] forState:UIControlStateNormal];
            btn.userInteractionEnabled = NO;
            btn;
        });
    }
    return _playButton;
}

- (UILabel *)GifLabel {
    if (!_GifLabel) {
        _GifLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = UIColor.whiteColor;
            label.font = [UIFont regularCustomFontOfSize:13];
            label.text = @"GIF";
            label;
        });
    }
    return _GifLabel;
}

- (UIView *)voiceContainer {
    if (!_voiceContainer) {
        _voiceContainer = ({
            UIView *view = UIView.new;
            view.backgroundColor = [UIColor.colorMain colorWithAlphaComponent:0.1];
            [view xhq_cornerRadius:5];
            view;
        });
    }
    return _voiceContainer;
}

@end
