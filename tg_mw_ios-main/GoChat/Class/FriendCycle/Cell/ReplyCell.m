//
//  ReplyCell.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/2.
//

#import "ReplyCell.h"

@interface ReplyCell ()

@property (nonatomic, strong) UIImageView * headImageV;
@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UILabel * timeL;
@property (nonatomic, strong) UIButton * replayBtn;
@property (nonatomic, strong) UILabel * contentL;

@property (nonatomic, strong) UIButton * likeBtn;
@end



@implementation ReplyCell

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
    [self.contentView addSubview:self.headImageV];
    
    self.nameL = [[UILabel alloc] init];
    self.nameL.textColor = HEX_COLOR(@"#00C69B");
    self.nameL.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:self.nameL];
    
    self.timeL = [[UILabel alloc] init];
    self.timeL.font = [UIFont systemFontOfSize:14];
    self.timeL.textColor = HEX_COLOR(@"#999999");
    [self.contentView addSubview:self.timeL];
    
    self.replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.replayBtn setTitle:@"回复".lv_localized forState:UIControlStateNormal];
    [self.replayBtn setTitleColor:HEX_COLOR(@"#5A6C92") forState:UIControlStateNormal];
    self.replayBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.replayBtn];
    
    self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.likeBtn setImage:[UIImage imageNamed:@"love_unSelect"] forState:UIControlStateNormal];
    [self.likeBtn setImage:[UIImage imageNamed:@"love_select"] forState:UIControlStateSelected];
    [self.contentView addSubview:self.likeBtn];
    
    self.contentL = [[UILabel alloc] init];
    self.contentL.font = [UIFont systemFontOfSize:14];
    self.contentL.textColor = HEX_COLOR(@"#04020C");
    [self.contentView addSubview:self.contentL];
    
    [self.headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(15);
        make.width.height.equalTo(@34);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageV.mas_top);
        make.left.equalTo(self.headImageV.mas_right).offset(10);
        make.height.equalTo(@15);
    }];
    
    [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_left);
        make.top.equalTo(self.nameL.mas_bottom).offset(10);
        make.height.equalTo(@10);
    }];
    
    [self.replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.timeL.mas_centerY);
        make.left.equalTo(self.timeL.mas_right).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@15);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageV.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
        make.width.height.equalTo(@22);
    }];
    
    [self.contentL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_left);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.top.equalTo(self.timeL.mas_bottom).offset(10);
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(NSDictionary *)model{
    self.headImageV.backgroundColor = [UIColor orangeColor];
    self.nameL.text = @"lidya";
    self.timeL.text = @"2020.10.14";
    self.contentL.text = @"这是哪里? 风景好漂亮啊 !".lv_localized;
}


@end
