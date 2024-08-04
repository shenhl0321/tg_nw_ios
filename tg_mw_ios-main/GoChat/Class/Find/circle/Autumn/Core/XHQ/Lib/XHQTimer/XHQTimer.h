//
//  XHQTimer.h
//  U-Alley
//
//  Created by 帝云科技 on 2018/2/24.
//  Copyright © 2018年 diyunkeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XHQTimer : NSObject

+ (nullable NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)aTime target:(nullable id)aTarget selector:(nullable SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

@end
