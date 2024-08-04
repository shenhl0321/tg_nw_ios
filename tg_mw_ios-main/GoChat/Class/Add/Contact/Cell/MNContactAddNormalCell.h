//
//  MNContactAddNormalCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactAddNormalCell : BaseTableCell
@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImgV;

- (void)fillDataWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
