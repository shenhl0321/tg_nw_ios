//
//  LocationManager.h
//  GoChat
//
//  Created by 李标 on 2021/6/19.
//

#import <Foundation/Foundation.h>

typedef void(^locationSuccess)(CLLocationCoordinate2D locationCoordinate);

NS_ASSUME_NONNULL_BEGIN

@interface LocationManager : NSObject

/// 获取经纬度成功的回调
@property (nonatomic,copy) locationSuccess block;

+ (LocationManager *)shareInstance;

/// 当前定位的经纬度
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate;

/// 获取当前经纬度
/// @param success 获取成功的回调
- (void)startSerialLocationSuccess:(locationSuccess)success;

// 请求逆地理编码
- (void)startReGeocodeSearchRequestWithCoordinate:(CLLocationCoordinate2D)centerCoordinate fromChatId:(long)chatId;
// 获取缓存地理位置
- (NSDictionary *)getCacheLocationAddress:(CLLocationCoordinate2D)centerCoordinate;
@end

NS_ASSUME_NONNULL_END
