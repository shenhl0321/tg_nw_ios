//
//  DYCollectionViewCell.h
//  FireControl
//
//  Created by 帝云科技 on 2019/5/28.
//  Copyright © 2019 帝云科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DYCollectionViewCellItem : NSObject

/** 标识 */
@property (nonatomic, strong, readonly) NSString *cellIdentifier;
/** 当前class */
@property (nonatomic, weak, readonly) Class cellClass;
/** 数据源 */
@property (nonatomic, strong) DYModel *cellModel;
/** 尺寸 */
@property (nonatomic, assign) CGSize cellSize;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;


/** 初始化 */
+ (instancetype)item;

@end

@interface DYCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) DYCollectionViewCellItem *item;

/** 自定义底线 */
@property (nonatomic, assign) BOOL hideSeparatorLabel;

/** 底线的所有间距 */
@property (nonatomic, assign) CGFloat sideMargin;

/** 响应回调 统一用一个 持有基类里已经实现，子类直接调用基类里面的方法 */
@property (nonatomic, copy) dispatch_block_t responseBlock;

/** 初始化UI */
- (void)dy_initUI;

@end

@interface NSMutableArray (DYCollectionViewCellItem)

- (__kindof DYCollectionViewCellItem *)dy_cItemForTitle:(NSString *)title;

@end


NS_ASSUME_NONNULL_END
