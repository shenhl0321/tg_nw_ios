//
//  GC_FindCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/4.
//

#import "GC_FindCell.h"

@interface GC_FindCell()

@property (nonatomic, strong)UIImageView *imageV;
@property (nonatomic, strong)UIImageView *arrowImageV;
@property (nonatomic, strong)UILabel *titleLab;
@property (nonatomic, strong)UILabel *numLab;

@end

@implementation GC_FindCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}
- (void)initUI{
    self.imageV = [UIImageView new];
    [self.contentView addSubview:self.imageV];
    
    self.titleLab = [UILabel new];
    self.titleLab.textColor = [UIColor colorTextFor23272A];
    self.titleLab.font = [UIFont regularCustomFontOfSize:16];
    [self.contentView addSubview:self.titleLab];
    
    self.numLab = [UILabel new];
    self.numLab.backgroundColor = XHQHexColor(0xFD4E57);
    self.numLab.textColor = UIColor.colorTextForFFFFFF;
    self.numLab.font = [UIFont regularCustomFontOfSize:11];
    self.numLab.text = @"";
    self.numLab.textAlignment = 1;
    [self.numLab xhq_cornerRadius:4];
    [self.contentView addSubview:self.numLab];
    
    self.arrowImageV = [UIImageView new];
    self.arrowImageV.image = [UIImage imageNamed:@"icon_next"];
    [self.contentView addSubview:self.arrowImageV];
    
    [self layout];
}
- (void)layout{
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(0);
        make.height.width.mas_equalTo(40);
    }];
    
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageV.mas_right).offset(12);
        make.centerY.mas_equalTo(0);
    }]; 
    
    [self.arrowImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
        make.centerY.mas_equalTo(0);
    }];
    
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-35);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(8);
    }];
}
- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    
    self.imageV.image = [UIImage imageNamed:[dataDic stringValueForKey:@"image" defaultValue:@""].lv_Style];
    self.titleLab.text = [dataDic stringValueForKey:@"title" defaultValue:@""];
    NSNumber *num = dataDic[@"num"];
    if (num) {
        self.numLab.hidden = NO;
        self.numLab.text = num.stringValue;
        self.numLab.hidden = num.integerValue == 0;
    } else {
        self.numLab.hidden = YES;
    }
}

- (void)setModel:(DiscoverMenuInfo *)model{
    _model = model;
//    self.imageV.image = [UIImage imageNamed:model.icon.lv_Style];
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.titleLab.text = model.title;
}


@end
