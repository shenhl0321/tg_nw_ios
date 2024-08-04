//
//  MNScanVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/5.
//

#import "BaseVC.h"


@class MNScanVC;

@protocol MNScanVCDelegate <NSObject>

@optional
- (void)scanVC:(MNScanVC *)scanvc scanResult:(NSString *)result;


@end
NS_ASSUME_NONNULL_BEGIN

@interface MNScanVC : BaseVC

@property (nonatomic, weak) id<MNScanVCDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
