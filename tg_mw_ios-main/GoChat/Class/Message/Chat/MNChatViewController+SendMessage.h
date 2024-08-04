//
//  MNChatViewController+SendMessage.h
//  GoChat
//
//  Created by Autumn on 2022/1/19.
//

#import "MNChatViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNChatViewController (SendMessage)

/// 图片广告内容
@property (nonatomic, copy) NSString * _Nullable photoAdContent;
/// 图片广告所在数组索引
@property (nonatomic, assign) NSInteger photoAdIndex;

- (BOOL)isAdSend;

- (NSDictionary *)photoMarkup;

#pragma mark - 广告消息
/// 广告匹配正则内容
/// 仅管理员以上级别可获取，发广告使用
- (NSArray<NSString *> *)ADMsgMatchsFromText:(NSString *)text;

/// 将广告内容转成提交的 json 数据
- (NSDictionary *)ADReplyMarkup:(NSArray<NSString *> *)ads;

/// 去掉广告内容，转成新的文本消息
- (NSString *)text:(NSString *)text forReplaceMatchs:(NSArray<NSString *> *)matchs;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
