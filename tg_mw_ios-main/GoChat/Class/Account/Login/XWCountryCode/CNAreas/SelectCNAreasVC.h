//
//  SelectCNAreasVC.h
//  GoChat
//
//  Created by Autumn on 2022/3/12.
//

#import "DYTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^returnCountryAreaBlock) (NSString * _Nullable countryName, NSString * _Nullable code, NSString * _Nullable province, NSString * _Nullable city, NSString * _Nullable cityCode);

@class CNAreasModel;
@interface SelectCNAreasVC : DYTableViewController

@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, strong) CNAreasModel *parentArea;
@property (nonatomic, copy) returnCountryAreaBlock block;

@end

NS_ASSUME_NONNULL_END
