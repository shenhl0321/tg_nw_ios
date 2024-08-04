//
//  MNSlider.h
//  iCurtain
//
//  Created by XMJ on 2020/7/30.
//  Copyright © 2020 dooya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNSlider;
@protocol MNSlierDelegate <NSObject>

@optional
- (void)slider_continueTouch:(MNSlider *)slider;
- (void)slider_beginTouch:(MNSlider *)slider;
- (void)slider_endTouch:(MNSlider *)slider;
- (void)slider:(MNSlider *)slider updatePercent:(CGFloat)percent;

@end

@interface MNSlider : UIControl

@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, assign) BOOL isReverse;//从上往下，从左往右是isReverse=NO
@property (nonatomic, assign) BOOL isVertical;

@property (nonatomic, strong) UIColor *backImgVColor;
@property (nonatomic, strong) UIColor *fontImgVColor;
@property (nonatomic, strong) UIImageView *backImgV;
@property (nonatomic, strong) UIImageView *fontImgV;

@property (nonatomic, strong) UIImageView *touchIV;

@property (nonatomic, assign) CGSize touchSize;
@property (nonatomic, assign) UIEdgeInsets xmjEdge;

@property (nonatomic, weak) id <MNSlierDelegate>delegate;
- (void)refreshUI;

- (void)percentChangeFromTracking;

@end


