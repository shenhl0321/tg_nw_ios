//
//  TF_CommonSettingCell.m
//  GoChat
//
//  Created by apple on 2022/1/28.
//

#import "TF_CommonSettingCell.h"


@implementation TF_settingModel

@end

@interface TF_CommonSettingCell()
/// 标题
@property (nonatomic,strong) UILabel *nameL;
/// 右侧值
@property (nonatomic,strong) UILabel *valueL;
/// 右侧箭头图标
@property (nonatomic,strong) UIImageView *arrowImgV;
/// switch开关
@property (nonatomic,strong) UISwitch *switchBtn;

@end

@implementation TF_CommonSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupUI];
    }
    return self;
}


- (void)setupUI{
    
    
    UILabel *nameL = [[UILabel alloc] init];
    [self.contentView addSubview:nameL];
    self.nameL = nameL;
    nameL.font = XHQFont(16);
    nameL.textColor = [UIColor colorTextFor23272A];
    
    UILabel *valueL = [[UILabel alloc] init];
    [self.contentView addSubview:valueL];
    self.valueL = valueL;
    valueL.font = XHQFont(16);
    valueL.textColor = [UIColor colorTextFor878D9A];
    
    UIImageView *arrowImgV = [[UIImageView alloc] init];
    [self.contentView addSubview:arrowImgV];
    self.arrowImgV = arrowImgV;
    arrowImgV.image = [UIImage imageNamed:@"CellArrow"];
    
    UISwitch *switchBtn = [[UISwitch alloc] init];
    self.switchBtn = switchBtn;
    [self.contentView addSubview:switchBtn];
    switchBtn.onTintColor = [UIColor colorMain];
    [switchBtn addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)layoutUI{
    
    [self.nameL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.mas_lessThanOrEqualTo(150);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    switch (self.model.tipType) {
        case TF_settingTipTypeArrow:
        {
            [self.arrowImgV mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-15);
                make.width.mas_equalTo(5);
                make.height.mas_equalTo(12);
                make.centerY.mas_equalTo(self.nameL);
            }];
            [self.valueL mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.arrowImgV.mas_left).offset(-10);
                make.centerY.mas_equalTo(self.nameL);
            }];
            
            break;
        }
        case TF_settingTipTypeSwith:
        {
            [self.switchBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-15);
                make.width.mas_equalTo(45);
                make.height.mas_equalTo(22);
                make.centerY.mas_equalTo(self.nameL);
            }];
            [self.valueL mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.switchBtn.mas_left).offset(-10);
                make.centerY.mas_equalTo(self.nameL);
            }];
        }
            break;
        default:
        {
            [self.valueL mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-15);
                make.centerY.mas_equalTo(self.nameL);
            }];
        }
            break;
    }
    
    
}

- (void)setModel:(TF_settingModel *)model{
    _model = model;
    self.nameL.text = model.title;
    self.valueL.text = model.tipValue;
    self.valueL.hidden = model.tipValue.length < 1;
    [self.switchBtn setOn:model.switchOn];
    switch (model.tipType) {
        case TF_settingTipTypeArrow:
            self.arrowImgV.hidden = NO;
            self.switchBtn.hidden = YES;
            break;
        case TF_settingTipTypeSwith:
            self.arrowImgV.hidden = YES;
            self.switchBtn.hidden = NO;
            break;
        default:
            self.arrowImgV.hidden = YES;
            self.switchBtn.hidden = YES;
            break;
    }
    
    [self layoutUI];
}

- (void)switchClick:(UISwitch *)switchBtn{
    if (self.controlCall) {
        self.controlCall(self.model);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


@interface TF_SettingSectionHeaderV ()
/// <#code#>
@property (nonatomic,strong) UILabel *titleL;
@end

@implementation TF_SettingSectionHeaderV

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
        self.backgroundColor = [UIColor colorForF5F9FA];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
        self.backgroundColor = [UIColor colorForF5F9FA];
    }
    return self;
}

- (void)initUI{
    UILabel *titleL = [[UILabel alloc] init];
    self.titleL = titleL;
    [self.contentView addSubview:titleL];
    titleL.font = XHQFont(16);
    titleL.textColor = [UIColor colorFor878D9A];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
//        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleL.text = title;
}

@end
