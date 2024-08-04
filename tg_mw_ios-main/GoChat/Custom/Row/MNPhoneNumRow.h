//
//  MNPhoneNumRow.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import "MNRow.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNPhoneNumRow : MNRow
@property (nonatomic, strong) UITextField *countryTf;
@property (nonatomic, strong) UITextField *phoneNumTf;
@property (strong, nonatomic) UIImageView *imageV;
@end

NS_ASSUME_NONNULL_END
