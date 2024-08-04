//
//  MNCountryCodeCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/28.
//

#import "MNCountryCodeCell.h"

@implementation MNCountryCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillDataWithText:(NSString *)text{
    NSArray *arr = [text componentsSeparatedByString:@" "];
    if (arr.count == 2) {
        self.nameLabel.text = arr[0];
        self.codeLabel.text = arr[1];
    }else{
        self.nameLabel.text = @"";
        self.codeLabel.text = @"";
    }
}

- (void)initSubUI{
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.codeLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.right.mas_equalTo(-100);
        make.centerY.mas_equalTo(0);
    }];
    [self.codeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-left_margin());
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(60);
    }];
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontRegular(16);
        _nameLabel.textColor = [UIColor colorTextFor010009];
    }
    return _nameLabel;
}

-(UILabel *)codeLabel{
    if (!_codeLabel) {
        _codeLabel = [[UILabel alloc] init];
        _codeLabel.font = fontRegular(16);
        _codeLabel.textColor = [UIColor colorTextFor878D9A];
        _codeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _codeLabel;
}
@end
