//
//  TF_TimeVideoCell.h
//  GoChat
//
//  Created by apple on 2022/2/9.
//

#import <UIKit/UIKit.h>
#import "BlogInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface TF_TimeVideoCell : UITableViewCell
/// 内容信息
@property (nonatomic,strong) BlogInfo *blog;
/// 显示第几张图片
@property (nonatomic,assign) NSInteger imageIndex;
/// <#code#>
@property (nonatomic,copy) void(^commentCall)(BlogInfo *blog);
/// 更多的回调
@property (nonatomic,copy) void(^moreCall)(TF_TimeVideoCell *cell);
/// <#code#>
@property (nonatomic,copy) void(^rotationCall)(void);

- (void)resetVideoThumbnail;
@end

NS_ASSUME_NONNULL_END
