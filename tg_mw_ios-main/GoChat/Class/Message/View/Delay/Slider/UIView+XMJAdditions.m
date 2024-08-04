//
//  UIView+XMJAdditions.m
//  iCurtain
//
//  Created by XMJ on 2020/7/29.
//  Copyright © 2020 dooya. All rights reserved.
//

#import "UIView+XMJAdditions.h"



@implementation UIView (XMJAdditions)
-(CGFloat)x{
    return self.frame.origin.x;
}

-(void)setX:(CGFloat)x{
     CGRect frame = self.frame;
     frame.origin.x = x;
     self.frame = frame;
}

-(CGFloat)y{
    return self.frame.origin.y;
}

-(void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(CGFloat)width{
    if (self.frame.size.width == NAN) {
        return 300;
    }
    return self.frame.size.width;
}

-(void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(CGFloat)height{
    if (self.frame.size.height == NAN) {
        return 300;
    }
    return self.frame.size.height;
}

-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(CGSize)size{
    return self.frame.size;
}

-(void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end
