//
//  UILabel+XHQAttributed.m
//  Cafu
//
//  Created by 帝云科技 on 2018/4/25.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import "UILabel+XHQAttributed.h"

@implementation UILabel (XHQAttributed)

#pragma mark - 富文本修改标签文字样式
- (void)xhq_AttributeTextAttributes:(NSDictionary *)att range:(NSRange)range {
    
    NSMutableAttributedString *attribute = nil;
    if (self.attributedText)
    {
        attribute = [self.attributedText mutableCopy];
    }
    else
    {
        attribute = [[NSMutableAttributedString alloc]initWithString:self.text];
    }
    [attribute setAttributes:att range:range];
    [self setAttributedText:attribute];
}


#pragma mark - 修改行间距
- (void)xhq_lineSpace:(CGFloat)lineSpace {
    [self xhq_lineSpace:lineSpace wordSpace:0 paragraphSpace:0];
}


#pragma mark - 修改字间距
- (void)xhq_wordSpace:(CGFloat)wordSpace {
    [self xhq_lineSpace:0 wordSpace:wordSpace paragraphSpace:0];
}


#pragma mark - 修改段间距
- (void)xhq_paragraphSpace:(CGFloat)paragraphSpace {
    [self xhq_lineSpace:0 wordSpace:0 paragraphSpace:paragraphSpace];
}


#pragma mark - 修改行间距，字体间距，段落间距
- (void)xhq_lineSpace:(CGFloat)lineSpace wordSpace:(CGFloat)wordSpace paragraphSpace:(CGFloat)paragraphSpace {
    
    NSString *string = self.text;
    
    NSMutableAttributedString *attributedString = nil;
    if (self.attributedText) {
        attributedString = [self.attributedText mutableCopy];
    }else {
        attributedString = [[NSMutableAttributedString alloc]initWithString:string];
    }
    
    if (wordSpace > 0) {
        [attributedString addAttributes:@{NSKernAttributeName:@(wordSpace)} range:NSMakeRange(0, [string length])];
    }
    
    if (lineSpace > 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:lineSpace];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    }
    
    if (paragraphSpace > 0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setParagraphSpacing:paragraphSpace];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    }
    
    self.attributedText = attributedString;
    [self sizeToFit];
}


- (void)xhq_textAlignmentLeftAndRight {
    CGFloat width = CGRectGetWidth(self.frame);
    [self xhq_textAlignmentLeftAndRightWith:width];
}

- (void)xhq_textAlignmentLeftAndRightWith:(CGFloat)labelWidth {
    if(!self.text || self.text.length == 0) {
        return;
    }
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading;
    CGSize size = [self.text boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT) options:options attributes:@{NSFontAttributeName:self.font} context:nil].size;
    NSInteger length = (self.text.length - 1);
    NSString* lastStr = [self.text substringWithRange:NSMakeRange(self.text.length - 1, 1)];
    
    if ([lastStr isEqualToString:@":"] || [lastStr isEqualToString:@"："]) {
        length = (self.text.length-2);
    }
    CGFloat margin = (labelWidth - size.width) / length;
    NSNumber*number = [NSNumber numberWithFloat:margin];
    NSMutableAttributedString* attribute = [[NSMutableAttributedString alloc]initWithString:self.text];
    [attribute addAttribute:NSKernAttributeName value:number range:NSMakeRange(0,length)];
    self.attributedText= attribute;
}

@end
