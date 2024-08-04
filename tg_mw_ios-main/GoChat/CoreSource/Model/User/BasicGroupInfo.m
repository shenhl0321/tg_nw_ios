//
//  BasicGroupInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/12/9.
//

#import "BasicGroupInfo.h"

@implementation Group_ChatMemberStatus

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (GroupMemberState)getMemberState
{
    //chatMemberStatusAdministrator, chatMemberStatusBanned, chatMemberStatusCreator, chatMemberStatusLeft, chatMemberStatusMember, and chatMemberStatusRestricted
    if([@"chatMemberStatusAdministrator" isEqualToString:self.type])
    {
        return GroupMemberState_Administrator;
    }
    if([@"chatMemberStatusBanned" isEqualToString:self.type])
    {
        return GroupMemberState_Banned;
    }
    if([@"chatMemberStatusCreator" isEqualToString:self.type])
    {
        return GroupMemberState_Creator;
    }
    if([@"chatMemberStatusLeft" isEqualToString:self.type])
    {
        return GroupMemberState_Left;
    }
    if([@"chatMemberStatusMember" isEqualToString:self.type])
    {
        return GroupMemberState_Member;
    }
    if([@"chatMemberStatusRestricted" isEqualToString:self.type])
    {
        return GroupMemberState_Restricted;
    }
    //未知状态当成不在群组状态处理
    return GroupMemberState_Left;
}

@end

@implementation BasicGroupInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id", @"type" : @"@type"};
}

@end

@implementation BasicGroupFullInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type", @"group_description" : @"description"};
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"members" : @"GroupMemberInfo"};
}

@end

@implementation SuperGroupInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id", @"type" : @"@type"};
}

@end

@implementation SuperGroupFullInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type", @"group_description" : @"description"};
}

@end
