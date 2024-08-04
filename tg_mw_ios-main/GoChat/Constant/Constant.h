//
//  Header.h
//  iCurtain
//
//  Created by moorgen on 2017/6/27.
//  Copyright © 2017年 dooya. All rights reserved.
//
/**
 *  此.h用来放常用杂项宏
 **/
#ifndef Header_h
#define Header_h


#define BridgeSDK [BridgeManager SharedInstance]
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]



#define OraginX(view) view.frame.origin.x
#define OraginY(view) view.frame.origin.y
#define SizeHeight(view) view.frame.size.height
#define SizeWidth(view) view.frame.size.width


#define LBXScan_Define_Native  //下载了native模块
//#define LBXScan_Define_ZXing   //下载了ZXing模块
//#define LBXScan_Define_ZBar   //下载了ZBar模块
#define LBXScan_Define_UI     //下载了界面模块



#define colorFromRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define colorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define HexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define TP_SYSTEM_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

//是否是IPhoneX的设备

#define IPhoneX ([UIApplication sharedApplication].statusBarFrame.size.height >= 44)

// Color
#define HEXCOLORA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:a]
#define HEXCOLOR(rgbValue) HEXCOLORA(rgbValue, 1.0)

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define RGBCOLOR(r,g,b) RGBACOLOR(r,g,b,1)

// Screen
#define APP_SCREEN_BOUNDS   [[UIScreen mainScreen] bounds]
#define APP_SCREEN_HEIGHT   (APP_SCREEN_BOUNDS.size.height)
#define APP_SCREEN_WIDTH    (APP_SCREEN_BOUNDS.size.width)
#define APP_STATUS_FRAME    [UIApplication sharedApplication].statusBarFrame
#define APP_NAV_BAR_HEIGHT (kIsIpad() ? 84 :44)

#define APP_STATUS_BAR_HEIGHT (kIPhoneXSeries2() ? 44 : 20)
#define APP_TOP_BAR_HEIGHT    (APP_NAV_BAR_HEIGHT + APP_STATUS_BAR_HEIGHT)

#define ContentHeight (APP_SCREEN_HEIGHT - kBottom34() - APP_TOP_BAR_HEIGHT)



#define APP_CONTENT_WIDTH     (APP_SCREEN_BOUNDS.size.width)
#define APP_CONTENT_HEIGHT    (APP_SCREEN_HEIGHT - APP_TOP_BAR_HEIGHT - kIPhoneXSeries2())
#define APP_VISIBLE_HEIGHT    (APP_SCREEN_HEIGHT - APP_TOP_BAR_HEIGHT)

//current window
#define kCurrentWindow [[UIApplication sharedApplication].windows firstObject]

#define kKeyWindow [UIApplication sharedApplication].keyWindow

#define kSDKVersion @"3.17.6"



static inline BOOL kIsIpad(){
    if ([[UIDevice currentDevice] userInterfaceIdiom] ==

          UIUserInterfaceIdiomPad)

          return YES;

      else{

          return NO;

      }
}

//#define kBottom34 (kIPhoneXSeries2?34:0)
static inline CGFloat APP_TAB_BAR_HEIGHT2() {
    CGFloat value = 49;
   
    return value;
}
static inline BOOL kIPhone5Size(){
    BOOL iPhone5Size = NO;
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(size, CGSizeMake(320, 568)) ||
              CGSizeEqualToSize(size, CGSizeMake(568, 320))){
        iPhone5Size = TRUE;
    }
    return iPhone5Size;
}

static inline BOOL kIPhone6Size(){
    BOOL iPhone6Size = NO;
    CGSize size = [UIScreen mainScreen].bounds.size;
    if ((CGSizeEqualToSize(size, CGSizeMake(375, 667)) ||
         CGSizeEqualToSize(size, CGSizeMake(667, 375)))){
        iPhone6Size = TRUE;
    }
    return iPhone6Size;
}

static inline BOOL kIPhoneXSeries2() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}
//默认是15
static inline CGFloat left_margin() {
    CGFloat value = 15;

    return value;
}

static inline CGFloat left_margin20() {
    CGFloat value = 20;

    return value;
}

static inline CGFloat left_margin40() {
    CGFloat value = 40;

    return value;
}

static inline CGFloat left_margin30() {
    CGFloat value = 30;
    return value;
}
static inline CGFloat left_padding(){
    CGFloat value = 20;
    return value;
}

static inline CGFloat kBottom34(){
    CGFloat value = 0;
    if (kIPhoneXSeries2()) {
        value = 34;
    }
    return value;
}

static inline CGFloat kCellLRLabMargin(){
    CGFloat value = 50;
    
    return value;
}


static inline NSString * _Nullable keyAgreeProvicyProtol(){
    return @"keyAgreeProvicyProtol";
}

static inline NSString * _Nullable keyWifiInfo(){
    return @"keyWifiInfo_xmj";
}

static inline NSString * _Nullable kDestroyDate(){
    return @"kDestroyDate";
}
static inline NSString * _Nullable kDestroyDateState(){
    return @"kDestroyDate_DestoryState";
}

static inline NSString * _Nullable kWifiLockRreshDataNoti(){
    return @"kWifiLockRreshDataNoti";
}
static inline NSString * _Nullable kWifiLockRreshDataFinishNoti(){
    return @"kWifiLockRreshDataFinishNoti";
}


static inline NSString * _Nonnull kCameraFilePath(){
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *dataPath = [docPath stringByAppendingPathComponent:@"Camera"];
    return dataPath;

}

static inline NSString * _Nonnull kCameraAeraFilePath(){
    NSString *docPath =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *dataPath = [docPath stringByAppendingPathComponent:@"CameraArea"];
    return dataPath;

}

static inline NSString * _Nonnull kCameraTalkWay(NSString *devId){
    NSString *text = [NSString stringWithFormat:@"kCameraTalkWay_%@",devId];
    return text;
}

static inline NSArray * _Nullable kCameraSong(){
    NSArray *arr = @[@"3 Blind Mice",@"Brahms",@"Hush Baby",@"Night Night",@"Twinkle Star",@"Bird Song",@"Calm Waves",@"Lake Sounds",@"Ocean Sounds",@"Summer Night",@"Whale Song",@"Dream Chaase",@"Night Music",@"Pavane",@"Train track sound",@"White Niose"];
    return arr;
}

//腾讯地图apiKey
static inline NSString * kQMapAPIKey(){
#if TT
    return @"T44BZ-652WS-SAAOI-6MI7G-WLCQH-A5BS5";
//    return @"JP7BZ-BGEK2-3TEUO-CO3TW-K34PT-MMBUJ";
#else
    return @"UJCBZ-SD2CJ-KUDFT-KJGSQ-QCNDE-IWBTN";
#endif
}

//腾讯地图apiKey
static inline NSString * kGoogleMapAPIKey(){
//    return  @"2K4BZ-YLVLU-M3QV2-2YE7P-F7UPZ-MSBJ5";
    if (YELLOW) {
        return @"AIzaSyBvtqXa9z83f9T8laALXvpESLI7r0VNCVo";
    }
    return @"AIzaSyDvYDO1Pnq9-Re1hTEviESOhKXWED53OGY";
}
//#define HolfMannAPPDelegate ((AppDelegate*)[UIApplication sharedApplication].delegate)

//typedef void (^StrBlock)(NSString *text);
//typedef void (^NullBlock)(void);
typedef void (^ _Nullable NullBlock)(void);
//typedef void(^ _Nullable DeviceInfoBlock)(DeviceInfo *device);

typedef void(^ _Nullable ComponentsBlock)(NSDateComponents *dateComponents);
//typedef void(^ _Nullable SceneBlock)(  SceneInfo * _Nullable scene);
//typedef void(^ _Nullable ActionBlock)(ActionInfo * _Nullable action);
typedef void (^_Nullable StringBlock) (NSString *text);
typedef void(^IndexBlock)(NSInteger index);
typedef void (^MDicBlock)(NSMutableDictionary * dic);
typedef void (^MArrBlock)(NSMutableArray * arr);
typedef void (^MArr2Block)(NSMutableArray * arr,NSMutableArray * arr2);
typedef void (^MDicReturnMDicBlock)(NSMutableDictionary * dic,NSMutableDictionary *stateDic);
typedef void (^StrBlock)(NSString *text);
typedef void(^BoolBlockArg)(BOOL value);
typedef void (^SetBlock)(id ctrlInfo);
typedef void(^FloatBlockArg)(float value);
typedef void (^IntBlock) (int value);
typedef void (^BtnBlock)(UIButton *btn);
typedef void (^TfBlock)(UITextField *tf);
typedef void (^TapRecBlock)(UITapGestureRecognizer *tapRec);
typedef void (^CellTapRecBlock)(UITableViewCell *cell,UITapGestureRecognizer *tapRec);
//typedef void (^MSSliderBlock)(MNSlider *slider);
typedef void (^CellBtnBlock)(UITableViewCell *cell,UIButton *btn);
typedef void (^FailedBlock)(NSError *error);

#endif /* Header_h */
