//
//  NSString+SFLocalizedString.m
//  AppModules
//
//  Created by mac on 2019/9/17.
//  Copyright © 2019 wangfei. All rights reserved.
//

#import "NSString+SFLocalizedString.h"

NSString *const SFLocalizedStringLanguageDidChangeNotificationName = @"SFLocalizedStringLanguageDidChangeNotificationName";
static NSString *const SFLocalizedStringAppLanguageCodeCacheKey = @"SFLocalizedStringAppLanguageCodeCacheKey";
static NSString *const SFLocalizedStringAppLanguageCacheKey = @"SFLocalizedStringAppLanguageCacheKey";
static NSString *const SFLocalizedStringsCacheKey = @"SFLocalizedStringsCacheKey";

@interface SFLocalizedStringManager()
@property (nonatomic,assign) BOOL isSetup;
@property (nonatomic,strong) NSBundle *currentLanguageBundle;
@property (nonatomic,strong) NSPointerArray *observers;
@end

@implementation SFLocalizedStringManager
@synthesize localizedStrings = _localizedStrings;

+ (instancetype)manager {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaultLanguage = AppLanguageTypeEN;
        _currentLanguage = AppLanguageTypeEN;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cacheLocalizedStrings)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - public
- (void)addObserver:(id<SFLocalizedStringDelegate>)observer {
    if (observer && [self.observers.allObjects indexOfObject:observer] == NSNotFound) {
        [self.observers addPointer:(__bridge void * _Nullable)(observer)];
    }
}

- (void)addObserver:(id<SFLocalizedStringDelegate>)observer didChangeLanguage:(void (^)(AppLanguageType))didChangeLanguage {
    objc_setAssociatedObject(observer, _cmd, didChangeLanguage, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addObserver:observer];
    if (didChangeLanguage) {
        didChangeLanguage(_currentLanguage);
    }
}

- (void)removeObserver:(id<SFLocalizedStringDelegate>)observer {
    NSInteger index = [self.observers.allObjects indexOfObject:observer];
    if (index != NSNotFound) {
        [self.observers removePointerAtIndex:index];
    }
}

- (void)clearLocalizedStrings {
    [self.localizedStrings removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SFLocalizedStringsCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)cacheLocalizedStrings {
    if (_localizedStrings) {
        [[NSUserDefaults standardUserDefaults] setObject:_localizedStrings forKey:SFLocalizedStringsCacheKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)localizedStringWithString:(NSString *)string {
    return [self localizedStringWithString:string tableName:_tableName];
}

- (NSString *)localizedStringWithString:(NSString *)string tableName:(NSString *)tableName {
        NSString *localizedString = string;
//        if (_isSetup) {
//            if (tableName && _currentLanguageBundle) {
//                localizedString = NSLocalizedStringFromTableInBundle(string,tableName,_currentLanguageBundle,nil);
//            }
//        }
//    #ifdef DEBUG
//        if ([self.localizedStrings containsObject:localizedString] == NO) {
//            [self.localizedStrings addObject:localizedString];
//        }
//    #endif
    if (tableName && _currentLanguageBundle) {
        localizedString = NSLocalizedStringFromTableInBundle(string,tableName,_currentLanguageBundle,nil);
    } else if (tableName){
        localizedString = NSLocalizedStringFromTable(string, tableName, nil);
    } else {
        localizedString = NSLocalizedString(string, nil);
    }
    return localizedString;
}

- (NSString *)localizedStringWithString:(NSString *)string language:(AppLanguageType)language {
    return [self localizedStringWithString:string language:language tableName:_tableName];
}

- (NSString *)localizedStringWithString:(NSString *)string language:(AppLanguageType)language tableName:(NSString *)tableName {
    NSString *localizedString = string;
    NSBundle *bundle = _currentLanguageBundle;
    if (bundle == nil || language != _currentLanguage) {
        bundle = [self _bundleForLanguageCode:[self _languageCodeForLanguageType:language]];
    }
    if (tableName && bundle) {
        localizedString = NSLocalizedStringFromTableInBundle(string,tableName,bundle,nil);
        if (localizedString == nil) {
            localizedString = string;
        }
    }
    return localizedString;
}

#pragma mark - private
- (void)_setupCurrentLanguageType {
    id languageCode = [[NSUserDefaults standardUserDefaults] objectForKey:SFLocalizedStringAppLanguageCodeCacheKey];
    id languageType = [[NSUserDefaults standardUserDefaults] objectForKey:SFLocalizedStringAppLanguageCacheKey];
    if (languageCode && languageType) {
        _currentLanguageCode = languageCode;
        _currentLanguage = [languageType integerValue];
        return;
    }
    if (_enableDefaultLanguage) {
        _currentLanguageCode = [self _languageCodeForLanguageType:_defaultLanguage];
        _currentLanguage = _defaultLanguage;
    }
    else {
        BOOL isSimulator = NO;
#ifdef TARGET_IPHONE_SIMULATOR
        isSimulator = YES;
#endif
        /// 设置模拟器的默认系统语言为简体中文
        if (isSimulator) {
            _currentLanguageCode = @"zh-Hans";
            _currentLanguage = AppLanguageTypeCN_S;
        }
        /// 获取系统语言
        else {
            NSArray<NSString *> *preferredLanguages = [NSLocale preferredLanguages];
            _currentLanguageCode = preferredLanguages.firstObject;
            if (_currentLanguageCode == nil) {
                _currentLanguageCode = @"zh-Hans";
                _currentLanguage = AppLanguageTypeCN_S;
            }
            else {
                /// 中文
                if ([_currentLanguageCode hasPrefix:@"zh"]) {
                    /// 简体中文:zh-Hans
                    if ([_currentLanguageCode rangeOfString:@"Hans"].location != NSNotFound) {
                        _currentLanguage = AppLanguageTypeCN_S;
                    }
                    /// 繁體中文:zh-Hant\zh-HK\zh-TW
                    else {
                        _currentLanguage = AppLanguageTypeCN_T;
                    }
                }
                /// 英文
                else if ([_currentLanguageCode hasPrefix:@"en"]) {
                    _currentLanguage = AppLanguageTypeEN;
                }
                /// 日文
                else if ([_currentLanguageCode hasPrefix:@"ja"]) {
                    _currentLanguage = AppLanguageTypeJA;
                }
                /// 韩文
                else if ([_currentLanguageCode hasPrefix:@"ko"]) {
                    _currentLanguage = AppLanguageTypeKO;
                }
                /// 俄文
                else  if ([_currentLanguageCode hasPrefix:@"ru"]) {
                    _currentLanguage = AppLanguageTypeRU;
                }
                /// 其他不处理的情况默认为简体中文
                else {
                    _currentLanguageCode = @"zh-Hans";
                    _currentLanguage = AppLanguageTypeCN_S;
                }
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:_currentLanguageCode forKey:SFLocalizedStringAppLanguageCodeCacheKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(_currentLanguage) forKey:SFLocalizedStringAppLanguageCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSBundle *)_bundleForLanguageCode:(NSString *)languageCode {
    NSString *path = [[NSBundle mainBundle] pathForResource:languageCode ofType:@"lproj"];
    return [NSBundle bundleWithPath:path];
}

- (NSString *)_languageCodeForLanguageType:(AppLanguageType)languageType {
    switch (languageType) {
        case AppLanguageTypeCN_S:return @"zh-Hans";break;
        case AppLanguageTypeCN_T:return @"zh-Hant";break;
        case AppLanguageTypeEN:return @"en";break;
        case AppLanguageTypeJA:return @"ja";break;
        case AppLanguageTypeKO:return @"ko";break;
        case AppLanguageTypeRU:return @"ru";break;
        default:return @"zh-Hans";break;
    }
}

- (void)_callbackForLanguageChange {
    NSArray<id<SFLocalizedStringDelegate>> *observers = self.observers.allObjects;
    [observers enumerateObjectsUsingBlock:^(id<SFLocalizedStringDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// block 回调
        void(^didChangeLanguage)(AppLanguageType) = objc_getAssociatedObject(obj, @selector(addObserver:didChangeLanguage:));
        if (didChangeLanguage) {
            didChangeLanguage(_currentLanguage);
        }
        /// 代理回调
        if ([obj respondsToSelector:@selector(localizedStringManager:changeLanguage:)]) {
            [obj localizedStringManager:self changeLanguage:_currentLanguage];
        }
    }];
    /// 通知回调
    [[NSNotificationCenter defaultCenter] postNotificationName:SFLocalizedStringLanguageDidChangeNotificationName
                                                        object:@{@"currentLanguage":@(_currentLanguage)}];
}

#pragma mark - set/get
- (void)setup {
    _isSetup = YES;
    [self _setupCurrentLanguageType];
    if (_currentLanguageBundle == nil) {
        _currentLanguageBundle = [self _bundleForLanguageCode:_currentLanguageCode];
    }
}

- (void)setCurrentLanguage:(AppLanguageType)currentLanguage {
    if (_isSetup) {
        if (currentLanguage != _currentLanguage) {
            _currentLanguageCode = [self _languageCodeForLanguageType:currentLanguage];
            _currentLanguageBundle = [self _bundleForLanguageCode:_currentLanguageCode];
            [self _callbackForLanguageChange];
            [[NSUserDefaults standardUserDefaults] setObject:_currentLanguageCode forKey:SFLocalizedStringAppLanguageCodeCacheKey];
            [[NSUserDefaults standardUserDefaults] setObject:@(currentLanguage) forKey:SFLocalizedStringAppLanguageCacheKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    _currentLanguage = currentLanguage;
}

- (NSPointerArray *)observers {
    return _observers?:({
        _observers = [NSPointerArray weakObjectsPointerArray];
        _observers;
    });
}

- (NSMutableArray<NSString *> *)localizedStrings {
    return _localizedStrings?:({
        _localizedStrings = [NSMutableArray new];
        NSArray<NSString *> *cacheLocalizedStrings = [[NSUserDefaults standardUserDefaults] objectForKey:SFLocalizedStringsCacheKey];
        if (cacheLocalizedStrings.count) {
            [_localizedStrings addObjectsFromArray:cacheLocalizedStrings];
        }
        _localizedStrings;
    });
}

@end

@implementation NSString (SFLocalizedString)

- (NSString *)lv_localized {
    return [[SFLocalizedStringManager manager] localizedStringWithString:self];
}

- (NSString *)lv_localizedWithLanguage:(AppLanguageType)language {
    return [[SFLocalizedStringManager manager] localizedStringWithString:self language:language];
}

- (NSString *)lv_Style {
    return [[SFLocalizedStringManager manager] localizedStringWithString:self];
}


- (NSString * _Nonnull (^)(AppLanguageType))lvbk_localized {
    return ^NSString *(AppLanguageType language) {
        return [self lv_localizedWithLanguage:language];
    };
}

@end

