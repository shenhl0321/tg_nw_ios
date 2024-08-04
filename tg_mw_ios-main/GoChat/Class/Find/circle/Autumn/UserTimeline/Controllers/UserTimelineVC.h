//
//  UserTimelineVC.h
//  GoChat
//
//  Created by Autumn on 2021/12/15.
//

#import "DYCollectionViewRefreshController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserTimelineVC : DYCollectionViewRefreshController

- (instancetype)initWithUserid:(NSInteger)userid;

@end

NS_ASSUME_NONNULL_END
