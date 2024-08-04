//
//  MNChatInputView.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNChatInputView : UIView
//@property (nonatomic, assign) BOOL noDelayBtn;//不需要延迟按钮
@property (nonatomic, strong) UITextView *tv;//输入框
- (instancetype)initWithSuperView:(UIView *)superView;
- (void)refreshToolBarWithNoDelay:(BOOL)noDelay;

@end

NS_ASSUME_NONNULL_END
