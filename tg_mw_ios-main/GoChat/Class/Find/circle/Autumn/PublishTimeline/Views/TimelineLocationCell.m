//
//  TimelineLocationCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/17.
//

#import "TimelineLocationCell.h"

@implementation TimelineLocationCellItem

- (CGFloat)cellHeight {
    return 50;
}

@end

@interface TimelineLocationCell ()

@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *addressLabel;

@end

@implementation TimelineLocationCell

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    _selectImageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_aTitle;
        label.font = [UIFont systemFontOfSize:15];
        label;
    });
    _addressLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = [UIFont systemFontOfSize:12];
        label.text = @"";
        label;
    });
    [self addSubview:_titleLabel];
    [self addSubview:_addressLabel];
    [self addSubview:_selectImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(15);
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_selectImageView.mas_trailing).offset(10);
        if (_addressLabel.text.length == 0) {
            make.centerY.mas_equalTo(0);
        } else {
            make.bottom.mas_equalTo(self.mas_centerY).offset(-2);
        }
    }];
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_titleLabel);
        make.trailing.mas_equalTo(-10);
        make.top.mas_equalTo(self.mas_centerY).offset(2);
    }];
}

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    TimelineLocationCellItem *m = (TimelineLocationCellItem *)item;
    _selectImageView.image = [UIImage imageNamed:m.isSelected ? @"icon_choose_sel" : @"icon_choose"];
    _addressLabel.text = @"";
    if (m.poi) {
        _titleLabel.text = m.poi.name;
        _addressLabel.text = m.poi.address;
    } else if (m.city) {
        _titleLabel.text = m.city;
    } else if (m.isNone) {
        _titleLabel.text = @"不显示位置".lv_localized;
    }
    [self layoutIfNeeded];
}

@end
