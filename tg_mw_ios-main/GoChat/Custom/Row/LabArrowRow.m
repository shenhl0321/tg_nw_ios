//
//  LabArrowRow.m
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/10.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import "LabArrowRow.h"

@implementation LabArrowRow

- (void)initSubUI{
    [self addSubview:self.lcLabel];
    [self.lcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(-50);
    }];
    
    [self addSubview:self.rcArrow];
    [self.rcArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(5, 12));
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
}

-(UILabel *)lcLabel{
    if (!_lcLabel) {
        _lcLabel = [[UILabel alloc] init];
        _lcLabel.textColor = [UIColor colorTextFor23272A];
        _lcLabel.font = fontRegular(17);
    }
    return _lcLabel;
}

-(UIImageView *)rcArrow{
    if (!_rcArrow) {
        _rcArrow = [[UIImageView alloc] init];
        _rcArrow.image = [UIImage imageNamed:@"CellArrow"];
    }
    return _rcArrow;
}
@end
