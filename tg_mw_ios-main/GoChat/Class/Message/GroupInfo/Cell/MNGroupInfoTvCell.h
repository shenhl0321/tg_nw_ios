//
//  MNGroupInfoTvCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/25.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNGroupInfoTvCell : BaseTableCell
@property (nonatomic, strong) UITextView *tv;
- (void)fillDataWithText:(NSString *)text placeholder:(NSString *)placeholder;
@end

NS_ASSUME_NONNULL_END
