//
//  CustomUserPrivacyRules.m
//  GoChat
//
//  Created by apple on 2022/2/7.
//

#import "CustomUserPrivacyRules.h"

@implementation CustomUserPrivacyRules

- (void)setDays:(NSInteger)days{
    _days = days;
    switch (days) {
        case 3:
            self.timeTip = @"最近3天".lv_localized;
            break;
        case 30:
            self.timeTip = @"最近一个月".lv_localized;
            break;
        case 180:
            self.timeTip = @"最近半年".lv_localized;
            break;
        case 365:
            self.timeTip = @"最近一年".lv_localized;
            break;
            
        default:
            break;
    }
}

- (void)setCounts:(NSInteger)counts{
    _counts = counts;
    switch (counts) {
        case 3:
            self.rangeTip = @"3条".lv_localized;
            break;
        case 10:
            self.rangeTip = @"10条".lv_localized;
            break;
        case 0:
            self.rangeTip = @"所有".lv_localized;
            break;
            
        default:
            break;
    }
}

@end

@implementation CustomUserPrivacy

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"rules" : @"CustomUserPrivacyRules"};
}
@end
