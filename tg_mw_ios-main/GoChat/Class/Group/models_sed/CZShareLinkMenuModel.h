//
//  CZShareLinkMenuModel.h
//  GoChat
//
//  Created by mac on 2021/7/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CZShareLinkMenuModel : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSInteger tag;

+ (CZShareLinkMenuModel *)initModleWithTilele:(NSString *)title withTag:(NSInteger)tag;

@end

NS_ASSUME_NONNULL_END
