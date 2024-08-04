//
//  CreateTagsSectionHeaderView.m
//  GoChat
//
//  Created by Autumn on 2021/11/9.
//

#import "CreateTagsSectionHeaderView.h"


@implementation CreateTagsSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.xhq_content;
        label.font = [UIFont systemFontOfSize:13];
        label;
    });
    [self addSubview:_titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.bottom.mas_equalTo(-10);
    }];
}

@end
