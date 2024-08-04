//
//  TransferObject.h
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TransferChatType) {
    TransferChatType_Single = 1,
    TransferChatType_Group,
};

@interface TransferObject : JWModel

@property (nonatomic, assign) NSInteger chatId;
@property (nonatomic, assign) NSInteger userid;
@property (nonatomic) double amount;
@property (nonatomic, assign) TransferChatType chatType;
@property (nonatomic, copy) NSString *descriptions;
@property (nonatomic, copy) NSString *password;

- (NSDictionary *)jsonObject;

@end

NS_ASSUME_NONNULL_END
