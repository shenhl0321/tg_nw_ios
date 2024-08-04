//
//  BaseTableCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "BaseTableCell.h"

@interface BaseTableCell ()

@end
@implementation BaseTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//
//-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
//    [super setHighlighted:highlighted animated:animated];
//    if (self.highlighted) {
////        self.backView.backgroundColor = [UIColor colorForECECEC];
//    }else{
////        self.backView.backgroundColor = [UIColor whiteColor];
//    }
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}


- (void)initUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initSubUI];
}

- (void)initSubUI{
    
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    }
    return _lineView;
}

-(void)setNeedLine:(BOOL)needLine{
    _needLine = needLine;
    if (needLine) {
        if (self.lineView.superview == nil) {
            [self.contentView addSubview:self.lineView];
        }
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left_margin());
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }else{
        if (self.lineView.superview) {
            [self.lineView removeFromSuperview];
        }
    }
}
@end
