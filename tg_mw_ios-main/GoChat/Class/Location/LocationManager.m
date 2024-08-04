//
//  LocationManager.m
//  GoChat
//
//  Created by 李标 on 2021/6/19.
//

#import "LocationManager.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

static LocationManager *g_LocationManager = nil;

@interface LocationManager()<AMapSearchDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *mapSearch; // 定义搜索对象
@property (nonatomic, strong) NSMutableDictionary *addressDic;
@property (nonatomic, strong) NSMutableDictionary *requestDic;
@end

@implementation LocationManager

+ (LocationManager *)shareInstance
{
    if(g_LocationManager == nil)
    {
        g_LocationManager = [[LocationManager alloc] init];
    }
    return g_LocationManager;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        [self initReGeocodeSearchRequest];
    }
    return self;
}

- (NSMutableDictionary *)addressDic
{
    if (!_addressDic) {
        _addressDic = [NSMutableDictionary dictionary];
    }
    return _addressDic;
}

- (NSMutableDictionary *)requestDic
{
    if (!_requestDic) {
        _requestDic = [NSMutableDictionary dictionary];
    }
    return _requestDic;
}


-(CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        //控制定位精度,越高耗电量越
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        // 总是授权
        [_locationManager requestWhenInUseAuthorization];
        _locationManager.distanceFilter = 10.0f;
        [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}



//结束定位
- (void)stopLocation{
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager stopUpdatingLocation];
    }
}


- (void)startSerialLocationSuccess:(locationSuccess)success{
    
    BOOL status = [CLLocationManager locationServicesEnabled];
    if (status) {
        self.block = success;
        [self.locationManager startUpdatingLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    int status = [CLLocationManager locationServicesEnabled];
    
    if (status < 3) {
        
    }
    if ([error code] == kCLErrorDenied) {
        ChatLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        ChatLog(@"无法获取位置信息");
    }
}

//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = locations[0];
    
    self.currentLocationCoordinate = newLocation.coordinate;
    self.block(newLocation.coordinate);
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

#pragma mark - 地图
// 初始化
- (void)initReGeocodeSearchRequest
{
    // 初始化地图服务
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].apiKey = GaoDeMap_AppId;
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
}

// 请求逆地理编码
- (void)startReGeocodeSearchRequestWithCoordinate:(CLLocationCoordinate2D)centerCoordinate fromChatId:(long)chatId
{
    NSString *coordinateKey = [NSString stringWithFormat:@"%f,%f",centerCoordinate.latitude,centerCoordinate.longitude];
    if ([self.requestDic objectForKey:coordinateKey]) {
        return;
    }
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.requireExtension = YES;
    regeo.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    [self.mapSearch AMapReGoecodeSearch:regeo];
    [self.requestDic setObject:[NSNumber numberWithLong:chatId] forKey:coordinateKey];
}

// 获取缓存地理位置
- (NSDictionary *)getCacheLocationAddress:(CLLocationCoordinate2D)centerCoordinate
{
    NSString *coordinateKey = [NSString stringWithFormat:@"%f,%f",centerCoordinate.latitude,centerCoordinate.longitude];
    return [self.addressDic objectForKey:coordinateKey];
}

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        NSString *address = @"";
        NSString *addressName = @"";
        //解析response获取地址描述，具体解析见 Demo
        AMapAddressComponent *addressComponent = (AMapAddressComponent *)response.regeocode.addressComponent;
        if (addressComponent)
        {
            address = [address stringByAppendingString:IsStrEmpty(addressComponent.province)?@"":addressComponent.province];
            address = [address stringByAppendingString:IsStrEmpty(addressComponent.city)?@"":addressComponent.city];
            address = [address stringByAppendingString:IsStrEmpty(addressComponent.district)?@"":addressComponent.district];
            address = [address stringByAppendingString:IsStrEmpty(addressComponent.township)?@"":addressComponent.township];
            AMapStreetNumber *streetNumber = (AMapStreetNumber *)addressComponent.streetNumber;
            if (streetNumber)
            {
                address = [address stringByAppendingString:IsStrEmpty(streetNumber.street)?@"":streetNumber.street];
            }
            ChatLog(@"address:%@",address);
        }
        if (response.regeocode.aois.count > 0)
        {
            AMapAOI *aoi = (AMapAOI *)response.regeocode.aois[0];
            addressName = aoi.name;
        }
        
        
        NSString *coordinateKey = [NSString stringWithFormat:@"%f,%f",request.location.latitude,request.location.longitude];
        NSNumber *chatId = [self.requestDic objectForKey:coordinateKey];
        NSDictionary *dic;
        if (chatId) {
            dic = @{@"addressTitle":(addressName!=nil?addressName:@""), @"addressDetail":(address!=nil?address:@""), @"ChatId":chatId};
        }
        else
        {
            dic = @{@"addressTitle":(addressName!=nil?addressName:@""), @"addressDetail":(address!=nil?address:@"")};
        }
        [self.addressDic setObject:dic forKey:coordinateKey];
        
        //发送通知
        [[BusinessFramework defaultBusinessFramework] broadcastBusinessNotify:MakeID(EUserManager, EUser_Td_Location_ReGeocode_Search) withInParam:dic];
    }
    else
    {
        ChatLog(@"地理位置解析失败");
    }
    
    AMapReGeocodeSearchRequest *searchRequest = (AMapReGeocodeSearchRequest *)request;
    NSString *coordinateKey = [NSString stringWithFormat:@"%f,%f",searchRequest.location.latitude,searchRequest.location.longitude];
    [self.requestDic removeObjectForKey:coordinateKey];
}

/**
 * @brief 当请求发生错误时，会调用代理的此方法.
 * @param request 发生错误的请求.
 * @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    AMapReGeocodeSearchRequest *searchRequest = (AMapReGeocodeSearchRequest *)request;
    NSString *coordinateKey = [NSString stringWithFormat:@"%f,%f",searchRequest.location.latitude,searchRequest.location.longitude];
    [self.requestDic removeObjectForKey:coordinateKey];
}

@end
