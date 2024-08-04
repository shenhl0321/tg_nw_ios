//
//  CFont.h
//  moorgeniPad
//
//  Created by moorgen on 2017/3/15.
//  Copyright © 2017年 moorgen. All rights reserved.
//
/**
 *  此.h用来放常用字体
 **/
//#import "CustomFont.h"
//#ifndef CFont_h
//#define CFont_h
//
///**
// *  SF Regular
// */
//#define fontRegular(X)  [CustomFont fontWithName:@"SFUIText-Regular" size:X]
//
///**
// *  SF Semibold
// */
//#define fontSemiBold(X)  [CustomFont fontWithName:@"SFUIText-Semibold" size:X]
//
///**
// *  SF Heavy
// */
//#define fontHeavy(X)  [CustomFont fontWithName:@"SFUIText-Heavy" size:X]
//
///**
// *  SF Semibold
// */
//#define fontBold(X)  [CustomFont fontWithName:@"SFUIText-Bold" size:X]
//
///**
// *  SF Display Bold
// */
//#define fontDisPlayBold(X)  [CustomFont fontWithName:@"SFUIDisplay-Bold" size:X]
//
///**
// *  SF Display SemiBold
// */
//#define fontDisPlaySemiBold(X)  [CustomFont fontWithName:@"SFUIDisplay-Semibold" size:X]
//
///**
// *  SF Medium
// */
//#define fontMedium(X)  [CustomFont fontWithName:@"SFUIText-Medium" size:X]
//
///**
// *  Roboto-Regular
// */
//#define fontRORegular(X)  [CustomFont fontWithName:@"Roboto-Regular" size:X]
//
///**
// *  Roboto-Light
// */
//#define fontLight(X)  [CustomFont fontWithName:@"Roboto-Light" size:X]
//
//#endif /* CFont_h */

#define fontBold(X)  [UIFont boldCustomFontOfSize:X]
#define fontHeavy(X) [UIFont heavyCustomFontOfSize:X]
#define fontMedium(X) [UIFont mediumCustomFontOfSize:X]
#define fontRegular(X) [UIFont regularCustomFontOfSize:X]


#define fontBlack(X) [UIFont blackCustomFontOfSize:X]
#define fontExtraBold(X) [UIFont extraBoldCustomFontOfSize:X]
#define fontSemiBold(X) [UIFont semiBoldCustomFontOfSize:X]
#define fontLight(X) [UIFont lightCustomFontOfSize:X]
#define fontThin(X) [UIFont thinCustomFontOfSize:X]

#define font(X,weight) [UIFont ttFontOfSize:X weight:weight]


