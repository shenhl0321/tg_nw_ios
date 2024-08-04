//
//  MNGroupInfoTvCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "MNGroupInfoTvCell.h"

@implementation MNGroupInfoTvCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    
}

-(void)fillDataWithText:(NSString *)text placeholder:(NSString *)placeholder{
    self.tv.text = [Util objToStr:text];
    self.tv.zw_placeHolder = [Util objToStr:placeholder];
}

- (void)initUI{
    [self.contentView addSubview:self.tv];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(35-8);
        make.left.mas_equalTo(25-8);
        make.centerX.mas_equalTo(0);
        make.bottom.mas_equalTo(10);
    }];
}

-(UITextView *)tv{
    if (!_tv) {
        _tv = [[UITextView alloc] init];
        _tv.font = fontRegular(16);
        _tv.textColor = [UIColor colorTextFor23272A];
        _tv.zw_placeHolder = @"请编辑群简介".lv_localized;
        _tv.zw_placeHolderColor = [UIColor colorTextForA9B0BF];
        _tv.backgroundColor = [UIColor clearColor];
        _tv.userInteractionEnabled = YES;
    }
    return _tv;
}

@end
