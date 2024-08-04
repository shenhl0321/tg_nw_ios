//
//  GC_RedRecordCell.m
//  GoChat
//
//  Created by wangfeiPro on 2022/1/5.
//

#import "GC_RedRecordCell.h"

@interface GC_RedRecordCell()
@property (nonatomic, strong) RedPacketInfo *rpInfo;
@end

@implementation GC_RedRecordCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.textColor = [UIColor colorTextFor23272A];
    self.titleLabel.font = [UIFont regularCustomFontOfSize:16];
    
    self.timeLabel.textColor = [UIColor colorTextForA9B0BF];
    self.timeLabel.font = [UIFont regularCustomFontOfSize:15];
    self.desLabel.textColor = [UIColor colorTextForA9B0BF];
    self.desLabel.font = [UIFont regularCustomFontOfSize:15];
    
    self.priceLabel.textColor = [UIColor colorTextFor23272A];
    self.priceLabel.font = [UIFont semiBoldCustomFontOfSize:16];
}

- (void)resetRpInfo:(RedPacketInfo *)rp isSendRp:(BOOL)isSendRp
{
    self.rpInfo = rp;
    
    //1.单聊红包 2.拼手气红包 3.普通红包
    if(self.rpInfo.type == 1)
    {
        self.titleLabel.text = @"单聊红包".lv_localized;
    }
    else if(self.rpInfo.type == 2)
    {
        self.titleLabel.text = @"拼手气红包".lv_localized;
    }
    else
    {
        self.titleLabel.text = @"普通红包".lv_localized;
    }
    
    if(isSendRp)
    {
        self.timeLabel.text = [Common getFullMessageTime:self.rpInfo.createAt showDetail:YES];
        self.priceLabel.text = [NSString stringWithFormat:@"%@元".lv_localized, [Common priceFormat:self.rpInfo.total_price]];
        self.bestView.hidden = YES;
        self.desLabel.hidden = NO;
        self.desLabel.text = [NSString stringWithFormat:@"已领完%d/%d".lv_localized, (int)self.rpInfo.users.count, self.rpInfo.count];
    }
    else
    {
        RedPacketPickUser *gotUser = [self.rpInfo curUserRp];
        self.timeLabel.text = [Common getFullMessageTime:gotUser.gotAt showDetail:YES];
        self.priceLabel.text = [NSString stringWithFormat:@"%@元".lv_localized, [Common priceFormat:gotUser.price]];
        
        self.desLabel.hidden = YES;
        BOOL isBest = self.rpInfo.type==2&&self.rpInfo.users.count>=self.rpInfo.count&&gotUser.price>=self.rpInfo.bestPrice;
        self.bestView.hidden = !isBest;
    }
}


@end
