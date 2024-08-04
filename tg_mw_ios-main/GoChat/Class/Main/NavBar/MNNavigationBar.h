//
//  MNNavigationBar.h
//  iOSBaseTuya
//
//  Created by XMJ on 2020/8/7.
//  Copyright © 2020 Moorgen Deutschland GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MNNavigationBar;
@protocol MNNavigationBarDelegate <NSObject>

@optional
//从左往右第一个按钮
- (void)navigationBar:(MNNavigationBar *)navationBar didClickLeftBtn:(UIButton *)btn;
//从右往左第一个按钮
- (void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn;
//从左往右第一个按钮
- (void)navigationBar:(MNNavigationBar *)navationBar didClickSecondLeftBtn:(UIButton *)btn;
//从右往左第一个按钮
- (void)navigationBar:(MNNavigationBar *)navationBar didClickSecondRightBtn:(UIButton *)btn;

@end


@interface MNNavigationBar : UIView


//给几个默认的UI。。后面的自己写
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *contentView;

//@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, weak) id<MNNavigationBarDelegate> delegate;


//导航栏中间的title
- (UILabel *)setTitle:(NSString *)title;
- (UILabel *)setSecondTitle:(NSString *)secondTitle;
//导航栏中间的图片
- (UIImageView *)setTitleIVWithImageName:(NSString *)imageName;
//导航栏最左边的按钮
-(UIButton *)setLeftBtnWithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName;
//导航栏最右边的按钮
- (UIButton *)setRightBtnWithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName;
//导航栏从左第二个按钮
-(UIButton *)setLeftBtn2WithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName;
//导航栏从右第二个按钮
-(UIButton *)setRightBtn2WithImageName:(NSString *)imageName title:(NSString *)title highlightedImageName:(NSString *)highlightedImageName;
//左右2个按钮加标题的
- (void)style_title_LeftBtn_RightBtn;
//左右2个按钮中间图片
- (void)style_titleIV_LeftBtn_RightBtn;
//左边一个按钮中间文字右边2个按钮的
- (void)style_title_LeftBtn_2RightBtn;

#pragma mark - iPad 新增的
//左边图片 右边按钮
- (void)style_LeftIV_RightBtn_Ipad;

#pragma mark - goChat导航栏样式单独定义
//登录的导航栏样式
- (void)style_GoChatLogin;
////首页消息的页面
- (UILabel *)style_GoChatMessage;

- (void)style_Chat;//聊天页面的

- (void)style_ChatPrivate;
//聊天的计数
-(UILabel *)setCountLabelText:(NSString *)countText;
@end

