//
//  CNAreasModel.h
//  GoChat
//
//  Created by Autumn on 2022/3/12.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CNAreasModel : JWModel

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *children;

@end

NS_ASSUME_NONNULL_END
