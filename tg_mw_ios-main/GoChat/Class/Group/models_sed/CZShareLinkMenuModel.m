//
//  CZShareLinkMenuModel.m
//  GoChat
//
//  Created by mac on 2021/7/25.
//

#import "CZShareLinkMenuModel.h"

@implementation CZShareLinkMenuModel

+ (CZShareLinkMenuModel *)initModleWithTilele:(NSString *)title withTag:(NSInteger)tag{
    CZShareLinkMenuModel *model = [CZShareLinkMenuModel new];
    model.title = title;
    model.tag = tag;
    return model;
}

@end
