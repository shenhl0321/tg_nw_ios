//
//  TF_SlidePopupView.h
//  GoChat
//
//  Created by apple on 2022/2/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TF_SlidePopupView : UIView
+ (instancetype)popupViewWithFrame:(CGRect)frame contentView:(UIView *)contentView;

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView;

- (void)showFrom:(UIView *)fromView completion:(void (^)(void))completion;

- (void)dismiss;

- (void)showWithCompletion:(void (^)(void))completion;

- (void)showInSuperView;
@end

NS_ASSUME_NONNULL_END
