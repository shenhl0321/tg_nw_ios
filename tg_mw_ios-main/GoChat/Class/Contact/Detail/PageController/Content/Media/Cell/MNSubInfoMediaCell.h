//
//  MNSubInfoMediaCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import "BaseTableCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNSubInfoMediaCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImgV;
- (void)fillDataWithMessageInfo:(MessageInfo *)message;
@end

NS_ASSUME_NONNULL_END
