//
//  CustomTextView.h
//  GoChat
//
//  Created by 吴亮 on 2021/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomTextView : UITextView
/** 占位文字 */
@property (nonatomic,copy) NSString *placeholder;
/** 占位文字颜色 */
@property (nonatomic,strong) UIColor *placeholderColor;
@property (nonatomic,assign) int paddingLeft;
@property (nonatomic,assign) int paddingtop;
@property (nonatomic,assign) BOOL usePadding;

@end

NS_ASSUME_NONNULL_END
