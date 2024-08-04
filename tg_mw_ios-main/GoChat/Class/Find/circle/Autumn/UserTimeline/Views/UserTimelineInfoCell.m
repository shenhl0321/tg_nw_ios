//
//  UserTimelineInfoCell.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineInfoCell.h"
#import "UserinfoHelper.h"

@implementation UserTimelineInfoCellItem

- (CGSize)cellSize {
    if (!self.isDisplayAllDesc) {
        return CGSizeMake(kScreenWidth(), 125 + 25);
    }
    CGFloat height = MAX(40, self.descHeight);
    return CGSizeMake(kScreenWidth(), height + 75 + 25);
}

- (CGFloat)descHeight {
    CGSize size = CGSizeMake(kScreenWidth() - 45 - 76, CGFLOAT_MAX);
    return [self.desc xhq_sizeWithFont:[UIFont systemFontOfSize:14] withSize:size].height;
}


@end

@interface UserTimelineInfoCell ()

@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UIImageView *genderIcon;
@property (nonatomic, strong) UIButton *ageButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UIButton *more;

@end

@implementation UserTimelineInfoCell

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    UserTimelineInfoCellItem *m = (UserTimelineInfoCellItem *)item;
    self.desc.text = m.desc;
    if (m.isDisplayAllDesc) {
        _desc.numberOfLines = 0;
        _more.hidden = YES;
    } else {
        _more.hidden = m.descHeight < 40;
        _desc.numberOfLines = 2;
    }
    [UserinfoHelper setUsername:m.userid inLabel:_name];
    [UserinfoHelper setUserAvatar:m.userid inImageView:_avatar];
    if (m.ext) {
        NSString *age = [NSString stringWithFormat:@" 年龄%ld岁".lv_localized, m.ext.age];
        NSString *country = [NSString stringWithFormat:@" %@", m.ext.countrys];
        [_ageButton setTitle:age forState:UIControlStateNormal];
        [_locationButton setTitle:country forState:UIControlStateNormal];
        _genderIcon.hidden = _ageButton.hidden = _locationButton.hidden = NO;
        _genderIcon.image = m.ext.sexIcon;
    } else {
//        [_ageButton setTitle:@"中国" forState:UIControlStateNormal];
//        [_locationButton setTitle:@"年龄 18 岁" forState:UIControlStateNormal];
        _genderIcon.hidden = _ageButton.hidden = _locationButton.hidden = YES;
    }
}


- (void)dy_initUI {
    [super dy_initUI];
    self.hideSeparatorLabel = NO;
    self.sideMargin = 15;
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv.backgroundColor = UIColor.xhq_randorm;
        [iv xhq_cornerRadius:38];
        [iv xhq_borderColor:XHQHexColor(0xE5EAF0) borderWidth:1.5];
        iv;
    });
    _genderIcon = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    _name = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = XHQHexColor(0x23272A);
        label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        label.text = @"Username";
        label;
    });
    _ageButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:UIColor.colorFor878D9A forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"icon_info_birthday"] forState:UIControlStateNormal];
        btn;
    });
    _locationButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:UIColor.colorFor878D9A forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
        btn.userInteractionEnabled = NO;
        [btn setImage:[UIImage imageNamed:@"icon_info_address"] forState:UIControlStateNormal];
        btn;
    });
    _desc = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = XHQHexColor(0x878D9A);
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 2;
        label;
    });
    _more = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"更多".lv_localized forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.xhq_assist forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn xhq_addTarget:self action:@selector(moreAction:)];
        btn;
    });
    [self addSubview:_avatar];
    [self addSubview:_genderIcon];
    [self addSubview:_name];
    [self addSubview:_ageButton];
    [self addSubview:_locationButton];
    [self addSubview:_desc];
    [self addSubview:_more];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.top.mas_equalTo(24.5);
        make.size.mas_equalTo(76);
    }];
    [_genderIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.equalTo(_avatar);
        make.size.mas_equalTo(17);
    }];
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_avatar.mas_trailing).offset(15);
        make.trailing.mas_lessThanOrEqualTo(-15);
        make.top.equalTo(_avatar);
    }];
    [_ageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_name);
        make.top.equalTo(_name.mas_bottom).offset(3);
    }];
    [_locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_ageButton);
        make.trailing.mas_equalTo(-15);
    }];
    [_desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_name);
        make.trailing.mas_equalTo(-15);
        make.top.equalTo(_ageButton.mas_bottom).offset(7);
    }];
    [_more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.bottom.mas_equalTo(-5);
        make.size.mas_equalTo(CGSizeMake(30, 20));
    }];
    [self xhq_roundCorners:UIRectCornerTopLeft | UIRectCornerTopRight radius:20];
}

- (void)moreAction:(UIButton *)sender {
    UserTimelineInfoCellItem *item = (UserTimelineInfoCellItem *)self.item;
    item.displayAllDesc = YES;
    !self.responseBlock ? : self.responseBlock();
}

@end


