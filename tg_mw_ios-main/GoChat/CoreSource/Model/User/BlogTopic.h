//
//  BlogTopic.h
//  GoChat
//
//  Created by Autumn on 2022/3/1.
//

#import "JWModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlogTopic : JWModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger ranking;

+ (instancetype)topicWithKeyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
