//
//  CallInfo.m
//  GoChat
//
//  Created by wangyutao on 2021/2/25.
//

#import "CallInfo.h"

@implementation CallBaseInfo

- (long)getRealChatId
{
    if(self.isMeetingAV)
    {
        return self.chatId;
    }
    else
    {
        if(self.from == [UserInfo shareInstance]._id)
        {
            return self.chatId;
        }
        else
        {
            return self.from;
        }
    }
}

- (NSString *)done_jsonForMessage
{
    return [MessageInfo getTextExMessage:[self mj_JSONString] mainCode:AudioAVideo_MessageType subCode:AudioAVideo_MessageType_Done];
}

@end

@implementation LocalCallInfo

+ (instancetype)callWithRemote:(RemoteCallInfo *)call
{
    LocalCallInfo *local = [LocalCallInfo new];
    local.callId = call.callId;
    local.channelName = [call.channelName copy];
    local.from = call.from;
    local.to = [call.to copy];
    local.chatId = call.chatId;
    local.isVideo = call.isVideo;
    local.isMeetingAV = call.isMeetingAV;
    local.callState = CallingState_Incoming_Waiting;
    local.callTime = [NSDate new].timeIntervalSince1970;
    return local;
}

- (NSString *)displayDesc
{
    return self.isVideo?@"[视频通话]".lv_localized:@"[语音通话]".lv_localized;
}

- (NSString *)displayDetailDesc
{
    if(self.startTime>0&&self.endTime>0)
    {
        long intervel = self.endTime - self.startTime;
        return [Common timeFormatted:(int)intervel];
    }
    else
    {
        if(self.callState == CallingState_Canceled_2_Timeout)
        {
            return @"对方无应答".lv_localized;
        }
        else if(self.callState == CallingState_C2C_Canceled)
        {
            return @"对方已取消".lv_localized;
        }
        else
        {
            return @"已取消".lv_localized;
        }
    }
}

- (NSString *)displayCallTime
{
    if(self.startTime>0)
    {
        int intervel = [NSDate new].timeIntervalSince1970 - self.startTime;
        return [Common timeFormatted:intervel];
    }
    return @"00:00";
}

@end

@implementation RemoteCallInfo

@end
