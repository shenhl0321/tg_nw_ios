//
//  JWAlertTool.m
//  JWGeneral
//
//  Created by 帝云科技 on 2017/4/12.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "XHQAlertManager.h"


@implementation XHQAlertManager

static inline BOOL iOS_8_4_orLater() {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.4;
}

+ (UIAlertController *)showTitle:(NSString *)title
                         message:(NSString *)message
                      enterTitle:(NSString *)eTitle
                     cancelTitle:(NSString *)cTitle
                     enterAction:(dispatch_block_t)eAction
                    cancelAction:(dispatch_block_t)cAction {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleAlert];
    if (title && title.length > 0) {
        NSMutableAttributedString *attriuteTitle =
        [[NSMutableAttributedString alloc]initWithString:title
                                              attributes:@{NSForegroundColorAttributeName: [UIColor xhq_aTitle],
                                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:17]}];
        [alert setValue:attriuteTitle forKey:@"attributedTitle"];
    }
    
    if (message && message.length > 0) {
        NSMutableAttributedString *attriuteMessage =
        [[NSMutableAttributedString alloc]initWithString:message
                                              attributes:@{NSForegroundColorAttributeName: [UIColor xhq_content],
                                                           NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        [alert setValue:attriuteMessage forKey:@"attributedMessage"];
    }
    
    if (cTitle && cTitle.length > 0) {
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:cTitle
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  !cAction ? : cAction();
                                                              }];
        if (iOS_8_4_orLater()) {
            [cancel setValue:[UIColor xhq_content] forKey:@"_titleTextColor"];
        }
        [alert addAction:cancel];
    }
    
    if (eTitle) {
        UIAlertAction * enter = [UIAlertAction actionWithTitle:eTitle
                                                               style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           !eAction ? : eAction();
                                                       }];
        if (iOS_8_4_orLater()) {
            [enter setValue:[UIColor xhq_base] forKey:@"_titleTextColor"];
        }
        [alert addAction:enter];
    }
    
    return alert;
}

@end


@implementation UIViewController (XHQAlert)

- (void)xhq_popActionWithMsg:(NSString *)msg {
    XHQAlertOnlyAction(msg, nil, @"确定".lv_localized, ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
