//
//  TimelineListVC.h
//  GoChat
//
//  Created by Autumn on 2021/11/20.
//

#import "DYRefreshViewController.h"
#import "JXCategoryView.h"

#import "TimelineHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineListVC : DYRefreshViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, assign) TimelineType type;

@property (nonatomic, copy) NSString *topic;

@end

NS_ASSUME_NONNULL_END
