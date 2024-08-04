//
//  TransferInfoContentCell.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferInfoContentCell.h"

@implementation TransferInfoContentCellItem



@end

@interface TransferInfoContentCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation TransferInfoContentCell

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    TransferInfoContentCellItem *m = (TransferInfoContentCellItem *)item;
    _titleLabel.text = m.title;
    _contentLabel.text = m.content;
}

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = YES;
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorFor878D9A;
        label.font = [UIFont regularCustomFontOfSize:14];
        label;
    });
    _contentLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.font = [UIFont regularCustomFontOfSize:14];
        label.textAlignment = NSTextAlignmentRight;
        label.numberOfLines = 0;
        label;
    });
    [self addSubview:_titleLabel];
    [self addSubview:_contentLabel];
    self.hyb_lastViewInCell = _contentLabel;
    self.hyb_bottomOffsetToCell = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.leading.mas_equalTo(25);
    }];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel);
        make.trailing.mas_equalTo(-25);
        make.leading.equalTo(_titleLabel.mas_trailing).offset(25);
    }];
}

@end
