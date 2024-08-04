//
//  TextUnit.h
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, TextUnitType)
{
    TextUnitTypeUnknown = 0,
    TextUnitTypeText,                //纯文本
    TextUnitTypeIMEmoji,             //im表情
    //链接类型的
    TextUnitTypeLinkBegin,
    TextUnitTypeURL,                 //网址
    TextUnitTypeEmail,               //电子邮件
    TextUnitTypePhoneNumber,         //电话号码
    TextUnitTypeSomeone,             //@某人
    TextUnitTypeTopic,               //话题
    TextUnitTypeDepartment,          //@体系(部门)
    TextUnitTypeRetryInvite,         //点击重试
    TextUnitTypeAutoReply,           //自动回复
    TextUnitTypeName,                //人名
    TextUnitTypeURLSample,           //网址简写
    TextUnitTypeKfcQuitQueue, //在线客服－结束排队
    TextUnitTypeKfcAppraise, //在线客服－进行评价
    TextUnitTypeRPPrompt, //
    TextUnitTypeTransferRemind, //
    TextUnitTypeLinkEnd,
    TextUnitTypeImage,//图片
};

//某人id  sn+工号
UIKIT_EXTERN NSString *const TextUnitUserInfoSomeoneID;
//某人名称
UIKIT_EXTERN NSString *const TextUnitUserInfoSomeoneName;

//话题id
UIKIT_EXTERN NSString *const TextUnitUserInfoTopicID;
//话题名称
UIKIT_EXTERN NSString *const TextUnitUserInfoTopicName;

//部门id tx+部门号
UIKIT_EXTERN NSString *const TextUnitUserInfoDepartmentID;
//部门名称
UIKIT_EXTERN NSString *const TextUnitUserInfoDepartmentName;

@interface TextUnit : NSObject
@property (nonatomic, assign) TextUnitType textUnitType;//标识该串的类型
@property (nonatomic, strong) NSString *originalContent;//原来的内容
@property (nonatomic, assign) NSRange range;//originalContent在原串中位置
@property (nonatomic, strong) NSString *transferredContent;//转义后内容（显示的内容）
@property (nonatomic, strong) NSString *transferredImageId;//转义后图片的唯一id
@property (nonatomic, strong) NSString *transferredImagePath;//转义后图片的本地路径
@property (nonatomic, strong) UIColor *textColor;//显示的字体颜色
@property (nonatomic, assign) BOOL underline;//是否需要下滑线
@property (nonatomic, strong) NSMutableArray *rects;//绘制在界面上时，对应的区域，当需要响应点击时候需要
@property (nonatomic, assign, getter=isSelected) BOOL selected;//是否处于选中状态
@property (nonatomic, strong) UserInfo *selUserInfo;

//存储一些其他信息，比如someone类型时的id，
@property (nonatomic, strong) NSMutableDictionary *userInfo;

//返回是否是一种链接类型（如email url @某人等都属于连接类型）
- (BOOL)isLinkType;
@end
