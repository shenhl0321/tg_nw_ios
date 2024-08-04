//
//  UITableView+Ext.m
//  Excellence
//
//  Created by 帝云科技 on 2017/6/16.
//  Copyright © 2017年 diyunkeji. All rights reserved.
//

#import "UITableView+Ext.h"

@implementation UITableView (Ext)

- (void)xhq_registerCell:(Class _Nullable )cellClass {
    NSString *identifier = NSStringFromClass(cellClass);
    NSString *path = [NSBundle.mainBundle pathForResource:identifier ofType:@"nib"];
    if (path) {
        UINib *nib = [UINib nibWithNibName:identifier bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:identifier];
    } else {
        [self registerClass:cellClass forCellReuseIdentifier:identifier];
    }
}

- (void)xhq_registerView:(Class _Nullable )viewClass {
    [self registerClass:viewClass forHeaderFooterViewReuseIdentifier:NSStringFromClass(viewClass)];
}

- (UITableViewCell *)xhq_dequeueCell:(Class)cellClass indexPath:(NSIndexPath *)indexPath {
    return [self dequeueReusableCellWithIdentifier:NSStringFromClass([cellClass class]) forIndexPath:indexPath];
}

- (UITableViewHeaderFooterView *)xhq_dequeueView:(Class)viewClass {
    return [self dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(viewClass)];
}

@end
