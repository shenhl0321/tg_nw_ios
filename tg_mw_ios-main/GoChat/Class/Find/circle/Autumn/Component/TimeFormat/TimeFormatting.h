//
//  TimeFormatting.h
//  GoChat
//
//  Created by Autumn on 2021/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeFormatting : NSObject

+ (NSString *)formatTimeWithTimeInterval:(NSInteger)timeInterval;

@end

NS_ASSUME_NONNULL_END
