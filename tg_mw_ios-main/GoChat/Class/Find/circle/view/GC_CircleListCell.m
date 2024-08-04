//
//  GC_CircleListCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/15.
//

#import "GC_CircleListCell.h"
#import "GC_RewardView.h"

@interface GC_CircleListCell()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImageView *headerImageV;
@property (nonatomic, strong) UILabel *nameLab;
@property (nonatomic, strong) UIButton *followBtn;
@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) GC_RewardView *rewardView;
@property (nonatomic, strong) UILabel *addressLab;

@property (nonatomic, strong) UILabel *praiseNumLab;

@property (nonatomic, strong) UILabel *comentNumLab;


@property (nonatomic, strong) UILabel *lineLab;


@end

@implementation GC_CircleListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return  self;
}

- (void)initUI{
    self.topView  = [UIView new];
    self.bannerView = [UIView new];
    self.bannerView.backgroundColor = [UIColor redColor];
    self.menuView  = [UIView new];
    self.bottomView = [UIView new];
    self.lineLab = [UILabel new];
    self.lineLab.backgroundColor = [UIColor colorTextForE5EAF0];
    
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.bannerView];
    [self.contentView addSubview:self.menuView];
    [self.contentView addSubview:self.bottomView];
    [self.contentView addSubview:self.lineLab];
    
    [self.topView addSubview:self.headerImageV];
    [self.topView addSubview:self.nameLab];
    [self.topView addSubview:self.followBtn];
    [self.topView addSubview:self.moreBtn];
    
    
    [self.menuView addSubview:self.praiseBtn];
    [self.menuView addSubview:self.commentBtn];
    [self.menuView addSubview:_addressLab];
    
    [self.bottomView addSubview:self.comentNumLab];
    [self.bottomView addSubview:self.desLab];
    [self.bottomView addSubview:self.praiseNumLab];
    [self.bottomView addSubview:self.timeLab];
    [self.bottomView addSubview:self.deleteBtn];
    

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(75);
    }];
    
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.topView.mas_bottom).offset(0);
        make.height.mas_equalTo(200);
    }];
    
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.bannerView.mas_bottom).offset(0);
        make.height.mas_equalTo(46);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.menuView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(-1);
    }];
    
    self.headerImageV = [UIImageView new];
    self.headerImageV.image = [UIImage imageNamed:@"icon_mine_place"];
    [self.topView addSubview:self.headerImageV];
    
    [self.headerImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(0);
    }];
    
    self.nameLab = [UILabel new];
    self.nameLab.text = @"昵称字数限制最多不...".lv_localized;
    [self.topView addSubview:self.nameLab];

    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(67);
        make.right.mas_equalTo(-140);
        make.centerY.mas_equalTo(0);
    }];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setBackgroundImage:[UIImage imageNamed:@"icon_circle_more"] forState:UIControlStateNormal];
    [self.topView addSubview:self.moreBtn];

    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(0);
    }];

    self.followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followBtn.titleLabel.font = [UIFont regularCustomFontOfSize:14];
    [self setFollowStatus:NO];
    [self.topView addSubview:self.followBtn];

    [self.followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-53);
        make.width.mas_equalTo(61);
        make.height.mas_equalTo(30);
        make.centerY.mas_equalTo(0);
    }];
    

    self.praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.praiseBtn setBackgroundImage:[UIImage imageNamed:@"icon_circle_praise"] forState:UIControlStateNormal];
    [self.praiseBtn setBackgroundImage:[UIImage imageNamed:@"icon_circle_praise_select"] forState:UIControlStateSelected];
    [self.menuView addSubview:self.praiseBtn];

    [self.praiseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.width.height.mas_equalTo(22);
        make.centerY.mas_equalTo(0);
    }];
    
    self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentBtn setBackgroundImage:[UIImage imageNamed:@"icon_circle_comment"] forState:UIControlStateNormal];
    [self.menuView addSubview:self.commentBtn];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(52);
        make.width.height.mas_equalTo(22);
        make.centerY.mas_equalTo(0);
    }];
    
    self.rewardView = [[GC_RewardView alloc] init];
    [self.menuView addSubview:self.rewardView];
    
    [self.rewardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(75);
        make.height.mas_equalTo(22);
        make.left.mas_equalTo(85);
        make.centerY.mas_equalTo(0);
    }];
    
    self.addressLab = [UILabel new];
    self.addressLab.font = [UIFont regularCustomFontOfSize:14];
    self.addressLab.textColor = [UIColor colorFor878D9A];
    self.addressLab.textAlignment = 2;
    [self.menuView addSubview:self.addressLab];
    
    [self.addressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(SCREEN_WIDTH/2. - 15);
    }];
    
    self.praiseNumLab = [UILabel new];
    self.praiseNumLab.text = @"88次点赞".lv_localized;
    self.praiseNumLab.textColor = [UIColor colorTextFor23272A];
    self.praiseNumLab.font = [UIFont fontWithName:@"Helvetica" size:16];
    [self.bottomView addSubview:self.praiseNumLab];
    [self.praiseNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(0);
    }];
    
    self.desLab = [UILabel new];
    self.desLab.text = @"总以为生活欠我们一个满意，其实是我们欠生活一个努力你还年轻，别凑活过。没事早点睡，有空多...".lv_localized;
    self.desLab.font = [UIFont fontWithName:@"Helvetica" size:15];
    self.desLab.textColor = [UIColor colorFor878D9A];
    self.desLab.numberOfLines = 2;
    [self.bottomView addSubview:self.desLab];
    [self.desLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-57);
    }];
    
    self.comentNumLab = [UILabel new];
    self.comentNumLab.text = @"100条评论";
    self.comentNumLab.textColor = [UIColor colorTextFor23272A];
    self.comentNumLab.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.bottomView addSubview:self.comentNumLab];
    [self.comentNumLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo(-25);
    }];
    
    self.timeLab = [UILabel new];
    self.timeLab.text = @"30分钟前".lv_localized;
    self.timeLab.textColor = [UIColor colorTextForA9B0BF];
    self.timeLab.font = [UIFont fontWithName:@"Helvetica" size:14];
    [self.bottomView addSubview:self.timeLab];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.bottom.mas_equalTo(-25);
    }];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setTitle:@"删除".lv_localized forState:UIControlStateNormal];
    self.deleteBtn.titleLabel.textAlignment = 2;
    [self.deleteBtn setTitleColor:[UIColor colorforFD4E57] forState:UIControlStateNormal];
    self.deleteBtn.hidden = YES;
    [self.menuView addSubview:self.deleteBtn];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
        make.bottom.mas_equalTo(-25);
    }];
    
    [self.lineLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_banner_place"]];
    [self.bannerView addSubview:imageV];
    
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(0);
    }];
    
}

- (void)setFollowStatus:(BOOL)isSelect{
    if (isSelect) {
        [self.followBtn setTitle:@"已关注".lv_localized forState:UIControlStateNormal];
        [self.followBtn setTitleColor:[UIColor colorFor878D9A] forState:UIControlStateNormal];
        [self.followBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        self.followBtn.backgroundColor = [UIColor colorForF5F9FA];
        self.followBtn .layer.borderWidth = 0;
        self.followBtn .layer.cornerRadius = 8;
    }else{
        [self.followBtn setTitle:@"关注".lv_localized forState:UIControlStateNormal];
        [self.followBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
        [self.followBtn setImage:[UIImage imageNamed:@"icon_circle_follow_add"] forState:UIControlStateNormal];
        self.followBtn .layer.borderWidth = 1;
        self.followBtn .layer.borderColor = [UIColor colorMain].CGColor;
        self.followBtn .layer.backgroundColor = [UIColor colorMain].CGColor;
        self.followBtn .layer.cornerRadius = 8;
        self.followBtn.backgroundColor = [UIColor whiteColor];
    }
}
- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
