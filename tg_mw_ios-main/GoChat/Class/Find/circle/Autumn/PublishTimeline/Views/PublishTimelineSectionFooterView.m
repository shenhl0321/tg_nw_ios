//
//  PublishTimelineSectionFooterView.m
//  GoChat
//
//  Created by Autumn on 2021/11/4.
//

#import "PublishTimelineSectionFooterView.h"

@implementation PublishTimelineSectionFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorTextForE5EAF0];
        [self addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(0);
            make.left.mas_equalTo(25);
            make.right.mas_equalTo(-25);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}


@end
