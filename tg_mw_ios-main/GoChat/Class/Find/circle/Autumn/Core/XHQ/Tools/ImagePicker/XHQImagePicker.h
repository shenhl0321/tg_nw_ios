//
//  XHQImagePicker.h
//  Julong
//
//  Created by 帝云科技 on 2017/7/20.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^XHQFinishedImageHandler)(UIImage *finishedImage);

@interface XHQImagePicker : NSObject

+ (void)xhq_imagePicker:(UIViewController *)viewController
          allowsEditing:(BOOL)edit
                 finish:(XHQFinishedImageHandler)handler;

@end
