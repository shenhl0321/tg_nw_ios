//
//  BottomPopView.h
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/24.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterDelegate.h"
#import "YCShadowView.h"

@interface BottomPopView : UIView

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, weak)  id <CommonDelegate> delegate;

- (void)show;
- (void)hide;
@end


