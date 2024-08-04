//
//  AssetsBgCollectionViewCell.h
//  GoChat
//
//  Created by 李标 on 2021/5/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AssetsBgCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgChoose;

- (void)setBgImageWithName:(NSString *)imageName imageSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
