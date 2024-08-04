//
//  CZGroupShareLinkTableViewCell.m
//  GoChat
//
//  Created by mac on 2021/7/24.
//

#import "CZGroupShareLinkTableViewCell.h"

@interface CZGroupShareLinkTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;

@end

@implementation CZGroupShareLinkTableViewCell

- (void)setSuper_groupFullInfo:(SuperGroupFullInfo *)super_groupFullInfo{
    if (super_groupFullInfo) {
        _super_groupFullInfo = super_groupFullInfo;
        NSString *invitationStr = self.super_groupFullInfo.invite_link;
        if (!invitationStr || invitationStr.length < 5) {
//            NSString *tipsStr = [NSString stringWithFormat:@"用户在%@中打开此链接均可加入本群。你可以随时重置此链接",APP_NAME];
            NSString *tipsStr = @"管理员未设置链接".lv_localized;
            _linkLabel.text = tipsStr;
        }else{
            NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
            NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:invitationStr attributes:attribtDic];
            _linkLabel.attributedText = attribtStr;
        }
    }else{
        NSString *tipsStr = @"管理员未设置链接".lv_localized;
//        NSString *tipsStr = [NSString stringWithFormat:@"用户在%@中打开此链接均可加入本群。你可以随时重置此链接",APP_NAME];
        _linkLabel.text = tipsStr;
    }
    //添加手势
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createTapGesture:)];
//    tap.numberOfTouchesRequired = 1;
//    _linkLabel.userInteractionEnabled = YES;
//    [_linkLabel addGestureRecognizer:tap];
}

//手势点击
- (void)createTapGesture:(UITapGestureRecognizer *)tap{
    if (_delegate && [_delegate respondsToSelector:@selector(shareLinkClickWithTag:)]) {
        [_delegate shareLinkClickWithTag:100];
    }
}

//二维码点击
- (IBAction)qrcodeClick:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(shareLinkClickWithTag:)]) {
        [_delegate shareLinkClickWithTag:101];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.linkLabel.textColor = [UIColor colorMain];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end
