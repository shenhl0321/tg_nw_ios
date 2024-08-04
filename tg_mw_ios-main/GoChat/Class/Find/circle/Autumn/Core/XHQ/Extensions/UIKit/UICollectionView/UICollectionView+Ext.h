//
//  UICollectionView+Ext.h
//  Excellence
//
//  Created by 帝云科技 on 2017/7/19.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionView (Ext)

- (void)xhq_registerCell:(Class)cellClass;

- (void)xhq_registerHeaderView:(Class)viewClass;

- (void)xhq_registerFooterView:(Class)viewClass;

- (__kindof UICollectionViewCell *)xhq_dequeueCell:(Class)cellClass indexPath:(NSIndexPath *)indexPath;

- (__kindof UICollectionReusableView *)xhq_dequeueHeaderView:(Class)viewClass indexPath:(NSIndexPath *)indexPath;

- (__kindof UICollectionReusableView *)xhq_dequeueFooterView:(Class)viewClass indexPath:(NSIndexPath *)indexPath;

@end
