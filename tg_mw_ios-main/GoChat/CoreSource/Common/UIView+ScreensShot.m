//
//  UIView+ScreensShot.m

#import "UIView+ScreensShot.h"
#import <objc/runtime.h>

@implementation UIView (ScreensShot)

- (UIImage *)screenShot
{
    if (self && self.frame.size.height && self.frame.size.width)
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    else
    {
        return nil;
    }
}

@end
