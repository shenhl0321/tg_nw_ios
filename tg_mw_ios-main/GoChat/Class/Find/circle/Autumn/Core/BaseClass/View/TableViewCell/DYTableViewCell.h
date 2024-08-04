//
//  DYTableViewCell.h
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static const CGFloat DYCellSideMarge = 12.f;

@class DYModel;
@interface DYTableViewCellItem : NSObject

/** 标识 */
@property (nonatomic, strong) NSString *cellIdentifier;
/** 数据源 */
@property (nonatomic, strong) DYModel *cellModel;
/** 高度 */
@property (nonatomic, assign) CGFloat cellHeight;
/** 缓存标识 */
@property (nonatomic, copy) NSString *cacheKey;

/** 当前class */
@property (nonatomic, weak, readonly) Class cellClass;

/** 标题 */
@property (nonatomic, strong) NSString *title;
/** 图片 */
@property (nonatomic, strong) NSString *imageName;

/** 显示指示器 */
@property (nonatomic, assign, getter=isShowIndicator) BOOL showIndicator;

/** 自定义底线 */
@property (nonatomic, assign, getter=isHideSeparatorLabel) BOOL hideSeparatorLabel;

/** 初始化 */
+ (instancetype)item;

@end


@interface DYTableViewCell : UITableViewCell

/** 自定义底线 */
@property (nonatomic, assign) BOOL hideSeparatorLabel;

/** 底线的所有间距 */
@property (nonatomic, assign) CGFloat sideMargin;

/** 赋值item */
@property (nonatomic, strong) DYTableViewCellItem *item;

/** 响应回调 统一用一个 持有基类里已经实现，子类直接调用基类里面的方法 */
@property (nonatomic, copy) dispatch_block_t responseBlock;


/** 初始化UI */
- (void)dy_initUI;

/** 取消选中效果 */
- (void)dy_noneSelectionStyle;

@end


@interface NSMutableArray (DYTableViewCellItem)

- (__kindof DYTableViewCellItem *)dy_itemForTitle:(NSString *)title;

@end


NS_ASSUME_NONNULL_END
