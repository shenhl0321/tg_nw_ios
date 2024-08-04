//
//  MNLocationViewController.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "BaseTableVC.h"

@protocol MNLocationViewDelegate <NSObject>
// 发送当前位置经纬度
- (void)SendCurrentLocation:(CLLocationCoordinate2D)centerCoordinate;
@end

@interface MNLocationViewController : BaseTableVC

@property (nonatomic, assign) id<MNLocationViewDelegate> delegate;

@end

