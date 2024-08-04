//
//  MNChatDelayView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/26.
//

#import <UIKit/UIKit.h>
#import "MNSlider.h"
#import "ASwitch.h"
NS_ASSUME_NONNULL_BEGIN
@class MNChatDelayView;
@protocol MNChatDelayViewDelegate <NSObject>

- (void)chatDelayView:(MNChatDelayView *)chatDelayView isOn:(BOOL)isOn value:(NSInteger)value;

@end
@interface MNChatDelayView : UIView
@property (nonatomic, assign) NSInteger min;
@property (nonatomic, assign) NSInteger max;

@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) NSInteger value;

@property (nonatomic, strong) UIImageView *iconImgV;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) MNSlider *slider;
@property (nonatomic, strong) ASwitch *aSwitch;
@property (nonatomic, weak) id<MNChatDelayViewDelegate>delegate;

- (void)refreshDataWithValue:(NSInteger)value;
@end

NS_ASSUME_NONNULL_END
