//
//  TimelineLocationVC.m
//  GoChat
//
//  Created by Autumn on 2021/11/17.
//

#import "TimelineLocationVC.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "LocationSearchView.h"
#import "TimelineLocationCell.h"

#import "PublishTimeline.h"

@interface TimelineLocationVC ()<AMapSearchDelegate, AMapLocationManagerDelegate, SearchViewDelegate, SearchViewDelegate>

@property (nonatomic, strong) AMapSearchAPI *mapSearch;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic ,strong) NSString *city;

@property (nonatomic, strong) AMapGeoPoint *geoPoint;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate; // 当前定位的经纬度

@end

@implementation TimelineLocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, kNavigationStatusHeight() + 60, kScreenWidth(), kScreenHeight() - kNavigationStatusHeight() - 60);
}

- (void)dy_initData {
    [super dy_initData];
    
    
    [self configLocationManager];
    [self dy_configureData];
}

- (void)dy_initUI {
    [super dy_initUI];
    
    self.navigationItem.title = @"选择位置".lv_localized;
    
    [self initSearch];
    [self.tableView xhq_registerCell:TimelineLocationCell.class];
    
    LocationSearchView *header = [[[NSBundle mainBundle]loadNibNamed:@"LocationSearchView" owner:nil options:nil] lastObject];
    header.delegate = self;
    header.frame = CGRectMake(0, kNavigationStatusHeight(), kScreenWidth(), 60);
    [self.view addSubview:header];
}


- (void)initSearch {
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
}

#pragma mark - 地图
// 位置定位初始化
- (void)configLocationManager {
    
    self.locationManager = [[AMapLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setLocationTimeout:6];
    [self.locationManager setReGeocodeTimeout:3];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        if (error) {
//            [UserInfo showTips:self.view des:@"定位失败..."];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self configLocationManager];
            });
            return;
        }
        if (regeocode) {
            self.city = regeocode.city;
            self.currentLocationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            self.geoPoint = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            
            TimelineLocationCellItem *item = TimelineLocationCellItem.item;
            item.city = self.city;
            if ([self.location.address isEqualToString:self.city]) {
                item.selected = YES;
            }
            [self.sectionArray1 addObject:item];
            if (self.location.poi) {
                item = TimelineLocationCellItem.item;
                item.poi = self.location.poi;
                item.selected = YES;
                [self.sectionArray1 addObject:item];
            }
            [self.dataArray addObject:self.sectionArray1];
            [self.tableView reloadData];
            
            AMapPOIAroundSearchRequest *req = [[AMapPOIAroundSearchRequest alloc] init];
            req.city = regeocode.city;
            req.location = self.geoPoint;
            req.keywords = @"商务住宅|餐饮服务|生活服务".lv_localized;
            req.sortrule = 0;
            req.offset = 25;
            req.requireExtension = YES;
            [self.mapSearch AMapPOIAroundSearch:req];
            
        }
    }];
}

- (void)search:(NSString *)keyword {
    AMapPOIKeywordsSearchRequest *req = [[AMapPOIKeywordsSearchRequest alloc] init];
    req.city = self.city;
    req.cityLimit = YES;
    req.offset = 25;
    req.sortrule = 0;
    req.location = self.geoPoint;
    req.keywords = keyword;
    [self.mapSearch AMapPOIKeywordsSearch:req];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TimelineLocationCellItem *item = self.dataArray[indexPath.section][indexPath.row];
    [self.dataArray enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull objs, NSUInteger idx, BOOL * _Nonnull stop) {
        [objs enumerateObjectsUsingBlock:^(TimelineLocationCellItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = NO;
        }];
    }];
    item.selected = YES;
    [tableView reloadData];
    if (item.poi) {
        self.location.poi = item.poi;
        self.location.location.longitude = item.poi.location.longitude;
        self.location.location.latitude = item.poi.location.latitude;
        self.location.address = [NSString stringWithFormat:@"%@ · %@", self.city, item.poi.name];
    } else if (item.city) {
        self.location.location.longitude = self.currentLocationCoordinate.longitude;
        self.location.location.latitude = self.currentLocationCoordinate.latitude;
        self.location.address = item.city;
        self.location.poi = nil;
    } else {
        self.location.poi = nil;
        self.location.address = nil;
    }
    !self.block ? : self.block();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - ConfigureData
- (void)dy_configureData {
    TimelineLocationCellItem *item = TimelineLocationCellItem.item;
    item.none = YES;
    [self.sectionArray0 addObject:item];
    [self.dataArray addObject:self.sectionArray0];
}

#pragma mark - SearchViewDelegate

- (void)TextFieldBeginEditing:(UITextField *)textField {
    
}

- (void)SearchViewDoSearch:(NSString *)result {
    [self search:result];
}

#pragma mark - AMapSearchDelegate
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if (response.pois.count == 0) {
        return;
    }
    [self.dataArray removeObject:self.sectionArray2];
    [self.sectionArray2 removeAllObjects];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.location.poi == obj) {
            return;
        }
        TimelineLocationCellItem *item = TimelineLocationCellItem.item;
        item.poi = obj;
        [self.sectionArray2 addObject:item];
    }];
    [self.dataArray addObject:self.sectionArray2];
    [self.tableView reloadData];
}

@end
