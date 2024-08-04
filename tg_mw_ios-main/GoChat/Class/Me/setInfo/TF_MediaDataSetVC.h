//
//  TF_MediaDataSetVC.h
//  GoChat
//
//  Created by apple on 2022/2/15.
//

#import "BaseVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface TF_MediaDataSetVC : BaseVC
/// 网络类型 0-移动数据 1-WIFI
@property (nonatomic,assign) NSInteger netType;
@end

NS_ASSUME_NONNULL_END
