//
//  MNSubInfoLinkCell.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "MNSubInfoLinkCell.h"

@implementation MNSubInfoLinkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)fillDataWithMessageInfo:(MessageInfo *)message{
    WebpageModel *webmodel = message.content.web_page;
    if (webmodel) {
        self.nameLabel.text = webmodel.title;
        self.subLabel.text = webmodel.descriptionmsg;
        self.linkLabel.text = webmodel.url;
    }else{
        if (message.headerInfo.count > 0) {
            self.linkLabel.text = message.textTypeContent;
            NSString *title = message.headerInfo[@"title"];
            if (IsStrEmpty(title)) {
                self.nameLabel.text = @"链接地址".lv_localized;
            } else {
                self.nameLabel.text = title;
            }
            self.subLabel.text = message.headerInfo[@"description"];
            [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:message.headerInfo[@"icon"]] placeholderImage:[UIImage imageNamed:@"detail_link"]];
            self.subLabel.hidden = NO;
        } else if (message.linkUrls.count > 0) {
            self.linkLabel.text = message.textTypeContent;
            self.nameLabel.text = message.linkUrls.firstObject.transferredContent;
            self.subLabel.hidden = YES;
            self.iconImgV.image = [UIImage imageNamed:@"detail_link"];
        } else {
            self.linkLabel.text = message.textTypeContent;
            self.nameLabel.text = @"链接地址".lv_localized;
            self.subLabel.hidden = YES;
            self.iconImgV.image = [UIImage imageNamed:@"detail_link"];
//            [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:message.headerInfo[@"icon"]] placeholderImage:[UIImage imageNamed:@"detail_link"]];
        }
#if 0
        if ([CZCommonTool checkUrlWithString:message.textTypeContent]) {
            if ([message.textTypeContent hasPrefix:@"http"]) {
                NSURL *url = [NSURL URLWithString:message.textTypeContent];
                self.nameLabel.text = url.host;
                self.linkLabel.text = message.textTypeContent;
            }else{
                self.nameLabel.text = message.textTypeContent;
                self.linkLabel.text = message.textTypeContent;
            }
        }else{
            NSArray *arr = [CZCommonTool getURLFromStr:message.textTypeContent];
            if (arr && arr.count > 0) {
                NSURL *url = [NSURL URLWithString:[arr firstObject]];
                self.nameLabel.text = url.host;
                if ([message.textTypeContent containsString:@"\n"]) {
                    NSArray *arr = [message.textTypeContent componentsSeparatedByString:@"\n"];
                    if (arr.count == 2) {
                        self.subLabel.text = arr[0];
                        self.linkLabel.text = arr[1];
                    }else{
                        self.linkLabel.text = message.textTypeContent;
                        self.subLabel.text = @"";
                    }
                }else{
                    self.linkLabel.text = message.textTypeContent;
                    self.subLabel.text = @"";
                }
               
            }else{
                self.nameLabel.text = @"数据异常".lv_localized;
            }
        }
#endif
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initUI{
    [super initUI];
    self.needLine = YES;
    [self.contentView addSubview:self.iconImgV];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.subLabel];
    [self.contentView addSubview:self.linkLabel];
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left_margin());
        make.top.mas_equalTo(20);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImgV.mas_right).with.offset(12);
        make.top.equalTo(self.iconImgV);
        make.right.mas_equalTo(-left_margin());
    }];
    [self.subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
        make.bottom.equalTo(self.iconImgV);
    }];
    [self.linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
        make.height.mas_equalTo(20);
        make.top.equalTo(self.subLabel.mas_bottom).with.offset(10);
    }];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_link"]];
    }
    return _iconImgV;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontRegular(16);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
        _nameLabel.text = @"百度一下，你就知道".lv_localized;
    }
    return _nameLabel;
}

-(UILabel *)subLabel{
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.font = fontRegular(14);
        _subLabel.textColor = [UIColor colorTextForA9B0BF];
        _subLabel.text = @"全球最大的中文搜索引擎、致力於讓網民更...".lv_localized;
    }
    return _subLabel;
}

-(UILabel *)linkLabel{
    if (!_linkLabel) {
        _linkLabel = [[UILabel alloc] init];
        _linkLabel.font = fontRegular(14);
        _linkLabel.textColor = [UIColor colorTextFor4D6EF1];
        _linkLabel.text = @"www.baidu.com";
        
    }
    return _linkLabel;
}
@end
