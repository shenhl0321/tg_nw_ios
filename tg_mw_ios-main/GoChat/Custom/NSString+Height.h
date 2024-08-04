//
//  NSString+Height.h
//  EasyLoan
//
//  Created by 许蒙静 on 2016/11/21.
//  Copyright © 2016年 ming yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Height)

-(CGFloat)heightWithWidth:(CGFloat)width font:(UIFont *)font;
- (CGFloat)heightWithWidth:(CGFloat)width font:(UIFont *)font lineSpace:(CGFloat)lineSpace kern:(CGFloat)kern;
- (int)tipHeightWithWidth:(CGFloat)width;
- (BOOL)haveSpace;
- (NSString*)trim;

-(CGFloat)widthWithfont:(UIFont*) font;
-(CGFloat)heightWithFont:(UIFont*) font
                   width:(CGFloat) width;
@end
