//
//  CycleMainViewCell.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/7.
//

#import "CycleMainViewCell.h"
@interface CycleMainViewCell ()
@property (nonatomic, strong) UIImageView * imageV;
@end



@implementation CycleMainViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI{
    self.imageV = [[UIImageView alloc] init];
    self.imageV.backgroundColor = [UIColor orangeColor];
    self.imageV.layer.masksToBounds = YES;
    self.imageV.layer.cornerRadius = 10;
    [self.contentView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(self.contentView);
    }];
}
@end
