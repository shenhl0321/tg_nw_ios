//
//  UIButton+XHQEdgeInsets.m
//  Cafu
//
//  Created by 帝云科技 on 2018/4/27.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import "UIButton+XHQEdgeInsets.h"

@implementation UIButton (XHQEdgeInsets)

- (void)xhq_setImagePosition:(XHQImagePosition)position spacing:(CGFloat)spacing
{
    [self layoutIfNeeded];
    
    CGFloat imageViewWidth = self.imageView.image.size.width;
    CGFloat imageViewHeight = self.imageView.image.size.height;
    CGFloat titleLabelWidth = self.titleLabel.intrinsicContentSize.width;
    CGFloat titleLabelHeight = self.titleLabel.intrinsicContentSize.height;
    
    spacing = spacing * 0.5;

    CGFloat imageOffsetX = (imageViewWidth + titleLabelWidth) / 2 - imageViewWidth / 2;//image中心移动的x距离
    CGFloat imageOffsetY = imageViewHeight / 2 + spacing;//image中心移动的y距离
    CGFloat labelOffsetX = (imageViewWidth + titleLabelWidth / 2) - (imageViewWidth + titleLabelWidth) / 2;//label中心移动的x距离
    CGFloat labelOffsetY = titleLabelHeight / 2 + spacing;//label中心移动的y距离
    
    switch (position)
    {
        case XHQImagePositionLeft:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -spacing, 0, spacing);
            self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, -spacing);
        }
            break;
        case XHQImagePositionRight:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, spacing + titleLabelWidth, 0, -(spacing + titleLabelWidth));
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(spacing + imageViewWidth), 0, spacing + imageViewWidth);
        }
            break;
        case XHQImagePositionTop:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY, imageOffsetX, imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY, labelOffsetX);
        }
            break;
        case XHQImagePositionBottom:
        {
            self.imageEdgeInsets = UIEdgeInsetsMake(imageOffsetY, imageOffsetX, -imageOffsetY, -imageOffsetX);
            self.titleEdgeInsets = UIEdgeInsetsMake(-labelOffsetY, -labelOffsetX, labelOffsetY, labelOffsetX);
        }
            break;
    }
}

@end
