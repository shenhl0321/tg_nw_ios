//
//  UIImage+SNCompress.m

#import "UIImage+SNCompress.h"

#define COMPRESSION 1.0f //第一次不压缩
//static CGFloat const compression = 0.9f;
static CGFloat const maxCompression = 0.3f;

@implementation UIImage (SNCompress)

- (UIImage *)compressImageToFileSizeKB:(NSUInteger)maxFileSize;
{
    CGFloat compression = COMPRESSION;

    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    NSUInteger imageFileSize = imageData.length / 1024; //KB
    if (imageFileSize <= maxFileSize) {
        return self;
    }
    
    //图片太大就继续压缩
    while (imageFileSize > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        //降低内存峰值
        @autoreleasepool {
            imageData = UIImageJPEGRepresentation(self, compression);
            imageFileSize = imageData.length / 1024;
        }
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

- (NSArray *)compressImageDataToFileSizeKB:(NSUInteger)maxFileSize
{
    NSArray *compressDic = nil;
    
    CGFloat compression = COMPRESSION;
    
    NSData *imageData = UIImageJPEGRepresentation(self, compression);
    NSUInteger imageFileSize = imageData.length / 1024; //KB
    if (imageFileSize <= maxFileSize) {
        compressDic = @[self, imageData];
        return compressDic;
    }
    
    //图片太大就继续压缩
    while (imageFileSize > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        //降低内存峰值
        @autoreleasepool {
            imageData = UIImageJPEGRepresentation(self, compression);
            imageFileSize = imageData.length / 1024;
        }
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    compressDic = @[compressedImage, imageData];
    return compressDic;
}

+ (UIImage *)compressImage:(UIImage *)image toFileSizeKB:(NSUInteger)maxFileSize;
{
    CGFloat compression = COMPRESSION;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    NSUInteger imageFileSize = imageData.length / 1024; //KB
    if (imageFileSize <= maxFileSize) {
        return [UIImage imageWithData:imageData];//确保是 jpeg 格式
    }
    
    //图片太大就继续压缩
    while (imageFileSize > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        //降低内存峰值
        @autoreleasepool {
            imageData = UIImageJPEGRepresentation(image, compression);
            imageFileSize = imageData.length / 1024;
        }
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

+ (UIImage *)compressImagePath:(NSString *)imagePath toFileSizeKB:(NSUInteger)maxFileSize;
{
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    NSUInteger imageFileSize = imageData.length / 1024; //KB
    if (imageFileSize <= maxFileSize) {
        return [UIImage imageWithContentsOfFile:imagePath];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    UIImage *compressedImage = [UIImage compressImage:image toFileSizeKB:maxFileSize];
    
    return compressedImage;
}

@end
