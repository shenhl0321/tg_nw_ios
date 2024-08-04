//
//  PublishTimelineRemindTitleCell.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineRemindTitleCell.h"

@implementation PublishTimelineRemindTitleCellItem

- (CGSize)cellSize {
    return CGSizeMake(kScreenWidth() - 40, 40);
}

@end

@interface PublishTimelineRemindTitleCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation PublishTimelineRemindTitleCell

- (void)dy_initUI {
    [super dy_initUI];
    
    _titleLabel = ({
        UILabel *label = [UILabel xhq_layoutColor:UIColor.xhq_aTitle
                                             font:UIFont.xhq_font17
                                             text:@"提醒谁看".lv_localized];
        label;
    });
    
    [self addSubview:_titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
}

@end
