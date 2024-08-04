//
//  ASwitch.h
//  ASwitchDemo
//
//  Created by XMJ on 2018/5/4.
//  Copyright © 2018年 Mona's Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock)(BOOL);
@class ASwitch;
@protocol ASwitchDelegate <NSObject>
@optional
- (void)aSwitch:(ASwitch *)aSwitch isOn:(BOOL)isOn;
@end

@interface ASwitch : UIControl


@property (nonatomic, assign, getter=isOn) BOOL on;
@property (nonatomic, weak) id<ASwitchDelegate> aSwitchDelegate;
@property (nonatomic, strong) UIColor *onColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, assign) CGFloat circleRadius;

- (void)setOnWithOutAnimation:(BOOL)isOn;

@end
