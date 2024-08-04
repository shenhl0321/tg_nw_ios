//
//  AvFloatingView.m
//  GoChat
//
//  Created by wangyutao on 2021/3/1.
//

#import "AvFloatingView.h"
#import "CallManager.h"

@interface AvFloatingView()
@end

@implementation AvFloatingView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isKeepBounds = YES;
}

- (void)resetCallInfo
{
    if([CallManager shareInstance].isVideo)
    {
        self.flagView.image = [UIImage imageNamed:@"call_video"];
    }
    else
    {
        self.flagView.image = [UIImage imageNamed:@"call_audio"];
    }
    if([CallManager shareInstance].currentCallState == CallingState_In_Calling)
    {
        self.statusLabel.text = [CallManager shareInstance].callDisplayTime;
    }
    else if([CallManager shareInstance].isInCalling)
    {
        self.statusLabel.text = @"等待接听".lv_localized;
    }
    else
    {
        switch ([CallManager shareInstance].currentCallState) {
            case CallingState_Canceled:
                self.statusLabel.text = @"已取消".lv_localized;
                break;
            case CallingState_Canceled_2_Timeout:
                self.statusLabel.text = @"已超时".lv_localized;
                break;
            case CallingState_C2C_Canceled:
                self.statusLabel.text = @"对方已取消".lv_localized;
                break;
            case CallingState_Call_End:
                self.statusLabel.text = @"通话结束".lv_localized;
                break;
            default:
                self.statusLabel.text = @"已结束".lv_localized;
                break;
        }
    }
}

@end
