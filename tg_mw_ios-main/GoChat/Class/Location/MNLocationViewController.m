//
//  MNLocationViewController.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNLocationViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "LocationSearchView.h"
#import "MNLocationDetailCell.h"

@interface MNLocationViewController ()
<AMapSearchDelegate, AMapLocationManagerDelegate, MAMapViewDelegate, SearchViewDelegate, SearchViewDelegate, TimerCounterDelegate>
@property (nonatomic, strong) UIButton *sendBtn;  // 发送按钮

@property (nonatomic, strong) MAMapView *mapView; //地图
@property (nonatomic, strong) AMapSearchAPI *mapSearch; // 定义搜索对象
@property (nonatomic, strong) AMapLocationManager *locationManager; // 定位
@property (nonatomic ,strong) AMapInputTipsSearchRequest *tips; // 关键词搜索
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate; // 当前定位的经纬度
@property (nonatomic ,strong) NSString *city;//定位的当前城市，用于搜索功能
@property (nonatomic, strong) UIButton *localButton; // 定位按钮
@property (nonatomic ,assign) BOOL isSelectedAddress;
@property (nonatomic, strong) NSArray *addressList;//地址列表
@property (nonatomic ,strong) NSIndexPath *selectedIndexPath; // 选中的row

@property (nonatomic, strong) AMapGeoPoint *curLocation;
@property (nonatomic, strong) TimerCounter *reloadPoiListTimer;
@end

@implementation MNLocationViewController

- (void)dealloc
{
    [self.reloadPoiListTimer stopCountProcess];
    self.reloadPoiListTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"位置".lv_localized];
    self.sendBtn = [self.customNavBar setRightBtnWithImageName:nil title:@"发送".lv_localized highlightedImageName:nil];
    
//    self.contentView.frame = CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT);
    [self.contentView addSubview:self.mapView];
    self.tableView.frame = CGRectMake(0, ContentHeight*0.5, APP_SCREEN_WIDTH, ContentHeight*0.5);
    [self initMap];
    
    [self initApi];
    //
    self.reloadPoiListTimer = [TimerCounter new];
    self.reloadPoiListTimer.delegate = self;
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    //发送按钮的动作
    [self click_send];
}

-(MAMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, ContentHeight*0.5)];
    }
    return _mapView;
}

- (void)initMap
{
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].apiKey = GaoDeMap_AppId;
    
    self.mapView.zoomLevel = 18; // 缩放级别
    self.mapView.delegate = self;
    self.mapView.showsLabels = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    r.showsAccuracyRing = YES;///精度圈是否显示，默认YES
    r.enablePulseAnnimation = YES;///内部蓝色圆点是否使用律动效果, 默认YES
    [self.mapView updateUserLocationRepresentation:r];
}

// 发送地址位置 经纬度
- (void)click_send
{
    if([self.delegate respondsToSelector:@selector(SendCurrentLocation:)])
    {
        [self.delegate SendCurrentLocation:self.currentLocationCoordinate];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 回到所在当前位置
- (void)localButtonAction
{
    [self initApi];
}

- (void)initApi
{
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    // 配置定位
    [self configLocationManager];
    // 请求定位
    [self locateAction];
    
    // 定位按钮
    [self.mapView addSubview:self.localButton];
}

#pragma mark - 地图
// 位置定位初始化
- (void)configLocationManager
{// 单次定位，可获取当前位置信息
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    // 定位超时时间，最低2s，此处设置为2s
    [self.locationManager setLocationTimeout:6];
    // 逆地理请求超时时间，最低2s，此处设置为2s
    [self.locationManager setReGeocodeTimeout:3];
}

// 单次定位
- (void)locateAction
{//带逆地理的单次定位 （返回坐标和地址信息） 将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [UserInfo showTips:nil des:@"正在定位...".lv_localized];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            [UserInfo dismiss];
            [UserInfo showTips:self.view des:@"定位失败...".lv_localized];
            NSLog(@"locError:{%ld - %@};",(long)error.code,error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        //定位信息
        NSLog(@"location:%@", location);
        if (regeocode)
        {
            [UserInfo dismiss];
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.city = regeocode.city;
            [self showMapPoint];
//            [self setCenterPoint];
            self.curLocation = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            [self.reloadPoiListTimer stopCountProcess];
            [self.reloadPoiListTimer startCountProcess:0.1 repeat:NO];
            NSLog(@"添加好友 - bbbbbbbbbb");
        }
    }];
}

// 设置地图中心为当前位置
- (void)showMapPoint
{
    [self.mapView setZoomLevel:18 animated:YES];
    [_mapView setCenterCoordinate:self.currentLocationCoordinate animated:YES];
}

- (void)setCenterPoint
{// 添加大头针
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];
    centerAnnotation.coordinate = self.currentLocationCoordinate;//定位经纬度
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];
}

#pragma mark - TimerCounterDelegate
- (void)TimerCounter_RunCountProcess:(TimerCounter *)tm
{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.keywords = @"商务住宅|餐饮服务|生活服务".lv_localized;
    request.sortrule            = 0;
    request.offset = 50;
    request.requireExtension    = YES;
    request.location = self.curLocation;
    [self.mapSearch AMapPOIAroundSearch:request];
}

#pragma mark - AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    //解析response获取POI信息，
    NSArray *remoteArray = response.pois;
    self.addressList = remoteArray;
    [self.tableView reloadData];
}

#pragma mark - MAMapView Delegate
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapView removeAnnotations:self.mapView.annotations];

    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    self.currentLocationCoordinate = centerCoordinate;

    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];
    centerAnnotation.coordinate = centerCoordinate;
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapView addAnnotation:centerAnnotation];
    //主动选择地图上的地点
    if (!self.isSelectedAddress)
    {// 如果是点击地址栏就不需要搜索周边，如果是拖拽地图需要搜索周边
        [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
        self.selectedIndexPath =  [NSIndexPath indexPathForRow:0 inSection:0];
        
        // 请求当前位置周边POI
        self.curLocation = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        [self.reloadPoiListTimer stopCountProcess];
        [self.reloadPoiListTimer startCountProcess:0.1 repeat:NO];
        NSLog(@"添加好友 - cccccccccc");
    }
    self.isSelectedAddress = NO;
}

- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    //解析response获取提示词
    if ([response.tips count]>0)
    {
        AMapTip *tipModel = [response.tips objectAtIndex:0];
        CLLocationCoordinate2D locationCoordinate;
        locationCoordinate.latitude = tipModel.location.latitude;
        locationCoordinate.longitude = tipModel.location.longitude;
        [_mapView setCenterCoordinate:locationCoordinate animated:YES];
    }
    self.addressList = response.tips;
    [self.tableView reloadData];
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{// 搜索失败
    NSLog(@"Error: %@", error);
    //[UserInfo showTips:self.view des:@"搜索失败..."];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.addressList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LocationSearchView *header = [[[NSBundle mainBundle]loadNibNamed:@"LocationSearchView" owner:nil options:nil] lastObject];
    header.delegate = self;
    return header;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"MNLocationDetailCell";
    MNLocationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[MNLocationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([[self.addressList objectAtIndex:indexPath.row] isKindOfClass:[AMapTip class]])
    {
        AMapTip *tipModel = self.addressList[indexPath.row];
        cell.lbAddressName.text = tipModel.name;
        cell.lbAddressDetail.text = tipModel.address;
    }
    else
    {
        AMapPOI *model = [self.addressList objectAtIndex:indexPath.row];
        cell.lbAddressName.text = model.name;
        cell.lbAddressDetail.text = model.address;
    }

    if (indexPath.row == self.selectedIndexPath.row) {
        cell.selectedImgV.hidden = NO;
    } else {
        cell.selectedImgV.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    [tableView reloadData];
    
    CLLocationCoordinate2D locationCoordinate;
    if ([self.addressList[indexPath.row] isKindOfClass:[AMapPOI class]])
    {
        AMapPOI *POIModel = self.addressList[indexPath.row];
        locationCoordinate = CLLocationCoordinate2DMake(POIModel.location.latitude, POIModel.location.longitude);
    }
    else
    {
        AMapTip *POIModel = self.addressList[indexPath.row];
        locationCoordinate = CLLocationCoordinate2DMake(POIModel.location.latitude, POIModel.location.longitude);
    }
    self.isSelectedAddress = YES;
    self.currentLocationCoordinate = locationCoordinate;
    [_mapView setCenterCoordinate:self.currentLocationCoordinate animated:YES];
}

#pragma mark - SearchViewDelegate
// 搜索关键词
- (void)SearchViewDoSearch:(NSString *)result
{
    if (IsStrEmpty(result))
    {
        return;
    }
    self.tips = [[AMapInputTipsSearchRequest alloc] init];
    self.tips.keywords = result;
    self.tips.city     = self.city;
    [self.mapSearch AMapInputTipsSearch:self.tips];
}

- (void)TextFieldBeginEditing:(UITextField *)textField
{
}

#pragma mark - 懒加载
- (UIButton *)sendBtn
{
    if (!_sendBtn)
    {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(0, 0, 55, 29);
        [_sendBtn setTitle:@"发送".lv_localized forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:COLOR_CG1];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.layer.cornerRadius = 4;
        [_sendBtn addTarget:self action:@selector(click_send) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

- (UIButton *)localButton
{
    if (!_localButton)
    {
        _localButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _localButton.frame = CGRectMake(SCREEN_WIDTH - 60, ContentHeight*0.5-50, 50, 50);
        [_localButton addTarget:self action:@selector(localButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_localButton setImage:[UIImage imageNamed:@"Location"] forState:UIControlStateNormal];
    }
    return _localButton;
}

@end
