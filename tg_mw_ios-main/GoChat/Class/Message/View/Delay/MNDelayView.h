//
//  MNDelayView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/8.
//

#import <UIKit/UIKit.h>
#import "ASwitch.h"
#import "MNSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNDelayView : UIView
@property (nonatomic, strong) UIImageView *timerIcon;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) MNSlider *slider;
@property (nonatomic, strong) ASwitch *aSwitch;
@property (nonatomic, strong) UIButton *delayBtn;
@end

NS_ASSUME_NONNULL_END
