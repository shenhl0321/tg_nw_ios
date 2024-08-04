//
//  CSize.h
//  iCurtain
//
//  Created by moorgen on 2017/6/27.
//  Copyright © 2017年 dooya. All rights reserved.
//

/**
 *  此.h用来放常用宽高
 **/
#ifndef CSize_h
#define CSize_h

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//#define KScreenWidth [UIScreen mainScreen].bounds.size.width

//#define KScreenHeight [UIScreen mainScreen].bounds.size.height

/**
 *  导航栏及状态栏高度和
 */
//#define KiPhoneX (((int)((KScreenHeight/KScreenWidth)*100) == 216)?YES:NO)

//判断是否为 iPhoneXS  Max，iPhoneXS，iPhoneXR，iPhoneX
//#define KiPhoneX ([UIScreen mainScreen].bounds.size.height==812)
//#define KNavigationBarHeight 56 //自定义高度
//#define APP_STATUS_BAR_HEIGHT (KiPhoneX?44:20)

//#define KStatusNavBarHeight  (KNavigationBarHeight+APP_STATUS_BAR_HEIGHT)

//#define Bottom34 (34*floor(KScreenHeight/812))

//#define ContentHeight (KScreenHeight - Bottom34 - KStatusNavBarHeight)


/**
 *  TabBar高度
 */
//#define KTabBarHeight  56

/**
 *  高度缩放系数
 */
//#define hightCoefficient        [UIScreen mainScreen].bounds.size.height/667.0

/**
 *  宽度缩放系数
 */
//#define widthCoefficient        [UIScreen mainScreen].bounds.size.width/375.0

/**
 *  view除去导航栏之后的高度
 **/
//#define viewheight              (self.view.frame.size.height-64)

/**
 *  主Cell高度
 */
//#define hightMainCell    112.f

/**
 *  折叠cell默认高度
 **/
//#define hightDefaultFoldCell  136.f

/**
 *  折叠cell两倍高度
 **/
//#define hightDoubleFoldCell 248.f

/**
 *  折叠cell三倍高度
// **/
//#define hightTrebleFoldCell 360.f
//
//#define hightAutoCell    80
//
//#define hightSpaceSection   24
//
///**
// *  子Cell高度
// */
//#define hightsubCell     44
//
///**
// *  Cell头部视图高度
// */
//#define hightCellHeaderView   41
//
///**
// *  Cell属性高度（名字，图片）
// */
//#define hightAttributeCell   50
//
///**
// *  Cell设备高度
// */
//#define hightDeviceCell   64

/**
 *  Cell设备两倍展开高度
 */
//#define hightDoubleDeviceCell   178
//
///**
// *  Cell设备三倍展开高度
// */
//#define hightTrebleDeviceCell   290
//
///**
// *  左边边距距离
// */
//#define kLeftMargin 14

/**
 左边内边距
 */
//#define left_padding() 14

/**
 *  去除左右留白后的宽度
 **/
//#define kClearWidth (KScreenWidth-2*kLeftMargin)
//
//
//#define KScaleHeight (KScreenHeight/667.0)
//
//#define KScaleWidth  (KScreenWidth/375.0)
//
//#define KScaleMinInWidthAndHeight MIN(KScaleHeight, KScaleWidth)
//
//#define KBtnHeight (42*KScaleHeight)
//
//#define KBtnBottom (64*KScaleMinInWidthAndHeight)
//
////iPad设备控制页宽高
//#define kIPadDeviceHeight   620
//#define kIPadDeviceWidth    460
//#define kIPadDeviceNavHeight 64


#endif /* CSize_h */
