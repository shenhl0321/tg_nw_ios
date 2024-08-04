//
//  TransferUserCell.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferUserCell.h"
#import "UserinfoHelper.h"
#import "TransferObject.h"

@implementation TransferUserCellItem

- (CGFloat)cellHeight {
    return 160;
}


@end

@interface TransferUserCell ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatar;

@end

@implementation TransferUserCell

#pragma mark - setter
- (void)setItem:(DYTableViewCellItem *)item {
    [super setItem:item];
    TransferObject *m = (TransferObject *)item.cellModel;
    [UserinfoHelper setUsername:m.userid inLabel:_nameLabel];
    [UserinfoHelper setUserAvatar:m.userid inImageView:_avatar];
}

- (void)dy_initUI {
    [super dy_initUI];
    [self dy_noneSelectionStyle];
    self.hideSeparatorLabel = YES;
    _nameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorTextFor23272A];
        label.font = [UIFont semiBoldCustomFontOfSize:16];
        label.text = @"昵称".lv_localized;
        label;
    });
    _avatar = ({
        UIImageView *iv = [[UIImageView alloc] init];
        [iv xhq_cornerRadius:35];
        iv;
    });
    [self addSubview:_nameLabel];
    [self addSubview:_avatar];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(_avatar.mas_bottom).offset(10);
    }];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(70);
    }];
}

@end
