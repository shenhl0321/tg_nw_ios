//
//  XHQAlertManager.h
//
//
//  Created by 帝云科技 on 2017/4/12.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XHQAlertManager : NSObject

/**
 快捷创建按钮警告框

 @param title 标题
 @param message 明细
 @param eTitle 确认按钮
 @param cTitle 取消按钮
 @param eAction 确认回调
 @param cAction 取消回调
 @return UIAlertController
 */
+ (UIAlertController *)showTitle:(NSString *)title
                         message:(NSString *)message
                      enterTitle:(NSString *)eTitle
                     cancelTitle:(NSString *)cTitle
                     enterAction:(dispatch_block_t)eAction
                    cancelAction:(dispatch_block_t)cAction;

@end

@interface UIViewController (XHQAlert)

/// 弹框消息框，点击返回上一级
/// @param msg 消息内容
- (void)xhq_popActionWithMsg:(NSString *)msg;

@end


/** 两个响应按钮 */
static inline void XHQAlertDoubleAction(NSString *title, NSString *msg, NSString *enterText, NSString *cancelText, dispatch_block_t enterAction, dispatch_block_t cencleAction) {
    UIAlertController *alert = [XHQAlertManager showTitle:title
                                                  message:msg
                                               enterTitle:enterText
                                              cancelTitle:cancelText
                                              enterAction:enterAction
                                             cancelAction:cencleAction];
    UIViewController *VC = [UIViewController xhq_currentController];
    [VC presentViewController:alert animated:YES completion:nil];
}

/** 俩按钮，单个响应 */
static inline void XHQAlertSingleAction(NSString *title, NSString *msg, NSString *enterText, NSString *cancelText, dispatch_block_t enterAction) {
    XHQAlertDoubleAction(title, msg, enterText, cancelText, enterAction, nil);
}

/** 唯一响应按钮 */
static inline void XHQAlertOnlyAction(NSString *title, NSString *msg, NSString *enter , dispatch_block_t action) {
    XHQAlertSingleAction(title, msg, enter, nil, action);
}

/** 标题内容，单个按钮，无响应 */
static inline void XHQAlertTextMsg(NSString *title, NSString *msg) {
    XHQAlertOnlyAction(title, msg, @"确定", nil);
}

/** 标题，单个按钮，无响应 */
static inline void XHQAlertText(NSString *text) {
    XHQAlertTextMsg(text, nil);
}
