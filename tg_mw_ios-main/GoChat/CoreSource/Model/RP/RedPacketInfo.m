//
//  RedPacketInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/4/6.
//

#import "RedPacketInfo.h"

@implementation RedPacketPickUser
@end

@implementation RedPacketInfo

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"users" : @"RedPacketPickUser"};
}

- (BOOL)isDone
{
    if(self.type == 1)
    {//单聊红包
        return self.users.count>=1;
    }
    return self.users.count>=self.count;
}

- (BOOL)isGot
{
    if(self.users.count>0)
    {
        for(RedPacketPickUser *user in self.users)
        {
            if(user.userId == [UserInfo shareInstance]._id)
            {
                return YES;
            }
        }
    }
    return NO;
}

- (RpState)getRpState
{
    if([self isGot])
    {
        if([self isDone])
        {
            return RpState_GotADone;
        }
        else
        {
            return RpState_Got;
        }
    }
    else
    {
        if([self isDone])
        {
            return RpState_Done;
        }
        else
        {
            if(self.isExpire)
            {
                return RpState_Expire;
            }
            else
            {
                return RpState_To_Get;
            }
        }
    }
}

- (RedPacketPickUser *)curUserRp
{
    for(RedPacketPickUser *user in self.users)
    {
        if(user.userId == [UserInfo shareInstance]._id)
        {
            return user;
        }
    }
    return nil;
}

- (float)bestPrice
{
    float best = 0.0f;
    for(RedPacketPickUser *user in self.users)
    {
        if(user.price>best)
        {
            best = user.price;
        }
    }
    return best;
}

- (float)totalGotPrice
{
    float total = 0.0f;
    for(RedPacketPickUser *user in self.users)
    {
        total+= user.price;
    }
    return total;
}

- (long)doneTotalSeconds
{
    long gotAt = 0;
    for(RedPacketPickUser *user in self.users)
    {
        if(user.gotAt>gotAt)
        {
            gotAt = user.gotAt;
        }
    }
    return gotAt - self.createAt;
}

- (NSString *)detailDes
{
    if(self.type == 1)
    {//单聊红包
        if(self.users.count>=1)
        {//已被领取
            if([UserInfo shareInstance]._id == self.from)
                return [NSString stringWithFormat:@"红包金额%@元，对方已领取".lv_localized, [Common priceFormat:self.total_price]];
            else
                return [NSString stringWithFormat:@"红包金额%@元，已领取".lv_localized, [Common priceFormat:self.total_price]];
        }
        else
        {
            if(self.isExpire)
            {//已过期
                return [NSString stringWithFormat:@"红包金额%@元，已过期".lv_localized, [Common priceFormat:self.total_price]];
            }
            else
            {
                if([UserInfo shareInstance]._id == self.from)
                    return [NSString stringWithFormat:@"红包金额%@元，等待对方领取".lv_localized, [Common priceFormat:self.total_price]];
                else
                    return [NSString stringWithFormat:@"红包金额%@元，等待领取".lv_localized, [Common priceFormat:self.total_price]];
            }
        }
    }
    else
    {
        if(self.users.count >= self.count)
        {//领光
            return [NSString stringWithFormat:@"%d个红包共%@元，%@被抢光".lv_localized, self.count, [Common priceFormat:self.total_price], [Common timeFormattedForRp:(int)[self doneTotalSeconds]]];
        }
        else
        {//未领完
            if(self.isExpire)
            {
                return [NSString stringWithFormat:@"该红包已过期。已领取%d/%d个，共%@/%@元".lv_localized, (int)self.users.count, self.count, [Common priceFormat:[self totalGotPrice]], [Common priceFormat:self.total_price]];
            }
            else
            {
                if([UserInfo shareInstance]._id == self.from)
                {//自己发的
                    return [NSString stringWithFormat:@"已领取%d/%d个，共%@/%@元".lv_localized, (int)self.users.count, self.count, [Common priceFormat:[self totalGotPrice]], [Common priceFormat:self.total_price]];
                }
                else
                {
                    return [NSString stringWithFormat:@"已领取%d/%d个".lv_localized, (int)self.users.count, self.count];
                }
            }
        }
    }
}

@end

@implementation RP_Msg
@end

@implementation RP_Pick_Msg

- (NSString *)description:(long)whoGot
{
    if([UserInfo shareInstance]._id == self.from)
    {//当前用户创建的
        if(whoGot == self.from)
        {//自己领取了自己的
            return @"你领取了自己发的红包".lv_localized;
        }
        else
        {//他人领取
            if(self.type == 1)
            {//单聊
                return [NSString stringWithFormat:@"%@领取了你的红包".lv_localized, [UserInfo userDisplayName:whoGot]];
            }
            else
            {
                if(self.isLast)
                {
                    return [NSString stringWithFormat:@"%@领取了你的红包，你的红包已被领完".lv_localized, [UserInfo userDisplayName:whoGot]];
                }
                else
                {
                    return [NSString stringWithFormat:@"%@领取了你的红包".lv_localized, [UserInfo userDisplayName:whoGot]];
                }
            }
        }
    }
    else
    {//其他用户创建的
        if([UserInfo shareInstance]._id == whoGot)
        {
            return @"你领取了红包".lv_localized;
        }
        else
        {
            return [NSString stringWithFormat:@"%@领取了红包".lv_localized, [UserInfo userDisplayName:whoGot]];
        }
    }
}

@end
