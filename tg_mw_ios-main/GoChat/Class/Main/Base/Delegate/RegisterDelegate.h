//
//  RegisterDelegate.h
//  LoganSmart
//
//  Created by 许蒙静 on 2021/10/22.
//

#import <Foundation/Foundation.h>

//@class RegisterDelegate;

@protocol CommonDelegate <NSObject>
@optional
- (void)curObj:(id)vc selectedObj:(id)selectedObj;
- (void)popView:(id)obj touchUpInsideCancel:(id)obj;
- (void)popView:(id)obj touchUpInsideDelete:(id)obj;
- (void)popView:(id)obj touchUpInsideBtn:(id)obj;
- (void)popView:(id)obj touchUpInsideSureBtn:(id)obj;
- (void)popView:(id)obj touchDownBtn:(id)obj;
- (void)popView:(id)obj selectIndex:(NSInteger)obj;
//slider的代理方法
- (void)beginTrackingWithSlider:(UISlider *)slider;
- (void)continueTrackingWithSlider:(UISlider *)slider;
- (void)endTrackingWithSlider:(UISlider *)slider;

- (void)addReduceView:(UIView *)view didEndTouchBtn:(UIButton *)btn;//左边 和上面的 /右边 和下面的按钮
- (void)addReduceView:(UIView *)view endTimerWithValue:(NSInteger)value;//结束计时的

@end

NS_ASSUME_NONNULL_BEGIN

@interface RegisterDelegate : NSObject

@end

NS_ASSUME_NONNULL_END
