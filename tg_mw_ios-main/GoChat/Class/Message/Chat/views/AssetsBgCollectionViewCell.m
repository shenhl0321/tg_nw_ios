//
//  AssetsBgCollectionViewCell.m
//  GoChat
//
//  Created by 李标 on 2021/5/15.
//

#import "AssetsBgCollectionViewCell.h"

@implementation AssetsBgCollectionViewCell

- (void)setBgImageWithName:(NSString *)imageName imageSize:(CGSize)size {
    if ([imageName isEqualToString:@""]) {
        self.bgImageView.backgroundColor = [UIColor lightGrayColor];
        self.bgImageView.image = nil;
    }
    else
    {
        UIImage *img = [self reSizeImage:[UIImage imageNamed:imageName] toSize:size];
        self.bgImageView.image = img;
    }
}

// 图片的自定义尺寸压缩（压缩之后图片容量也相应变化）
- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

@end
