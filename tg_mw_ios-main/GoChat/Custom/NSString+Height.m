//
//  NSString+Height.m
//  EasyLoan
//
//  Created by 许蒙静 on 2016/11/21.
//  Copyright © 2016年 ming yang. All rights reserved.
//

#import "NSString+Height.h"

@implementation NSString (Height)

-(CGFloat)heightWithWidth:(CGFloat)width font:(UIFont *)font{
    if (width<=0) {
        width = APP_SCREEN_WIDTH;
    }
    if (font<=0) {
        font = [UIFont systemFontOfSize:14];
    }
    
    NSString *str = [self stringByReplacingOccurrencesOfString:@"<br />" withString:@"\r\n"];
    //获取当前文本的属性
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:6];
    NSDictionary *attributes = @{NSFontAttributeName: font,NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@1.0f};
    [attrStr setAttributes:attributes range:NSMakeRange(0, str.length)];
    NSRange range = NSMakeRange(0, attrStr.length);
    // 获取该段attributedString的属性字典
    //NSDictionary *dic = [attrStr attributesAtIndex:0 effectiveRange:&range];
    
    // 计算文本的大小
    CGSize sizeToFit = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                        attributes:attributes        // 文字的属性
                                           context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    return ceil(sizeToFit.height);
}


- (CGFloat)heightWithWidth:(CGFloat)width font:(UIFont *)font lineSpace:(CGFloat)lineSpace kern:(CGFloat)kern{
    if (width<=0) {
        width = APP_SCREEN_WIDTH;
    }
    if (font == nil) {
        font = [UIFont systemFontOfSize:14];
    }
    
    NSString *str = [self stringByReplacingOccurrencesOfString:@"<br />" withString:@"\r\n"];
    //获取当前文本的属性
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:lineSpace];
    NSDictionary *attributes = @{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@(kern)};
    [attrStr setAttributes:attributes range:NSMakeRange(0, str.length)];
    // 计算文本的大小
    CGSize sizeToFit = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) // 用于计算文本绘制时占据的矩形块
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
                                       attributes:attributes        // 文字的属性
                                          context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    return ceil(sizeToFit.height);
}

- (int)tipHeightWithWidth:(CGFloat)width{
    CGFloat height = [self heightWithWidth:width font:[UIFont mediumCustomFontOfSize:14] lineSpace:0 kern:-0.47];
    return ceilf(height);
}

- (BOOL)haveSpace{
    if (self.length) {
        if ([[self substringWithRange:NSMakeRange(0, 1)] isEqualToString:@" "]) {
            return TRUE;
        }else if ([[self substringWithRange:NSMakeRange(self.length-1, 1)] isEqualToString:@" "]){
            return TRUE;
        }
    }
    
    return FALSE;
}
-(NSString*)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; 
}

-(CGFloat)widthWithfont:(UIFont*)font{
    return [self boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                              options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                           attributes:@{NSFontAttributeName:font}
                              context:nil].size.width+1;
}

-(CGFloat)heightWithFont:(UIFont*) font
                   width:(CGFloat) width{
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
       attr[NSFontAttributeName] = font;
    CGSize titleSize = [self boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    
    return ceil(titleSize.height);
}
@end
