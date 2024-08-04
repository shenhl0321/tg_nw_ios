//
//  NNContactDetailPageVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/20.
//

#import "WMPageController.h"

@class NNContactDetailPageVC;

NS_ASSUME_NONNULL_BEGIN

@interface NNContactDetailPageVC : WMPageController
@property (nonatomic, assign) CGFloat mnTop;
@property (nonatomic, strong) UserInfo *user;
- (instancetype)initWithUser:(UserInfo *)user;

@end

NS_ASSUME_NONNULL_END
