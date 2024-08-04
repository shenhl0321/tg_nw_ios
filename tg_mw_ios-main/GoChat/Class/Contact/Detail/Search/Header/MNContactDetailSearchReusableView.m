//
//  MNContactDetailSearchReusableView.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNContactDetailSearchReusableView.h"


@implementation MNContactDetailSearchReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self addSubview:self.searchBar];
    UILabel *aLabel = [[UILabel alloc] init];
    aLabel.font = fontRegular(15);
    aLabel.textColor = [UIColor colorTextForA9B0BF];
    aLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:aLabel];
    aLabel.text = @"按指定内容搜索".lv_localized;
    [aLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.searchBar.mas_bottom).with.offset(70);
        make.height.mas_equalTo(21);
    }];
    NSArray *titles = @[@"链接".lv_localized,@"媒体".lv_localized,@"文件".lv_localized];
    CGFloat left = 3;
    CGFloat btnWidth = (kScreenWidth()-2*left)/3.0;
    CGFloat btnHeight = 24;
    CGFloat lineLeft = (APP_SCREEN_WIDTH-10)/3.0;
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:HEXCOLOR(0x08CF98) forState:UIControlStateNormal];
        btn.titleLabel.font = fontSemiBold(17);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(left + btnWidth*i, 163, btnWidth, btnHeight);
        [self addSubview:btn];
        btn.tag = i + 1000;
        if (i>0) {
            UIView *linView = [[UIView alloc] initWithFrame:CGRectMake(i*lineLeft+(i-1)*10, 163, 0.5, btnHeight)];
            linView.backgroundColor = [UIColor colorTextFor878D9A];
            [self addSubview:linView];
        }
    }
    UILabel *label2 = [[UILabel alloc] init];
    label2.font = fontRegular(15);
    label2.textColor = [UIColor colorTextForA9B0BF];
    label2.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label2];
    label2.text = @"搜索历史记录".lv_localized;
   
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(257);
        make.height.mas_equalTo(21);
    }];
    [self addSubview:self.clearBtn];
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-left_margin());
        make.size.mas_equalTo(CGSizeMake(60, 39));
        make.centerY.equalTo(label2);
    }];
}

- (void)btnAction:(UIButton *)btn{
    !self.block ? : self.block(btn.tag - 1000);
}

-(UIButton *)clearBtn{
    if (!_clearBtn) {
        _clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearBtn setImage:[UIImage imageNamed:@"search_history_clear"] forState:UIControlStateNormal];
        [_clearBtn setTitle:@"清除".lv_localized forState:UIControlStateNormal];
        [_clearBtn setTitleColor:HexRGB(0x222222) forState:UIControlStateNormal];
        _clearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_clearBtn setImagePosition:LXMImagePositionLeft spacing:4];
        _clearBtn.titleLabel.font = fontRegular(13);
        
    }
    return _clearBtn;
}
-(ContactSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ContactSearchBar alloc] init];
        _searchBar.frame = CGRectMake(0, 5, APP_SCREEN_WIDTH, 42);
        [_searchBar styleNoCancel];
        _searchBar.cornerRadius = 21;
    }
    return _searchBar;
}
@end
