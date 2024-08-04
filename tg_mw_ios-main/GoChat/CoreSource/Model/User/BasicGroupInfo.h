//
//  BasicGroupInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/12/9.
//

#import <Foundation/Foundation.h>

@interface Group_ChatMemberStatus : NSObject
//chatMemberStatusAdministrator, chatMemberStatusBanned, chatMemberStatusCreator, chatMemberStatusLeft, chatMemberStatusMember, and chatMemberStatusRestricted.
@property (nonatomic, copy) NSString *type;
//管理员 - chatMemberStatusAdministrator
//A custom title of the administrator; 0-16 characters without emojis; applicable to supergroups only.
@property (nonatomic, copy) NSString *custom_title;
//True, if the current user can edit the administrator privileges for the called user.
@property (nonatomic) BOOL can_be_edited;
//True, if the administrator can change the chat title, photo, and other settings.
@property (nonatomic) BOOL can_change_info;
//True, if the administrator can create channel posts; applicable to channels only.
@property (nonatomic) BOOL can_post_messages;
//True, if the administrator can edit messages of other users and pin messages; applicable to channels only.
@property (nonatomic) BOOL can_edit_messages;
//True, if the administrator can delete messages of other users.
@property (nonatomic) BOOL can_delete_messages;
//True, if the administrator can invite new users to the chat.
@property (nonatomic) BOOL can_invite_users;
//True, if the administrator can restrict, ban, or unban chat members.
@property (nonatomic) BOOL can_restrict_members;
//True, if the administrator can pin messages; applicable to groups only.
@property (nonatomic) BOOL can_pin_messages;
//True, if the administrator can add new administrators with a subset of their own privileges or demote administrators that were directly or indirectly promoted by them.
@property (nonatomic) BOOL can_promote_members;
//True, if the administrator isn't shown in the chat member list and sends messages anonymously; applicable to supergroups only.
@property (nonatomic) BOOL is_anonymous;

//被禁止 - chatMemberStatusBanned
//Point in time (Unix timestamp) when the user will be unbanned; 0 if never. If the user is banned for more than 366 days or for less than 30 seconds from the current time, the user is considered to be banned forever.
@property (nonatomic) long banned_until_date;

//群创建者 - chatMemberStatusCreator - The user is the owner of a chat and has all the administrator privileges.
//A custom title of the owner; 0-16 characters without emojis; applicable to supergroups only.
//@property (nonatomic, copy) NSString *custom_title;
//True, if the creator isn't shown in the chat member list and sends messages anonymously; applicable to supergroups only.
//@property (nonatomic) BOOL is_anonymous;
//True, if the user is a member of the chat.
@property (nonatomic) BOOL is_member;

//已离开群 - chatMemberStatusLeft

//群成员 - chatMemberStatusMember

//受限制成员 - chatMemberStatusRestricted - The user is under certain restrictions in the chat. Not supported in basic groups and channels.
//待扩展
//......

- (GroupMemberState)getMemberState;
@end

@interface BasicGroupInfo : NSObject

//@basicGroup
@property (nonatomic, copy) NSString *type;
//Group identifier
@property (nonatomic) long _id;
//Number of members in the group
@property (nonatomic) int member_count;
//True, if the group is active
@property (nonatomic) BOOL is_active;
//Identifier of the supergroup to which this group was upgraded; 0 if none
@property (nonatomic) long upgraded_to_supergroup_id;

//Status of the current user in the group
@property (nonatomic, strong) Group_ChatMemberStatus *status;

@end

@interface BasicGroupFullInfo : NSObject
//@basicGroupFullInfo
@property (nonatomic, copy) NSString *type;

//走ChatInfo通道-此处忽略
//object_ptr< chatPhoto >     photo_
//Chat photo; may be null.

@property (nonatomic, copy) NSString *group_description;

//User identifier of the creator of the group; 0 if unknown.
@property (nonatomic) long creator_user_id;

//GroupMemberInfo
@property (nonatomic, strong) NSArray *members;

//Invite link for this group; available only after it has been generated at least once and only for the group creator.
@property (nonatomic, copy) NSString *invite_link;

@end

@interface SuperGroupInfo : NSObject

//@supergroup
@property (nonatomic, copy) NSString *type;
//Group identifier
@property (nonatomic) long _id;
//Number of members in the group
@property (nonatomic) int member_count;
//True, if the supergroup is a channel.
@property (nonatomic) BOOL is_channel;
//True, if the supergroup or channel is verified.
@property (nonatomic) BOOL is_verified;

//Status of the current user in the group
@property (nonatomic, strong) Group_ChatMemberStatus *status;
/// username 有的话，就是公开群，否则就不是公开群
@property (nonatomic,copy) NSString *username;
@end

@interface SuperGroupFullInfo : NSObject
//@supergroupFullInfo
@property (nonatomic, copy) NSString *type;

@property (nonatomic, copy) NSString *group_description;

//Number of members in the supergroup or channel; 0 if unknown.
@property (nonatomic) int member_count;
//Number of privileged users in the supergroup or channel; 0 if unknown.
@property (nonatomic) int administrator_count;
//Number of restricted users in the supergroup; 0 if unknown.
@property (nonatomic) int restricted_count;
//Number of users banned from chat; 0 if unknown.
@property (nonatomic) int banned_count;
//Invite link for this chat.
@property (nonatomic, copy) NSString *invite_link;

@end
