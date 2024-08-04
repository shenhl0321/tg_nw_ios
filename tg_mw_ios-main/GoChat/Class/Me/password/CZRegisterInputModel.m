//
//  CZRegisterInputModel.m
//  GoChat
//
//  Created by mac on 2021/6/30.
//

#import "CZRegisterInputModel.h"

@implementation CZRegisterInputModel

+ (CZRegisterInputModel *)initWithPlaceHodlerStr:(NSString *)placeStr withFieldTag:(NSInteger)fieldCellTag{
    CZRegisterInputModel *model = [[CZRegisterInputModel alloc]init];
    model.placeStr = placeStr;
    model.fieldCellTag = fieldCellTag;
    return model;
}

+ (CZRegisterInputModel *)initWithPlaceHodlerStr:(NSString *)placeStr withtitleStr:(NSString *)titleStr withFieldTag:(NSInteger)fieldCellTag{
    CZRegisterInputModel *model = [[CZRegisterInputModel alloc]init];
    model.titleStr = titleStr;
    model.placeStr = placeStr;
    model.fieldCellTag = fieldCellTag;
    return model;
}

@end
