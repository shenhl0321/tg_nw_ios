//
//  CZGroupInvitatioModel.h
//  GoChat
//
//  Created by mac on 2021/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZGroupInvitatioModel : NSObject

@property (nonatomic,strong)    NSString *tipsStr;
@property (nonatomic,assign)    NSInteger fontSize;

+ (CZGroupInvitatioModel *)getModelWithTips:(NSString *)tipsStr withFontSze:(NSInteger)fontSize;

@end

NS_ASSUME_NONNULL_END
