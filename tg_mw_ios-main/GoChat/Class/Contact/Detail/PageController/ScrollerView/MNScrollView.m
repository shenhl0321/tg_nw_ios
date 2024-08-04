//
//  MNScrollView.m
//  GoChat
//
//  Created by 许蒙静 on 2022/1/11.
//

#import "MNScrollView.h"

@implementation MNScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
@end
