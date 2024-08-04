//
//  UserTimelineNaviView.h
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "DYView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTimelineNaviView : DYView

- (instancetype)initWithUserid:(NSInteger)userid;

- (void)reloadData;

- (void)bindScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
