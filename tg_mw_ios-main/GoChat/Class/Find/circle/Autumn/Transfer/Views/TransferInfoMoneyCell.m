//
//  TransferInfoMoneyCell.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferInfoMoneyCell.h"
#import "Transfer.h"

@implementation TransferInfoMoneyCellItem

- (CGFloat)cellHeight {
    return 290;
}

@end

@interface TransferInfoMoneyCell ()

@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation TransferInfoMoneyCell

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    Transfer *t = (Transfer *)item.cellModel;
    _moneyLabel.text = t.money;
    _statusImageView.image = t.icon;
    _tipLabel.hidden = !t.showRemindView;
    @weakify(self);
    [t tipMessage:^(NSString * _Nonnull msg) {
        @strongify(self);
        self.statusLabel.text = msg;
    }];
}

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = YES;
    _statusImageView = ({
        UIImageView *iv = [[UIImageView alloc] init];
        iv;
    });
    _statusLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.textAlignment = 1;
        label.font = [UIFont regularCustomFontOfSize:16];
        label;
    });
    _moneyLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorTextFor23272A;
        label.font = [UIFont semiBoldCustomFontOfSize:44];
        label;
    });
    _tipLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = UIColor.colorFor878D9A;
        label.font = [UIFont regularCustomFontOfSize:14];
        label.text = @"1天内对方未收款，将退还给你。 提醒对方收款".lv_localized;
        NSRange range = [label.text rangeOfString:@"提醒对方收款".lv_localized];
        [label xhq_AttributeTextAttributes:@{NSForegroundColorAttributeName: UIColor.xhq_base} range:range];
        label;
    });
    
    [self addSubview:_statusLabel];
    [self addSubview:_statusImageView];
    [self addSubview:_moneyLabel];
    [self addSubview:_tipLabel];
    @weakify(self);
    [_tipLabel xhq_addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        !self.responseBlock ? : self.responseBlock();
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.size.mas_equalTo(70);
        make.centerX.mas_equalTo(0);
    }];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(_statusImageView.mas_bottom).offset(40);
        make.leading.lessThanOrEqualTo(@25);
        make.trailing.lessThanOrEqualTo(@-25);
    }];
    [_moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(_statusLabel.mas_bottom).offset(5);
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_moneyLabel.mas_bottom).offset(15);
        make.centerX.mas_equalTo(0);
    }];
}

@end
