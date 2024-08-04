//
//  MNContactDetailDynamicCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "MNContactDetailDynamicCell.h"


@implementation MNContactDetailDynamicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)fillDataWithBlogs:(NSMutableArray *)blogs{
    [self.dynamicView fillDataWithArray:blogs];
}

- (void)initUI{
    [super initUI];
    self.needLine = YES;
    [self.contentView addSubview:self.leftLabel];
    [self.contentView addSubview:self.arrowImgV];
    [self.contentView addSubview:self.dynamicView];
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(22.5);
        make.width.mas_lessThanOrEqualTo(150);
    }];
    [self.arrowImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_offset(16);
        make.centerY.mas_equalTo(0);
    }];
    [self.dynamicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(62);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(100);
        make.right.mas_equalTo(-25);
    }];
}

-(UILabel *)leftLabel{
    if (!_leftLabel) {
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.font = fontRegular(16);
        _leftLabel.textColor = [UIColor colorTextFor23272A];
        _leftLabel.text = @"动态".lv_localized;
    }
    return _leftLabel;
}

-(UIImageView *)arrowImgV{
    if (!_arrowImgV) {
        _arrowImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_next"]];
        
    }
    return _arrowImgV;
}

-(MNDetailDynamicView *)dynamicView{
    if (!_dynamicView) {
        _dynamicView = [[MNDetailDynamicView alloc] init];
        _dynamicView.userInteractionEnabled = NO;
    }
    return _dynamicView;
}

@end
