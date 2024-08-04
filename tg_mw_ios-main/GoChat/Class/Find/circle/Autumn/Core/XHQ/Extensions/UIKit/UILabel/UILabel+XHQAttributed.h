//
//  UILabel+XHQAttributed.h
//  Cafu
//
//  Created by 帝云科技 on 2018/4/25.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (XHQAttributed)


/**
 富文本修改标签文字样式
 */
- (void)xhq_AttributeTextAttributes:(NSDictionary *)att range:(NSRange)range;



/**
 *  修改行间距
 *
 *  @param lineSpace 间距
 */
- (void)xhq_lineSpace:(CGFloat)lineSpace;


/**
 *  修改字间距
 *
 *  @param wordSpace 间距
 */
- (void)xhq_wordSpace:(CGFloat)wordSpace;


/**
 *  修改段落间距（\n换行）
 *
 *  @param paragraphSpace 间距
 */
- (void)xhq_paragraphSpace:(CGFloat)paragraphSpace;


/**
 *  修改行间距与字间距
 *
 *  @param lineSpace 行间距
 *  @param wordSpace 字间距
 *  @param paragraphSpace 段间距
 */
- (void)xhq_lineSpace:(CGFloat)lineSpace wordSpace:(CGFloat)wordSpace paragraphSpace:(CGFloat)paragraphSpace;


- (void)xhq_textAlignmentLeftAndRight;

- (void)xhq_textAlignmentLeftAndRightWith:(CGFloat)labelWidth;

@end
