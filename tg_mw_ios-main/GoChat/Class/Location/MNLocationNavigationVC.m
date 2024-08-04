//
//  MNLocationNavigationVC.m
//  GoChat
//
//  Created by 许蒙静 on 2021/12/13.
//

#import "MNLocationNavigationVC.h"
#import <MapKit/MapKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "ChatChooseViewController.h"
#import "LocationManager.h"

@interface MNLocationNavigationVC ()
<BusinessListenerProtocol,AMapSearchDelegate, AMapLocationManagerDelegate, MAMapViewDelegate,ChatChooseViewControllerDelegate, MessageViewBaseCellDelegate>

@property (strong, nonatomic) MAMapView *mapVIew;
@property (nonatomic, strong) UIButton *menuBtn;  // 发送按钮
@property (nonatomic, strong) AMapSearchAPI *mapSearch; // 定义搜索对象
@property (nonatomic, strong) AMapLocationManager *locationManager; // 定位
@property (nonatomic ,strong) AMapPOIAroundSearchRequest *request; // 周边搜索
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate; // 当前定位的经纬度
@property (nonatomic ,strong) NSString *city;//定位的当前城市，用于搜索功能
@property (nonatomic, strong) UIButton *localButton; // 定位按钮
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (nonatomic, strong) NSString *currentAOI; // 当前地址名称
@property (nonatomic, strong) NSMutableArray *mapList;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *daohangBtn;

@end

@implementation MNLocationNavigationVC

- (void)dealloc
{
    [[BusinessFramework defaultBusinessFramework] unregisterBusinessListener:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.customNavBar setTitle:@"位置".lv_localized];
    [self.customNavBar setRightBtnWithImageName:@"icon_more_black" title:nil highlightedImageName:@"icon_more_black"];
    [self initUI];
    [[BusinessFramework defaultBusinessFramework] registerBusinessListener:self];
    
    //菜单
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 44, 44);
    [moreBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"icon_more":@"icon_more_black"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:Is_Special_Theme?@"icon_more":@"icon_more_black"] forState:UIControlStateHighlighted];
    [moreBtn addTarget:self action:@selector(click_menu) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
    // 定位
    _mapVIew.zoomLevel = 18; // 缩放级别
    _mapVIew.delegate = self;
    _mapVIew.showsLabels = YES;
    _mapVIew.showsUserLocation = YES;
    _mapVIew.userTrackingMode = MAUserTrackingModeFollow;
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    r.showsAccuracyRing = YES;///精度圈是否显示，默认YES
    r.enablePulseAnnimation = YES;///内部蓝色圆点是否使用律动效果, 默认YES
    [_mapVIew updateUserLocationRepresentation:r];
    
    // 设置中心点位置
    [self showMapPoint:self.locationCoordinate];
    // 添加大头针
    [self setCenterPoint:self.locationCoordinate];
    // 初始化
    [self initApi];
    // 支持地图种类
    [self SupportMaps];
}

-(void)navigationBar:(MNNavigationBar *)navationBar didClickRightBtn:(UIButton *)btn{
    [self click_menu];
}
- (void)initUI{
    [self.contentView addSubview:self.mapVIew];
    [self.contentView addSubview:self.bottomView];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.addressLabel];
    [self.bottomView addSubview:self.daohangBtn];
   
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(87);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-45-left_margin());
        make.height.mas_equalTo(24);
    }];
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(3);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.nameLabel);
        make.height.mas_equalTo(20);
    }];
    [self.daohangBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-left_margin());
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(0);
    }];
}


-(MAMapView *)mapVIew{
    if (!_mapVIew) {
        _mapVIew = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, APP_SCREEN_HEIGHT-APP_TOP_BAR_HEIGHT-kBottom34()-87)];
    }
    return _mapVIew;
}

-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = fontRegular(17);
        _nameLabel.textColor = [UIColor colorTextFor23272A];
    }
    return _nameLabel;
}

-(UILabel *)addressLabel{
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = fontRegular(14);
        _addressLabel.textColor = [UIColor colorFor878D9A];
    }
    return _addressLabel;
}

-(UIButton *)daohangBtn{
    if (!_daohangBtn) {
        _daohangBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_daohangBtn setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
        [_daohangBtn addTarget:self action:@selector(navigation_click:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _daohangBtn;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN_WIDTH, 87)];
        
    }
    return _bottomView;
}
- (void)initApi
{
//    [MAMapView updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
//        [MAMapView updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
    [AMapServices sharedServices].enableHTTPS = YES;
    [AMapServices sharedServices].apiKey = GaoDeMap_AppId;
    
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    
    // 周边搜索
    [self AroundSearchRequest];
    // 配置定位
    [self configLocationManager];
    // 请求定位
    [self locateAction];
    // 定位按钮
    [self.mapVIew addSubview:self.localButton];
    // 逆地址编码 -- 定位的地址
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = self.locationCoordinate.latitude;
    centerCoordinate.longitude = self.locationCoordinate.longitude;
    
    NSDictionary *dic = [[LocationManager shareInstance] getCacheLocationAddress:centerCoordinate];
    if ([dic allKeys].count == 0)
    {
        [[LocationManager shareInstance] startReGeocodeSearchRequestWithCoordinate:centerCoordinate fromChatId:self.chatRecordDTO.chat_id];
    }
    else
    {
         self.nameLabel.text = [dic objectForKey:@"addressTitle"];
         self.addressLabel.text = [dic objectForKey:@"addressDetail"];
    }
}

// 判断当前手机支持的地图app
- (void)SupportMaps
{
    [self.mapList addObject:@{@"name":@"苹果原生地图".lv_localized,@"type":@1}];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
    {// 百度地图
        [self.mapList addObject:@{@"name":@"百度地图".lv_localized,@"type":@5}];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {// 高德地图
        [self.mapList addObject:@{@"name":@"高德地图".lv_localized,@"type":@2}];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {// 谷歌地图
        [self.mapList addObject:@{@"name":@"谷歌地图".lv_localized,@"type":@3}];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]])
    {// 腾讯地图
        [self.mapList addObject:@{@"name":@"腾讯地图".lv_localized,@"type":@4}];
    }
    
}

// 调用第三方地图，进行导航
- (void)navigation:(NavigationType)type
{
    // 当前位置的纬度
    CGFloat curr_lat = self.currentLocationCoordinate.latitude;
    // 当前位置的经度
    CGFloat curr_lon = self.currentLocationCoordinate.longitude;
    // 当前位置的名称
    NSString *curr_name = self.currentAOI;
    // 目的地位置的纬度
    CGFloat dest_lat = self.locationCoordinate.latitude;
    // 目的地位置的经度
    CGFloat dest_lon = self.locationCoordinate.longitude;
    // 目的地位置的名称
    NSString *dest_name = self.nameLabel.text;
    switch (type)
    {
        case NavigationType_Apple:
        {
            ChatLog(@"NavigationType_Apple");
            MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate: CLLocationCoordinate2DMake(curr_lat, curr_lon) addressDictionary: nil]];
            currentLocation.name = @"我的位置".lv_localized;
            // 目的地的位置
            CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(dest_lat, dest_lon);
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark: [[MKPlacemark alloc] initWithCoordinate:coords addressDictionary:nil]];
            toLocation.name = dest_name;

            NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
            NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey: @YES };

            // 打开苹果地图应用，并呈现指定的item
            [MKMapItem openMapsWithItems:items launchOptions:options];
        }
            break;
        case NavigationType_QQ:
        {
            ChatLog(@"NavigationType_QQ");
            CLLocationCoordinate2D gcj02Coord = CLLocationCoordinate2DMake(dest_lat, dest_lon);

            float shopLat = gcj02Coord.latitude;
            float shoplng = gcj02Coord.longitude;

            NSString *urlString = [NSString stringWithFormat:@"qqmap://map/routeplan?fromcoord=%f,%f&from=我的位置&referer=jikexiu".lv_localized,curr_lat, curr_lon];

            urlString = [NSString stringWithFormat:@"%@&tocoord=%f,%f&to=%@",urlString, shopLat, shoplng, dest_name];

            urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                    if (success == NO)
                    {
                        [UserInfo showTips:nil des:@"打开腾讯地图失败".lv_localized];
                    }
                }];
            } else {
                // Fallback on earlier versions
            }
        }
            break;
        case NavigationType_Baidu:
        {
            ChatLog(@"NavigationType_Baidu");
            NSString *url = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&mode=driving", curr_lat, curr_lon, dest_lat, dest_lon, dest_name] stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:^(BOOL success) {
                if (success == NO)
                {
                    [UserInfo showTips:nil des:@"打开百度地图失败".lv_localized];
                }
            }];
        }
            break;
        case NavigationType_GaoDe:
        {
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&poiname=%@&lat=%f&lon=%f&dev=1", localAppName.lv_localized, dest_name, dest_lat, dest_lon ] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                if (success == NO)
                {
                    [UserInfo showTips:nil des:@"打开高德地图失败".lv_localized];
                }
            }];
        }
            break;
        case NavigationType_Google:
        {
            ChatLog(@"NavigationType_Google");
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving", localAppName.lv_localized, localAppName.lv_localized, dest_lat, dest_lon] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
                if (success == NO)
                {
                    [UserInfo showTips:nil des:@"打开谷歌地图失败".lv_localized];
                }
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 地图
// 周边搜索POI初始化
- (void)AroundSearchRequest
{
    self.request = [[AMapPOIAroundSearchRequest alloc] init];
    self.request.keywords = @"商务住宅|餐饮服务|生活服务".lv_localized;
    /* 按照距离排序. */
    self.request.sortrule            = 0;
    self.request.offset = 50;
    self.request.requireExtension    = YES;
}

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
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error)
        {
            [UserInfo showTips:self.view des:@"定位失败...".lv_localized];
            ChatLog(@"locError:{%ld - %@};",(long)error.code,error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        //定位信息
        ChatLog(@"location:%@", location);
        if (regeocode)
        {
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.city = regeocode.city;
            self.currentAOI = regeocode.AOIName;
//            [self showMapPoint];
//            [self setCenterPoint];
//            self.request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
//            [self.mapSearch AMapPOIAroundSearch:self.request]; // 请求当前周边POI
        }
    }];
}

// 设置地图中心为当前位置
- (void)showMapPoint:(CLLocationCoordinate2D)centerCoordinate
{
    [self.mapVIew setZoomLevel:18 animated:YES];
    [_mapVIew setCenterCoordinate:centerCoordinate animated:YES];
}

- (void)setCenterPoint:(CLLocationCoordinate2D)centerCoordinate
{// 添加大头针
    MAPointAnnotation * centerAnnotation = [[MAPointAnnotation alloc] init];
    centerAnnotation.coordinate = centerCoordinate;//定位经纬度
    centerAnnotation.title = @"";
    centerAnnotation.subtitle = @"";
    [self.mapVIew addAnnotation:centerAnnotation];
}

- (void)click_menu
{
    MMPopupItemHandler block = ^(NSInteger index){
        if(index == 0)
        {//发送给朋友
            ChatChooseViewController *chooseView = [[ChatChooseViewController alloc] init];
            chooseView.toSendMsgsList = @[self.chatRecordDTO];
            chooseView.hidesBottomBarWhenPushed = YES;
            chooseView.delegate = self;
            [self.navigationController pushViewController:chooseView animated:YES];
        }
        if(index == 1)
        {//收藏
            [[TelegramManager shareInstance] forwardMessage:[UserInfo shareInstance]._id msgs:@[self.chatRecordDTO]];
            //
            [UserInfo showTips:nil des:@"已收藏".lv_localized];
        }
    };
    NSArray *items =
    @[MMItemMake(@"发送给朋友".lv_localized, MMItemTypeNormal, block),
      MMItemMake(@"收藏".lv_localized, MMItemTypeNormal, block)];
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                          items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
}

- (void)navigation_click:(id)sender
{
    MMPopupItemHandler block = ^(NSInteger index){
        if(index == 0)
        {// 苹果原生地图
            [self navigation:NavigationType_Apple];
        }
        else
        {
            NavigationType type = [[[self.mapList objectAtIndex:index] objectForKey:@"type"] intValue];
            [self navigation:type];
        }
    };
    
    NSMutableArray *list = [NSMutableArray array];
    for (int i = 0; i< [self.mapList count]; i++)
    {
        [list addObject:MMItemMake([[self.mapList objectAtIndex:i] objectForKey:@"name"], MMItemTypeNormal, block)];
    }
    NSArray *items = list;
    MMSheetView *sheetView = [[MMSheetView alloc] initWithTitle:nil
                                                          items:items];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    [sheetView show];
    
}

//定位当前位置
- (IBAction)localButtonAction:(id)sender
{
    [self showMapPoint:self.currentLocationCoordinate];
}

#pragma mark - ChatChooseViewControllerDelegate
// 群发
- (void)ChatChooseViewController_Chats_ChooseArr:(NSArray *)chatArr msg:(NSArray *)msgs{
    for (int i=0; i<chatArr.count; i++) {
        id chat = chatArr[i];
        [self ChatChooseViewController_Chat_Choose:chat msg:msgs];
    }
}

- (void)ChatChooseViewController_Chat_Choose:(id)chat msg:(NSArray *)msgs{
    if ([chat isKindOfClass:[ChatInfo class]]) {
        ChatInfo *chatinfo = chat;
        //转发消息
        [[TelegramManager shareInstance] forwardMessage:chatinfo._id msgs:msgs];
        //
        [UserInfo showTips:nil des:@"已发送".lv_localized];
    }else if([chat isKindOfClass:[UserInfo class]]){
        UserInfo *user = chat;
        [[TelegramManager shareInstance] createPrivateChat:user._id resultBlock:^(NSDictionary *request, NSDictionary *response, id obj) {
                if(obj != nil && [obj isKindOfClass:ChatInfo.class])
                {
                    ChatInfo *chatinfo = obj;
                    //转发消息
                    [[TelegramManager shareInstance] forwardMessage:chatinfo._id msgs:msgs];
                    //
                    [UserInfo showTips:nil des:@"已发送".lv_localized];
                }
            } timeout:^(NSDictionary *request) {
            }];
    }
    
}

#pragma mark - 懒加载
//- (UIButton *)menuBtn
//{
//    if (!_menuBtn)
//    {
//        _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _menuBtn.frame = CGRectMake(0, 0, 55, 29);
//        [_menuBtn setTitle:@"菜单" forState:UIControlStateNormal];
//        [_menuBtn setBackgroundColor:COLOR_CG1];
//        [_menuBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_menuBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
//        _menuBtn.layer.masksToBounds = YES;
//        _menuBtn.layer.cornerRadius = 4;
//        [_menuBtn addTarget:self action:@selector(click_menu) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _menuBtn;
//}
    
- (UIButton *)localButton
{
    if (!_localButton)
    {
        _localButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _localButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.mapVIew.frame.size.height - 25-50, 50, 50);
        [_localButton addTarget:self action:@selector(localButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_localButton setImage:[UIImage imageNamed:@"Location"] forState:UIControlStateNormal];
    }
    return _localButton;
}

- (NSMutableArray *)mapList
{
    if(!_mapList)
    {
        _mapList = [NSMutableArray array];
    }
    return _mapList;
}

#pragma mark - BusinessListenerProtocol
- (void)processBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
    switch(notifcationId)
    {
        case MakeID(EUserManager, EUser_Td_Location_ReGeocode_Search):
        {
            ChatLog(@"EUser_Td_Location_ReGeocode_Search");
            CLLocationCoordinate2D centerCoordinate;
            centerCoordinate.latitude = self.locationCoordinate.latitude;
            centerCoordinate.longitude = self.locationCoordinate.longitude;
            
            NSDictionary *dicParam = inParam;
            NSNumber *chatId =[dicParam objectForKey:@"ChatId"];
            if(chatId != nil && [chatId isKindOfClass:[NSNumber class]])
            {
                if(self.chatRecordDTO.chat_id == [chatId longValue])
                {
                    NSDictionary *dic = [[LocationManager shareInstance] getCacheLocationAddress:centerCoordinate];
                    self.nameLabel.text = [dic objectForKey:@"addressTitle"];
                    self.addressLabel.text = [dic objectForKey:@"addressDetail"];
                }
            }
        }
            break;
        default:
            break;
    }
}


@end
