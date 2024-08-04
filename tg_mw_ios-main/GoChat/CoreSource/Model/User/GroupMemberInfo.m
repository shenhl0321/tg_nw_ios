//
//  GroupMemberInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/12/9.
//

#import "GroupMemberInfo.h"

@implementation GroupMemberInfo

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"type" : @"@type"};
}

- (BOOL)isManagerRole
{
    switch ([self.status getMemberState])
    {
        case GroupMemberState_Administrator:
            //管理员
            return YES;
        case GroupMemberState_Creator:
            //创建者
            if(self.status.is_member)
            {//创建者已不在群组
                return YES;
            }
            break;
        case GroupMemberState_Left:
            //不在群组
            break;
        case GroupMemberState_Member:
            //普通成员
            break;
        case GroupMemberState_Banned:
            //被禁用
            break;
        case GroupMemberState_Restricted:
            //被禁言
            break;
        default:
            break;
    }
    return NO;
}

@end
