//
//  PublishTimelineRemindHeaderView.m
//  GoChat
//
//  Created by Autumn on 2021/11/9.
//

#import "PublishTimelineRemindHeaderView.h"

@implementation PublishTimelineRemindHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        UILabel *titleLabel = ({
            UILabel *label = [UILabel xhq_layoutColor:UIColor.xhq_aTitle
                                                 font:UIFont.xhq_font17
                                                 text:@"提醒谁看".lv_localized];
            label;
        });
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(25);
            make.centerY.mas_equalTo(0);
        }];
    }
    return self;
}

@end
