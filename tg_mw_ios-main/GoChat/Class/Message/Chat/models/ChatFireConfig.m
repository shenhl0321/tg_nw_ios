//
//  ChatFireConfig.m
//  GoChat
//
//  Created by 吴亮 on 2021/9/22.
//

#import "ChatFireConfig.h"

@implementation ChatFireConfig
+ (instancetype)shareInstance
{
    static ChatFireConfig * sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.fireConfigDic = @{}.mutableCopy;
    });
    return sharedManager;
}
@end
