//
//  AddressItemCell.m
//  GoChat
//
//  Created by Demi on 2021/9/5.
//

#import "AddressItemCell.h"
#import "AddressItemModel.h"
@interface AddressItemCell()

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *addressNameLab;
@property (nonatomic, strong) UILabel *remarkNameLab;
@property (nonatomic, strong) UIButton *statusBtn;
@property (nonatomic, strong) UILabel *statusLab;
@property (nonatomic, strong) UIView *lineV;

@end

@implementation AddressItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews{
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.addressNameLab];
    [self.contentView addSubview:self.remarkNameLab];
    [self.contentView addSubview:self.statusLab];
    [self.contentView addSubview:self.statusBtn];
    [self.contentView addSubview:self.lineV];
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(9);
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(42);
    }];
    
    [self.addressNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(self.iconImgV.mas_right).offset(13);
//        make.height.mas_equalTo(18);
        make.bottom.mas_equalTo(-34);
        
    }];
    
    [self.remarkNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addressNameLab.mas_bottom);
        make.left.mas_equalTo(self.addressNameLab.mas_left);
        make.height.mas_equalTo(17);
    }];
    
    [self.statusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(56);
        make.height.mas_equalTo(30);
    }];
    [self.statusLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-22);
        make.centerY.mas_equalTo(0);
        make.width.mas_equalTo(66);
        make.height.mas_equalTo(30);
    }];
    [self.lineV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.addressNameLab.mas_bottom).mas_offset(32);
        make.left.mas_equalTo(self.addressNameLab.mas_left);
        make.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setModel:(AddressItemModel *)model {
    _model = model;
    self.addressNameLab.text = model.name;
    self.remarkNameLab.hidden = YES;
    self.statusBtn.hidden = NO;
    self.statusLab.hidden = YES;
#pragma mark - 默认显示发消息
//    if (model.is_contact) {//是好友
//        self.remarkNameLab.hidden = NO;
//        self.remarkNameLab.text = [NSString stringWithFormat:@"gochat：%@",model.nickname];
//        self.statusBtn.hidden = YES;
//        self.statusLab.hidden = NO;
//    }
    self.remarkNameLab.hidden = NO;
    self.remarkNameLab.text = [NSString stringWithFormat:@"gochat：%@",model.nickname];
    self.statusBtn.hidden = YES;
    self.statusLab.hidden = NO;
    
    if (model.profile_photo != nil) {
        ProfilePhoto * profile_photo = [ProfilePhoto mj_objectWithKeyValues:model.profile_photo];
        if(!profile_photo.isSmallPhotoDownloaded){
            self.iconImgV.image = [UIImage imageNamed:@"ic_default_header"];
        }else{
            self.iconImgV.image = [UIImage imageWithContentsOfFile:profile_photo.localSmallPath];
        }
    }else{
        self.iconImgV.image = [UIImage imageNamed:@"ic_default_header"];
    }

#pragma mark - end
}

- (void)statusEvent:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(addContact_click:)]) {
        [self.delegate addContact_click:self];
    }
}

- (UIImageView *)iconImgV {
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] init];
        _iconImgV.layer.cornerRadius = 7;
        _iconImgV.layer.masksToBounds=YES;
    }
    return _iconImgV;
}

- (UILabel *)addressNameLab {
    if (!_addressNameLab) {
        _addressNameLab = [[UILabel alloc] init];
        _addressNameLab.font = [UIFont fontWithName:@"PingFang SC" size: 16];
        _addressNameLab.textColor = HEX_COLOR(@"#010108");
        _addressNameLab.text = @"阿离";
    }
    return _addressNameLab;
}

- (UILabel *)remarkNameLab {
    if (!_remarkNameLab) {
        _remarkNameLab = [[UILabel alloc] init];
        _remarkNameLab.font = [UIFont fontWithName:@"PingFang SC" size: 14];
        _remarkNameLab.textColor = HEX_COLOR(@"#999999");
        _remarkNameLab.text = @"gochat：a003小红帽";
    }
    return _remarkNameLab;
}

- (UIButton *)statusBtn {
    if (!_statusBtn) {
        _statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_statusBtn setBackgroundColor:HEX_COLOR(@"#3EC59C")];
        _statusBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size: 15];
        _statusBtn.layer.cornerRadius = 4;
        _statusBtn.layer.masksToBounds=YES;
        [_statusBtn setTitle:@"添加".lv_localized forState:UIControlStateNormal];
        [_statusBtn addTarget:self action:@selector(statusEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _statusBtn;
}

- (UILabel *)statusLab {
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.font = [UIFont fontWithName:@"PingFang SC" size: 15];
        _statusLab.textColor = UIColor.whiteColor;
        _statusLab.backgroundColor = HEX_COLOR(@"#3EC59C");
        _statusLab.layer.cornerRadius = 4;
        _statusLab.layer.masksToBounds=YES;
        _statusLab.text = @"发消息".lv_localized;
        _statusLab.hidden = YES;
        _statusLab.textAlignment = NSTextAlignmentCenter;
    }
    return _statusLab;
}

- (UIView *)lineV {
    if (!_lineV) {
        _lineV = [[UIView alloc] init];
        _lineV.backgroundColor = HEX_COLOR(@"#E9E9E9");
    }
    return _lineV;
}

@end
