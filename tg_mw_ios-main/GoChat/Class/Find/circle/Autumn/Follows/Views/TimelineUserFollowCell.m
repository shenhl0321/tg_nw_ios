//
//  TimelineUserFollowCell.m
//  GoChat
//
//  Created by Autumn on 2021/12/16.
//

#import "TimelineUserFollowCell.h"
#import "TimelineHelper.h"
#import "UserinfoHelper.h"

@implementation TimelineUserFollowCellItem

- (CGFloat)cellHeight {
    return 73;
}

@end

@interface TimelineUserFollowCell ()

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation TimelineUserFollowCell

- (void)dy_initUI {
    [super dy_initUI];
    
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = YES;
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:23.5];
        [iv xhq_borderColor:XHQHexColor(0xE5EAF0) borderWidth:1];
        iv;
    });
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_aTitle;
        label.font = UIFont.xhq_font15;
        label.text = @"Username";
        label;
    });
    _followButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = [UIFont semiBoldCustomFontOfSize:14];
        [btn xhq_cornerRadius:8];
        [btn xhq_addTarget:self action:@selector(followAction:)];
        btn;
    });
    [self addSubview:_avatar];
    [self addSubview:_nameLabel];
    [self addSubview:_followButton];
    [self setFollowStatus:NO];
}

- (void)setFollowStatus:(BOOL)isSelect{
    if (isSelect) {
        [self.followButton setTitle:@"已关注".lv_localized forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        [self.followButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.followButton.backgroundColor = [UIColor colorForF5F9FA];
        self.followButton .layer.borderWidth = 0;
        self.followButton .layer.cornerRadius = 8;
    }else{
        [self.followButton setTitle:@"关注".lv_localized forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        [self.followButton setImage:[UIImage imageNamed:@"icon_circle_follow_add"] forState:UIControlStateNormal];
        self.followButton .layer.borderWidth = 1;
        self.followButton .layer.borderColor = [UIColor colorMain].CGColor;
        self.followButton .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.followButton .layer.cornerRadius = 8;
        self.followButton.backgroundColor = [UIColor whiteColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(47);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_avatar.mas_trailing).offset(12);
        make.trailing.equalTo(_followButton.mas_leading).offset(-10);
        make.centerY.mas_equalTo(0);
    }];
    [_followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.trailing.mas_equalTo(-15);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
}

- (void)followAction:(UIButton *)sender {
    if (sender.isSelected) {
        [self.xhq_currentController xhq_actionSheetTitle:nil message:nil cancelTitle:@"取消".lv_localized dataSource:@[@"取消关注".lv_localized] selectedHandler:^(NSString *selectedValue) {
            [self follow:sender];
        }];
    } else {
        [self follow:sender];
    }
}

- (void)follow:(UIButton *)sender {
    BlogUserDate *user = (BlogUserDate *)self.item.cellModel;
    sender.selected = !sender.isSelected;
    sender.backgroundColor = sender.isSelected ? UIColor.lightGrayColor : UIColor.whiteColor;
    [self setFollowStatus:sender];
   
    [TimelineHelper followBlogUser:user.user_id isFollow:sender.isSelected completions:^(BOOL success) {
        if (!success) {
            sender.selected = !sender.isSelected;
            [self setFollowStatus:sender.selected];
        }
    }];
}

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    
    TimelineUserFollowCellItem *m = (TimelineUserFollowCellItem *)item;
    NSString *title = m.userid == UserInfo.shareInstance._id ? @" 回关".lv_localized : @" 关注".lv_localized;
    [_followButton setTitle:title forState:UIControlStateNormal];
    BlogUserDate *user = (BlogUserDate *)item.cellModel;
    [UserinfoHelper setUsername:user.user_id inLabel:_nameLabel];
    [UserinfoHelper setUserAvatar:user.user_id inImageView:_avatar];
    BOOL isFollow = [TimelineHelper.helper.followIds containsObject:@(user.user_id)];
    [self setFollowStatus:isFollow];
}

@end
