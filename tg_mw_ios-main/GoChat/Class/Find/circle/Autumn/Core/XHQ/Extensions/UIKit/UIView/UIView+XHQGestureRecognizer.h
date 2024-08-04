//
//  UIView+XHQGestureRecognizer.h
//  Cafu
//
//  Created by 帝云科技 on 2018/4/25.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^XHQGestureActionBlock)(UIGestureRecognizer *gestureRecoginzer);

@interface UIView (XHQGestureRecognizer)

/**
 添加点击手势

 @param block 点击回调
 */
- (void)xhq_addTapActionWithBlock:(XHQGestureActionBlock)block;

@end
