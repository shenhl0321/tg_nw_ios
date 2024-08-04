//
//  ChatMsgObject.h
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 消息参数模型基类

@interface ChatMsgObject : NSObject

@property (nonatomic, copy, readonly) NSString *types;

- (NSDictionary *)jsonObject;

@end

NS_ASSUME_NONNULL_END
