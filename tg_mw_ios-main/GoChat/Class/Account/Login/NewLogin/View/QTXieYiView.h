//
//  QTXieYiView.h
//  QTMobileProject
//
//  Created by 爱情营行 on 2021/8/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 点击确定
typedef void(^QTXieYiViewClickSuccess)(void);
@interface QTXieYiView : UIView

//HEXCOLOR(0x34CDAC)
/// 协议
/// @param title 全部文字
/// @param array 点击链接和文字。 1、title 文字 2、url 链接 3、type 类型 1、跳转网页 2、自定义跳转 3、话题跳转 4、@用户
- (void)showTitle:(NSString *)title font:(UIFont *)font array:(NSArray *)array SelectedColor:(UIColor *)selectedColor confirm:(QTXieYiViewClickSuccess)confirm;

@end

NS_ASSUME_NONNULL_END
