//
//  UIButton+ClickRange.h
//  Coulisse
//
//  Created by XMJ on 2017/9/21.
//  Copyright © 2017年 Coulisse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ClickRange)
- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;
- (CGRect)enlargedRect;
@end
