//
//  XFTextTranslateRequest.h
//  GoChat
//
//  Created by apple on 2022/2/20.
//

#import <Foundation/Foundation.h>
#import "VoiceTransferRequest.h"
NS_ASSUME_NONNULL_BEGIN

@interface XFTextTranslateRequest : NSObject

+ (void)translateText:(NSString *)text success:(XFResponseSuccessBlock)success failure:(XFResponseFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
