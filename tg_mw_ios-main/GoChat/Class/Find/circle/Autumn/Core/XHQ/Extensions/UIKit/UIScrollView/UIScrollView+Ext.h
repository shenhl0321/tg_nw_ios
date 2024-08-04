//
//  UIScrollView+Ext.h
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (Ext)

@end

NS_ASSUME_NONNULL_END


NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (XHQRefresh)

- (void)xhq_refreshHeaderBlock:(dispatch_block_t)block;

- (void)xhq_refreshFooterBlock:(dispatch_block_t)block;

- (void)xhq_stopRefresh;

- (void)xhq_footerWithNoMoreData;

- (void)xhq_footerResetNoMoreData;

@end

NS_ASSUME_NONNULL_END
