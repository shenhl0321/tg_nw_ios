//
//  NSData+Ext.h
//  ControlPressure
//
//  Created by 帝云科技 on 2020/4/2.
//  Copyright © 2020 帝云科技. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Ext)

+ (NSData *)resetSizeOfImageData:(UIImage *)sourceImage maxSize:(NSInteger)maxSize;

@end

NS_ASSUME_NONNULL_END
