//
//  DYTableViewController.h
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "BaseVC.h"
#import "UIScrollView+EmptyDataSet.h"

NS_ASSUME_NONNULL_BEGIN

@interface DYTableViewController : BaseVC<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) UITableViewStyle style;

/**
 隐藏section最后一个cell的底部线
 */
@property (nonatomic, assign, getter=isHideSectionLastCellLine) BOOL hideSectionLastCellLine;

@property (nonatomic, strong) NSMutableArray *sectionArray0;
@property (nonatomic, strong) NSMutableArray *sectionArray1;
@property (nonatomic, strong) NSMutableArray *sectionArray2;
@property (nonatomic, strong) NSMutableArray *sectionArray3;
@property (nonatomic, strong) NSMutableArray *sectionArray4;
@property (nonatomic, strong) NSMutableArray *dataArray;



@property (nonatomic, copy) NSString *emptyTitle;
@property (nonatomic, copy) NSString *emptyImageName;


/** 初始化数据 */
- (void)dy_configureData;
/** 初始化数据 */
- (void)dy_configureDataWithModel:(DYModel *)model;


/**
 cell block回调
 
 @param item 当前item
 @param indexPath 当前indexPath
 */
- (void)dy_cellResponse:(__kindof DYTableViewCellItem *)item indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
