//
//  CZRegisterInputModel.h
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZRegisterInputModel : NSObject

@property (nonatomic,strong)   NSString     *titleStr;
@property (nonatomic,strong)   NSString     *placeStr;
@property (nonatomic,assign)   NSInteger    fieldCellTag;

+ (CZRegisterInputModel *)initWithPlaceHodlerStr:(NSString *)placeStr withFieldTag:(NSInteger)fieldCellTag;

+ (CZRegisterInputModel *)initWithPlaceHodlerStr:(NSString *)placeStr withtitleStr:(NSString *)titleStr withFieldTag:(NSInteger)fieldCellTag;

@end

NS_ASSUME_NONNULL_END
