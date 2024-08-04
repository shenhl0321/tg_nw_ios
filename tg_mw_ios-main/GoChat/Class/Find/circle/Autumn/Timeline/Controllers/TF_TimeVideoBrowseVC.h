//
//  TF_TimeVideoBrowseVC.h
//  GoChat
//
//  Created by apple on 2022/2/8.
//

//#import "BaseTableVC.h"
#import "BaseVC.h"
#import "BlogInfo.h"
#import "TimelineHelper.h"
NS_ASSUME_NONNULL_BEGIN

@interface TF_TimeVideoBrowseVC : BaseVC
/// 原始数据
@property (nonatomic,strong) NSArray<BlogInfo *> *blogs;

@property (nonatomic, assign) TimelineType type;

@property (nonatomic, copy) NSString *topic;

/// <#code#>
@property (nonatomic,assign) NSInteger firstIndex;

@end

NS_ASSUME_NONNULL_END
