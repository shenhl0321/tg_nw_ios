//
//  GroupMemberNicknameUpdate.h
//  GoChat
//
//  Created by Autumn on 2022/2/27.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN


/// 群组用户修改昵称通知信息
@interface GroupMemberNicknameUpdate : JWModel

@property (nonatomic, assign) long chatId;
@property (nonatomic, assign) long userId;
@property (nonatomic, copy) NSString *nickname;

@end

NS_ASSUME_NONNULL_END
