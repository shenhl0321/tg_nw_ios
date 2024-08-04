//
//  ReactionCoreTextView.m
//

#import "ReactionCoreTextView.h"
#import <CoreText/CoreText.h>
@interface ReactionCoreTextView ()
@property (nonatomic, assign) BOOL willDrawSelectBackground;
@end

@implementation ReactionCoreTextView

#pragma mark
#pragma mark touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    if (self.selectedTextUnit == nil) {
        self.willDrawSelectBackground = YES;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if (self.willDrawSelectBackground) {
        [self performSelector:@selector(touchesEnd) withObject:nil afterDelay:0.2];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if (self.willDrawSelectBackground) {
        [self performSelector:@selector(touchesEnd) withObject:nil afterDelay:0.2];
    }
}

//触摸结束
- (void)touchesEnd
{
    self.willDrawSelectBackground = NO;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.willDrawSelectBackground)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
        CGContextFillRect(context, rect);
    }
}

- (CGSize)sizeWith:(CTFramesetterRef)framesetterRef
{
    //获取实际需要大小
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), NULL, CGSizeMake(floorf(self.maxWidth), CGFLOAT_MAX), NULL);
    
  
    size.width = fmaxf(size.width, floorf(self.maxWidth));
    
    if (floorf(size.height) < size.height)
    {
        size.height += 1;
    }
    return size;
}

@end
