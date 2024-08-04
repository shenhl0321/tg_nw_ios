//
//  TransferObject.m
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "TransferObject.h"

/**
 {method=remittance.remit, @type=sendCustomRequest, parameters={"amount":1.0,"chatId":136817699,"description":"","password":"e10adc3949ba59abbe56e057f20f883e","payee":136817699,"type":1}, @extra=64}
 */

@implementation TransferObject

- (NSDictionary *)jsonObject {
    NSDictionary *param = @{
        @"amount": @(self.amount),
        @"chatId": @(self.chatId),
        @"description": self.descriptions ? : @"",
        @"password": self.password,
        @"payee": @(self.userid),
        @"type": @(self.chatType)
    };
    return @{
        @"@type": @"sendCustomRequest",
        @"method": @"remittance.remit",
        @"parameters": param.mj_JSONString
    };
}

@end
