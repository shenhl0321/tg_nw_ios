//
//  MNGroupAnnounceHeaderView.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/7.
//

#import "MNGroupAnnounceHeaderView.h"
#import "MNGroupAnnounceVC.h"

@interface MNGroupAnnounceHeaderView ()
@property (nonatomic, strong) MessageInfo *pinnedMessage;
@property (nonatomic, strong) ChatInfo *chat;
@property (nonatomic, strong) SuperGroupInfo *supGroupInfo;
@end

@implementation MNGroupAnnounceHeaderView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initUI];
}



- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, 57);
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

-(void)refreshDataWithChat:(ChatInfo *)chat pinnedMessage:(MessageInfo *)pinnedMessage superGroup:(SuperGroupInfo *)superGroup{
    self.chat = chat;
    self.pinnedMessage = pinnedMessage;
    self.supGroupInfo = superGroup;
    NSString *text = pinnedMessage.description;
    if([text hasPrefix:GROUP_NOTICE_PREFIX])
    {
        text = [text substringFromIndex:GROUP_NOTICE_PREFIX.length];
    }
    self.contentLabel.text = text;
    if ([CZCommonTool isGroupManager:superGroup]){
        self.closeBtn.hidden = NO;
    }else{
        self.closeBtn.hidden = YES;
    }
    
}

- (void)groupCloseAnnouceAction{
    !self.closeBlock ? : self.closeBlock();
}

- (void)initUI{
    self.backgroundColor = [UIColor colorForF5F9FA];
    [self addSubview:self.iconImgV];
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.closeBtn];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(37, 37));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(12);
        make.top.mas_equalTo(7);
        make.right.mas_equalTo(-44);
        make.height.mas_equalTo(23);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-7);

    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-2);
        make.centerY.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
    
}

- (void)tap:(UITapGestureRecognizer *)tap{
    MNGroupAnnounceVC *vc = [[MNGroupAnnounceVC alloc] init];
    vc.chat = self.chat;
    vc.originName = self.contentLabel.text;
    vc.canEdit = [CZCommonTool isGroupManager:self.supGroupInfo];
    [tp_topMostViewController().navigationController pushViewController:vc animated:YES];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GroupAnnounceIcon"]];
    }
    return _iconImgV;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = fontSemiBold(16);
        _titleLabel.textColor = [UIColor colorTextFor23272A];
        _titleLabel.text = @"置頂公告".lv_localized;
    }
    return _titleLabel;
}

-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = fontRegular(14);
        _contentLabel.textColor = [UIColor colorTextFor999999];
    }
    return _contentLabel;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"GroupAnnounceClose"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(groupCloseAnnouceAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
