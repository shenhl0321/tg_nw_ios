//
//  ZFDouYinControlView.h
//  GoChat
//
//  Created by apple on 2022/2/9.
//

#import <UIKit/UIKit.h>
#import "ZFPlayerMediaControl.h"

@interface ZFDouYinControlView : UIView <ZFPlayerMediaControl>

- (void)resetControlView;

- (void)showCoverViewWithUrl:(VideoInfo *)video;

@end
