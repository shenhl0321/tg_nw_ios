//
//  MNContactDetailDynamicCell.h
//  GoChat
//
//  Created by 许蒙静 on 2021/12/15.
//

#import "BaseTableCell.h"
#import "MNDetailDynamicView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MNContactDetailDynamicCell : BaseTableCell
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UIImageView *arrowImgV;
@property (nonatomic, strong) MNDetailDynamicView *dynamicView;
- (void)fillDataWithBlogs:(NSMutableArray *)blogs;
@end

NS_ASSUME_NONNULL_END
