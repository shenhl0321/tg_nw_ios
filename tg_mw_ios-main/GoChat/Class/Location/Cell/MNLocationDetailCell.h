//
//  MNLocationDetailCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNLocationDetailCell : BaseTableCell
@property (strong, nonatomic) UILabel *lbAddressName;
@property (strong, nonatomic) UILabel *lbAddressDetail;
@property (nonatomic, strong) UIImageView *selectedImgV;
@end

NS_ASSUME_NONNULL_END
