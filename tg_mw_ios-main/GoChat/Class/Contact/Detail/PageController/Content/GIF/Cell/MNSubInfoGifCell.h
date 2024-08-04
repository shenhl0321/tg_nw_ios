//
//  MNSubInfoGifCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNSubInfoGifCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *gifLabel;
@property (nonatomic, strong) UIImageView *gifBgView;
- (void)fillDataWithMessageInfo:(MessageInfo *)message;

@end

NS_ASSUME_NONNULL_END
