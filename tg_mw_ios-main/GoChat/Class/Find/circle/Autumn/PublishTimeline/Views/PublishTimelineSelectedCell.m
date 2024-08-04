//
//  PublishTimelineSelectedCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineSelectedCell.h"

@implementation PublishTimelineSelectedCellItem

- (CGSize)cellSize {
    return CGSizeMake(kScreenWidth() - 40, 55);
}

@end

@interface PublishTimelineSelectedCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation PublishTimelineSelectedCell

- (void)dy_initUI {
    [super dy_initUI];
    
    _titleLabel = ({
        UILabel *label = [UILabel xhq_layoutColor:UIColor.xhq_aTitle
                                             font:UIFont.xhq_font17
                                             text:@""];
        label.font = [UIFont helveticaFontOfSize:17];
        label.textColor = [UIColor colorTextFor000000];
        label;
    });
    _contentLabel = ({
        UILabel *label = [UILabel xhq_layoutColor:UIColor.xhq_content
                                             font:UIFont.xhq_font15
                                             text:@""];
        label.font = [UIFont regularCustomFontOfSize:15];
        label.textColor = [UIColor colorFor878D9A];
        label.textAlignment = NSTextAlignmentRight;
        label;
    });
    _arrowImageView = ({
        UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CellArrow"]];
        iv;
    });
    
    [self addSubview:_titleLabel];
    [self addSubview:_contentLabel];
    [self addSubview:_arrowImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(5, 12));
    }];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.trailing.mas_equalTo(_arrowImageView.mas_leading).offset(-10);
        make.leading.mas_lessThanOrEqualTo(_titleLabel.mas_trailing).offset(10);
    }];
}

- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    PublishTimelineSelectedCellItem *m = (PublishTimelineSelectedCellItem *)item;
    _titleLabel.text = m.title;
    _contentLabel.text = m.content;
    _contentLabel.textColor = !m.isChangeColor ? [UIColor colorFor878D9A] : [UIColor colorMain];
}

@end
