//
//  NSString+SFLocalizedString.h
//  AppModules
//
//  Created by mac on 2019/9/17.
//  Copyright © 2019 wangfei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,AppLanguageType) {
    AppLanguageTypeCN_S = 0,
    AppLanguageTypeCN_T,
    AppLanguageTypeEN,
    AppLanguageTypeJA,
    AppLanguageTypeKO,
    AppLanguageTypeRU
};

typedef NS_ENUM(NSInteger,AppStyle) {
    AppStyleImageDefault = 0,
    AppStyleImageYellow,
    AppStyleImageBlue,
    AppStyleImageGreen
};

#define SFLocalizedString(text) [text lv_localized]

extern NSString *const SFLocalizedStringLanguageDidChangeNotificationName;

@class SFLocalizedStringManager;
@protocol SFLocalizedStringDelegate <NSObject>
- (void)localizedStringManager:(SFLocalizedStringManager *)manager changeLanguage:(AppLanguageType)currentLanguage;
@end

@interface SFLocalizedStringManager : NSObject
/// 多语言文件名称
@property (nonatomic,copy) NSString *tableName;
/// 是否使用指定的默认语言，为YES时使用defaultLanguage,为NO时使用系统当前语言
@property (nonatomic,assign) BOOL enableDefaultLanguage;
/// 指定默认语言
@property (nonatomic,assign) AppLanguageType defaultLanguage;
/// 当前语言
@property (nonatomic,assign) AppLanguageType currentLanguage;
/// 当前语言编码
@property (nonatomic,copy,readonly) NSString *currentLanguageCode;
/// 需要翻译的所有文本记录(使用到该文本时才会被记录)
@property (nonatomic,strong,readonly) NSMutableArray<NSString *> *localizedStrings;
+ (instancetype)manager;
/// 初始化
- (void)setup;
/// 调用的时候执行一次languageDidChange用来初始化文本,语言发生变化的时候再执行一次languageDidChange用来更新文本(其他监听方式只有在语言发生变化的时候才会回调)
- (void)addObserver:(id)observer didChangeLanguage:(void(^)(AppLanguageType language))languageDidChange;
- (void)addObserver:(id<SFLocalizedStringDelegate>)observer;
- (void)removeObserver:(id<SFLocalizedStringDelegate>)observer;
/// 根据当前语言获取翻译文本
- (NSString *)localizedStringWithString:(NSString *)string;
/// 根据当前语言和指定的翻译表获取翻译文本
- (NSString *)localizedStringWithString:(NSString *)string tableName:(NSString *)tableName;
/// 根据指定语言获取翻译文本
- (NSString *)localizedStringWithString:(NSString *)string language:(AppLanguageType)language;
/// 根据指定语言和指定的翻译表获取翻译文本
- (NSString *)localizedStringWithString:(NSString *)string language:(AppLanguageType)language tableName:(NSString *)tableName;
/// 清空当前需要翻译的文本记录
- (void)clearLocalizedStrings;
@end

@interface NSString (SFLocalizedString)
@property (nonatomic,copy,readonly) NSString *lv_localized;
@property (nonatomic,copy,readonly) NSString *lv_Style;
- (NSString *)lv_localizedWithLanguage:(AppLanguageType)language;
- (NSString *(^)(AppLanguageType language))lvbk_localized;
@end

NS_ASSUME_NONNULL_END
