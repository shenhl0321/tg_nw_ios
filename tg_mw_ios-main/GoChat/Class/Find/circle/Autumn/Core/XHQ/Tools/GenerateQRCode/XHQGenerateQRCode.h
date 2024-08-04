//
//  XHQGenerateQRCode.h
//  Julong
//
//  Created by 帝云科技 on 2017/8/16.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XHQGenerateQRCode : NSObject

/**
 二维码生成
 */
+ (UIImage *)xhq_getQRCodeWithString:(NSString *)xhqString;

@end
