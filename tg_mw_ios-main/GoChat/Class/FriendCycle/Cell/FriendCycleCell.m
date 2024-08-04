//
//  FriendCycleCell.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/2.
//

#import "FriendCycleCell.h"
#import "UITableViewCell+HYBMasonryAutoCellHeight.h"

@interface FriendCycleCell ()
@property (nonatomic, strong) UIImageView * headImageV;
@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UIButton * fuocusBtn;

@property (nonatomic, strong) UIScrollView * scrollView;

@property (nonatomic, strong) UIButton * loveBtn;
@property (nonatomic, strong) UIButton * commentBtn;
@property (nonatomic, strong) UIPageControl * pageControll;

@property (nonatomic, strong) UILabel * positionL;
@property (nonatomic, strong) UILabel * loveL;
@property (nonatomic, strong) UILabel * contentL;

@property (nonatomic, strong) UILabel * commentL;
@property (nonatomic, strong) UILabel * timeL;

@end


@implementation FriendCycleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
    }
    return self;
}

-(void)buildUI{
    self.headImageV = [[UIImageView alloc] init];
    self.headImageV.layer.masksToBounds = YES;
    self.headImageV.layer.cornerRadius = 20;
    [self.contentView addSubview:self.headImageV];
    
    
    self.nameL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameL.font = [UIFont boldSystemFontOfSize:19];
    [self.contentView addSubview:self.nameL];
    
    self.fuocusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fuocusBtn setTitle:@"关注".lv_localized forState:UIControlStateNormal];
    [self.fuocusBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    self.fuocusBtn.backgroundColor = HEX_COLOR(@"#00C69B");
    [self.fuocusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.fuocusBtn];

    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.moreBtn];


    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.layer.masksToBounds = YES;
    self.scrollView.layer.cornerRadius = 10;
    [self.contentView addSubview:self.scrollView];


    self.loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loveBtn setImage:[UIImage imageNamed:@"love_unSelect"] forState:UIControlStateNormal];
    [self.loveBtn setImage:[UIImage imageNamed:@"love_select"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.loveBtn];

    self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commentBtn setImage:[UIImage imageNamed:@"comments"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.commentBtn];

    self.pageControll = [[UIPageControl alloc] init];;
    [self.contentView addSubview:self.pageControll];


    self.positionL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.positionL.font = [UIFont systemFontOfSize:14];
    self.positionL.textColor = HEX_COLOR(@"#5A6C92");
    [self.contentView addSubview:self.positionL];

    self.loveL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.loveL.font = [UIFont boldSystemFontOfSize:16];
    
    [self.contentView addSubview:self.loveL];

    self.contentL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.contentL.numberOfLines = 2;
    self.contentL.textColor = HEX_COLOR(@"#717682");
    self.contentL.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.contentL];


    self.commentL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.commentL.textColor = HEX_COLOR(@"#A3A3A3");
    self.commentL.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.commentL];

    self.timeL = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeL.textColor = HEX_COLOR(@"#A3A3A3");
    self.timeL.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.timeL];
    self.hyb_lastViewInCell = self.commentL;
    self.hyb_bottomOffsetToCell = 10;

    [self.headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).offset(15);
        make.width.height.equalTo(@40);
    }];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageV.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.equalTo(@5);
        make.height.equalTo(@20);
    }];
    
    [self.fuocusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageV.mas_centerY);
        make.right.equalTo(self.moreBtn.mas_left).offset(-15);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageV.mas_centerY);
        make.left.equalTo(self.headImageV.mas_right).offset(10);
        make.right.equalTo(self.fuocusBtn.mas_left).offset(-10);
        make.height.equalTo(@30);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.headImageV.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@185);
    }];


    [self.loveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.scrollView.mas_bottom).offset(15);
        make.height.width.equalTo(@22);
    }];

    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loveBtn.mas_right).offset(15);
        make.top.equalTo(self.scrollView.mas_bottom).offset(15);
        make.height.width.equalTo(@22);
    }];

    [self.pageControll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.commentBtn.mas_centerY);
    }];


    [self.positionL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.loveBtn.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@15);
    }];

    [self.loveL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.loveBtn.mas_bottom).offset(15);
        make.height.equalTo(@20);
    }];

    [self.contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.loveL.mas_bottom).offset(15);
        make.right.equalTo(self.contentView).offset(-15);
        make.height.lessThanOrEqualTo(@40);
    }];
    self.contentL.preferredMaxLayoutWidth = SCREEN_WIDTH - 30;
    [self.commentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentL.mas_bottom).offset(15);
        make.height.equalTo(@15);
    }];

    [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.height.equalTo(@15);
        make.top.equalTo(self.contentL.mas_bottom).offset(15);
    }];
    self.scrollView.backgroundColor = [UIColor orangeColor];
}

-(void)setModel:(NSDictionary *)dic{
    self.headImageV.backgroundColor = [UIColor orangeColor];
    self.nameL.text = @"昵称字数限制最多不...".lv_localized;
    self.positionL.text = @"广东省·深圳市".lv_localized;
    self.loveL.text = @"88次点赞".lv_localized;
    self.contentL.text = @"总以为生活欠我们一个\"满意\"，其实是我们欠生活一个努力你还年轻，别凑活过。没事早点睡，有空多...".lv_localized;
    self.commentL.text = @"100条评论".lv_localized;
    self.timeL.text = @"30分钟前".lv_localized;
    
}

- (void)setBlog:(BlogInfo *)blog {
    _blog = blog;
//    self.contentL.text = blog.text;
//    self.commentL.text = [NSString stringWithFormat:@"%ld条评论", blog.replys.total_count];
//    self.loveL.text = [NSString stringWithFormat:@"%ld次点赞", blog.likes.total_count];
//    self.loveBtn.selected = blog.liked;
//    self.positionL.text = blog.location.address;
//    [self setUserInfo];
}

- (void)setUserInfo {
    /// 本地有保存 直接读取显示
    /// 没有保存则获取一遍，
    UserInfo *userInfo = [TelegramManager.shareInstance contactInfo:_blog.user_id];
    if (!userInfo) {
        [TelegramManager.shareInstance getUserSimpleInfo_inline:_blog.user_id resultBlock:^(NSDictionary *request, NSDictionary *response) {
            if ([response[@"@type"] isEqualToString:@"user"]) {
                [self setUserInfo];
            }
        } timeout:^(NSDictionary *request) {
            
        }];
    }
    
    NSString *name = userInfo.username;
    if (name.length > 12) {
        self.nameL.text = [NSString stringWithFormat:@"%@...", [name substringToIndex:11]];
    } else {
        self.nameL.text = name;
    }
    
    if (userInfo.profile_photo) {
        if(!userInfo.profile_photo.isSmallPhotoDownloaded) {
            self.headImageV.image = [UIImage imageNamed:@"ic_default_header"];
        } else {
            self.headImageV.image = [UIImage imageWithContentsOfFile:userInfo.profile_photo.localSmallPath];
        }
    }else{
        self.headImageV.image = [UIImage imageNamed:@"ic_default_header"];
    }
    
}

@end
