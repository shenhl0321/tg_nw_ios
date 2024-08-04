//
//  CZCommonTool.h
//  GoChat
//
//  Created by mac on 2021/7/1.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^customBlock)(NSString *str);

@interface CZCommonTool : NSObject

/*工具*/

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+(NSString*)dictionaryToJson:(NSDictionary *)dic;

//判断是否以字母开头
+ (BOOL)isEnglishFirst:(NSString *)str;
//判断是否是群管理
+ (BOOL)isGroupManager:(SuperGroupInfo *)superGroupInfo;
//创建二维码
+ (UIImage *)createQRCodeWithTargetString:(NSString *)targetString logoImage:(UIImage *)logoImage;
//截图
+ (UIImage *)captureImageInView:(UIView *)view;
//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC;
//计算在线时间
+ (NSString *)labelFinallyTime:(NSString *)yetTime;



/*业务工具*/


+ (NSDictionary *)getGreyRedPagListwithPkid:(long)rId;
//存储
+(void)saveGreyRedpadID:(NSDictionary *)msgDic;
//写gif到沙盒
+ (void)saveGifImage:(PHAssetResource *)resource withImage:(UIImage *)gifimage withblock:(customBlock)block;
//计算文本高度
+ (CGSize)boundingRectWithString:(NSString *)str withFont:(float)fontsize withWidth:(float)width;
//提取url
+ (NSArray*)getURLFromStr:(NSString *)string;
//是否是url
+ (BOOL)checkUrlWithString:(NSString *)url;
/// 解析文本中的链接地址
+ (NSArray<TextUnit *> *)parseURLWithContent:(NSString *)urlStr;
//是否为二维码
+ (BOOL)isQRcodeImage:(UIImage *)image;
//聊天信息是否包含敏感词
+ (BOOL)chatMessageContainsKeys:(NSArray *)keywords withmsg:(NSString *)msgstr;
//存储会话的草稿  chatid   message
+(void)savedraftchatid:(long)chatid saveString:(NSString *)contentstr;
//获取草稿
+ (NSString *)getdraftchatid:(long)chatid;
//正则  是否为数字
+ (BOOL)deptNumInputShouldNumber:(NSString *)str;
//根据文字内容、字体大小和宽度限制计算文本控件的行数
+ (NSArray *)rowsOfString:(NSString *)text withFont:(UIFont *)font withWidth:(CGFloat)width;
// 获取cell高度
+ (CGFloat)getCellHeightWithStr:(NSString *)str withbool:(BOOL)showAll;

//存储会话的草稿  chatid   message  草稿中@的对象
+(void)saveUserMsgdraftchatid:(long)chatid saveArray:(NSArray *)userinfoArr;
//获取草稿  提醒的用户数组
+ (NSArray *)getUserMsgdraftchatid:(long)chatid;
//获取在串中位置
+ (NSRange)getRangeFromString:(NSString *)targetStr withString:(NSString *)subStr;
//秒 转为 01:30:20
+ (NSString *)getFormatTimeStrWith:(NSInteger)timeTotal;

@end

NS_ASSUME_NONNULL_END
