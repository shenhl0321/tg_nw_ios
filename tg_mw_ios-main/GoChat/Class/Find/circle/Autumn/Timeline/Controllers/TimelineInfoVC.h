//
//  TimelineInfoVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/19.
//

#import "DYRefreshViewController.h"
#import "TimelineHelper.h"
NS_ASSUME_NONNULL_BEGIN

@class BlogInfo;
@interface TimelineInfoVC : DYRefreshViewController

@property (nonatomic, strong) BlogInfo *blog;

@property (nonatomic, assign) TimelineType type;
@end

NS_ASSUME_NONNULL_END
