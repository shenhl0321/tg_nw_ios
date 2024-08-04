//
//  UIImageView+Rotate.m
//  ControlPressure
//
//  Created by 帝云科技 on 2020/3/27.
//  Copyright © 2020 帝云科技. All rights reserved.
//

#import "UIImageView+Rotate.h"

@implementation UIImageView (Rotate)

- (void)xhq_rotateDirection:(DYRotateType)type duration:(CGFloat)duration
{
    //type DYRotateTypeClockwise 顺时针  DYRotateTypeAnticlockwise 逆时针
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    if (type==DYRotateTypeClockwise) {
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        animation.fromValue = [NSNumber numberWithFloat:0.f];
        animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    }else{
        animation.fromValue = [NSNumber numberWithFloat:M_PI *2];
        animation.toValue =  [NSNumber numberWithFloat:0.f];
    }
    animation.duration  = duration;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.removedOnCompletion = NO; //防止动画结束后回到初始状态
    animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
    [self.layer addAnimation:animation forKey:@"rotationAnimation"];
    
}

- (void)xhq_ratateStop {
    [self.layer removeAllAnimations];
}


@end
