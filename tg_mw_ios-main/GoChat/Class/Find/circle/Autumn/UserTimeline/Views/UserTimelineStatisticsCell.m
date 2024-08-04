//
//  UserTimelineStatisticsCell.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineStatisticsCell.h"

@implementation UserTimelineStatisticsCellItem

- (CGSize)cellSize {
    return CGSizeMake(kScreenWidth() / 4.0, 50);
}

- (NSString *)titleOfType {
    switch (self.type) {
        case UserTimelineStatisticsType_Blogs:
            return @"动态".lv_localized;
        case UserTimelineStatisticsType_Followed:
            return @"关注".lv_localized;
        case UserTimelineStatisticsType_Followers:
            return @"粉丝".lv_localized;
        case UserTimelineStatisticsType_Liked:
            return @"获赞".lv_localized;
    }
}

- (BOOL)isLastOne {
    return self.type == UserTimelineStatisticsType_Liked;
}

- (NSString *)numberString {
    if (self.number <= 0) {
        return @"0";
    }
    NSInteger temp = 100000000;
    NSString *unit = @"亿".lv_localized;
    if (self.number / temp > 0) {
        return [NSString stringWithFormat:@"%.f%@", self.number * 1.0 / temp, unit];
    }
    temp = 10000;
    unit = @"万".lv_localized;
    if (self.number / temp > 0) {
        return [NSString stringWithFormat:@"%.f%@", self.number * 1.0 / temp, unit];
    }
    return [NSString stringWithFormat:@"%ld", self.number];
}

- (NSString *)alertMessage {
    if (self.type == UserTimelineStatisticsType_Blogs) {
        return [NSString stringWithFormat:@"共发表%ld条动态".lv_localized, self.number];
    } else if (self.type == UserTimelineStatisticsType_Liked) {
        return [NSString stringWithFormat:@"共获赞%ld个".lv_localized, self.number];
    }
    return @"";
}

@end

@interface UserTimelineStatisticsCell ()

@property (nonatomic, strong) UILabel *number;
@property (nonatomic, strong) UIView *line;

@end

@implementation UserTimelineStatisticsCell



- (void)setItem:(DYCollectionViewCellItem *)item {
    [super setItem:item];
    UserTimelineStatisticsCellItem *m = (UserTimelineStatisticsCellItem *)item;
    _line.hidden = m.isLastOne;
    _number.text = [m.numberString stringByAppendingString:m.titleOfType];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    _number = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorFor878D9A];
        label.font = [UIFont semiBoldCustomFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    _line = ({
        UIView *view = UIView.new;
        view.backgroundColor = [UIColor colorFor878D9A];
        view;
    });
    [self addSubview:_number];
    [self addSubview:_line];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_number mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.leading.mas_lessThanOrEqualTo(5);
        make.trailing.mas_lessThanOrEqualTo(-5);
    }];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(0.5, 15));
    }];
}

@end
