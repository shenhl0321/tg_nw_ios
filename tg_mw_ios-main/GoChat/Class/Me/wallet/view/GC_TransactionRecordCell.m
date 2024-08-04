//
//  GC_TransactionRecordCell.m
//  GoChat
//
//  Created by wangfeiPro on 2021/12/13.
//

#import "GC_TransactionRecordCell.h"

@implementation GC_TransactionRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentV.clipsToBounds = YES;
    self.contentV.layer.cornerRadius = 13;
    // Initialization code
}

- (void)resetOrderInfo:(WalletOrderInfo *)info
{
    //类型 1.充值 2提现 3.收款 4.转账 5.创建红包 6.领取红包 7.红包退回 12转账付款 13转账收款 14用户退款 15 系统退款
    UIColor *reduceColor = HEX_COLOR(@"#E9230F"), *plusColor = COLOR_CG1;
    switch (info.type)
    {
        case 1:
            self.titleLab.text = @"充值".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
           
            break;
        case 2:
            self.titleLab.text = @"提现".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = reduceColor;
            break;
        case 3:
            self.titleLab.text = @"收款".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
        case 4:
            self.titleLab.text = @"转账".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = reduceColor;
            break;
        case 5:
            self.titleLab.text = [NSString stringWithFormat:@"红包-%@".lv_localized, info.rpContent ? : @""];
            self.moneyLab.text = [NSString stringWithFormat:@"%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = reduceColor;
            break;
        case 6:
            self.titleLab.text = [NSString stringWithFormat:@"红包-%@".lv_localized, info.rpContent ? : @""];
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
        case 7:
            self.titleLab.text = @"红包-退回".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
        case 12:
            self.titleLab.text = [NSString stringWithFormat:@"转账-转给%@".lv_localized, info.remittanceInfo.payeeName];
            self.moneyLab.text = [NSString stringWithFormat:@"%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = reduceColor;
            break;
        case 13:
            self.titleLab.text = [NSString stringWithFormat:@"转账-来自%@".lv_localized, info.remittanceInfo.payerName];
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
        case 14:
            self.titleLab.text = [NSString stringWithFormat:@"转账-%@退款".lv_localized, info.remittanceInfo.payeeName];
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
        case 15:
            self.titleLab.text = @"转账-系统退款".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"+%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
        default:
            self.titleLab.text = @"未知类型".lv_localized;
            self.moneyLab.text = [NSString stringWithFormat:@"%@", [Common priceFormat:info.amount]];
            self.statusLab.text = info.remarks;
            self.statusLab.textColor = plusColor;
            break;
    }
    self.timeLab.text = [Common getFullMessageTime:info.createAt showDetail:YES];
}

@end
