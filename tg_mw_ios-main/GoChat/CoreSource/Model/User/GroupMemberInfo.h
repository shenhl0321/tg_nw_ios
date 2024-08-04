//
//  GroupMemberInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/12/9.
//

#import <Foundation/Foundation.h>
#import "BasicGroupInfo.h"

@interface GroupMemberInfo : NSObject

//@chatMember
@property (nonatomic, copy) NSString *type;
//User identifier of the chat member.
@property (nonatomic) long user_id;
//Identifier of a user that invited/promoted/banned this member in the chat; 0 if unknown.
@property (nonatomic) long inviter_user_id;
//Point in time (Unix timestamp) when the user joined the chat.
@property (nonatomic) long joined_chat_date;
//Status of the member in the chat.
@property (nonatomic, strong) Group_ChatMemberStatus *status;

@property (nonatomic, copy) NSString *nickname;

- (BOOL)isManagerRole;
@end
