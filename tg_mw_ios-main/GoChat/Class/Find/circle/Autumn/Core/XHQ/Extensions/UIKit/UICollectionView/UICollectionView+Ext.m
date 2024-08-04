//
//  UICollectionView+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/7/19.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UICollectionView+Ext.h"

@implementation UICollectionView (Ext)

- (void)xhq_registerCell:(Class)cellClass {
    [self registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
}

- (void)xhq_registerHeaderView:(Class)viewClass {
    [self registerClass:viewClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
    withReuseIdentifier:NSStringFromClass(viewClass)];
}

- (void)xhq_registerFooterView:(Class)viewClass {
    [self registerClass:viewClass forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
    withReuseIdentifier:NSStringFromClass(viewClass)];
}

- (UICollectionViewCell *)xhq_dequeueCell:(Class)cellClass indexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableCellWithReuseIdentifier:NSStringFromClass(cellClass) forIndexPath:indexPath];
}

- (UICollectionReusableView *)xhq_dequeueHeaderView:(Class)viewClass indexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(viewClass) forIndexPath:indexPath];
}

- (UICollectionReusableView *)xhq_dequeueFooterView:(Class)viewClass indexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass(viewClass) forIndexPath:indexPath];
}

@end
