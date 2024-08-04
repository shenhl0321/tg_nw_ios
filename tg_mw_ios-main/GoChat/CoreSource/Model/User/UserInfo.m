//
//  UserInfo.m
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import "UserInfo.h"
#import "AESCrypt.h"
#import "NSString+URL.h"
#import "TimeFormatting.h"

static UserInfo *g_UserInfo = nil;

@implementation UserFullInfo
@end

@implementation OrgUserInfo

- (NSString *)displayName
{
    return [NSString stringWithFormat:@"%@%@", self.firstName, self.lastName];
}

@end

@implementation UserType

- (BOOL)isDeleted {
    return [self.atType isEqualToString:@"userTypeDeleted"];
}

@end

@implementation UserInfoExt


- (NSString *)births {
    if ([NSString xhq_notEmpty:_birth]) {
        return _birth;
    }
    return @"";
}

- (NSString *)countrys {
    if ([NSString xhq_notEmpty:_province] && [NSString xhq_notEmpty:_city]) {
        return [NSString stringWithFormat:@"%@-%@", _province, _city];
    }
    if ([NSString xhq_notEmpty:_country]) {
        return _country;
    }
    return LanguageIsEnglish ? @"China" : @"中国";
}

- (NSString *)sex {
    return self.gender == 0 ? @"男".lv_localized : @"女".lv_localized;
}

- (UIImage *)sexIcon_QT{
    return self.gender == 0 ? [UIImage imageNamed:@"icon_man_qt"] : [UIImage imageNamed:@"icon_women_qt"];
}
- (UIImage *)sexIcon {
    return self.gender == 0 ? [UIImage imageNamed:@"icon_info_gender_male"] : [UIImage imageNamed:@"icon_info_gender_female"];
}

- (NSString *)birthday {
    return self.births;
}

- (NSInteger)age {
    NSDate *birth = [NSDate dateWithString:self.births format:@"yyyy-mm-dd"];
    NSTimeInterval time = [NSDate.date timeIntervalSinceDate:birth];
    return (int)time / (3600 * 24 * 365);
}

- (NSDictionary *)jsonObject {
    return @{
        @"gender": @(_gender),
        @"birth": _birth,
        @"country": _country,
        @"countryCode": _countryCode,
        @"province": _province ? : @"",
        @"city": _city ? : @"",
        @"cityCode": _cityCode ? : @""
    };
}

@end

@implementation UserInfo

+ (UserInfo *)shareInstance
{
    if(g_UserInfo == nil)
    {
        g_UserInfo = [[UserInfo alloc] init];
    }
    return g_UserInfo;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"_id" : @"id"};
}

- (NSString *)displayName
{
    if (self.type.isDeleted) {
        return @"已销号".lv_localized;
    }
    /// 群组内用户昵称
    /// 仅在 userinfo copy 后使用
    if (self.groupNickname && self.groupNickname.length > 0) {
        return self.groupNickname;
    }
    return [NSString stringWithFormat:@"%@%@", !self.first_name ? @"":self.first_name, !self.last_name ? @"":self.last_name];
}

- (NSString *)onlineStatus {
    NSString *type = self.status[@"@type"];
    if ([type isEqualToString:@"userStatusOnline"]) {
        return @"在线".lv_localized;
    } else if ([type isEqualToString:@"userStatusRecently"]) {
        return @"最近在线".lv_localized;
    } else if ([type isEqualToString:@"userStatusLastWeek"]) {
        return @"上周".lv_localized;
    } else if ([type isEqualToString:@"userStatusLastMonth"]) {
        return @"上个月".lv_localized;
    } else if ([type isEqualToString:@"userStatusOffline"]) {
        NSInteger online = [self.status[@"was_online"] intValue];
        return [TimeFormatting formatTimeWithTimeInterval:online];
    }
    return @"离线".lv_localized;
}

//关键字是否匹配
- (BOOL)isMatch:(NSString *)keyword
{
    return [[self.displayName uppercaseString] containsString:[keyword uppercaseString]]
    || [[self.displayName_full_py uppercaseString] containsString:[keyword uppercaseString]]
    || [[self.username uppercaseString] containsString:[keyword uppercaseString]];
}

+ (NSString *)userDisplayName:(long)userId
{
    UserInfo *user = [[TelegramManager shareInstance] contactInfo:userId];
    if(user != nil)
    {
        return user.displayName;
    }
    else
    {
        return [NSString stringWithFormat:@"%ld", userId];
    }
}

- (NSMutableDictionary *)privacyRules{
    if (!_privacyRules) {
        _privacyRules = [NSMutableDictionary dictionary];
    }
    return _privacyRules;
}

//qr string
- (NSString *)qrString
{
    NSString *uidString = [AESCrypt encrypt:[NSString stringWithFormat:@"%ld", self._id] password:AES_PASSWORD];
    NSString *ids = [AESCrypt decrypt:uidString password:AES_PASSWORD];
    NSLog(@"%ld - %@", self._id, ids);
    NSString *qr = [NSString stringWithFormat:@"%@?uid=%@", KShareHostAddress, [uidString URLEncodedString]];
    //long uid = [self userIdFromQrString:qr];
    return qr;
}

//-1表示无效qrString
- (long)userIdFromQrString:(NSString *)qrString
{
    if(!IsStrEmpty(qrString))
    {
        NSURL *url = [NSURL URLWithString:qrString];
        return [self userIdFromUrl:url];
    }
    return -1;
}

- (long)userIdFromUrl:(NSURL *)url
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    __block NSString *uidString = nil;
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([@"uid" isEqualToString:obj.name])
        {
            uidString = obj.value;
            *stop = YES;
            return;
        }
    }];
    if(uidString && [uidString isKindOfClass:[NSString class]])
    {
        uidString = [AESCrypt decrypt:[uidString URLDecodedString] password:AES_PASSWORD];
        long uid = [uidString longLongValue];
        if(uid>0)
            return uid;
    }
    return -1;
}

- (NSString *)userIdFromInvitrLink:(NSURL *)linkurl
{
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:linkurl.absoluteString];
    __block NSString *uidString = nil;
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([@"link" isEqualToString:obj.name])
        {
            uidString = obj.value;
            *stop = YES;
            return;
        }
    }];
    if(uidString && [uidString isKindOfClass:[NSString class]])
    {
        return [NSString stringWithFormat:@"t.me/joinchat/%@",[uidString stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }
    return nil;
}

//重置
- (void)reset
{
    self._id = 0;
    self.first_name = nil;
    self.last_name = nil;
    self.phone_number = nil;
    self.username = nil;
    self.is_contact = false;
    self.is_mutual_contact = false;
    self.is_verified = false;
    self.displayName_full_py = nil;
    self.displayName_short_py = nil;
    self.sectionNum = 0;
    self.profile_photo = nil;
    self.msgUnreadTotalCount = 0;
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:UserInfo.class]) {
        return NO;
    }
    UserInfo *obj = (UserInfo *)object;
    return obj._id == self._id;
}

- (id)copyWithZone:(NSZone *)zone {
    UserInfo *user = UserInfo.new;
    user._id = self._id;
    user.first_name = self.first_name;
    user.last_name = self.last_name;
    user.phone_number = self.phone_number;
    user.username = self.username;
    user.is_contact = self.is_contact;
    user.is_mutual_contact = self.is_mutual_contact;
    user.is_verified = self.is_verified;
    user.displayName_full_py = self.displayName_full_py;
    user.displayName_short_py = self.displayName_short_py;
    user.sectionNum = self.sectionNum;
    user.profile_photo = self.profile_photo;
    user.bio = self.bio;
    user.type = self.type;
    user.groupNickname = self.groupNickname;
    user.realyName = self.realyName;
    return user;
}

//设置渐变色及文字
+ (void)setColorBackgroundWithView:(UIView *)view withSize:(CGSize)size withChar:(unichar)text
{
    int index = text%7;
    UIColor *startColor = nil;
    UIColor *endColor = nil;
    switch (index)
    {
        case 0:
            startColor = HEX_COLOR(@"#0feebe");
            endColor = HEX_COLOR(@"#00bb92");
            break;
        case 1:
            startColor = HEX_COLOR(@"#18ec27");
            endColor = HEX_COLOR(@"#06b216");
            break;
        case 2:
            startColor = HEX_COLOR(@"#6fd3ff");
            endColor = HEX_COLOR(@"#2189da");
            break;
        case 3:
            startColor = HEX_COLOR(@"#6fa5ff");
            endColor = HEX_COLOR(@"#3539ef");
            break;
        case 4:
            startColor = HEX_COLOR(@"#ba61ff");
            endColor = HEX_COLOR(@"#6d11ae");
            break;
        case 5:
            startColor = HEX_COLOR(@"#c281ff");
            endColor = HEX_COLOR(@"#7450b1");
            break;
        case 6:
            startColor = HEX_COLOR(@"#fe81ff");
            endColor = HEX_COLOR(@"#b83683");
            break;
        default:
            startColor = HEX_COLOR(@"#0feebe");
            endColor = HEX_COLOR(@"#00bb92");
            break;
    }
    [view cb_gradientBackgroundFromColor:startColor toColor:endColor fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, 1) withChar:text withFontSize:size.width*0.45f];
}

+ (void)cleanColorBackgroundWithView:(UIView *)view
{
    [view cb_removeGradientBackground];
}

#pragma mark - tips & progress
+ (void)show
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
}

+ (void)show:(NSString *)text;
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    if(text.length>0)
    {
        [SVProgressHUD showWithStatus:text];
    }
    else
    {
        [SVProgressHUD show];
    }
}

+ (void)dismiss
{
    [SVProgressHUD dismiss];
}

+ (void)showTips:(UIView *)view des:(NSString *)des errorMsg:(NSString *)errorMsg
{
    if(DEBUG_MODE)
    {
        if(!IsStrEmpty(errorMsg))
        {
            [UserInfo showTips:view des:[NSString stringWithFormat:@"%@ - %@", des, errorMsg]];
        }
        else
        {
            [UserInfo showTips:view des:des];
        }
    }
    else
    {
        [UserInfo showTips:view des:des];
    }
}

+ (void)showTips:(UIView *)view des:(NSString *)des
{
    if(!IsStrEmpty(des))
    {
        //if(view == nil)
        [[UIApplication sharedApplication].keyWindow makeToast:des duration:[CSToastManager defaultDuration] position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.3)]];
        //else
        //    [view makeToast:des duration:[CSToastManager defaultDuration] position:CSToastPositionTop];
    }
}

+ (void)showTips:(UIView *)view des:(NSString *)des duration:(NSTimeInterval)duration
{
    if(!IsStrEmpty(des))
    {
        //if(view == nil)
        [[UIApplication sharedApplication].keyWindow makeToast:des duration:duration position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT*0.3)]];
        //else
        //    [view makeToast:des duration:[CSToastManager defaultDuration] position:CSToastPositionTop];
    }
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithLong:self._id] forKey:@"_id"];
    [aCoder encodeObject:self.first_name forKey:@"first_name"];
    [aCoder encodeObject:self.last_name forKey:@"last_name"];
    [aCoder encodeObject:self.username forKey:@"username"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self._id = [[aDecoder decodeObjectForKey:@"_id"] longValue];
        self.first_name = [aDecoder decodeObjectForKey:@"first_name"];
        self.last_name = [aDecoder decodeObjectForKey:@"last_name"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        }
    return self;
}


+ (BOOL)supportsSecureCoding
{
    return YES;
}


@end
