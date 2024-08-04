//
//  TransferHelper.h
//  GoChat
//
//  Created by Autumn on 2022/1/18.
//

#import <Foundation/Foundation.h>
#import "Transfer.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TransferCompletion)(BOOL isSuccess, NSString * _Nullable error, NSInteger errorCode);
typedef void(^TransferInfoCompletion)(Transfer * _Nullable transfer);

@interface TransferHelper : NSObject

+ (void)transfer:(NSDictionary *)param completion:(TransferCompletion)completion;

+ (void)transferInfo:(NSInteger)tId completion:(TransferInfoCompletion)completion;

+ (void)received:(NSInteger)tId completion:(void(^)(NSString * _Nullable error))completion;

+ (void)refund:(NSInteger)tId completion:(void(^)(NSString * _Nullable error))completion;

+ (void)remind:(NSInteger)tId completion:(void(^)(NSString * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
