//
//  MNRedTvCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNRedTvCell.h"

@interface MNRedTvCell ()

@end

@implementation MNRedTvCell

//-(UILabel *)tipLabel{
//    if (!_tipLabel) {
//        _tipLabel = [[UILabel alloc] init];
//        _tipLabel.font = fontRegular(14);
//        _tipLabel.textColor = [UIColor colorTextForA9B0BF];
//    }
//    return _tipLabel;
//}

- (void)initUI{
    [super initUI];
    [self.bgView addSubview:self.tv];
    [self.tv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(23-8);
        make.left.mas_equalTo(15-8);
        make.center.mas_equalTo(0);
    }];
}

-(UITextView *)tv{
    if (!_tv) {
        _tv = [[UITextView alloc] init];
        _tv.font = fontRegular(17);
        _tv.zw_placeHolder = @"恭喜发财，大吉大利".lv_localized;
        _tv.zw_placeHolderColor = [UIColor colorTextForA9B0BF];
        _tv.backgroundColor = [UIColor clearColor];
    }
    return _tv;
}
@end
