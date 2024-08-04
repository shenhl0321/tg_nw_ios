//
//  MNTabExploreVC.h
//  GoChat
//
//  Created by 许蒙静 on 2021/11/21.
//

#import "BaseWebViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNTabExploreVC : BaseVC
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *urlStr;

@property (nonatomic) BOOL canRotate;
@end

NS_ASSUME_NONNULL_END
