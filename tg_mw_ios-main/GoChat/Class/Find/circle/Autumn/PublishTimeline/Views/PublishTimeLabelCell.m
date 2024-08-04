//
//  PublishTimeLabelCell.m
//  GoChat
//
//  Created by Autumn on 2022/3/5.
//

#import "PublishTimeLabelCell.h"

@implementation PublishTimeLabelCellItem

- (CGSize)cellSize {
    return CGSizeMake(75, 32);
}

@end

@interface PublishTimeLabelCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation PublishTimeLabelCell

#pragma mark - setter
- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    PublishTimeLabelCellItem *m = (PublishTimeLabelCellItem *)item;
    switch (m.label) {
        case PublishTimeLabelType_At:
            _titleLabel.text = @"@提及".lv_localized;
            break;
        case PublishTimeLabelType_Topic:
            _titleLabel.text = @"#话题".lv_localized;
            break;
    }
}

- (void)dy_initUI {
    [super dy_initUI];
    self.backgroundColor = UIColor.colorMain;
    [self xhq_cornerRadius:16];
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont regularCustomFontOfSize:15];
        label;
    });
    [self addSubview:_titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
    }];
}

@end
