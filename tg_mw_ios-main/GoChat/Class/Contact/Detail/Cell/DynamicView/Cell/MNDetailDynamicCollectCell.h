//
//  MNDetailDynamicCollectCell.h
//  GoChat
//
//  Created by 许蒙静 on 2022/1/15.
//

#import <UIKit/UIKit.h>
#import "BlogInfo.h"
#import "PhotoImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNDetailDynamicCollectCell : UICollectionViewCell
@property (nonatomic, strong) PhotoImageView *iconImgV;
@property (nonatomic, strong) UIImageView *playImgV;
- (void)fillDataWithBlog:(BlogInfo *)blog;
@end

NS_ASSUME_NONNULL_END
