//
//  UIButton+XHQEdgeInsets.h
//  Cafu
//
//  Created by 帝云科技 on 2018/4/27.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, XHQImagePosition) {
    XHQImagePositionLeft = 0, /**<图片在左*/
    XHQImagePositionRight, /**<图片在右*/
    XHQImagePositionTop, /**<图片在上*/
    XHQImagePositionBottom, /**<图片在下*/
};
@interface UIButton (XHQEdgeInsets)


- (void)xhq_setImagePosition:(XHQImagePosition)position spacing:(CGFloat)spacing;

@end
