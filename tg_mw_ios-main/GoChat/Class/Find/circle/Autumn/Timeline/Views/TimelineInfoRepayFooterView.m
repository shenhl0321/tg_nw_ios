//
//  TimelineInfoRepayFooterView.m
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "TimelineInfoRepayFooterView.h"

@interface TimelineInfoRepayFooterView ()

@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UILabel *tip;

@end

@implementation TimelineInfoRepayFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = UIColor.whiteColor;
    _arrow = ({
        UIImageView *iv = [[UIImageView alloc] init];
        @weakify(self);
        [iv xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            [self moreAction];
        }];
        iv;
    });
    _tip = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = XHQHexColor(0x878D9A);
        label.font = UIFont.xhq_font14;
        label.text = @"- 收起回复 -".lv_localized;
        @weakify(self);
        [label xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            [self moreAction];
        }];
        label;
    });
    _bottomLine = ({
        UIView *view = UIView.new;
        view.backgroundColor = UIColor.xhq_line;
        view;
    });
    [self addSubview:_arrow];
    [self addSubview:_tip];
    [self addSubview:_bottomLine];
}

- (void)moreAction {
    NSInteger current = self.currentDisplayNumber;
    switch (self.displayMode) {
        case RepayListDisplayMode_All:
            current += 5;
            _displayMode = RepayListDisplayMode_More;
            break;
        case RepayListDisplayMode_More:
            current += 3;
            _displayMode = RepayListDisplayMode_More;
            break;
        case RepayListDisplayMode_Close:
            _displayMode = RepayListDisplayMode_All;
            break;
        default:
            break;
    }
    if (current > self.totalDisplayNumber && _displayMode != RepayListDisplayMode_All) {
        _displayMode = RepayListDisplayMode_Close;
    }
    !self.moreBlock ? : self.moreBlock();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(@5);
    }];
    [_tip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(_arrow.mas_bottom).offset(0);
        make.height.equalTo(@25);
    }];
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.trailing.equalTo(@-15);
        make.bottom.equalTo(@0);
        make.height.equalTo(@0.7);
    }];
}

- (void)setDisplayMode:(RepayListDisplayMode)displayMode {
    _displayMode = displayMode;
    _tip.hidden = _arrow.hidden = NO;
    _arrow.image = [UIImage imageNamed:@"icon_timeline_down"];
    switch (displayMode) {
        case RepayListDisplayMode_All:
            _tip.text = [NSString stringWithFormat:@"- 展开%ld条回复 -".lv_localized, self.totalDisplayNumber - 1];
            break;
        case RepayListDisplayMode_More:
            _tip.text = @"- 展开更多回复 -".lv_localized;
            break;
        case RepayListDisplayMode_Close:
            _tip.text = @"- 收起回复 -".lv_localized;
            _arrow.image = [UIImage imageNamed:@"icon_timeline_up"];
            break;
        case RepayListDisplayMode_None:
            _tip.text = @"";
            _tip.hidden = _arrow.hidden = YES;
            break;
    }
}

@end
