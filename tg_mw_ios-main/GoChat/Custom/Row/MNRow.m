//
//  MNRow.m
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNRow.h"

@interface MNRow ()

//@property (nonatomic, strong) UIView *lineView;

@end

@implementation MNRow

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(left_margin40(), 0, APP_SCREEN_WIDTH-2*left_margin40(), 62);
        [self initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self addSubview:self.lineView];
    [self refreshLineWithStyle:MNRowLineStyleDefault];
    [self initSubUI];
}
//自己页面的样式
- (void)initSubUI{
    
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
    }
    return _lineView;
}

- (void)refreshLineWithStyle:(MNRowLineStyle)style{
    _rowLineStyle = style;
    if (style == MNRowLineStylePwd) {
        self.lineView.backgroundColor = [UIColor colorTextFor0DBFC0];
    }else{
        self.lineView.backgroundColor = [UIColor colorTextForE5EAF0];
    }
  
    CGFloat height = 1;
    if (style == MNRowLineStylePwd) {
        height = 1;
    }
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
}

@end
