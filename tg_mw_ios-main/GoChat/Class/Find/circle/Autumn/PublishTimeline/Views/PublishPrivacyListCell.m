//
//  PublishPrivacyListCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/5.
//

#import "PublishPrivacyListCell.h"

@implementation PublishPrivacyListCellItem

- (CGFloat)cellHeight {
    return 60;
}

@end

@interface PublishPrivacyListCell ()

@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

@implementation PublishPrivacyListCell

- (void)dy_initUI {
    [super dy_initUI];
    
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = true;
    
    _selectedImageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_aTitle;
        label.font = UIFont.xhq_font16;
        label;
    });
    _subtitleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = UIFont.xhq_font12;
        label;
    });
    [self addSubview:_selectedImageView];
    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(15);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY).offset(-2);
        make.leading.mas_equalTo(_selectedImageView.mas_trailing).offset(15);
    }];
    [_subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_titleLabel);
        make.top.mas_equalTo(self.mas_centerY).offset(2);
    }];
}

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    PublishPrivacyListCellItem *m = (PublishPrivacyListCellItem *)item;
    _titleLabel.text = [PublishTimelineVisible visibleTypeTitle:m.type];
    _subtitleLabel.text = [PublishTimelineVisible visibleTypeSubTitle:m.type];
    _selectedImageView.image = [UIImage imageNamed:m.isSelected ? @"icon_choose_sel" : @"icon_choose"];
}


@end
