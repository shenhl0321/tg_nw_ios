//
//  LCLabRCLabLineView.h
//  MoorgenSmartHome
//
//  Created by XMJ on 2020/8/17.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCLabRCLabLineView : UIView

@property (nonatomic, strong) UILabel *lcLabel;
@property (nonatomic, strong) UILabel *rcLabel;
@property (nonatomic, strong) UIView *lineView;
- (instancetype)initWithLeftText:(NSString *)leftText rightText:(NSString *)rightText needLine:(BOOL)needLine;
@end

NS_ASSUME_NONNULL_END
