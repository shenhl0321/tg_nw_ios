//
//  TimelineMessageCell.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineMessageCell.h"
#import "PhotoImageView.h"
#import "BlogMessage.h"
#import "UserinfoHelper.h"

@implementation TimelineMessageCellItem

@end

@interface TimelineMessageCell ()

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) PhotoImageView *photoView;

@end

@implementation TimelineMessageCell

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    BlogMessage *m = (BlogMessage *)item.cellModel;
    [UserinfoHelper setUsername:m.userid inLabel:_nameLabel];
    [UserinfoHelper setUserAvatar:m.userid inImageView:_avatar];
    _timeLabel.text = m.time;
    _contentLabel.text = m.content;
    @weakify(self);
    [m subReplyContent:^(NSAttributedString * _Nonnull attribute) {
        @strongify(self);
        self.contentLabel.attributedText = attribute;
    }];
    [m fetchBlogInfo:^{
        @strongify(self);
        if (m.blog.content.isPhotoContent) {
            self.photoView.photo = m.blog.content.photos.firstObject;
        } else {
            self.photoView.thumbnail = m.blog.content.video.thumbnail;
        }
    }];
}

- (void)dy_initUI {
    [super dy_initUI];
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:20];
        iv.backgroundColor = UIColor.xhq_randorm;
        iv;
    });
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_base;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        label.text = @"用户名".lv_localized;
        label;
    });
    _contentLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.blackColor;
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = 0;
        label.text = @"内容".lv_localized;
        label;
    });
    _timeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = XHQHexColor(0xA9B0BF);
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"10:10";
        label;
    });
    _photoView = ({
        PhotoImageView *iv = [[PhotoImageView alloc] init];
        [iv xhq_cornerRadius:7];
        iv;
    });
    [self addSubview:_avatar];
    [self addSubview:_nameLabel];
    [self addSubview:_timeLabel];
    [self addSubview:_contentLabel];
    [self addSubview:_photoView];
    self.hyb_lastViewsInCell = @[_timeLabel, _photoView];
    self.hyb_bottomOffsetToCell = 0;
    self.hideSeparatorLabel = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.leading.mas_equalTo(15);
        make.size.mas_equalTo(40);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatar.mas_trailing).offset(10);
        make.top.equalTo(_avatar.mas_top).offset(1);
        make.trailing.lessThanOrEqualTo(_photoView.mas_leading).offset(-10);
    }];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_nameLabel);
        make.trailing.equalTo(_photoView.mas_leading).offset(-10);
        make.top.equalTo(_nameLabel.mas_bottom).offset(6);
    }];
    _contentLabel.preferredMaxLayoutWidth = kScreenWidth() - 60 - 10 - 10 - 70 - 15;
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_contentLabel);
        make.top.equalTo(_contentLabel.mas_bottom).offset(7);
    }];
    [_photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_avatar);
        make.trailing.mas_equalTo(-15);
        make.size.mas_equalTo(70);
    }];
}


@end
