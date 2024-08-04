//
//  UserInfo.h
//  GoChat
//
//  Created by wangyutao on 2020/10/28.
//

#import <Foundation/Foundation.h>

@interface UserFullInfo : NSObject
//@property (nonatomic) BOOL is_blocked;
@property (nonatomic) BOOL supports_video_calls;
@property (nonatomic, copy) NSString *share_text;
@property (nonatomic, copy) NSString *bio;
@end

@interface OrgUserInfo : NSObject
@property (nonatomic) long uId;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic) BOOL isInternal;

- (NSString *)displayName;
@end

@interface UserType : JWModel

- (BOOL)isDeleted;

@end

@interface UserInfoExt : JWModel

/// 性别 0-男，1-女
@property (nonatomic, assign) NSInteger gender;
/// 生日 YYYY-mm-dd
@property (nonatomic, copy) NSString *birth;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cityCode;

- (NSString *)sex;
- (UIImage *)sexIcon_QT;
- (UIImage *)sexIcon;
- (NSString *)birthday;
- (NSInteger)age;

- (NSString *)births;
- (NSString *)countrys;

- (NSDictionary *)jsonObject;

@end

@interface UserInfo : NSObject<NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *realyName;

@property (assign, nonatomic) BOOL isChoose;

+ (UserInfo *)shareInstance;

@property (nonatomic) long _id;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *phone_number;
@property (nonatomic, copy) NSString *username;
// 是否是好友
@property (nonatomic) BOOL is_contact;
@property (nonatomic) BOOL is_mutual_contact;
@property (nonatomic) BOOL is_verified;
@property (nonatomic,strong) NSDictionary *status;

/// 显示用户在线状态
- (NSString *)onlineStatus;

/// 个性签名
@property (nonatomic, copy) NSString *bio;

@property (nonatomic, strong) UserType *type;

/// 群组内的昵称， 仅在群组内 copy 后使用。
/// 不可直接赋值，否则会导致各种不确定的问题
@property (nonatomic, copy) NSString *groupNickname;

//显示的名称
- (NSString *)displayName;
//displayName对应的拼音
@property (nonatomic, copy) NSString *displayName_short_py;
@property (nonatomic, copy) NSString *displayName_full_py;
//联系人列表索引使用
@property (nonatomic, assign) NSInteger sectionNum;

//头像
@property (nonatomic, strong) ProfilePhoto *profile_photo;

//关键字是否匹配
- (BOOL)isMatch:(NSString *)keyword;

//是否可以通过手机号码搜索到当前用户 - 只对单例有效
@property (nonatomic) BOOL isFindByPhoneNumber;

//是否可以通过用户名搜索到当前用户 - 只对单例有效
@property (nonatomic) BOOL isFindByUserName;

//当前消息未读总数 - 只对单例有效
@property (nonatomic) int msgUnreadTotalCount;

//推送token - 只对单例有效
@property (nonatomic, strong) NSString *pushToken;

//用户数据目录 - 只对单例有效
@property (nonatomic, strong) NSString *data_directory;

//临时变量 - 只对单例有效
@property (nonatomic, strong) NSArray *chatPopupMenuList;

//临时变量 - 只对单例有效，是否密码登录方式
@property (nonatomic) BOOL isPasswordLoginType;

//临时变量 - 只对单例有效，登录方式，登录注册时赋值
//@property (nonatomic) BOOL isPasswordLoginType;

//临时变量 - 只对单例有效，需要查看的联系人id
@property (nonatomic) long willShowContactId;

//临时变量 - 群聊邀请链接
@property (nonatomic,strong) NSString * inviteLink;

/// 是否在公开群页面
@property (nonatomic,assign) BOOL inOpenGroup;
/// 隐私规则
@property (nonatomic,strong) NSMutableDictionary *privacyRules;
/// 组织信息
@property (nonatomic, strong) OrgUserInfo *orgUserInfo;

+ (NSString *)userDisplayName:(long)userId;

//qr string
- (NSString *)qrString;
//-1表示无效qrString
- (long)userIdFromQrString:(NSString *)qrString;
- (long)userIdFromUrl:(NSURL *)url;
- (NSString *)userIdFromInvitrLink:(NSURL *)linkurl;

//重置
- (void)reset;
//设置渐变色及文字
+ (void)setColorBackgroundWithView:(UIView *)view withSize:(CGSize)size withChar:(unichar)text;
+ (void)cleanColorBackgroundWithView:(UIView *)view;
#pragma mark - tips & progress
+ (void)show;
+ (void)show:(NSString *)text;
+ (void)dismiss;
+ (void)showTips:(UIView *)view des:(NSString *)des;
+ (void)showTips:(UIView *)view des:(NSString *)des errorMsg:(NSString *)errorMsg;
+ (void)showTips:(UIView *)view des:(NSString *)des duration:(NSTimeInterval)duration;

@end


