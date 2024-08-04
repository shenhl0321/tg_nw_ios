//
//  MNRegisterVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "BaseVC.h"


NS_ASSUME_NONNULL_BEGIN

@interface MNRegisterVC : BaseVC
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, strong) NSDictionary *sortedNameDict;
@end

NS_ASSUME_NONNULL_END
