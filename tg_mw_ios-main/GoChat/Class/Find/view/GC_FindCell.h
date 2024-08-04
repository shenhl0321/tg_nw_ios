//
//  GC_FindCell.h
//  GoChat
//
//  Created by wangfeiPro on 2021/12/4.
//

#import <UIKit/UIKit.h>
#import "DiscoverMenuInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface GC_FindCell : UITableViewCell

@property (nonatomic, strong)NSDictionary *dataDic;
/// <#code#>
@property (nonatomic, strong) DiscoverMenuInfo *model;
@end

NS_ASSUME_NONNULL_END
