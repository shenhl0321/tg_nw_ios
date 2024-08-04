//
//  SliceIdGenerator.h
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SliceIdGenerator : NSObject
+ (SliceIdGenerator *)shareInstance;

- (NSString *)getNextSliceId;
@end

NS_ASSUME_NONNULL_END
