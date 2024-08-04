//
//  UIView+GradientBackground.h

#import <UIKit/UIKit.h>

@interface UIView (GradientBackground)

/**
 *  Gradient a view's background, default (0, 0) --> (1, 1)
 *  @praram fromColor begin color of gradient
 *  @praram toColor end color of gradient
 */

- (void)cb_gradientBackgroundFromColor:(UIColor *)fromColor
                               toColor:(UIColor *)toColor
                              withChar:(unichar)text
                          withFontSize:(int)size;

/**
 *  Gradient a view's background
 *  @praram fromPoint start point of gradient
 *  @praram toPoint end point of gradient
 *  @praram fromColor begin color of gradient
 *  @praram toColor end color of gradient
 */

- (void)cb_gradientBackgroundFromColor:(UIColor *)fromColor
                               toColor:(UIColor *)toColor
                             fromPoint:(CGPoint)fromPoint
                               toPoint:(CGPoint)toPoint
                              withChar:(unichar)text
                          withFontSize:(int)size;

/**
 *  Gradient a view's background
 *  @praram fromPoint start point of gradient
 *  @praram toPoint end point of gradient
 *  @praram fromColor begin color of gradient
 *  @praram toColor end color of gradient
 *  @praram useAutoLayout default YES
 */
- (void)cb_gradientBackgroundFromColor:(UIColor *)fromColor
                               toColor:(UIColor *)toColor
                             fromPoint:(CGPoint)fromPoint
                               toPoint:(CGPoint)toPoint
                              withChar:(unichar)text
                          withFontSize:(int)size
                         useAutoLayout:(BOOL)useAutoLayout;

/**
 *  Gradient a view's background
 *  @praram fromPoint start point of gradient default
 *  @praram toPoint end point of gradient default
 *  @praram colors color array of gradient
 *  @praram useAutoLayout default YES
 */
- (void)cb_gradientBackgroundWithColors:(NSArray *)colors
                              fromPoint:(CGPoint)fromPoint
                                toPoint:(CGPoint)toPoint
                               withChar:(unichar)text
                           withFontSize:(int)size
                          useAutoLayout:(BOOL)useAutoLayout;

- (void)cb_removeGradientBackground;

@end
