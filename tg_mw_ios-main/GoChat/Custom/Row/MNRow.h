//
//  MNRow.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/25.
//

#import <UIKit/UIKit.h>
typedef NS_OPTIONS(NSInteger, MNRowLineStyle) {
    
    MNRowLineStyleDefault,
    MNRowLineStylePwd,//设置密码的那边的样式
};
NS_ASSUME_NONNULL_BEGIN

@interface MNRow : UIView

@property (nonatomic, assign) MNRowLineStyle rowLineStyle;
@property (nonatomic, strong) UIView *lineView;

- (void)refreshLineWithStyle:(MNRowLineStyle)style;
- (void)initUI;
//自己页面的样式
- (void)initSubUI;
@end

NS_ASSUME_NONNULL_END
