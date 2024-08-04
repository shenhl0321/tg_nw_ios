//
//  MNCountryCodeCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/28.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNCountryCodeCell : BaseTableCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *codeLabel;
- (void)fillDataWithText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
