//
//  EmptyView.m
//  
//
//  Created by wang yutao on 2017/7/26.
//  Copyright © 2017 zy technologies inc. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.tipLabel.text = NSLocalizedString(@"no_data", nil);
    self.tipLabel.text = @"暂无数据".lv_localized;
}

@end
