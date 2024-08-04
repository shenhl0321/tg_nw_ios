//
//  CountryCodeViewController.h
//  GoChat
//
//  Created by 李标 on 2021/6/10.
//  国家代码选择界面

#import <UIKit/UIKit.h>

typedef void(^returnCountryCodeBlock) (NSString * _Nullable countryName, NSString * _Nullable code);

typedef void(^returnCountryAreaBlock) (NSString * _Nullable countryName, NSString * _Nullable code, NSString * _Nullable province, NSString * _Nullable city, NSString * _Nullable cityCode);

@protocol CountryCodeControllerDelegate <NSObject>

@optional

/**
 Delegate 回调所选国家代码

 @param countryName 所选国家
 @param code 所选国家代码
 */
-(void)returnCountryName:(NSString *_Nullable)countryName code:(NSString *_Nullable)code;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CountryCodeViewController : BaseTableVC

@property (nonatomic, strong) NSDictionary *sortedNameDict; //数据源
@property (nonatomic, weak) id<CountryCodeControllerDelegate> deleagete;
@property (nonatomic, copy) returnCountryCodeBlock returnCountryCodeBlock;

/// 修改用户地区
@property (nonatomic, assign, getter=isModifyAreas) BOOL modifyAreas;
@property (nonatomic, copy) returnCountryAreaBlock areaBlock;

@end

NS_ASSUME_NONNULL_END
