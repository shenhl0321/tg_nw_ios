//
//  UIScrollView+Ext.m
//  ShanghaiCard
//
//  Created by 帝云科技 on 2018/11/1.
//  Copyright © 2018 帝云科技. All rights reserved.
//

#import "UIScrollView+Ext.h"
#import "MJRefresh.h"

@implementation UIScrollView (Ext)

@end



@implementation UIScrollView (XHQRefresh)

- (void)xhq_refreshHeaderBlock:(dispatch_block_t)block
{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:block];
    header.lastUpdatedTimeLabel.hidden = YES;
    //自定义...
    
    [header setTitle:@"下拉刷新".lv_localized forState:MJRefreshStateIdle];
    [header setTitle:@"松开加载".lv_localized forState:MJRefreshStatePulling];
    [header setTitle:@"加载中...".lv_localized forState:MJRefreshStateRefreshing];
    [header setTitle:@"加载中...".lv_localized forState:MJRefreshStateWillRefresh];
    
    header.stateLabel.font = XHQFont(13);
    header.stateLabel.textColor = [UIColor xhq_content];
    self.mj_header = header;
}

- (void)xhq_refreshFooterBlock:(dispatch_block_t)block
{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:block];
    //自定义...
    footer.triggerAutomaticallyRefreshPercent = -1.0;
    [footer setTitle:@"上拉加载".lv_localized forState:MJRefreshStateIdle];
    [footer setTitle:@"松开加载".lv_localized forState:MJRefreshStatePulling];
    [footer setTitle:@"加载中...".lv_localized forState:MJRefreshStateRefreshing];
    [footer setTitle:@"加载中...".lv_localized forState:MJRefreshStateWillRefresh];
    [footer setTitle:@"已加载全部".lv_localized forState:MJRefreshStateNoMoreData];
    
    footer.stateLabel.font = XHQFont(13);
    footer.stateLabel.textColor = [UIColor xhq_content];
    self.mj_footer = footer;
}

- (void)xhq_stopRefresh
{
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshing];
    }
    if ([self.mj_footer isRefreshing]) {
        [self.mj_footer endRefreshing];
    }
}

-(void)xhq_footerWithNoMoreData
{
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)xhq_footerResetNoMoreData
{
    [self.mj_footer resetNoMoreData];
}
@end
