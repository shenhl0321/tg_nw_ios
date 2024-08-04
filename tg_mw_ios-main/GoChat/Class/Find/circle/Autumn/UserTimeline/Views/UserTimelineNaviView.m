//
//  UserTimelineNaviView.m
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "UserTimelineNaviView.h"
#import "UserinfoHelper.h"
#import "TimelineHelper.h"

#import "TimelineMessageVC.h"

@interface UserTimelineNaviView ()

@property (nonatomic, assign) NSInteger userid;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *messageButton;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation UserTimelineNaviView

- (instancetype)initWithUserid:(NSInteger)userid {
    self.userid = userid;
    self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth(), kNavigationStatusHeight())];
    if (self) {
    }
    return self;
}

- (void)dy_initUI {
    [super dy_initUI];
    _backButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_circle_photo_back"] forState:UIControlStateNormal];
        [btn xhq_addTarget:self action:@selector(bakAction)];
        btn;
    });
    _messageButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"icon_photo_tip"] forState:UIControlStateNormal];
        [btn xhq_addTarget:self action:@selector(messageAction)];
        btn;
    });
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = COLOR_C1;
        label.font = [UIFont boldSystemFontOfSize:FONT_S1];
        label;
    });
    _badgeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = XHQHexColor(0xFD4E57);
        label.textColor = UIColor.whiteColor;
        label.hidden = YES;
        label.font =  [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        [label xhq_cornerRadius:8];
        label;
    });
    [self addSubview:_nameLabel];
    [self addSubview:_backButton];
    [self addSubview:_messageButton];
    [self addSubview:_badgeLabel];
//    [UserinfoHelper setUsername:self.userid inLabel:_nameLabel];
    
    _messageButton.hidden = UserInfo.shareInstance._id != self.userid;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBarHeights());
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(kNavigationBarHeight());
    }];
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_nameLabel);
        make.leading.mas_equalTo(15);
        make.size.mas_equalTo(34);
    }];
    [_messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.centerY.equalTo(_backButton);
        make.trailing.mas_equalTo(-15);
    }];
    [_badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_messageButton.mas_trailing).offset(-4);
        make.centerY.equalTo(_messageButton.mas_top).offset(2);
        make.size.mas_equalTo(16);
    }];
}

- (void)bakAction {
    [self.xhq_currentController.navigationController popViewControllerAnimated:YES];
}

- (void)messageAction {
    TimelineMessageVC *message = [[TimelineMessageVC alloc] init];
    [self.xhq_currentController.navigationController pushViewController:message animated:YES];
}

- (void)reloadData {
    if (UserInfo.shareInstance._id != self.userid) {
        return;
    }
    [TimelineHelper queryUnreadCountCompletion:^(NSInteger count) {
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", count];
        self.badgeLabel.hidden = count == 0;
    }];
}

- (void)bindScrollView:(UIScrollView *)scrollView {
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY > 0) {
        self.backgroundColor = UIColor.whiteColor;
        return;
    }
    CGFloat value = scrollView.contentInset.top - CGRectGetHeight(self.frame);
    CGFloat alpha = (-1 *contentOffsetY - CGRectGetHeight(self.frame)) / value;
    alpha = MIN(MAX(alpha, 0), 1);
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1-alpha];
}

@end
