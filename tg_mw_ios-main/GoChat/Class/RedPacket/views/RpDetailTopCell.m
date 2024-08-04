//
//  RpDetailTopCell.m
//  GoChat
//
//  Created by wangyutao on 2021/4/9.
//

#import "RpDetailTopCell.h"

@implementation RpDetailTopCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.title1Label.font = fontRegular(24);
    self.title1Label.textColor = [UIColor colorTextFor23272A];
    self.title2Label.font = fontRegular(15);
    self.title2Label.textColor = [UIColor colorTextFor878D9A];
}

- (void)resetRpInfo:(RedPacketInfo *)rp
{
    self.title1Label.text = [NSString stringWithFormat:@"%@发出的红包".lv_localized, [UserInfo userDisplayName:rp.from]];
    self.title2Label.text = rp.title;
    if(self.priceLabel)
    {
        NSString *priceStr = [Common priceFormat:[rp curUserRp].price];
        [self priceAttributedUnit:@"￥" price:priceStr priceLabel:self.priceLabel];
    }
}

- (void)priceAttributedUnit:(NSString *)unitStr price:(NSString *)priceStr priceLabel:(UILabel *)priceLabel
{
    NSString *str = [NSString stringWithFormat:@"%@%@", unitStr, priceStr];
    NSMutableAttributedString *strAttr=[[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange range_s = [str rangeOfString:priceStr];
    [strAttr addAttributes:@{NSFontAttributeName:fontSemiBold(50), NSForegroundColorAttributeName:HEX_COLOR(@"#F4A63B")} range:range_s];
    
    NSRange range_u = [str rangeOfString:unitStr];
    [strAttr addAttributes:@{NSFontAttributeName:fontSemiBold(30), NSForegroundColorAttributeName:HEX_COLOR(@"#F4A63B")} range:range_u];
    
    [priceLabel setAttributedText:strAttr];
}

@end
