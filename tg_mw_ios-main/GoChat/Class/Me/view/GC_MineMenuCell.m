//
//  GC_MineMenuCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/1.
//

#import "GC_MineMenuCell.h"

@implementation GC_MineMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}
- (void)initUI{
    [self.contentView addSubview:self.contentV];
    [self.contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    AppConfigInfo *config = [AppConfigInfo sharedInstance];
    NSMutableArray *titleArr  = [NSMutableArray array];
    NSMutableArray *imageArr = [NSMutableArray array];
    NSMutableArray *tags = [NSMutableArray array];
    if (config.can_see_blog) {
        [titleArr addObject:@"相册".lv_localized];
        [imageArr addObject:@"icon_xiangce"];
        [tags addObject:@(2)];
    }
    if (config.can_see_qr_code) {
        [titleArr addObject:@"二维码".lv_localized];
        [imageArr addObject:@"icon_wallet_scan"];
        [tags addObject:@(3)];
    }
    [titleArr addObject:@"收藏".lv_localized];
    [imageArr addObject:@"user_icon_collect"];
    [tags addObject:@(4)];
    [titleArr addObject:@"最近通话".lv_localized];
    [imageArr addObject:@"icon_mobile"];
    [tags addObject:@(5)];
    [titleArr addObject:@"客服".lv_localized];
    [imageArr addObject:@"user_icon_service"];
    [tags addObject:@(6)];
    
//    if (![localAppName isEqualToString:@"涨聊"]) {
//        [titleArr addObject:@"关于我们".lv_localized];
//        [imageArr addObject:@"user_icon_help_black"];
//        [tags addObject:@(7)];
//    }
    
    
    [titleArr addObject:@"安全".lv_localized];
    [imageArr addObject:@"user_icon_safe"];
    [tags addObject:@(8)];
    
    [titleArr addObject:@"设置".lv_localized];
    [imageArr addObject:@"icon_mine_set"];
    [tags addObject:@(9)];
    
    for (int i = 0; i < titleArr.count; i ++) {
        UIView *view = [UIView new];
        [self.contentV addSubview:view];
        view.tag = [tags[i] integerValue];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.equalTo(self.contentV).offset(i*60);
        }];
        
        UIImageView *imageV = [UIImageView new];
        imageV.contentMode = UIViewContentModeScaleAspectFill;
        NSString *imageStr = imageArr[i];
        imageV.image = [UIImage imageNamed:imageStr.lv_Style];
        [view addSubview:imageV];
        
        UILabel *titleLab = [UILabel new];
        titleLab.textColor = [UIColor blackColor];
        titleLab.font = [UIFont systemFontOfSize:15];
        titleLab.text = titleArr[i];
        [view addSubview:titleLab];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = HEXCOLOR(0xF6F6F6);
        lineView.hidden = i+1==titleArr.count;
        [view addSubview:lineView];
        
        UIImageView *nextImageV = [[UIImageView alloc] init];
        nextImageV.image = [UIImage imageNamed:@"icon_next"];
        [view addSubview:nextImageV];
        
        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.width.height.mas_equalTo(25);
            make.left.equalTo(view).offset(25);
        }];
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view);
            make.left.equalTo(imageV.mas_right).offset(10);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.left.equalTo(view).offset(25);
            make.right.equalTo(view).offset(-25);
            make.bottom.equalTo(view);
            make.height.mas_offset(1);
        }];
        
        [nextImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            //
            make.centerY.equalTo(view);
            make.right.equalTo(view).offset(-25);
            make.width.height.mas_offset(18);
        }];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
        [view addGestureRecognizer:tap];
    }
}
- (UIView *)contentV{
    if (!_contentV) {
        _contentV = [UIView new];
//        _contentV.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
//        _contentV.layer.cornerRadius = 13;
//        _contentV.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08].CGColor;
//        _contentV.layer.shadowOffset = CGSizeMake(0,0);
//        _contentV.layer.shadowOpacity = 1;
//        _contentV.layer.shadowRadius = 7;
    }
    return _contentV;
}

- (void)tapGes:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    
    if(self.menuBlock){
        self.menuBlock(tag);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
