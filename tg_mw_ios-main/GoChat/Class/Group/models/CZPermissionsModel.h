//
//  CZPermissionsModel.h
//  GoChat
//
//  Created by mac on 2021/7/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZPermissionsModel : NSObject

@property (nonatomic,assign) BOOL  banSendKeyword;
@property (nonatomic,assign) BOOL  banSendQRcode;
@property (nonatomic,assign) BOOL  banSendWebLink;
@property (nonatomic,assign) BOOL  banWhisper;//私聊
/// 发送DM消息
@property (nonatomic,assign) BOOL  banSendDmMention;
//发送敏感词移出群聊
@property (nonatomic, assign) BOOL kickWhoSendKeyword;
//敏感词移出群聊提示
@property (nonatomic, assign) BOOL showKickMessage;

@end

NS_ASSUME_NONNULL_END
