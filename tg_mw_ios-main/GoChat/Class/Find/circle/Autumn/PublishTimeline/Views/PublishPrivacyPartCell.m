//
//  PublishPrivacyPartCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/5.
//

#import "PublishPrivacyPartCell.h"

@implementation PublishPrivacyPartCellItem

- (CGFloat)cellHeight {
    return 50;
}

- (NSString *)nameOfType {
    switch (self.type) {
        case PublishPrivacyPartTypeGroup:
            return @"从群选择".lv_localized;
        case PublishPrivacyPartTypeContact:
            return @"从通讯录选择".lv_localized;
    }
}

@end


@interface PublishPrivacyPartCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation PublishPrivacyPartCell

- (void)dy_initUI {
    [super dy_initUI];
    
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = true;
    
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_base;
        label.font = UIFont.xhq_font14;
        label;
    });
    _contentLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = UIFont.xhq_font12;
        label;
    });
    [self addSubview:_titleLabel];
    [self addSubview:_contentLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    PublishPrivacyPartCellItem *item = (PublishPrivacyPartCellItem *)self.item;
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(45);
        if (item.names.count > 0) {
            make.bottom.mas_equalTo(self.mas_centerY).offset(-2);
        } else {
            make.centerY.mas_equalTo(0);
        }
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_titleLabel);
        make.trailing.mas_equalTo(-15);
        make.top.mas_equalTo(self.mas_centerY).offset(2);
    }];
}

- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    PublishPrivacyPartCellItem *m = (PublishPrivacyPartCellItem *)item;
    _titleLabel.text = m.nameOfType;
    _contentLabel.text = [m.names componentsJoinedByString:@","];
    [self layoutIfNeeded];
}


@end
