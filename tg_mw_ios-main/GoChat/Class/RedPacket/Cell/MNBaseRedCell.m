//
//  MNBaseRedCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNBaseRedCell.h"

@interface MNBaseRedCell ()

@end

@implementation MNBaseRedCell


-(void)initUI{
    [super initUI];
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(60);
    }];
}
-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorForF5F9FA];
        _bgView.layer.cornerRadius = 13;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

@end
