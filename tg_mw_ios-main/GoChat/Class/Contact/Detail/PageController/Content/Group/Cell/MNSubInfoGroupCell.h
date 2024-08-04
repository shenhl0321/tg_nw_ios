//
//  MNSubInfoGroupCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNSubInfoGroupCell : BaseTableCell
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
- (void)fillDataWithChat:(ChatInfo *)chat;
@end

NS_ASSUME_NONNULL_END
