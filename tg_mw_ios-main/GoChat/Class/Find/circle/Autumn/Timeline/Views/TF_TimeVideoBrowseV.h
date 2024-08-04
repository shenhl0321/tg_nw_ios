//
//  TF_TimeVideoBrowseV.h
//  GoChat
//
//  Created by apple on 2022/2/9.
//

#import <UIKit/UIKit.h>
#import "BlogInfo.h"
#import "TimelineHelper.h"
NS_ASSUME_NONNULL_BEGIN

@interface TF_TimeVideoBrowseV : UIView

/// 原始数据
@property (nonatomic,strong) NSArray<BlogInfo *> *blogs;

@property (nonatomic, assign) TimelineType type;

/// <#code#>
@property (nonatomic,copy) void(^closeCall)(void);

- (void)stopOrRePlay;
@end

NS_ASSUME_NONNULL_END
