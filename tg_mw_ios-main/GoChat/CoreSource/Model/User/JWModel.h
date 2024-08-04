//
//  JWModel.h
//  GoChat
//
//  Created by mac on 2021/11/3.
//
/// 2021-11-03 by JWAutumn
/// 创建自定义基类模型，处理 MJExtension 属性

#import "DYModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface JWModel : DYModel

@property (nonatomic, assign) NSInteger extra;
@property (nonatomic, assign) NSInteger ids;
@property (nonatomic, copy) NSString *atType;

@end

NS_ASSUME_NONNULL_END
