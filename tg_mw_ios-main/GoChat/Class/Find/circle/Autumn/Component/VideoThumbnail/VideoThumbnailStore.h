//
//  VideoThumbnailStore.h
//  GoChat
//
//  Created by Autumn on 2021/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoThumbnailStore : NSObject

+ (BOOL)storeImage:(UIImage *)image withVideoName:(NSString *)name;

+ (UIImage *)imageWithVideoName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
