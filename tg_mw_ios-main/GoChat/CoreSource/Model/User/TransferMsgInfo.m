//
//  TransferMsgInfo.m
//  GoChat
//
//  Created by Autumn on 2022/1/24.
//

#import "TransferMsgInfo.h"
#import "TransferHelper.h"

@implementation TransferMsgInfo

- (void)setState:(Transfer_MessageSubType)state {
    _state = state;
    if (state == Transfer_MessageSubType_Remit) {
        [self fetchInfo];
    }
}

- (NSString *)money {
    return [NSString stringWithFormat:@"￥%.2f", self.amount];
}

- (UIImage *)icon {
    if (self.state == Transfer_MessageSubType_RefundByUser ||
        self.state == Transfer_MessageSubType_RefundBySystem) {
        return [UIImage imageNamed:@"chat_transfer_refund"];
    }
    if (self.transfer.status == 2 || self.transfer.status == 3) {
        return [UIImage imageNamed:@"chat_transfer_refund"];
    }
    return [UIImage imageNamed:@"chat_transfer_index"];
}


- (NSString *)tipMessage {
    BOOL isMeSend = UserInfo.shareInstance._id == self.payer;
    BOOL isMeReceived = UserInfo.shareInstance._id == self.payee;
    
    if (self.state != Transfer_MessageSubType_Remit) {
        switch (self.state) {
            case Transfer_MessageSubType_Receive:
                if (self.isOutgoing) {
                    return isMeSend ? @"已被接收".lv_localized : @"已收款".lv_localized;
                } else {
                    return isMeReceived ? @"已被接收".lv_localized : @"已收款".lv_localized;
                }
            case Transfer_MessageSubType_RefundByUser:
                if (self.isOutgoing) {
                    return isMeSend ? @"已被退还".lv_localized : @"已退还".lv_localized;
                } else {
                    return isMeReceived ? @"已被退还".lv_localized : @"已退还".lv_localized;
                }
            case Transfer_MessageSubType_RefundBySystem:
                return @"已退还".lv_localized;
            default:
                return @"";
        }
    }
    
    switch (self.transfer.status) {
        case 0:
            return self.isOutgoing ? @"你发起了一笔转账".lv_localized : @"请收款".lv_localized;
        case 1:
            if (self.isOutgoing) {
                return isMeSend ? @"已被接收".lv_localized : @"已收款".lv_localized;
            } else {
                return isMeReceived ? @"已被接收".lv_localized : @"已收款".lv_localized;
            }
        case 2:
            if (self.isOutgoing) {
                return isMeSend ? @"已被退还".lv_localized : @"已退还".lv_localized;
            } else {
                return isMeReceived ? @"已被退还".lv_localized : @"已退还".lv_localized;
            }
        case 3:
            return @"已退还".lv_localized;
        default:
            return @"";
    }
}

- (UIColor *)bgColor {
//    if () {
//        return UIColor.colorBubbleRedBubble;
//    }
    if (self.state == Transfer_MessageSubType_Remit && self.transfer.status == 0) {
        return UIColor.colorBubbleRedBubble;
    }
    return UIColor.colorBubbleRedBubbleGot;
}

- (void)fetchInfo {
    @weakify(self);
    [TransferHelper transferInfo:self.remittanceId completion:^(Transfer * _Nullable transfer) {
        @strongify(self);
        self.transfer = transfer;
        [NSNotificationCenter.defaultCenter postNotificationName:@"TransferMessageInfoDidChanged" object:@(self.remittanceId)];
    }];
}

- (Transfer *)transfer {
    if (!_transfer) {
        _transfer = Transfer.new;
        _transfer.ids = self.remittanceId;
    }
    return _transfer;
}

@end
