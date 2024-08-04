//
//  CZGroupInvitatioModel.m
//  GoChat
//
//  Created by mac on 2021/7/9.
//

#import "CZGroupInvitatioModel.h"

@implementation CZGroupInvitatioModel

+ (CZGroupInvitatioModel *)getModelWithTips:(NSString *)tipsStr withFontSze:(NSInteger)fontSize{
    CZGroupInvitatioModel *model = [[CZGroupInvitatioModel alloc]init];
    model.tipsStr = tipsStr;
    model.fontSize = fontSize;
    return model;
}

@end
