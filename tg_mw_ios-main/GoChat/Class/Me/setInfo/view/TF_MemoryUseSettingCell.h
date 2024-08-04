//
//  TF_MemoryUseSettingCell.h
//  GoChat
//
//  Created by apple on 2022/2/16.
//

#import <UIKit/UIKit.h>
#import "GC_DataSetInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface TF_MemoryUseSettingCell : UITableViewCell
/// 存储用量
@property (nonatomic,strong) GC_MemoryUse *model;
/// <#code#>
@property (nonatomic,strong) GC_DataSetInfo *setData;
@end

NS_ASSUME_NONNULL_END
