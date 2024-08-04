//
//  UIImageView+Rotate.h
//  ControlPressure
//
//  Created by 帝云科技 on 2020/3/27.
//  Copyright © 2020 帝云科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,DYRotateType){
    DYRotateTypeClockwise = 0 , /**<顺时针旋转*/
    DYRotateTypeAnticlockwise  /**<逆时针旋转*/
};


@interface UIImageView (Rotate)

/**
  图片旋转

 @param type 旋转方向
 @param duration 旋转一圈所需时间
 */
-(void)xhq_rotateDirection:(DYRotateType)type duration:(CGFloat)duration;


- (void)xhq_ratateStop;

@end

NS_ASSUME_NONNULL_END
