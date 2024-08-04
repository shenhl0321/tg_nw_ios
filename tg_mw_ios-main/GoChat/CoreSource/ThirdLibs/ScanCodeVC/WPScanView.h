//
//  MJScanView.h
//  MJJWFreshStore
//
//  Created by apple on 2018/5/21.
//  Copyright © 2018年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WPScanViewDelegate <NSObject>

-(void)getScanDataString:(NSString*)scanDataString;

@end



@interface WPScanView : UIView
@property (nonatomic,assign) id<WPScanViewDelegate> delegate;
@property (nonatomic,assign) int scanW; //扫描框的宽

- (void)startRunning; //开始扫描
- (void)stopRunning; //停止扫描

@end
