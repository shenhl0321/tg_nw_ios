//
//  UIViewController+XHQ_ActionSheet.m
//  U-Alley
//
//  Created by 帝云科技 on 2018/2/28.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import "UIViewController+XHQ_ActionSheet.h"

@implementation UIViewController (XHQ_ActionSheet)

static inline BOOL iOS_8_4_orLater() {
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.4;
}

- (void)xhq_defalutCancelActionSheetTitle:(NSString *)aTitle
                                  message:(NSString *)aMsg
                               dataSource:(NSArray<NSString *> *)datas
                          selectedHandler:(XHQSelectedHandler)handler
{
    [self xhq_actionSheetTitle:aTitle
                       message:aMsg
                   cancelTitle:@"取消".lv_localized
                    dataSource:datas
               selectedHandler:handler];
}


- (void)xhq_actionSheetTitle:(NSString *)aTitle
                     message:(NSString *)aMsg
                 cancelTitle:(NSString *)aCancel
                  dataSource:(NSArray<NSString *> *)datas
             selectedHandler:(XHQSelectedHandler)handler
{
    if (datas.count == 0)
    {
        return;
    }
    
    if (!aCancel || aCancel.length == 0)
    {
        [self xhq_defalutCancelActionSheetTitle:aTitle message:aMsg dataSource:datas selectedHandler:handler];
        return;
    }
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:aTitle
                                                                   message:aMsg
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *data in datas) {
        if (data && data.length > 0) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:data
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               !handler ? : handler(data);
                                                           }];
            if (iOS_8_4_orLater()) {
                [action setValue:[UIColor xhq_aTitle] forKey:@"_titleTextColor"];
            }
            [sheet addAction:action];
        }
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:aCancel
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    if (iOS_8_4_orLater()) {
        [cancel setValue:[UIColor xhq_content] forKey:@"_titleTextColor"];
    }
    [sheet addAction:cancel];
    
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
