//
//  SearchGroupCell.m
//  GoChat
//
//  Created by 吴亮 on 2021/10/20.
//

#import "SearchGroupCell.h"
#import "TF_RequestManager.h"
#import "MNAddContactGroupVC.h"

@interface SearchGroupCell ()
@property (nonatomic, strong) UIImageView * headImageV;
@property (nonatomic, strong) UILabel * nameL;
@property (nonatomic, strong) UIButton * deatilBtn;
@property (nonatomic, strong) UIButton * joinBtn;
@end



@implementation SearchGroupCell

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
- (void)joinGroup{
    MJWeakSelf
    [TF_RequestManager joinChatWithId:self.chatInfo._id result:^(NSDictionary *request, NSDictionary *response) {
        if(![TelegramManager isResultError:response])
        {
            weakSelf.joinBtn.hidden = YES;
        } else {
            NSString *msg = [NSString stringWithFormat:@"%@", response[@"message"]];
            NSString *tipMsg = @"加入失败".lv_localized;
            if (!IsStrEmpty(msg)) {
                tipMsg = [NSString stringWithFormat:@"加入失败\n%@".lv_localized, msg];
            }
            [UserInfo showTips:nil des:tipMsg];
        }
    } timeout:nil];
}

- (void)setChatInfo:(ChatInfo *)chatInfo{
    _chatInfo = chatInfo;
    
    self.nameL.text = chatInfo.title;
    if (chatInfo.totalNumber == 0) {
        self.deatilBtn.hidden = YES;
    } else {
        self.deatilBtn.hidden = NO;
        NSString *text = [NSString stringWithFormat:@"%ld名成员，%ld名在线".lv_localized, chatInfo.totalNumber, chatInfo.onlineNumber];
        [self.deatilBtn setTitle:text forState:UIControlStateNormal];
    }
    
    NSArray *list = [[TelegramManager shareInstance] getGroups];
    /// 判断当前用户是否在群中
    self.joinBtn.hidden = [list containsObject:chatInfo];
    
    [self setGroupIconUI];
}

- (void)setGroupIconUI{
    if(self.chatInfo.photo != nil){
        if(!self.chatInfo.photo.isSmallPhotoDownloaded && self.chatInfo.photo.small.remote.unique_id.length > 1){
            [[TelegramManager shareInstance] DownloadFile:[NSString stringWithFormat:@"%ld", self.chatInfo._id] fileId:self.chatInfo.photo.fileSmallId download_offset:0 type:FileType_Group_Photo];
            //本地头像
            self.headImageV.image = nil;
            unichar text = [@" " characterAtIndex:0];
            if(self.chatInfo.title.length>0){
                text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
            }
            [UserInfo setColorBackgroundWithView:self.headImageV withSize:CGSizeMake(50, 50) withChar:text];
        }else{
            [UserInfo cleanColorBackgroundWithView:self.headImageV];
            self.headImageV.image = [UIImage imageWithContentsOfFile:self.chatInfo.photo.localSmallPath];
        }
    }else{
        //本地头像
        self.headImageV.image = nil;
        unichar text = [@" " characterAtIndex:0];
        if(self.chatInfo.title.length>0)
        {
            text = [[self.chatInfo.title uppercaseString] characterAtIndex:0];
        }
        [UserInfo setColorBackgroundWithView:self.headImageV withSize:CGSizeMake(50, 50) withChar:text];
    }
}
-(void)buildUI{
   
    [self.contentView addSubview:self.headImageV];
    [self.contentView addSubview:self.nameL];
    
    self.deatilBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deatilBtn setTitleColor:[UIColor colorTextForA9B0BF] forState:UIControlStateNormal];
    self.deatilBtn.titleLabel.font = fontRegular(15);
    [self.contentView addSubview:self.deatilBtn];
    self.deatilBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.deatilBtn.userInteractionEnabled =NO;
    
    
    self.joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.joinBtn setTitleColor:[UIColor colorMain] forState:UIControlStateNormal];
    [self.joinBtn setTitle:@"加入".lv_localized forState:UIControlStateNormal];
    self.joinBtn.backgroundColor = [UIColor whiteColor];
    self.joinBtn.titleLabel.font = fontSemiBold(14);
    self.joinBtn.layer.cornerRadius = 8;
    self.joinBtn.layer.masksToBounds = YES;
    self.joinBtn.layer.borderWidth = 1;
    self.joinBtn.layer.borderColor = [UIColor colorMain].CGColor;
    [self.contentView addSubview:self.joinBtn];
    
    [self.headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@52);
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(left_margin());
    }];
    
    [self.joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-left_margin());
        make.width.equalTo(@60);
        make.height.equalTo(@30);
    }];
    
    [self.nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImageV.mas_top).with.offset(3);
        make.left.equalTo(self.headImageV.mas_right).offset(12);
        make.height.equalTo(@20);
        make.right.mas_equalTo(-(62+left_margin()));
    }];
    
    [self.deatilBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headImageV.mas_bottom).with.offset(-4);
        make.left.equalTo(self.nameL.mas_left);
        make.height.equalTo(@20);
        make.right.equalTo(self.nameL);
    }];
    [self.deatilBtn setTitle:@"100名成员，50名在线".lv_localized forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(UIImageView *)headImageV{
    if (!_headImageV) {
        _headImageV = [[UIImageView alloc] init];
        [_headImageV mn_iconStyle];
    }
    return _headImageV;
}

-(UILabel *)nameL{
    if (!_nameL) {
        _nameL = [[UILabel alloc] init];
        _nameL.textColor = [UIColor colorTextFor23272A];
        _nameL.font = fontRegular(16);
        _nameL.text = @"fasdfagsgs";
    }
        return _nameL;
}

@end
